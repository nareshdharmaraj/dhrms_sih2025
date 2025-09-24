import 'package:flutter/material.dart';
import '../../models/regional_health_officer.dart';
import '../../models/sho.dart';
import '../../services/regional_health_officer_service.dart';
import '../../utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_regional_health_officer_screen.dart';
import 'regional_health_officer_details_screen.dart';
import 'zone_management_screen.dart';

class RegionalHealthOfficerScreen extends StatefulWidget {
  final SHO? sho;
  
  const RegionalHealthOfficerScreen({super.key, this.sho});

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
        List<RegionalHealthOfficer> rhoData = result['data'] as List<RegionalHealthOfficer>;
        
        // Backend now filters by state, so no need for frontend filtering
        print('🔍 Received ${rhoData.length} RHOs from backend');
        for (var rho in rhoData) {
          print('🔍 RHO: ${rho.officerId} - ${rho.fullName} (${rho.assignedDistrict})');
        }
        
        setState(() {
          rhos = rhoData;
          statistics = result['statistics'] != null
              ? RHOStatistics.fromJson(result['statistics'])
              : null;
          isLoading = false;
        });
        
        print('🔍 Total RHOs loaded: ${rhos.length}');
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
    print('🔍 filteredRHOs getter called');
    print('🔍 Total rhos: ${rhos.length}');
    print('🔍 Selected filter: $selectedFilter');
    print('🔍 Search query: "$searchQuery"');
    
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
      print('🔍 After filter by status: ${filtered.length}');
    }

    // Apply search
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((rho) {
        return rho.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            rho.officerId.toLowerCase().contains(searchQuery.toLowerCase()) ||
            rho.assignedDistrict.toLowerCase().contains(searchQuery.toLowerCase()) ||
            rho.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
            rho.assignedAreaNames.any((area) => 
              area.toLowerCase().contains(searchQuery.toLowerCase()));
      }).toList();
      print('🔍 After search filter: ${filtered.length}');
    }

    print('🔍 Final filtered count: ${filtered.length}');
    return filtered;
  }

  Future<void> toggleRHOStatus(RegionalHealthOfficer rho) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${rho.isActive ? 'Deactivate' : 'Activate'} Regional Health Officer'),
        content: Text(
          rho.isActive 
              ? 'Are you sure you want to deactivate ${rho.fullName}? This will prevent them from accessing the system.'
              : 'Are you sure you want to activate ${rho.fullName}? This will allow them to access the system.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: rho.isActive ? Colors.orange : Colors.green,
            ),
            child: Text(rho.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

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

  Future<void> resetRHOPassword(RegionalHealthOfficer rho) async {
    // Show confirmation dialog with new password input
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool isPasswordVisible = false;
    bool isConfirmPasswordVisible = false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.lock_reset, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 300,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reset password for ${rho.fullName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      hintText: 'Enter new password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      // Check for password complexity
                      final RegExp regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$');
                      if (!regex.hasMatch(value)) {
                        return 'Password must contain uppercase, lowercase, number and special character';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: !isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Confirm new password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            isConfirmPasswordVisible = !isConfirmPasswordVisible;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm the password';
                      }
                      if (value != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange[700],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'The RHO will need to login with this new password.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                newPasswordController.dispose();
                confirmPasswordController.dispose();
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');

        if (token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication token not found'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        final result = await RegionalHealthOfficerService.resetRHOPassword(
          token, 
          rho.id, 
          newPasswordController.text,
        );

        // Close loading dialog
        Navigator.of(context).pop();

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password reset successfully for ${rho.fullName}'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to reset password'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Close loading dialog if it's still open
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        newPasswordController.dispose();
        confirmPasswordController.dispose();
      }
    } else {
      newPasswordController.dispose();
      confirmPasswordController.dispose();
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

  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ZoneManagementScreen(sho: widget.sho!),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.location_city,
                      size: 32,
                      color: Colors.purple[600],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Zone Management',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage RHO zones for dense areas',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 2,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateRegionalHealthOfficerScreen(
                      preferredState: widget.sho?.assignedState,
                    ),
                  ),
                ).then((_) => loadRHOs());
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add,
                      size: 32,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add New RHO',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create new Regional Health Officer',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRHOCard(RegionalHealthOfficer rho) {
    try {
      print('🔍 Building card for: ${rho.officerId} - ${rho.fullName}');
      print('🔍 RHO details: district=${rho.assignedDistrict}, region=${rho.assignedRegion}, active=${rho.isActive}');
      
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
                      value: 'reset_password',
                      child: Row(
                        children: [
                          Icon(Icons.lock_reset, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Reset Password'),
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
                      case 'reset_password':
                        resetRHOPassword(rho);
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
                Icon(Icons.map, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Areas: ${rho.assignedAreasText}',
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
                    color: rho.hasSpecificAreaAssignment ? Colors.purple[100] : Colors.indigo[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rho.assignmentTypeText,
                    style: TextStyle(
                      color: rho.hasSpecificAreaAssignment ? Colors.purple[800] : Colors.indigo[800],
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
                if (rho.totalAssignedPopulation > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      rho.assignedPopulationText,
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rho.staffUtilizationText,
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
    } catch (e, stackTrace) {
      print('❌ Error building RHO card for ${rho.officerId}: $e');
      print('❌ Stack trace: $stackTrace');
      // Return error card to help debug
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.error, color: Colors.red),
              Text('Error displaying RHO: ${rho.officerId}'),
              Text('Error: $e', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );
    }
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
            icon: const Icon(Icons.location_city),
            tooltip: 'Zone Management',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ZoneManagementScreen(sho: widget.sho!),
                ),
              );
            },
          ),
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
                        const SizedBox(height: 16),
                        _buildQuickActionsRow(),
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
                                initialValue: selectedFilter,
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
                          child: Builder(
                            builder: (context) {
                              print('🔍 Building list - filteredRHOs.isEmpty: ${filteredRHOs.isEmpty}');
                              print('🔍 Building list - filteredRHOs.length: ${filteredRHOs.length}');
                              if (filteredRHOs.isNotEmpty) {
                                print('🔍 First RHO: ${filteredRHOs.first.officerId} - ${filteredRHOs.first.fullName}');
                              }
                              
                              return filteredRHOs.isEmpty
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
                                        print('🔍 Building card for index $index: ${filteredRHOs[index].officerId}');
                                        return _buildRHOCard(filteredRHOs[index]);
                                      },
                                    );
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
              builder: (context) => CreateRegionalHealthOfficerScreen(
                preferredState: widget.sho?.assignedState,
              ),
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