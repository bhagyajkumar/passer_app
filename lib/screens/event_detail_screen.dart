import 'package:flutter/material.dart';
import 'package:passer/services/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'create_ticket_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final int eventId;

  EventDetailScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Detail'),
        actions: [
          IconButton(
            onPressed: () {
              _showQRScannerDialog(context);
            },
            icon: Icon(Icons.camera),
          ),
        ],
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
                  ),
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

  // Function to show the QR scanner dialog
  Future<void> _showQRScannerDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return QRScannerDialog();
      },
    );
  }
}

class QRScannerDialog extends StatefulWidget {
  @override
  _QRScannerDialogState createState() => _QRScannerDialogState();
}

class _QRScannerDialogState extends State<QRScannerDialog> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Scan QR Code'),
      content: Container(
        width: 300,
        height: 300,
        child: QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Close'),
          onPressed: () {
            controller?.dispose();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      if (result != null) {
        print('Scanned QR Code: ${result!.code}');
        Navigator.of(context).pop(); // Close the dialog
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
