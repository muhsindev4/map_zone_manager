import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class AutoInputBox<T> extends StatefulWidget {
  final TextEditingController textEditingController;
  final InputDecoration inputDecoration;
  final TextStyle textStyle;
  final int debounceTime;
  final List<T> suggestions;
  final String Function(T) toDisplayString; // Updated to use `T`
  final ValueChanged<T>? onItemSelected;

  const AutoInputBox({
    super.key,
    required this.textEditingController,
    this.inputDecoration = const InputDecoration(),
    this.textStyle = const TextStyle(),
    this.debounceTime = 300,
    required this.suggestions,
    required this.toDisplayString, // Marked as required
    this.onItemSelected,
  });

  @override
  State<AutoInputBox<T>> createState() => _AutoInputBoxState<T>();
}

class _AutoInputBoxState<T> extends State<AutoInputBox<T>> {
  final PublishSubject<String> _subject = PublishSubject<String>();

  late OverlayEntry _overlayEntry;

  final LayerLink _layerLink = LayerLink();

  List<T> _filteredSuggestions = [];

  bool _isOverlayVisible = false;

  @override
  void initState() {
    super.initState();
    _subject
        .debounceTime(Duration(milliseconds: widget.debounceTime))
        .listen(_onTextChanged);
    widget.textEditingController.addListener(_onEditorListener);
  }

  _onEditorListener() {
    if (widget.textEditingController.text.isEmpty) {
      _removeOverlay();
    }
  }

  @override
  void dispose() {
    _subject.close();
    if (_isOverlayVisible) _removeOverlay();
    super.dispose();
  }

  void _onTextChanged(String text) {
    if (text.isEmpty) {
      _removeOverlay();
      return;
    }
    _filteredSuggestions = widget.suggestions
        .where((item) => widget
            .toDisplayString(item)
            .toLowerCase()
            .contains(text.toLowerCase()))
        .toList();

    if (_filteredSuggestions.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    if (_isOverlayVisible) _removeOverlay();

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry);
    _isOverlayVisible = true;
  }

  void _removeOverlay() {
    if (_isOverlayVisible) {
      _overlayEntry.remove();
      _isOverlayVisible = false;
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: offset.dy + size.height,
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            offset: Offset(0, size.height),
            child: Material(
              elevation: 2,
              color: Colors.white,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _filteredSuggestions[index];
                  return ListTile(
                    title: Text(widget.toDisplayString(suggestion)),
                    onTap: () {
                      widget.textEditingController.text =
                          widget.toDisplayString(suggestion);
                      widget.onItemSelected?.call(suggestion);
                      _removeOverlay();
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.textEditingController,
        decoration: widget.inputDecoration,
        style: widget.textStyle,
        onChanged: _subject.add,
      ),
    );
  }
}
