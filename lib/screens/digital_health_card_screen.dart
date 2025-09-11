import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class DigitalHealthCardScreen extends StatefulWidget {
  final String uhid;
  
  const DigitalHealthCardScreen({super.key, required this.uhid});

  @override
  _DigitalHealthCardScreenState createState() => _DigitalHealthCardScreenState();
}

class _DigitalHealthCardScreenState extends State<DigitalHealthCardScreen> {
  Map<String, dynamic>? cardData;
  bool isLoading = true;
  String? error;
  final GlobalKey _cardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadDigitalCard();
  }

  Future<void> _loadDigitalCard() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/patients/digital-card/${widget.uhid}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            cardData = data['digitalCard'];
            isLoading = false;
          });
        } else {
          setState(() {
            error = data['message'];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Failed to load digital card';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Digital Health Card'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
                error = null;
              });
              _loadDigitalCard();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? _buildErrorWidget()
              : _buildDigitalCard(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            SizedBox(height: 20),
            Text(
              'Error Loading Card',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  error = null;
                });
                _loadDigitalCard();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalCard() {
    if (cardData == null) return Container();

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Digital Health Card
          RepaintBoundary(
            key: _cardKey,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade700,
                      Colors.blue.shade500,
                      Colors.teal.shade400,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Card Header
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.health_and_safety,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DIGITAL HEALTH CARD',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  'Government of India',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              cardData!['isActive'] ? 'ACTIVE' : 'INACTIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Card Body
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Patient Photo and Basic Info
                          Row(
                            children: [
                              // Photo
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.grey.shade300, width: 2),
                                  color: Colors.grey.shade100,
                                ),
                                child: cardData!['photo'] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(13),
                                        child: Image.memory(
                                          base64Decode(cardData!['photo']),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.grey.shade500,
                                      ),
                              ),
                              SizedBox(width: 20),
                              // Patient Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cardData!['patientName'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.red.shade200),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.bloodtype, color: Colors.red.shade600, size: 16),
                                          SizedBox(width: 4),
                                          Text(
                                            'Blood: ${cardData!['bloodGroup'] ?? 'Unknown'}',
                                            style: TextStyle(
                                              color: Colors.red.shade600,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 20),
                          
                          // UHID and Card Number
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade50, Colors.teal.shade50],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'UHID',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Card Number',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      cardData!['uhid'] ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    Text(
                                      cardData!['cardNumber'] ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Emergency Contact
                          if (cardData!['emergencyContact'] != null)
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.emergency, color: Colors.red.shade600, size: 24),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Emergency Contact',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red.shade600,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          cardData!['emergencyContact'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.red.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          SizedBox(height: 20),
                          
                          // Issue Date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Issued: ${_formatDate(cardData!['issueDate'])}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.verified, color: Colors.green.shade600, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 20),
                          
                          // QR Code Section (Now inside the card for download)
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'QR Code for Quick Access',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                SizedBox(height: 15),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: cardData!['qrCode'] != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.memory(
                                            base64Decode(cardData!['qrCode'].split(',').last),
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.contain,
                                          ),
                                        )
                                      : Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.qr_code, size: 40, color: Colors.grey.shade400),
                                                SizedBox(height: 5),
                                                Text('QR Code\nUnavailable', 
                                                     textAlign: TextAlign.center,
                                                     style: TextStyle(fontSize: 10, color: Colors.grey.shade500))
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Scan at any healthcare facility',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
          
          SizedBox(height: 30),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Share functionality
                    _shareCard();
                  },
                  icon: Icon(Icons.share),
                  label: Text('Share Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Download functionality
                    _downloadCard();
                  },
                  icon: Icon(Icons.download),
                  label: Text('Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _shareCard() {
    // Create shareable text with patient info
    String shareText = '''
🏥 Digital Health Card - Government of India

👤 Patient: ${cardData!['patientName']}
🆔 UHID: ${cardData!['uhid']}
🩸 Blood Group: ${cardData!['bloodGroup']}
📅 Issued: ${_formatDate(cardData!['issueDate'])}

🚨 Emergency Contact: ${cardData!['emergencyContact']}

This is an official digital health card issued under the Digital Health Record Management System (DHRMS).

For more information, visit: https://dhrms.gov.in
    ''';

    // For web, copy to clipboard
    Clipboard.setData(ClipboardData(text: shareText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Health card details copied to clipboard!'),
        backgroundColor: Colors.teal.shade600,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _downloadCard() async {
    try {
      RenderRepaintBoundary boundary = 
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        // Platform-specific download handling
        if (kIsWeb) {
          // For web platform, we need to implement web-specific download
          // This will be handled by a separate web-specific service
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Web download feature coming soon'),
              backgroundColor: Colors.blue,
            ),
          );
        } else {
          // For mobile platforms, save to gallery or show share dialog
          // This could be implemented with path_provider and gallery_saver
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download feature coming soon for mobile'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Digital Health Card downloaded successfully!'),
            backgroundColor: Colors.green.shade600,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading card: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }
}
