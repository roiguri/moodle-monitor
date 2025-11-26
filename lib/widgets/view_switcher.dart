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
    return IconButton(
      icon: Icon(
        _selectedView == ViewType.day
          ? Icons.calendar_today
          : Icons.category,
        size: 28,
      ),
      onPressed: _toggleView,
      tooltip: _selectedView == ViewType.day
        ? 'Switch to Category View'
        : 'Switch to Day View',
      style: IconButton.styleFrom(
        backgroundColor: Colors.blue.withOpacity(0.1),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  void _toggleView() {
    setState(() {
      _selectedView = _selectedView == ViewType.day
        ? ViewType.category
        : ViewType.day;
    });
    widget.onViewChanged(_selectedView);
  }
}
