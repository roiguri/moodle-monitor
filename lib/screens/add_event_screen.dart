import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodie/models/app_event.dart';
import 'package:moodie/models/custom_event.dart';
import 'package:moodie/services/database_service.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({Key? key}) : super(key: key);

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  AppEventType _type = AppEventType.customTask;
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();

  // Recurrence
  bool _isRecurring = false;
  RecurrenceType _recurrenceType = RecurrenceType.daily;
  final Set<int> _selectedWeekdays = {};
  int _recurrenceInterval = 1; // Default to 1

  // End condition
  // 0: Never (actually handled as null date/count), 1: On Date, 2: After Count
  int _endConditionType = 0;
  DateTime? _endDate;
  final _countController = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    // Default to next hour
    final now = DateTime.now();
    _startDate = now;
    _startTime = TimeOfDay(hour: now.hour + 1, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveEvent,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Type Selector
            SegmentedButton<AppEventType>(
              segments: const [
                ButtonSegment(
                  value: AppEventType.customTask,
                  label: Text('Task'),
                  icon: Icon(Icons.check_circle_outline),
                ),
                ButtonSegment(
                  value: AppEventType.customDeadline,
                  label: Text('Deadline'),
                  icon: Icon(Icons.timer),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (Set<AppEventType> newSelection) {
                setState(() {
                  _type = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Date and Time
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Date'),
                    subtitle: Text(DateFormat('MMM d, y').format(_startDate)),
                    leading: const Icon(Icons.calendar_today),
                    onTap: _pickDate,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ListTile(
                    title: const Text('Time'),
                    subtitle: Text(_startTime.format(context)),
                    leading: const Icon(Icons.access_time),
                    onTap: _pickTime,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recurrence Switch
            SwitchListTile(
              title: const Text('Repeat'),
              value: _isRecurring,
              onChanged: (val) {
                setState(() {
                  _isRecurring = val;
                });
              },
            ),

            if (_isRecurring) ...[
              const Divider(),
              const Text('Recurrence Settings', style: TextStyle(fontWeight: FontWeight.bold)),

              DropdownButton<RecurrenceType>(
                value: _recurrenceType,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: RecurrenceType.daily, child: Text('Daily')),
                  DropdownMenuItem(value: RecurrenceType.weekly, child: Text('Weekly')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _recurrenceType = val);
                },
              ),

              if (_recurrenceType == RecurrenceType.weekly) _buildWeekdaySelector(),

              const SizedBox(height: 16),
              const Text('Ends'),
              RadioListTile<int>(
                title: const Text('Never'),
                value: 0,
                groupValue: _endConditionType,
                onChanged: (val) => setState(() => _endConditionType = val!),
              ),
              RadioListTile<int>(
                title: const Text('On Date'),
                value: 1,
                groupValue: _endConditionType,
                onChanged: (val) => setState(() => _endConditionType = val!),
                secondary: _endConditionType == 1
                    ? TextButton(
                        child: Text(_endDate != null ? DateFormat('MMM d, y').format(_endDate!) : 'Select Date'),
                        onPressed: () async {
                           final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
                            firstDate: _startDate,
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() {
                              _endDate = date;
                              _endConditionType = 1;
                            });
                          }
                      })
                    : null,
              ),
              RadioListTile<int>(
                title: const Text('After occurrences'),
                value: 2,
                groupValue: _endConditionType,
                onChanged: (val) => setState(() => _endConditionType = val!),
                secondary: SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _countController,
                    keyboardType: TextInputType.number,
                    enabled: _endConditionType == 2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdaySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          // index 0 = Mon (1) ... index 6 = Sun (7)
          final day = index + 1;
          final isSelected = _selectedWeekdays.contains(day);
          final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedWeekdays.remove(day);
                } else {
                  _selectedWeekdays.add(day);
                }
              });
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
              foregroundColor: isSelected ? Colors.white : Colors.black,
              child: Text(labels[index]),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (time != null) {
      setState(() => _startTime = time);
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isRecurring && _recurrenceType == RecurrenceType.weekly && _selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day for weekly recurrence')),
      );
      return;
    }

    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    int? count;
    DateTime? endDate;

    if (_isRecurring) {
      if (_endConditionType == 1) {
        endDate = _endDate;
      } else if (_endConditionType == 2) {
        count = int.tryParse(_countController.text);
      }
    }

    final event = CustomEvent(
      title: _titleController.text,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      type: _type,
      startTime: startDateTime,
      recurrenceType: _isRecurring ? _recurrenceType : RecurrenceType.none,
      recurrenceInterval: _recurrenceInterval, // Always 1 for now based on UI
      recurrenceDays: _isRecurring && _recurrenceType == RecurrenceType.weekly
          ? _selectedWeekdays.toList()
          : null,
      recurrenceEndDate: endDate,
      recurrenceCount: count,
    );

    try {
      await DatabaseService().insertEvent(event);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving event: $e')),
        );
      }
    }
  }
}
