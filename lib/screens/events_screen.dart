import 'package:flutter/material.dart';
import 'package:passer/screens/event_detail_screen.dart';
import '../services/api_service.dart';
import '../models/event_model.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final ApiService apiService = ApiService();
  List<Event> events = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await apiService.getEvents();
      setState(() {
        events = data.map((event) => Event.fromJson(event)).toList();
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load events. Please try again.';
      });
      print(e);
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
        title: Text('Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result =
                  await Navigator.pushNamed(context, '/create_event');
              // If the result is not null, reload the events
              if (result == true) {
                _loadEvents();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show a loading indicator
          : errorMessage != null
              ? Center(child: Text(errorMessage!)) // Show the error message
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(events[index].name),
                            subtitle: Text(events[index].description),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetailScreen(
                                      eventId: events[index].id),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
