import 'package:flutter/material.dart';
import 'dart:async';
import '../models/who_admin.dart';
import '../models/state_health_officer.dart';
import '../services/sho_service.dart';

class ShoManagementScreen extends StatefulWidget {
  final WhoAdmin whoAdmin;

  const ShoManagementScreen({super.key, required this.whoAdmin});

  @override
  _ShoManagementScreenState createState() => _ShoManagementScreenState();
}

class _ShoManagementScreenState extends State<ShoManagementScreen> {
  bool isLoading = true;
  List<StateHealthOfficer> shos = [];
  SHOStatistics? statistics;
  String? error;
  String searchQuery = '';
  String filterState = 'All States';
  bool filterActive = true;

  // Indian States list
  final List<String> indianStates = [
    'All States', 'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
    'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
    'West Bengal', 'Delhi', 'Jammu and Kashmir', 'Ladakh'
  ];

  @override
  void initState() {
    super.initState();
    _loadSHOs();
  }

  Future<void> _loadSHOs() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      print('📋 Loading SHOs...');
      final result = await SHOService.getAllSHOs();
      print('📋 SHO load result: ${result['success']}');

      if (result['success']) {
        final newSHOs = (result['shos'] as List)
            .map((item) => StateHealthOfficer.fromJson(item))
            .toList();
        
        print('📋 Loaded ${newSHOs.length} SHOs');
        for (final sho in newSHOs) {
          print('  - ${sho.fullName}: ${sho.isActive ? 'ACTIVE' : 'INACTIVE'}');
        }
        
        setState(() {
          shos = newSHOs;
          isLoading = false;
        });
      } else {
        print('📋 SHO load failed: ${result['message']}');
        setState(() {
          error = result['message'];
          isLoading = false;
        });
      }

