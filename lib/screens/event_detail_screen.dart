import 'dart:io';

import 'package:flutter/material.dart';
import 'package:passer/services/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'create_ticket_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:math';
import 'dart:typed_data';

class EventDetailScreen extends StatelessWidget {
  final int eventId;

  EventDetailScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Detail'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to CreateTicketScreen with the eventId
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateTicketScreen(eventId: eventId),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      body: Center(
        child: FutureBuilder<List<dynamic>>(
          future: ApiService().getTickets(eventId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Failed to load tickets: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No tickets available for this event.');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final ticket = snapshot.data![index];
                  return ListTile(
                    title: Text('Ticket #${index + 1}: ${ticket['id']}'),
                    onTap: () {
                      // Show dialog with ticket details
                      _showTicketDetailsDialog(context, ticket);
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  ScreenshotController _screenshotController = ScreenshotController();

  // Function to show a dialog with ticket details
  Future<void> _showTicketDetailsDialog(BuildContext context, dynamic ticket) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ticket Details'),
          content: SingleChildScrollView(
            child: Screenshot(
              controller: _screenshotController,
              child: ListBody(
                children: <Widget>[
                  Text('Ticket ID: ${ticket['id']}'),
                  SizedBox(height: 10),
                  Text('Description: ${ticket['description']}'),
                  SizedBox(
                    height: 320,
                    width: 320,
                    child: QrImageView(
                      data: ticket['id'],
                      version: QrVersions.auto,
                      size: 320,
                      gapless: false,
                    ),
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await _screenshotController
                    .capture(delay: const Duration(milliseconds: 10))
                    .then((Uint8List? image) async {
                  // Note the change to Uint8List?
                  if (image != null) {
                    final directory = await getApplicationDocumentsDirectory();
                    final imagePath =
                        await File('${directory.path}/image.png').create();
                    await imagePath.writeAsBytes(image);

                    final imageXFile = XFile('${directory.path}/image.png');
                    await Share.shareXFiles([imageXFile]);
                  }
                });
              },
              child: Text("Share"),
            ),
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
