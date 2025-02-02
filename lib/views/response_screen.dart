import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';


class ResponseScreen extends StatelessWidget {
  final String response;

  const ResponseScreen({required this.response, super.key});

  Future<String?> _getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        // Request storage permission on Android
        if (await Permission.storage.request().isGranted) {
          // Get the Downloads directory
          directory = Directory('/storage/emulated/0/Download');
          // Create directory if it doesn't exist
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
        } else {
          return null;
        }
      } else if (Platform.isIOS) {
        // On iOS, we'll use the Documents directory since iOS doesn't have a dedicated Downloads folder
        directory = await getApplicationDocumentsDirectory();
      }
      return directory?.path;
    } catch (e) {
      print('Error getting download path: $e');
      return null;
    }
  }

  Future<void> _generateAndSavePdf(BuildContext context) async {
    try {
      // Check Android version for storage permissions
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 30) {
          // Android 11 and above needs MANAGE_EXTERNAL_STORAGE permission
          if (!await Permission.manageExternalStorage.request().isGranted) {
            throw Exception('Storage permission required');
          }
        } else {
          // Below Android 11 needs regular storage permission
          if (!await Permission.storage.request().isGranted) {
            throw Exception('Storage permission required');
          }
        }
      }

      // Get download path
      final downloadPath = await _getDownloadPath();
      if (downloadPath == null) {
        throw Exception('Could not access download directory');
      }

      // Create PDF document
      final pdf = pw.Document();

      // Add content to PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'Your Learning Path',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  response,
                  style: const pw.TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Generate filename with timestamp
      final fileName = 'learning_path_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '$downloadPath/$fileName';
      final file = File(filePath);

      // Save PDF
      await file.writeAsBytes(await pdf.save());

      // Show success message and share option
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to Downloads: $fileName'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () async {
                await Share.shareXFiles(
                  [XFile(file.path)],
                  subject: 'Learning Path',
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving PDF: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Learning Path'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _generateAndSavePdf(context),
            tooltip: 'Save as PDF',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: MarkdownBody(
                  data: response,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton.icon(
                onPressed: () => _generateAndSavePdf(context),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Save to Downloads'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
