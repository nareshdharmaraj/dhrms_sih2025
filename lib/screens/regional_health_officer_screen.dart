import 'package:flutter/material.dart';
import '../utils/colors.dart';

class RegionalHealthOfficerScreen extends StatefulWidget {
  const RegionalHealthOfficerScreen({super.key});

  @override
  State<RegionalHealthOfficerScreen> createState() =>
      _RegionalHealthOfficerScreenState();
}

class _RegionalHealthOfficerScreenState
    extends State<RegionalHealthOfficerScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> regionalOfficers = [];
  String? error;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRegionalOfficers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRegionalOfficers() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Simulate loading regional health officers
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        regionalOfficers = [
          {
            'id': '1',
            'name': 'Dr. Rajesh Kumar',
            'region': 'North Region',
            'email': 'rajesh.kumar@health.gov.in',
            'phone': '+91 9876543210',
            'status': 'Active',
            'staffCount': 45,
            'lastActive': '2 hours ago',
          },
          {
            'id': '2',
            'name': 'Dr. Priya Sharma',
            'region': 'South Region',
            'email': 'priya.sharma@health.gov.in',
            'phone': '+91 9876543211',
            'status': 'Active',
            'staffCount': 38,
            'lastActive': '5 hours ago',
          },
          {
            'id': '3',
            'name': 'Dr. Amit Patel',
            'region': 'East Region',
            'email': 'amit.patel@health.gov.in',
            'phone': '+91 9876543212',
            'status': 'Inactive',
            'staffCount': 22,
            'lastActive': '2 days ago',
          },
        ];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load regional health officers: $e';
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredOfficers {
    if (searchQuery.isEmpty) return regionalOfficers;
    return regionalOfficers
        .where(
          (officer) =>
              officer['name'].toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              officer['region'].toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              officer['email'].toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search regional health officers...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total RHOs',
                        regionalOfficers.length.toString(),
                        Icons.people,
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Active',
                        regionalOfficers
                            .where((o) => o['status'] == 'Active')
                            .length
                            .toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Inactive',
                        regionalOfficers
                            .where((o) => o['status'] == 'Inactive')
                            .length
                            .toString(),
                        Icons.cancel,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Officers List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadRegionalOfficers,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadRegionalOfficers,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredOfficers.length,
                      itemBuilder: (context, index) {
                        final officer = filteredOfficers[index];
                        return _buildOfficerCard(officer);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new regional health officer
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add new RHO functionality coming soon'),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOfficerCard(Map<String, dynamic> officer) {
    final isActive = officer['status'] == 'Active';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isActive ? Colors.green : Colors.red,
                  child: Text(
                    officer['name'].split(' ').map((n) => n[0]).join(''),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        officer['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        officer['region'],
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    officer['status'],
                    style: TextStyle(
                      color: isActive ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildInfoRow(Icons.email, officer['email'])),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: _buildInfoRow(Icons.phone, officer['phone'])),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.people,
                    '${officer['staffCount']} staff members',
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    Icons.access_time,
                    'Last active: ${officer['lastActive']}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: View officer details
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('View details for ${officer['name']}'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Edit officer
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Edit ${officer['name']}')),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Toggle officer status
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Toggle status for ${officer['name']}'),
                      ),
                    );
                  },
                  icon: Icon(
                    isActive ? Icons.toggle_on : Icons.toggle_off,
                    size: 16,
                  ),
                  label: Text(isActive ? 'Deactivate' : 'Activate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