      // Also load statistics
      try {
        final statsResult = await SHOService.getSHOStatistics();
        if (statsResult['success']) {
          setState(() {
            statistics = SHOStatistics.fromJson(statsResult['statistics']);
          });
          print('📊 Statistics updated: ${statistics?.total} total, ${statistics?.active} active');
        }
      } catch (e) {
        print('Error loading statistics: $e');
      }
    } catch (e) {
      print('📋 Error loading SHOs: $e');
      setState(() {
        error = 'Failed to load SHOs: $e';
        isLoading = false;
      });
    }
  }

  List<StateHealthOfficer> get filteredSHOs {
    return shos.where((sho) {
      bool matchesSearch = sho.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          sho.officerId.toLowerCase().contains(searchQuery.toLowerCase()) ||
          sho.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
          sho.assignedState.toLowerCase().contains(searchQuery.toLowerCase());

      bool matchesState = filterState == 'All States' || sho.assignedState == filterState;
      bool matchesActive = sho.isActive == filterActive;

      return matchesSearch && matchesState && matchesActive;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('State Health Officers'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadSHOs,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showCreateSHODialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
          ? _buildErrorWidget()
          : _buildContent(),
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
              'Error Loading SHOs',
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
              onPressed: _loadSHOs,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Statistics Header
        if (statistics != null) _buildStatisticsHeader(),
        
        // Search and Filter
        _buildSearchAndFilter(),
        
        // SHO List
        Expanded(
          child: filteredSHOs.isEmpty
              ? _buildEmptyState()
              : _buildSHOList(),
        ),
      ],
    );
  }

  Widget _buildStatisticsHeader() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem('Total SHOs', '${statistics!.total}', Icons.people),
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          Expanded(
            child: _buildStatItem('Active', '${statistics!.active}', Icons.check_circle),
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          Expanded(
            child: _buildStatItem('Inactive', '${statistics!.inactive}', Icons.pause_circle),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name, ID, email, or state...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          SizedBox(height: 12),
          
          // Filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: filterState,
                  decoration: InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: indianStates.map((state) {
                    return DropdownMenuItem(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      filterState = value!;
                    });
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<bool>(
                  value: filterActive,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    DropdownMenuItem(value: true, child: Text('Active')),
                    DropdownMenuItem(value: false, child: Text('Inactive')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      filterActive = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.admin_panel_settings, size: 80, color: Colors.grey.shade300),
          SizedBox(height: 20),
          Text(
            'No State Health Officers Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            searchQuery.isNotEmpty
                ? 'No SHOs match your search criteria'
                : 'Create your first State Health Officer',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showCreateSHODialog,
            icon: Icon(Icons.add),
            label: Text('Create SHO'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSHOList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredSHOs.length,
      itemBuilder: (context, index) {
        final sho = filteredSHOs[index];
        return _buildSHOCard(sho);
      },
    );
  }

  Widget _buildSHOCard(StateHealthOfficer sho) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: sho.isActive ? Colors.green.shade100 : Colors.red.shade100,
              child: Icon(
                Icons.admin_panel_settings,
                color: sho.isActive ? Colors.green.shade600 : Colors.red.shade600,
              ),
            ),
            title: Text(
              sho.fullName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${sho.formattedOfficerId}'),
                Text('State: ${sho.assignedState}'),
                Text('Email: ${sho.email}'),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleSHOAction(value, sho),
              itemBuilder: (context) => [
                PopupMenuItem(value: 'view', child: Text('View Details')),
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: sho.isActive ? 'deactivate' : 'activate',
                  child: Text(sho.isActive ? 'Deactivate' : 'Activate'),
                ),
                PopupMenuItem(value: 'reset_password', child: Text('Reset Password')),
              ],
            ),
          ),
          
          // Status and Last Login
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: sho.isActive ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    sho.statusText,
                    style: TextStyle(
                      color: sho.isActive ? Colors.green.shade700 : Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  sho.lastLogin != null
                      ? 'Last login: ${_formatDate(sho.lastLogin!)}'
                      : 'Never logged in',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSHOAction(String action, StateHealthOfficer sho) {
    switch (action) {
      case 'view':
        _showSHODetails(sho);
        break;
      case 'edit':
        _showEditSHODialog(sho);
        break;
      case 'activate':
      case 'deactivate':
        _toggleSHOStatus(sho);
        break;
      case 'reset_password':
        _resetSHOPassword(sho);
        break;
    }
  }

  void _showSHODetails(StateHealthOfficer sho) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('SHO Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', sho.fullName),
              _buildDetailRow('Officer ID', sho.formattedOfficerId),
              _buildDetailRow('Email', sho.email),
              _buildDetailRow('Phone', sho.phone),
              _buildDetailRow('Assigned State', sho.assignedState),
              _buildDetailRow('Status', sho.statusText),
              _buildDetailRow('Created', _formatDate(sho.createdAt)),
              _buildDetailRow('Last Updated', _formatDate(sho.updatedAt)),
              if (sho.lastLogin != null)
                _buildDetailRow('Last Login', _formatDate(sho.lastLogin!)),
              SizedBox(height: 16),
              Text(
                'Permissions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...sho.permissions.entries.map((entry) {
                return _buildDetailRow(
                  entry.key.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim(),
                  entry.value.toString(),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showCreateSHODialog() {
    _showSHODialog(null);
  }

  void _showEditSHODialog(StateHealthOfficer sho) {
    _showSHODialog(sho);
  }

  void _showSHODialog(StateHealthOfficer? sho) {
    final isEditing = sho != null;
    final formKey = GlobalKey<FormState>();
    
    // Use TextEditingControllers to properly handle form data
    final fullNameController = TextEditingController(text: sho?.fullName ?? '');
    final emailController = TextEditingController(text: sho?.email ?? '');
    final phoneController = TextEditingController(text: sho?.phone ?? '');
    final passwordController = TextEditingController();
    
    // Use ValueNotifier for assignedState to handle dropdown changes properly
    final assignedStateNotifier = ValueNotifier<String>(sho?.assignedState ?? indianStates[1]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit SHO' : 'Create New SHO'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: fullNameController,
                  decoration: InputDecoration(labelText: 'Full Name'),
                  validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
                  onChanged: (value) => print('📝 Full Name changed: "$value"'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Email is required';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                      return 'Invalid email format';
                    }
                    return null;
                  },
                  onChanged: (value) => print('📧 Email changed: "$value"'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value?.isEmpty == true ? 'Phone is required' : null,
                  onChanged: (value) => print('📱 Phone changed: "$value"'),
                ),
                SizedBox(height: 16),
                ValueListenableBuilder<String>(
                  valueListenable: assignedStateNotifier,
                  builder: (context, assignedState, child) {
                    return DropdownButtonFormField<String>(
                      value: assignedState,
                      decoration: InputDecoration(labelText: 'Assigned State'),
                      items: indianStates.skip(1).map((state) {
                        return DropdownMenuItem(value: state, child: Text(state));
                      }).toList(),
                      onChanged: (value) {
                        print('🏛️ State changed: "$value"');
                        assignedStateNotifier.value = value!;
                      },
                    );
                  },
                ),
                if (!isEditing) ...[
                  SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Password is required';
                      if (value!.length < 8) return 'Password must be at least 8 characters';
                      return null;
                    },
                    onChanged: (value) => print('🔒 Password changed: ${value.isNotEmpty ? '[HIDDEN ${value.length} chars]' : 'EMPTY'}'),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              print('\n=== FORM SUBMISSION DEBUG ===');
              print('Full Name Controller Text: "${fullNameController.text}"');
              print('Email Controller Text: "${emailController.text}"');
              print('Phone Controller Text: "${phoneController.text}"');
              print('Password Controller Text: "${passwordController.text}"');
              print('Assigned State: "${assignedStateNotifier.value}"');
              
              // Check if all fields are empty (which indicates an issue)
              bool allFieldsEmpty = fullNameController.text.trim().isEmpty &&
                                   emailController.text.trim().isEmpty &&
                                   phoneController.text.trim().isEmpty &&
                                   passwordController.text.trim().isEmpty;
              
              if (allFieldsEmpty) {
                print('❌ ERROR: All fields are empty! This indicates a form capture issue.');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill in all fields before submitting'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              print('Form Valid: ${formKey.currentState?.validate()}');
              print('================================\n');
              
              if (formKey.currentState!.validate()) {
                _submitSHOForm(
                  formKey, 
                  isEditing, 
                  sho?.id, 
                  fullNameController,
                  emailController,
                  phoneController,
                  assignedStateNotifier.value,
                  isEditing ? null : passwordController
                );
              } else {
                print('❌ Form validation failed');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please correct the form errors'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: Text(isEditing ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _submitSHOForm(GlobalKey<FormState> formKey, bool isEditing, String? shoId, 
      TextEditingController fullNameController, TextEditingController emailController, 
      TextEditingController phoneController, String assignedState, TextEditingController? passwordController) async {
    if (!formKey.currentState!.validate()) return;

    // Get the current values from controllers
    String fullName = fullNameController.text.trim();
    String email = emailController.text.trim();
    String phone = phoneController.text.trim();
    String? password = passwordController?.text.trim();

    // Additional validation
    if (fullName.isEmpty || email.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!isEditing && (password == null || password.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password is required for new SHO'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text(isEditing ? 'Updating SHO...' : 'Creating SHO...'),
          ],
        ),
      ),
    );

    try {
      Map<String, dynamic> result;
      
      if (isEditing) {
        result = await SHOService.updateSHO(
          shoId: shoId!,
          updates: {
            'fullName': fullName,
            'email': email,
            'phone': phone,
            'assignedState': assignedState,
          },
        );
      } else {
        // Generate Officer ID based on state
        String stateCode = _getStateCode(assignedState);
        String officerId = 'SHO_${stateCode}_001'; // You might want to check for existing IDs
        
        print('🚀 Creating SHO with data:');
        print('Officer ID: $officerId');
        print('Full Name: $fullName');
        print('Email: $email');
        print('Phone: $phone');
        print('State: $assignedState');
        print('Password length: ${password?.length ?? 0}');
        
        result = await SHOService.createSHO(
          officerId: officerId,
          fullName: fullName,
          email: email,
          phone: phone,
          assignedState: assignedState,
          password: password!,
        );
      }

      // Close loading dialog only if widget is still mounted
      if (mounted) {
        Navigator.pop(context);
      }

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'SHO updated successfully' : 'SHO created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadSHOs();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        
        // Show detailed error if available
        if (result['errors'] != null) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Validation Errors'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (result['errors'] as List).map((error) => 
                  Text('• ${error['msg']}', style: TextStyle(color: Colors.red))
                ).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog only if widget is still mounted
      if (mounted) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper function to get state code from state name
  String _getStateCode(String stateName) {
    final stateCodes = {
      'Andhra Pradesh': 'AP',
      'Arunachal Pradesh': 'AR',
      'Assam': 'AS',
      'Bihar': 'BR',
      'Chhattisgarh': 'CG',
      'Goa': 'GA',
      'Gujarat': 'GJ',
      'Haryana': 'HR',
      'Himachal Pradesh': 'HP',
      'Jharkhand': 'JH',
      'Karnataka': 'KA',
      'Kerala': 'KL',
      'Madhya Pradesh': 'MP',
      'Maharashtra': 'MH',
      'Manipur': 'MN',
      'Meghalaya': 'ML',
      'Mizoram': 'MZ',
      'Nagaland': 'NL',
      'Odisha': 'OR',
      'Punjab': 'PB',
      'Rajasthan': 'RJ',
      'Sikkim': 'SK',
      'Tamil Nadu': 'TN',
      'Telangana': 'TG',
      'Tripura': 'TR',
      'Uttar Pradesh': 'UP',
      'Uttarakhand': 'UK',
      'West Bengal': 'WB',
      'Delhi': 'DL',
      'Jammu and Kashmir': 'JK',
      'Ladakh': 'LA'
    };
    return stateCodes[stateName] ?? 'XX';
  }

  void _toggleSHOStatus(StateHealthOfficer sho) async {
    final action = sho.isActive ? 'deactivate' : 'activate';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.substring(0, 1).toUpperCase()}${action.substring(1)} SHO'),
        content: Text('Are you sure you want to $action ${sho.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading indicator with its own context tracking
              OverlayEntry? loadingOverlay;
              if (mounted) {
                loadingOverlay = OverlayEntry(
                  builder: (overlayContext) => Material(
                    color: Colors.black54,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(width: 20),
                            Text('${action.substring(0, 1).toUpperCase()}${action.substring(1)}ing SHO...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                Overlay.of(context).insert(loadingOverlay);
              }
              
              try {
                final result = await SHOService.updateSHOStatus(sho.id, !sho.isActive);
                
                // Remove loading overlay
                if (mounted && loadingOverlay != null) {
                  loadingOverlay.remove();
                  loadingOverlay = null;
                }
                
                if (result['success']) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('SHO ${action}d successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  
                  // Force refresh the SHO list to ensure UI updates
                  await _loadSHOs();
                  
                  // Also update statistics
                  try {
                    final statsResult = await SHOService.getSHOStatistics();
                    if (statsResult['success'] && mounted) {
                      setState(() {
                        statistics = SHOStatistics.fromJson(statsResult['statistics']);
                      });
                    }
                  } catch (e) {
                    print('Error updating statistics: $e');
                  }
                  
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${result['message']}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                // Remove loading overlay on error
                if (mounted && loadingOverlay != null) {
                  loadingOverlay.remove();
                  loadingOverlay = null;
                }
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                // Ensure overlay is removed in all cases
                if (loadingOverlay != null) {
                  try {
                    loadingOverlay.remove();
                  } catch (e) {
                    print('Error removing overlay: $e');
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: sho.isActive ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(action.substring(0, 1).toUpperCase() + action.substring(1)),
          ),
        ],
      ),
    );
  }

  void _resetSHOPassword(StateHealthOfficer sho) async {
    final passwordController = TextEditingController();
    bool useCustomPassword = false;
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setState) => AlertDialog(
          title: Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reset password for: ${sho.fullName}'),
              SizedBox(height: 16),
              
              // Option to use custom password
              CheckboxListTile(
                title: Text('Set custom password'),
                subtitle: Text('Otherwise, a random password will be generated'),
                value: useCustomPassword,
                onChanged: (value) {
                  setState(() {
                    useCustomPassword = value ?? false;
                    if (!useCustomPassword) {
                      passwordController.clear();
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              
              // Password input field (shown only if custom password is selected)
              if (useCustomPassword) ...[
                SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Enter new password (min 8 characters)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 8),
                Text(
                  'Password must be at least 8 characters long',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate custom password if provided
                if (useCustomPassword) {
                  final password = passwordController.text.trim();
                  if (password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a password'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  if (password.length < 8) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password must be at least 8 characters long'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                }
                
                // Close the password dialog first
                Navigator.of(dialogContext).pop();
                
                // Store the custom password value before showing loading dialog
                final customPassword = useCustomPassword ? passwordController.text.trim() : null;
                
                // Show loading dialog with its own context
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (loadingContext) => WillPopScope(
                    onWillPop: () async => false,
                    child: AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 20),
                          Text('Resetting password...'),
                        ],
                      ),
                    ),
                  ),
                );
                
                try {
                  final result = await SHOService.resetPassword(sho.id, customPassword: customPassword);
                  
                  // Close loading dialog - use the navigator from the main context only if mounted
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                  
                  if (result['success']) {
                    // Show success dialog only if widget is still mounted
                    if (mounted) {
                      showDialog(
                      context: context,
                      builder: (successContext) => AlertDialog(
                        title: Text('Password Reset Successful'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Password reset for: ${sho.fullName}'),
                            SizedBox(height: 16),
                            
                            if (useCustomPassword) ...[
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green.shade600),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Custom password has been set successfully.',
                                        style: TextStyle(color: Colors.green.shade700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Text('New generated password:'),
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SelectableText(
                                  result['data']['newPassword'] ?? 'Password not available',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Please share this password securely with the SHO.',
                                style: TextStyle(color: Colors.orange.shade700),
                              ),
                            ],
                            
                            SizedBox(height: 16),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Login Details:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text('Username: ${result['data']?['username'] ?? 'N/A'}'),
                                  Text('Email: ${result['data']?['email'] ?? 'N/A'}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(successContext).pop();
                            },
                            child: Text('Close'),
                          ),
                        ],
                      ),
                    );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['message'] ?? 'Failed to reset password'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  // Close loading dialog if still open only if widget is mounted
                  if (mounted) {
                    try {
                      Navigator.of(context).pop();
                    } catch (_) {
                      // Loading dialog might already be closed
                    }
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}