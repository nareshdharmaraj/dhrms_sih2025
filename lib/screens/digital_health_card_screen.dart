import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../utils/card_download_service.dart';
import '../utils/environment_config.dart';

class DigitalHealthCardScreen extends StatefulWidget {
  final String uhid;

  const DigitalHealthCardScreen({super.key, required this.uhid});

  @override
  _DigitalHealthCardScreenState createState() =>
      _DigitalHealthCardScreenState();
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
      // Get the current API base URL from environment config
      final apiBaseUrl = EnvironmentConfig.getApiBaseUrl();
      print('🔍 Loading digital card for UHID: ${widget.uhid}');
      print('🌐 Using API URL: $apiBaseUrl');

      final response = await http.get(
        Uri.parse('$apiBaseUrl/patients/digital-card/${widget.uhid}'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            cardData = data['digitalCard'];
            isLoading = false;
          });
          print('✅ Digital card loaded successfully');
        } else {
          setState(() {
            error = data['message'] ?? 'Failed to load card data';
            isLoading = false;
          });
          print('❌ API error: ${data['message']}');
        }
      } else {
        setState(() {
          error =
              'Failed to load digital card (Status: ${response.statusCode})';
          isLoading = false;
        });
        print('❌ HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        error = 'Network error: $e';
        isLoading = false;
      });
      print('❌ Network error: $e');
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
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      // Top Bar
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF1565C0), // Medical Blue
                              Color(0xFF0D47A1), // Darker Blue
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left: Issuing details
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Issued by Digital Health Mission',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // Center: Title
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Digital Health Card',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            // Right: Home State
                            Expanded(
                              flex: 2,
                              child: Text(
                                cardData!['homeState'] ?? 'Kerala',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Profile Section with Photo and QR Code
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Profile Photo Section
                            Column(
                              children: [
                                // Circular Profile Photo
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFF1565C0),
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 2,
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: cardData!['photo'] != null
                                        ? Image.memory(
                                            base64Decode(cardData!['photo']),
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: Colors.grey.shade200,
                                            child: Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(height: 12),
                                // Full Name
                                Container(
                                  width: 140,
                                  child: Text(
                                    cardData!['patientName'] ?? 'Unknown',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 8),
                                // UHID
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1565C0).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Color(0xFF1565C0).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'UHID: ${cardData!['uhid'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1565C0),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // QR Code Section
                            Column(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color(0xFF1565C0),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 2,
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: cardData!['qrCode'] != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.memory(
                                            base64Decode(
                                              cardData!['qrCode']
                                                  .split(',')
                                                  .last,
                                            ),
                                            fit: BoxFit.contain,
                                          ),
                                        )
                                      : Icon(
                                          Icons.qr_code,
                                          color: Colors.grey.shade600,
                                          size: 60,
                                        ),
                                ),
                                SizedBox(height: 12),
                                Container(
                                  width: 140,
                                  child: Text(
                                    'Digital Health ID',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1565C0),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  width: 140,
                                  child: Text(
                                    'Scan at Healthcare Facilities',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Details Section
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        child: Column(
                          children: [
                            // Details Header
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Personal Details',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            SizedBox(height: 15),

                            // Details in 2x3 grid
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      // Date of Birth
                                      _buildDetailItem(
                                        Icons.calendar_today,
                                        'Date of Birth',
                                        _formatDate(cardData!['dateOfBirth']),
                                        Color(0xFF4CAF50),
                                      ),
                                      SizedBox(height: 12),

                                      // Phone Number
                                      _buildDetailItem(
                                        Icons.phone,
                                        'Phone Number',
                                        cardData!['phone'] ?? 'Not provided',
                                        Color(0xFF2196F3),
                                      ),
                                      SizedBox(height: 12),

                                      // Address
                                      _buildDetailItem(
                                        Icons.location_on,
                                        'Address',
                                        _formatAddress(cardData!['address']),
                                        Color(0xFF607D8B),
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    children: [
                                      // Gender
                                      _buildDetailItem(
                                        _getGenderIcon(cardData!['gender']),
                                        'Gender',
                                        '${_getGenderSymbol(cardData!['gender'])} ${cardData!['gender']?.toString().toUpperCase() ?? 'Not specified'}',
                                        Color(0xFF9C27B0),
                                      ),
                                      SizedBox(height: 12),

                                      // Blood Group (highlighted in red)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.red.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.water_drop,
                                              color: Colors.red.shade600,
                                              size: 14,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'Blood Group',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.red.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade600,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                cardData!['bloodGroup'] ??
                                                    'Unknown',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 12),

                                      // Issue Date
                                      _buildDetailItem(
                                        Icons.date_range,
                                        'Issue Date',
                                        _formatDate(cardData!['issueDate']),
                                        Color(0xFF795548),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Emergency Section (Bottom highlighted bar)
                      if (cardData!['emergencyContact'] != null ||
                          cardData!['emergencyContactName'] != null)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade600,
                                Colors.orange.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.emergency,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Emergency Contact',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Row(
                                      children: [
                                        if (cardData!['emergencyContactName'] !=
                                                null &&
                                            cardData!['emergencyContactName'] !=
                                                'Not provided')
                                          Expanded(
                                            child: Text(
                                              cardData!['emergencyContactName'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        SizedBox(width: 10),
                                        Text(
                                          cardData!['emergencyContact'] ??
                                              'Not provided',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Small QR code in bottom-right
                              Container(
                                width: 50,
                                height: 50,
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.qr_code,
                                  color: Colors.grey.shade700,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // If no emergency contact, still show QR at bottom
                      if (cardData!['emergencyContact'] == null &&
                          cardData!['emergencyContactName'] == null)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Issued: ${_formatDate(cardData!['issueDate'])}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Icon(
                                  Icons.qr_code,
                                  color: Colors.grey.shade700,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Emergency Contact Section
                      if (cardData!['emergencyContact'] != null &&
                          cardData!['emergencyContact'] != 'Not provided')
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade600,
                                Colors.red.shade700,
                              ],
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.emergency,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Emergency Contact',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (cardData!['emergencyContactName'] !=
                                          null &&
                                      cardData!['emergencyContactName'] !=
                                          'Not provided')
                                    Expanded(
                                      child: Text(
                                        cardData!['emergencyContactName'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    cardData!['emergencyContact'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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
                    CardDownloadService.shareCard(
                      patientName: cardData!['patientName'] ?? 'Unknown',
                      uhid: cardData!['uhid'] ?? 'N/A',
                      bloodGroup: cardData!['bloodGroup'] ?? 'Unknown',
                      emergencyContact: cardData!['emergencyContact'] ?? 'N/A',
                      issueDate: _formatDate(cardData!['issueDate']),
                      context: context,
                    );
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
                    CardDownloadService.showDownloadOptions(
                      context: context,
                      cardKey: _cardKey,
                      cardData: cardData!,
                      patientName: cardData!['patientName'] ?? 'Unknown',
                      uhid: cardData!['uhid'] ?? 'N/A',
                      bloodGroup: cardData!['bloodGroup'] ?? 'Unknown',
                      emergencyContact: cardData!['emergencyContact'] ?? 'N/A',
                      issueDate: _formatDate(cardData!['issueDate']),
                    );
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

  // New helper methods for the redesigned card
  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value,
    Color color, {
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getGenderIcon(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'male':
        return Icons.man;
      case 'female':
        return Icons.woman;
      default:
        return Icons.person;
    }
  }

  String _getGenderSymbol(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'male':
        return '♂';
      case 'female':
        return '♀';
      default:
        return '⚧';
    }
  }

  String _formatAddress(dynamic address) {
    if (address == null) return 'Address not provided';
    if (address is String) return address;
    if (address is Map) {
      return address['fullAddress'] ?? 'Address not available';
    }
    return 'Address not available';
  }
}
