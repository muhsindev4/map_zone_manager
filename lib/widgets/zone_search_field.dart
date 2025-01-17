import 'package:flutter/material.dart';
import '../zone_manager.dart';
import 'auto_input_box.dart';

class ZoneSearchField extends StatefulWidget {
  final List<Zone> zones;
  final Function(Zone) onSelected;

  const ZoneSearchField(
      {super.key, required this.zones, required this.onSelected});

  @override
  State<ZoneSearchField> createState() => _ZoneSearchFieldState();
}

class _ZoneSearchFieldState extends State<ZoneSearchField> {
  final TextEditingController _controller = TextEditingController();

  // Store LocationPredictions
  final ValueNotifier<bool> _haveText = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _haveText.value = _controller.text.isNotEmpty ? true : false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutoInputBox<Zone>(
      textEditingController: _controller,
      textStyle: Theme.of(context)
          .textTheme
          .bodyMedium!
          .copyWith(fontWeight: FontWeight.w600),
      suggestions: widget.zones,
      inputDecoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        suffixIcon: ValueListenableBuilder(
            valueListenable: _haveText,
            builder: (context, value, widget) {
              if (_haveText.value) {
                return IconButton(
                    onPressed: () {
                      setState(() {
                        _controller.clear();
                        FocusManager.instance.primaryFocus?.unfocus();
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey,
                    ));
              } else {
                return SizedBox.shrink();
              }
            }),
        prefixIcon: Icon(
          Icons.search,
          color: Colors.grey,
        ),
        hintText: "Search zone",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 8, // Adjust vertical padding to reduce height
          horizontal: 16, // Adjust horizontal padding as needed
        ),
      ),
      onItemSelected: (zone) async {
        FocusManager.instance.primaryFocus?.unfocus();
        widget.onSelected(zone);
      },
      toDisplayString: (Zone zone) {
        return zone.zoneName;
      },
    );
  }
}
