import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final ApiService apiService = ApiService();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  void _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
          _dateController.text = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          ).toIso8601String();
        });
      }
    }
  }

  void _createEvent() async {
    try {
      final eventData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'date': _dateController.text,
      };
      await apiService.createEvent(eventData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event created successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(controller: _nameController, hintText: 'Event Name'),
            CustomTextField(controller: _descriptionController, hintText: 'Description'),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: CustomTextField(
                  controller: _dateController,
                  hintText: 'Select Date & Time',
                ),
              ),
            ),
            SizedBox(height: 20),
            CustomButton(text: 'Create Event', onPressed: _createEvent),
          ],
        ),
      ),
    );
  }
}
