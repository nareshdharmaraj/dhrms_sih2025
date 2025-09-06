import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  bool _isScanning = false;
  bool _flashOn = false;
  String? _scanResult;

  final List<QrScanRecord> _scanHistory = [
    QrScanRecord(
      type: 'Health Record',
      content: 'Patient: Rajesh Kumar - Blood Test Report',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      icon: Icons.medical_information,
      color: AppColors.primaryBlue,
    ),
    QrScanRecord(
      type: 'Prescription',
      content: 'Dr. Sarah Joseph - Medication Schedule',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.medication,
      color: AppColors.success,
    ),
    QrScanRecord(
      type: 'Appointment',
      content: 'Kochi General Hospital - Follow-up',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      icon: Icons.schedule,
      color: AppColors.primaryOrange,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
    });

    if (_isScanning) {
      _scanAnimationController.repeat();
      // Simulate scanning delay
      Future.delayed(const Duration(seconds: 3), () {
        if (_isScanning) {
          _onQrCodeScanned('HEALTH_RECORD_12345');
        }
      });
    } else {
      _scanAnimationController.stop();
      _scanAnimationController.reset();
    }
  }

  void _onQrCodeScanned(String result) {
    setState(() {
      _isScanning = false;
      _scanResult = result;
    });

    _scanAnimationController.stop();
    _scanAnimationController.reset();

    _showScanResult(result);
  }

  void _showScanResult(String result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildScanResultSheet(result),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey900,
      appBar: AppBar(
        title: const Text('QR Scanner'),
        backgroundColor: AppColors.grey900,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              setState(() {
                _flashOn = !_flashOn;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showScanHistory(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(flex: 3, child: _buildCameraView()),
          Expanded(flex: 1, child: _buildControlsSection()),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.grey800, AppColors.grey900],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Scanner frame
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLarge,
                  ),
                ),
                child: Stack(
                  children: [
                    // Corner indicators
                    ..._buildCornerIndicators(),

                    // Scanning line animation
                    if (_isScanning)
                      AnimatedBuilder(
                        animation: _scanAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: _scanAnimation.value * 220,
                            left: 10,
                            right: 10,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryBlue.withValues(
                                      alpha: 0.0,
                                    ),
                                    AppColors.primaryBlue,
                                    AppColors.primaryBlue.withValues(
                                      alpha: 0.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                    // Center crosshair
                    Center(
                      child: Icon(
                        Icons.center_focus_strong,
                        color: AppColors.white.withValues(alpha: 0.7),
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),

              // Camera placeholder
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: AppColors.grey700.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLarge,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_2,
                        size: 80,
                        color: AppColors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppDimensions.marginMedium),
                      Text(
                        _isScanning
                            ? 'Scanning...'
                            : 'Position QR code in frame',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.marginLarge),

          Text(
            'Align the QR code within the frame to scan',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerIndicators() {
    const double size = 20;
    const double thickness = 3;

    return [
      // Top-left
      Positioned(
        top: 5,
        left: 5,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.primaryBlue, width: thickness),
              left: BorderSide(color: AppColors.primaryBlue, width: thickness),
            ),
          ),
        ),
      ),
      // Top-right
      Positioned(
        top: 5,
        right: 5,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.primaryBlue, width: thickness),
              right: BorderSide(color: AppColors.primaryBlue, width: thickness),
            ),
          ),
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: 5,
        left: 5,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.primaryBlue,
                width: thickness,
              ),
              left: BorderSide(color: AppColors.primaryBlue, width: thickness),
            ),
          ),
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: 5,
        right: 5,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.primaryBlue,
                width: thickness,
              ),
              right: BorderSide(color: AppColors.primaryBlue, width: thickness),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildControlsSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      child: Column(
        children: [
          // Scan Button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: _toggleScanning,
              icon: Icon(_isScanning ? Icons.stop : Icons.qr_code_scanner),
              label: Text(_isScanning ? 'Stop Scanning' : 'Start Scanning'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isScanning
                    ? AppColors.error
                    : AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLarge,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.marginMedium),

          // Quick Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAction(
                Icons.image,
                'Gallery',
                () => _scanFromGallery(),
              ),
              _buildQuickAction(Icons.share, 'Share', () => _shareMyQR()),
              _buildQuickAction(
                Icons.history,
                'History',
                () => _showScanHistory(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Icon(icon, color: AppColors.grey600),
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildScanResultSheet(String result) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Success icon and title
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 30,
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Text(
                  'QR Code Scanned',
                  style: AppTextStyles.headline6.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Scanned content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: AppColors.grey300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scanned Data:',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginSmall),
                  Text(
                    result,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Detected information
            if (result.contains('HEALTH_RECORD')) ...[
              _buildDetectedInfo('Type', 'Health Record'),
              _buildDetectedInfo('Patient', 'Rajesh Kumar'),
              _buildDetectedInfo('Document', 'Blood Test Report'),
              _buildDetectedInfo('Date', 'Today'),
            ],

            const Spacer(),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Open relevant record/document
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectedInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _scanFromGallery() {
    // TODO: Implement gallery scanning
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery scanning coming soon')),
    );
  }

  void _shareMyQR() {
    // TODO: Share user's health QR code
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('QR sharing coming soon')));
  }

  void _showScanHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusLarge),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(
                vertical: AppDimensions.marginMedium,
              ),
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLarge,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scan History',
                    style: AppTextStyles.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Clear history
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                itemCount: _scanHistory.length,
                itemBuilder: (context, index) {
                  return _buildHistoryItem(_scanHistory[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(QrScanRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: record.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Icon(record.icon, color: record.color, size: 20),
        ),
        title: Text(
          record.type,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.content,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _formatTimestamp(record.timestamp),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // TODO: Show more options
          },
        ),
        isThreeLine: true,
        onTap: () {
          Navigator.pop(context);
          // TODO: Show scan details
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

class QrScanRecord {
  final String type;
  final String content;
  final DateTime timestamp;
  final IconData icon;
  final Color color;

  QrScanRecord({
    required this.type,
    required this.content,
    required this.timestamp,
    required this.icon,
    required this.color,
  });
}
