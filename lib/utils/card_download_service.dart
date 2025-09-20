import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CardDownloadService {
  /// Downloads the digital health card as an image
  static Future<bool> downloadDigitalCard({
    required GlobalKey cardKey,
    required String patientName,
    required String uhid,
    required BuildContext context,
  }) async {
    try {
      // Add a small delay to ensure the widget is fully rendered
      await Future.delayed(Duration(milliseconds: 200));

      // Get the RepaintBoundary
      final RenderObject? renderObject = cardKey.currentContext
          ?.findRenderObject();
      if (renderObject == null) {
        throw Exception('Could not find the card widget. Please try again.');
      }

      if (renderObject is! RenderRepaintBoundary) {
        throw Exception(
          'Widget is not properly set up for capture. Please try again.',
        );
      }

      final RenderRepaintBoundary boundary = renderObject;

      // Ensure the boundary is properly laid out
      if (!boundary.hasSize || boundary.size.isEmpty) {
        throw Exception(
          'Card is not properly rendered. Please scroll to view the full card and try again.',
        );
      }

      // Capture with appropriate pixel ratio for good quality but manageable size
      ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        Uint8List imageBytes = byteData.buffer.asUint8List();

        if (kIsWeb) {
          // Web download implementation
          return await _downloadOnWeb(imageBytes, patientName, uhid, context);
        } else {
          // Mobile download implementation
          return await _downloadOnMobile(
            imageBytes,
            patientName,
            uhid,
            context,
          );
        }
      } else {
        throw Exception('Failed to generate image data');
      }
    } catch (e) {
      _showErrorMessage(context, 'Error downloading card: $e');
      return false;
    }
  }

  /// Download implementation for web platform
  static Future<bool> _downloadOnWeb(
    Uint8List imageBytes,
    String patientName,
    String uhid,
    BuildContext context,
  ) async {
    try {
      if (kIsWeb) {
        // For web, we'll use Share functionality instead of direct download
        // Create a temporary file and share it
        final fileName =
            'HealthCard_${patientName.replaceAll(' ', '_')}_$uhid.png';

        // Use the mobile share functionality which works better for web
        await Share.shareXFiles([
          XFile.fromData(imageBytes, name: fileName, mimeType: 'image/png'),
        ], text: 'Digital Health Card - $patientName (UHID: $uhid)');

        _showSuccessMessage(context, 'Digital Health Card ready to download!');
        return true;
      } else {
        _showErrorMessage(
          context,
          'Web download is only available in web builds',
        );
        return false;
      }
    } catch (e) {
      _showErrorMessage(context, 'Web download failed: $e');
      return false;
    }
  }

  /// Download implementation for mobile platform
  static Future<bool> _downloadOnMobile(
    Uint8List imageBytes,
    String patientName,
    String uhid,
    BuildContext context,
  ) async {
    try {
      if (!kIsWeb) {
        // Get appropriate directory for saving files
        Directory? directory;
        if (Platform.isAndroid) {
          // For Android, try to get the Downloads directory
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            // Navigate to Downloads folder
            String newPath = "";
            List<String> folders = directory.path.split("/");
            for (int i = 1; i < folders.length; i++) {
              String folder = folders[i];
              if (folder != "Android") {
                newPath += "/$folder";
              } else {
                break;
              }
            }
            newPath = "$newPath/Download";
            directory = Directory(newPath);
          }
        } else {
          // For iOS and other platforms, use documents directory
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory != null) {
          // Create directory if it doesn't exist
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }

          final fileName =
              'HealthCard_${patientName.replaceAll(' ', '_')}_$uhid.png';
          final file = File('${directory.path}/$fileName');

          // Write image bytes to file
          await file.writeAsBytes(imageBytes);

          // Also share the file for immediate access
          await Share.shareXFiles([
            XFile(file.path),
          ], text: 'Digital Health Card - $patientName (UHID: $uhid)');

          _showSuccessMessage(
            context,
            'Digital Health Card saved to Downloads and shared!',
          );
          return true;
        } else {
          throw Exception('Could not access storage directory');
        }
      } else {
        // Fallback for web
        return await _downloadOnWeb(imageBytes, patientName, uhid, context);
      }
    } catch (e) {
      _showErrorMessage(context, 'Mobile download failed: $e');
      return false;
    }
  }

  /// Download card as PDF
  static Future<bool> downloadCardAsPDF({
    required Map<String, dynamic> cardData,
    required BuildContext context,
  }) async {
    try {
      // Create PDF document
      final pdf = pw.Document();

      // Add page with card content
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  begin: pw.Alignment.topLeft,
                  end: pw.Alignment.bottomRight,
                  colors: [
                    PdfColors.indigo800, // Government Indigo
                    PdfColors.green800, // Government Green
                  ],
                ),
                borderRadius: pw.BorderRadius.circular(15),
              ),
              padding: pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Row(
                    children: [
                      pw.Icon(
                        pw.IconData(0xe328),
                        size: 40,
                        color: PdfColors.white,
                      ), // Hospital icon
                      pw.SizedBox(width: 15),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Government of India',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'Digital Health Card',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 30),

                  // Patient Information
                  pw.Container(
                    padding: pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(10),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildPDFDetailRow(
                          'Name',
                          cardData['patientName'] ?? 'N/A',
                        ),
                        _buildPDFDetailRow('UHID', cardData['uhid'] ?? 'N/A'),
                        _buildPDFDetailRow(
                          'Date of Birth',
                          _formatDateForPDF(cardData['dateOfBirth']),
                        ),
                        _buildPDFDetailRow(
                          'Gender',
                          cardData['gender']?.toString().toUpperCase() ?? 'N/A',
                        ),
                        _buildPDFDetailRow(
                          'Blood Group',
                          cardData['bloodGroup'] ?? 'N/A',
                        ),
                        _buildPDFDetailRow('Phone', cardData['phone'] ?? 'N/A'),
                        if (cardData['address'] != null)
                          _buildPDFDetailRow(
                            'Address',
                            _formatAddressForPDF(cardData['address']),
                          ),
                        if (cardData['homeState'] != null)
                          _buildPDFDetailRow(
                            'Home State',
                            cardData['homeState'],
                          ),
                        if (cardData['emergencyContact'] != null &&
                            cardData['emergencyContact'] != 'Not provided')
                          _buildPDFDetailRow(
                            'Emergency Contact',
                            '${cardData['emergencyContactName'] ?? ''} - ${cardData['emergencyContact']}',
                          ),
                        _buildPDFDetailRow(
                          'Issue Date',
                          _formatDateForPDF(cardData['issueDate']),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // QR Code section
                  if (cardData['qrCodeData'] != null) ...[
                    pw.Text(
                      'QR Code Data:',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Container(
                      padding: pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Text(
                        cardData['qrCodeData'],
                        style: pw.TextStyle(fontSize: 8),
                      ),
                    ),
                  ],

                  pw.Spacer(),

                  // Footer
                  pw.Text(
                    'Generated on: ${DateTime.now().toString().split('.')[0]}',
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 10),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Save and share PDF
      final bytes = await pdf.save();
      final fileName =
          'HealthCard_${cardData['patientName']?.replaceAll(' ', '_')}_${cardData['uhid']}.pdf';

      if (kIsWeb) {
        // Web implementation - use XFile with bytes
        await Share.shareXFiles(
          [XFile.fromData(bytes, name: fileName, mimeType: 'application/pdf')],
          text:
              'Digital Health Card PDF - ${cardData['patientName']} (UHID: ${cardData['uhid']})',
        );
        _showSuccessMessage(context, 'PDF Health Card ready to download!');
      } else {
        // Mobile implementation - save to file then share
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);

        // Share PDF
        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              'Digital Health Card PDF - ${cardData['patientName']} (UHID: ${cardData['uhid']})',
        );
        _showSuccessMessage(context, 'PDF Health Card shared successfully!');
      }

      return true;
    } catch (e) {
      _showErrorMessage(context, 'Error generating PDF: $e');
      return false;
    }
  }

  /// Helper method to build PDF detail rows
  static pw.Widget _buildPDFDetailRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
          ),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  /// Format date for PDF
  static String _formatDateForPDF(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  /// Format address for PDF
  static String _formatAddressForPDF(Map<String, dynamic>? address) {
    if (address == null) return 'N/A';

    List<String> addressParts = [];
    if (address['street'] != null && address['street'].isNotEmpty) {
      addressParts.add(address['street']);
    }
    if (address['city'] != null && address['city'].isNotEmpty) {
      addressParts.add(address['city']);
    }
    if (address['state'] != null && address['state'].isNotEmpty) {
      addressParts.add(address['state']);
    }
    if (address['zipCode'] != null && address['zipCode'].isNotEmpty) {
      addressParts.add(address['zipCode']);
    }

    return addressParts.isNotEmpty ? addressParts.join(', ') : 'N/A';
  }

  /// Downloads card data as JSON file
  static Future<bool> downloadCardData({
    required Map<String, dynamic> cardData,
    required String patientName,
    required String uhid,
    required BuildContext context,
  }) async {
    try {
      final jsonData = {
        'digitalHealthCard': cardData,
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'format': 'DHRMS_DIGITAL_CARD',
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      final fileName =
          'HealthCard_Data_${patientName.replaceAll(' ', '_')}_$uhid.json';

      if (kIsWeb) {
        // For web, use share functionality
        await Share.shareXFiles(
          [
            XFile.fromData(
              Uint8List.fromList(utf8.encode(jsonString)),
              name: fileName,
              mimeType: 'application/json',
            ),
          ],
          text: 'Digital Health Card Data (JSON) - $patientName (UHID: $uhid)',
        );

        _showSuccessMessage(context, 'Card data ready to download!');
        return true;
      } else {
        // Mobile - save to file and also copy to clipboard
        try {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/$fileName');
          await file.writeAsString(jsonString);

          // Share the JSON file
          await Share.shareXFiles(
            [XFile(file.path)],
            text:
                'Digital Health Card Data (JSON) - $patientName (UHID: $uhid)',
          );

          // Also copy to clipboard for easy access
          await Clipboard.setData(ClipboardData(text: jsonString));

          _showSuccessMessage(
            context,
            'Card data saved and copied to clipboard!',
          );
          return true;
        } catch (e) {
          // If file operations fail, fallback to clipboard only
          await Clipboard.setData(ClipboardData(text: jsonString));
          _showSuccessMessage(
            context,
            'Card data copied to clipboard as JSON!',
          );
          return true;
        }
      }
    } catch (e) {
      _showErrorMessage(context, 'Failed to download card data: $e');
      return false;
    }
  }

  /// Create a shareable card summary
  static String createShareableText({
    required String patientName,
    required String uhid,
    required String bloodGroup,
    required String emergencyContact,
    required String issueDate,
  }) {
    return '''
🏥 Digital Health Card - Government of India

👤 Patient: $patientName
🆔 UHID: $uhid
🩸 Blood Group: $bloodGroup
📅 Issued: $issueDate
🚨 Emergency: $emergencyContact

✅ Verified Digital Health Record
📱 DHRMS - Digital Health Record Management System

For verification, visit: https://dhrms.gov.in/verify/$uhid
    ''';
  }

  /// Share card information
  static Future<void> shareCard({
    required String patientName,
    required String uhid,
    required String bloodGroup,
    required String emergencyContact,
    required String issueDate,
    required BuildContext context,
  }) async {
    try {
      final shareText = createShareableText(
        patientName: patientName,
        uhid: uhid,
        bloodGroup: bloodGroup,
        emergencyContact: emergencyContact,
        issueDate: issueDate,
      );

      // Show dialog with options
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.share, color: Colors.deepOrange, size: 24),
                SizedBox(width: 8),
                Text('Share Options'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Choose how you want to share:'),
                SizedBox(height: 20),

                // Copy to Clipboard
                ListTile(
                  leading: Icon(Icons.content_copy, color: Colors.blue),
                  title: Text('Copy to Clipboard'),
                  subtitle: Text('Copy card details to clipboard'),
                  onTap: () async {
                    Navigator.of(dialogContext).pop();
                    await Clipboard.setData(ClipboardData(text: shareText));
                    _showSuccessMessage(
                      context,
                      'Health card details copied to clipboard!',
                    );
                  },
                ),

                Divider(),

                // Share via Platform
                ListTile(
                  leading: Icon(Icons.share, color: Colors.deepOrange),
                  title: Text('Share via Apps'),
                  subtitle: Text('Share using other apps'),
                  onTap: () async {
                    Navigator.of(dialogContext).pop();
                    await Share.share(
                      shareText,
                      subject: 'Digital Health Card - $patientName',
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showErrorMessage(context, 'Failed to share card: $e');
    }
  }

  /// Show success message
  static void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Show error message
  static void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Create download options dialog
  static Future<void> showDownloadOptions({
    required BuildContext context,
    required GlobalKey cardKey,
    required Map<String, dynamic> cardData,
    required String patientName,
    required String uhid,
    required String bloodGroup,
    required String emergencyContact,
    required String issueDate,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.download, color: Colors.indigo.shade700, size: 24),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Download Options',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose how you want to download your digital health card:',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              SizedBox(height: 20),

              // Download as Image
              _buildDownloadOption(
                icon: Icons.image,
                title: 'Download as Image',
                subtitle: 'PNG format for easy sharing',
                color: Colors.indigo,
                onTap: () async {
                  Navigator.of(context).pop();
                  await downloadDigitalCard(
                    cardKey: cardKey,
                    patientName: patientName,
                    uhid: uhid,
                    context: context,
                  );
                },
              ),

              SizedBox(height: 12),

              // Download as PDF
              _buildDownloadOption(
                icon: Icons.picture_as_pdf,
                title: 'Download as PDF',
                subtitle: 'PDF format for official use',
                color: Colors.red,
                onTap: () async {
                  Navigator.of(context).pop();
                  await downloadCardAsPDF(cardData: cardData, context: context);
                },
              ),

              SizedBox(height: 12),

              // Download Card Data
              _buildDownloadOption(
                icon: Icons.data_object,
                title: 'Download Card Data',
                subtitle: 'JSON format for backup',
                color: Colors.green,
                onTap: () async {
                  Navigator.of(context).pop();
                  await downloadCardData(
                    cardData: cardData,
                    patientName: patientName,
                    uhid: uhid,
                    context: context,
                  );
                },
              ),

              SizedBox(height: 12),

              // Share Card Info
              _buildDownloadOption(
                icon: Icons.share,
                title: 'Share Card Info',
                subtitle: 'Copy details to clipboard',
                color: Colors.deepOrange,
                onTap: () async {
                  Navigator.of(context).pop();
                  await shareCard(
                    patientName: patientName,
                    uhid: uhid,
                    bloodGroup: bloodGroup,
                    emergencyContact: emergencyContact,
                    issueDate: issueDate,
                    context: context,
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Build download option widget
  static Widget _buildDownloadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color.shade700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
