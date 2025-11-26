import 'package:flutter/material.dart';

enum ViewType { day, category }

class ViewSwitcher extends StatefulWidget {
  final ViewType initialView;
  final Function(ViewType) onViewChanged;

  const ViewSwitcher({
    Key? key,
    this.initialView = ViewType.day,
    required this.onViewChanged,
  }) : super(key: key);

  @override
  _ViewSwitcherState createState() => _ViewSwitcherState();
}

class _ViewSwitcherState extends State<ViewSwitcher> {
  late ViewType _selectedView;

  @override
  void initState() {
    super.initState();
    _selectedView = widget.initialView;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildViewButton(ViewType.day, 'Day'),
        const SizedBox(width: 16),
        _buildViewButton(ViewType.category, 'Category'),
      ],
    );
  }

  Widget _buildViewButton(ViewType viewType, String text) {
    final isSelected = _selectedView == viewType;
    return ElevatedButton(
      onPressed: () {
        if (!isSelected) {
          setState(() {
            _selectedView = viewType;
          });
          widget.onViewChanged(_selectedView);
        }
      },
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(isSelected ? Colors.white : Colors.black),
        backgroundColor: MaterialStateProperty.all(isSelected ? Colors.blue : Colors.grey[300]),
      ),
      child: Text(text),
    );
  }
}
