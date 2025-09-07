import 'package:flutter/material.dart';
import '../core/services/geolocation_service.dart';

class NearbyHospitalsScreen extends StatefulWidget {
  const NearbyHospitalsScreen({super.key});

  @override
  State<NearbyHospitalsScreen> createState() => _NearbyHospitalsScreenState();
}

class _NearbyHospitalsScreenState extends State<NearbyHospitalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _hospitals = [];
  List<Map<String, dynamic>> _proximityAlerts = [];
  List<Map<String, dynamic>> _filteredHospitals = [];
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading

    setState(() {
      _hospitals = GeolocationService.getNearbyHospitals();
      _filteredHospitals = _hospitals;
      _proximityAlerts = GeolocationService.getProximityAlerts();
      _isLoading = false;
    });
  }

  void _filterHospitals() {
    setState(() {
      _filteredHospitals = _hospitals.where((hospital) {
        final matchesSearch =
            _searchQuery.isEmpty ||
            hospital['name'].toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            hospital['type'].toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesFilter =
            _selectedFilter == 'All' ||
            (_selectedFilter == 'Emergency' && hospital['emergencyServices']) ||
            (_selectedFilter == 'Available Beds' &&
                hospital['availableBeds'] > 0) ||
            (_selectedFilter == 'High Rating' && hospital['rating'] >= 4.5);

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Nearby Hospitals'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.blue[200],
          tabs: const [
            Tab(icon: Icon(Icons.local_hospital), text: 'Hospitals'),
            Tab(icon: Icon(Icons.warning), text: 'Alerts'),
            Tab(icon: Icon(Icons.map), text: 'Map View'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildHospitalsTab(),
                _buildAlertsTab(),
                _buildMapTab(),
              ],
            ),
    );
  }

  Widget _buildHospitalsTab() {
    return Column(
      children: [
        // Search and Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search hospitals...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (value) {
                  _searchQuery = value;
                  _filterHospitals();
                },
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      ['All', 'Emergency', 'Available Beds', 'High Rating']
                          .map(
                            (filter) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(filter),
                                selected: _selectedFilter == filter,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = selected ? filter : 'All';
                                    _filterHospitals();
                                  });
                                },
                                selectedColor: Colors.blue[100],
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        ),
        // Hospital List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredHospitals.length,
            itemBuilder: (context, index) {
              final hospital = _filteredHospitals[index];
              return _buildHospitalCard(hospital);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalCard(Map<String, dynamic> hospital) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showHospitalDetails(hospital),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_hospital,
                      color: Colors.blue[700],
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hospital['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hospital['type'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${hospital['distance']} km away',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            hospital['rating'].toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (hospital['emergencyServices'])
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '24/7',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Bed Availability
              Row(
                children: [
                  Icon(Icons.bed, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Available Beds: ${hospital['availableBeds']}/${hospital['totalBeds']}',
                    style: TextStyle(
                      color: hospital['availableBeds'] > 0
                          ? Colors.green[700]
                          : Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Wait: ${hospital['waitTime']}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Specialties
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: (hospital['specialties'] as List<String>)
                    .take(3)
                    .map(
                      (specialty) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          specialty,
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showDirections(hospital),
                      icon: const Icon(Icons.directions),
                      label: const Text('Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _callHospital(hospital),
                      icon: const Icon(Icons.phone),
                      label: const Text('Call'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Alert Summary Card
        Card(
          color: Colors.orange[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[700], size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Alerts in Your Area',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      Text(
                        '${_proximityAlerts.length} active alerts within 10km',
                        style: TextStyle(color: Colors.orange[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Alert List
        ..._proximityAlerts.map((alert) => _buildAlertCard(alert)),
      ],
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    Color alertColor = alert['severity'] == 'High'
        ? Colors.red
        : alert['severity'] == 'Medium'
        ? Colors.orange
        : Colors.yellow[700]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: alertColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    alert['type'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: alertColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    alert['severity'],
                    style: TextStyle(
                      color: alertColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${alert['location']} (${alert['distance']} km away)',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${alert['affectedCount']} confirmed cases',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                Text(
                  alert['reportedTime'],
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Precautions:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...((alert['precautions'] as List<String>).map(
              (precaution) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(precaution)),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Map placeholder
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 64, color: Colors.blue[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Interactive Map View',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Map integration coming soon',
                      style: TextStyle(color: Colors.blue[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Quick Stats
          Expanded(
            flex: 1,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Total Hospitals',
                  _hospitals.length.toString(),
                  Icons.local_hospital,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Available Beds',
                  _hospitals
                      .fold(0, (sum, h) => sum + (h['availableBeds'] as int))
                      .toString(),
                  Icons.bed,
                  Colors.green,
                ),
                _buildStatCard(
                  'Emergency Services',
                  _hospitals
                      .where((h) => h['emergencyServices'])
                      .length
                      .toString(),
                  Icons.emergency,
                  Colors.red,
                ),
                _buildStatCard(
                  'Active Alerts',
                  _proximityAlerts.length.toString(),
                  Icons.warning,
                  Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    MaterialColor color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color[700]),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color[700],
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showHospitalDetails(Map<String, dynamic> hospital) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Hospital info
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.local_hospital,
                      color: Colors.blue[700],
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hospital['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          hospital['type'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            Text(' ${hospital['rating']} '),
                            Text(
                              '• ${hospital['distance']} km',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Contact info
              _buildDetailSection('Contact Information', [
                _buildDetailRow(
                  Icons.location_on,
                  'Address',
                  hospital['address'],
                ),
                _buildDetailRow(Icons.phone, 'Phone', hospital['phone']),
              ]),
              const SizedBox(height: 16),
              // Services
              _buildDetailSection('Services & Specialties', [
                _buildDetailRow(
                  Icons.access_time,
                  'Wait Time',
                  hospital['waitTime'],
                ),
                _buildDetailRow(
                  Icons.emergency,
                  'Emergency Services',
                  hospital['emergencyServices']
                      ? 'Available 24/7'
                      : 'Not Available',
                ),
                _buildDetailRow(
                  Icons.airport_shuttle,
                  'Ambulance Service',
                  hospital['hasAmbulance'] ? 'Available' : 'Not Available',
                ),
              ]),
              const SizedBox(height: 16),
              // Specialties
              const Text(
                'Specialties',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (hospital['specialties'] as List<String>)
                    .map(
                      (specialty) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          specialty,
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _bookAmbulance(hospital),
                      icon: const Icon(Icons.emergency),
                      label: const Text('Book Ambulance'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showDirections(hospital),
                      icon: const Icon(Icons.directions),
                      label: const Text('Get Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  void _showDirections(Map<String, dynamic> hospital) {
    final route = GeolocationService.getRouteToHospital(hospital['id']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Directions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To: ${hospital['name']}'),
            const SizedBox(height: 8),
            Text('Distance: ${route['distance']} km'),
            Text('Estimated Time: ${route['estimatedTime']}'),
            Text('Traffic: ${route['traffic']}'),
            const SizedBox(height: 8),
            Text('Route: ${route['route']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would open maps app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening maps app...')),
              );
            },
            child: const Text('Open in Maps'),
          ),
        ],
      ),
    );
  }

  void _callHospital(Map<String, dynamic> hospital) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Hospital'),
        content: Text('Call ${hospital['name']} at ${hospital['phone']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would make a phone call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${hospital['phone']}...')),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _bookAmbulance(Map<String, dynamic> hospital) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Ambulance'),
        content: const Text(
          'Do you want to book an ambulance from this hospital?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final result = GeolocationService.bookAmbulance(
                hospital['id'],
                'Emergency',
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message']),
                  backgroundColor: result['success']
                      ? Colors.green
                      : Colors.red,
                ),
              );

              if (result['success']) {
                _showAmbulanceBookingDetails(result);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }

  void _showAmbulanceBookingDetails(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ambulance Booked'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking ID: ${booking['bookingId']}'),
            Text('Ambulance: ${booking['ambulanceNumber']}'),
            Text('Driver: ${booking['driverName']}'),
            Text('Contact: ${booking['driverPhone']}'),
            Text('ETA: ${booking['estimatedArrival']}'),
            const SizedBox(height: 8),
            const Text(
              'Please stay at your current location. The ambulance will arrive shortly.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
