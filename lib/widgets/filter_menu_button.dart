import 'package:flutter/material.dart';
import 'package:moodie/constants/app_strings.dart';

enum ViewType { day, category }
enum FilterType { all, deadlines, tasks }

class FilterMenuButton extends StatelessWidget {
  final ViewType currentView;
  final FilterType currentFilter;
  final bool showHidden;
  final Function(ViewType) onViewChanged;
  final Function(FilterType) onFilterChanged;
  final Function(bool) onShowHiddenChanged;

  const FilterMenuButton({
    Key? key,
    required this.currentView,
    required this.currentFilter,
    required this.showHidden,
    required this.onViewChanged,
    required this.onFilterChanged,
    required this.onShowHiddenChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<dynamic>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.tune, color: Theme.of(context).primaryColor),
      ),
      tooltip: AppStrings.filterTitle,
      onSelected: (value) {
        if (value is ViewType) {
          onViewChanged(value);
        } else if (value is FilterType) {
          onFilterChanged(value);
        } else if (value is bool) {
          onShowHiddenChanged(value);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          enabled: false,
          child: Text('תצוגה', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        CheckedPopupMenuItem(
          value: ViewType.day,
          checked: currentView == ViewType.day,
          child: Text(AppStrings.viewDay),
        ),
        CheckedPopupMenuItem(
          value: ViewType.category,
          checked: currentView == ViewType.category,
          child: Text(AppStrings.viewCourse),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          enabled: false,
          child: Text('סינון', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        CheckedPopupMenuItem(
          value: FilterType.all,
          checked: currentFilter == FilterType.all,
          child: Text(AppStrings.filterAll),
        ),
        CheckedPopupMenuItem(
          value: FilterType.deadlines,
          checked: currentFilter == FilterType.deadlines,
          child: Text(AppStrings.filterDeadlines),
        ),
        CheckedPopupMenuItem(
          value: FilterType.tasks,
          checked: currentFilter == FilterType.tasks,
          child: Text(AppStrings.filterTasks),
        ),
        const PopupMenuDivider(),
        CheckedPopupMenuItem(
          value: !showHidden,
          checked: showHidden,
          child: Text(showHidden ? AppStrings.hideHiddenTasks : AppStrings.showHiddenTasks),
        ),
      ],
    );
  }
}
