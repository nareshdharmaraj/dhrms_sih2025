import 'package:flutter/material.dart';
import '../../models/regional_health_officer.dart';
import '../../services/regional_health_officer_service.dart';
import '../../utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_regional_health_officer_screen.dart';
import 'regional_health_officer_details_screen.dart';

class RegionalHealthOfficerScreen extends StatefulWidget {
  const RegionalHealthOfficerScreen({super.key});

  @override
  State<RegionalHealthOfficerScreen> createState() => _RegionalHealthOfficerScreenState();
}

class _RegionalHealthOfficerScreenState extends State<RegionalHealthOfficerScreen> {
  List<RegionalHealthOfficer> rhos = [];
  RHOStatistics? statistics;
  bool isLoading = true;
  String? error;
  String searchQuery = '';
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    loadRHOs();
  }

  Future<void> loadRHOs() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() {
          error = 'Authentication token not found';
          isLoading = false;
        });
        return;
      }

      final result = await RegionalHealthOfficerService.getRHOs(token);

      if (result['success']) {
        setState(() {
          rhos = result['data'] as List<RegionalHealthOfficer>;
          statistics = result['statistics'] != null
              ? RHOStatistics.fromJson(result['statistics'])
              : null;
          isLoading = false;
        });
      } else {
        setState(() {
          error = result['message'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'An error occurred: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  List<RegionalHealthOfficer> get filteredRHOs {
    List<RegionalHealthOfficer> filtered = rhos;

    // Apply filter
    if (selectedFilter != 'All') {
      filtered = filtered.where((rho) {
        switch (selectedFilter) {
          case 'Active':
            return rho.isActive;
          case 'Inactive':
            return !rho.isActive;
          default:
            return true;
        }
      }).toList();
    }

    // Apply search
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((rho) {
        return rho.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            rho.officerId.toLowerCase().contains(searchQuery.toLowerCase()) ||
            rho.assignedRegion.toLowerCase().contains(searchQuery.toLowerCase()) ||
            rho.email.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  Future<void> toggleRHOStatus(RegionalHealthOfficer rho) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return;

      final result = await RegionalHealthOfficerService.toggleRHOStatus(token, rho.id);

      if (result['success']) {
        setState(() {
          final index = rhos.indexWhere((r) => r.id == rho.id);
          if (index != -1) {
            rhos[index] = result['data'] as RegionalHealthOfficer;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteRHO(RegionalHealthOfficer rho) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Regional Health Officer'),
        content: Text(
          'Are you sure you want to delete ${rho.fullName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return;

      final result = await RegionalHealthOfficerService.deleteRHO(token, rho.id);

      if (result['success']) {
        setState(() {
          rhos.removeWhere((r) => r.id == rho.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStatisticsCards() {
    if (statistics == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total RHOs',
            statistics!.total.toString(),
            Icons.people,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Active',
            statistics!.active.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Staff',
            statistics!.totalStaff.toString(),
            Icons.groups,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Patients',
            statistics!.totalPatients.toString(),
            Icons.local_hospital,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRHOCard(RegionalHealthOfficer rho) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: rho.isActive ? Colors.green : Colors.grey,
                  radius: 20,
                  child: Text(
                    rho.fullName.split(' ').map((n) => n[0]).take(2).join().toUpperCase(),
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
                        rho.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        rho.officerId,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility),
                          SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(rho.isActive ? Icons.block : Icons.check_circle),
                          const SizedBox(width: 8),
                          Text(rho.isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegionalHealthOfficerDetailsScreen(rho: rho),
                          ),
                        ).then((_) => loadRHOs());
                        break;
                      case 'toggle':
                        toggleRHOStatus(rho);
                        break;
                      case 'delete':
                        deleteRHO(rho);
                        break;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    rho.fullRegionName,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    rho.email,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rho.isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rho.statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${rho.totalStaff} Staff',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${rho.staffUtilizationText}',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regional Health Officers'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadRHOs,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        error!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: loadRHOs,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadRHOs,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildStatisticsCards(),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Search RHOs...',
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedFilter,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                items: ['All', 'Active', 'Inactive']
                                    .map((filter) => DropdownMenuItem(
                                          value: filter,
                                          child: Text(filter),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedFilter = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: filteredRHOs.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                                      const SizedBox(height: 16),
                                      Text(
                                        searchQuery.isNotEmpty || selectedFilter != 'All'
                                            ? 'No RHOs found matching your criteria'
                                            : 'No Regional Health Officers found',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredRHOs.length,
                                  itemBuilder: (context, index) {
                                    return _buildRHOCard(filteredRHOs[index]);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateRegionalHealthOfficerScreen(),
            ),
          ).then((_) => loadRHOs());
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add RHO'),
      ),
    );
  }
}