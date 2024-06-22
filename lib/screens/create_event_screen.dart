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

  void _createEvent() async {
    try {
      final eventData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'date': DateTime.parse(_dateController.text).toIso8601String(),
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
            CustomTextField(controller: _dateController, hintText: 'Date (YYYY-MM-DDTHH:MM:SS)'),
            SizedBox(height: 20),
            CustomButton(text: 'Create Event', onPressed: _createEvent),
          ],
        ),
      ),
    );
  }
}
