import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/event_model.dart';
import '../widgets/custom_button.dart';

class CreateTicketScreen extends StatefulWidget {
  @override
  _CreateTicketScreenState createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final ApiService apiService = ApiService();
  Event? selectedEvent;
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final data = await apiService.getEvents();
      setState(() {
        events = data.map((event) => Event.fromJson(event)).toList();
      });
    } catch (e) {
      // Handle error
    }
  }

  void _createTicket() async {
    if (selectedEvent != null) {
      try {
        final ticketData = {
          'event': selectedEvent!.id,
        };
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an event')),
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
            DropdownButton<Event>(
              hint: Text('Select Event'),
              value: selectedEvent,
              onChanged: (Event? newValue) {
                setState(() {
                  selectedEvent = newValue!;
                });
              },
              items: events.map<DropdownMenuItem<Event>>((Event event) {
                return DropdownMenuItem<Event>(
                  value: event,
                  child: Text(event.name),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            CustomButton(text: 'Create Ticket', onPressed: _createTicket),
          ],
        ),
      ),
    );
  }
}
