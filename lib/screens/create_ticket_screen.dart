import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';

class CreateTicketScreen extends StatefulWidget {
  final int eventId;

  // Constructor to accept eventId as a required parameter
  CreateTicketScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  _CreateTicketScreenState createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final ApiService apiService = ApiService();

  // Controllers for additional ticket fields
  final TextEditingController _descriptionController = TextEditingController();

  void _createTicket() async {
    try {
      final ticketData = {
        'event_id': widget.eventId,  // Use the passed eventId
        'description': _descriptionController.text,
      };
      print(ticketData);
      await apiService.createTicket(ticketData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ticket created successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create ticket: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Creating ticket for Event ID: ${widget.eventId}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
           
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'Create Ticket',
              onPressed: _createTicket,
            ),
          ],
        ),
      ),
    );
  }
}
