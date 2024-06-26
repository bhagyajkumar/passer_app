import 'package:flutter/material.dart';
import 'package:passer/services/api_service.dart';

class TicketCreationScreen extends StatefulWidget {
  final int eventId;

  TicketCreationScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  _TicketCreationScreenState createState() => _TicketCreationScreenState();
}

class _TicketCreationScreenState extends State<TicketCreationScreen> {
  final _descriptionController = TextEditingController();
  bool isLoading = false;

  void _createTicket() async {
    if ( _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final ticketData = {
        'description': _descriptionController.text,
        'event_id': widget.eventId,  // Link the ticket to the specific event
      };
      await ApiService().createTicket(ticketData);
      Navigator.pop(context, true); // Indicate a successful creation
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create ticket: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createTicket,
                    child: Text('Create Ticket'),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
