import 'package:flutter/material.dart';
import '../models/who_admin.dart';
import '../services/who_service.dart';

class WhoRegionalOfficersScreen extends StatefulWidget {
  final WhoAdmin whoAdmin;

  const WhoRegionalOfficersScreen({super.key, required this.whoAdmin});

  @override
  _WhoRegionalOfficersScreenState createState() => _WhoRegionalOfficersScreenState();
}

class _WhoRegionalOfficersScreenState extends State<WhoRegionalOfficersScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> regionalOfficers = [];
  String? error;
  String? selectedState;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  // Indian states list
  final List<String> indianStates = [
    'ALL',
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  @override
  void initState() {
    super.initState();
    _loadRegionalOfficers();
  }

  Future<void> _loadRegionalOfficers([String? state]) async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final result = await WhoService.getAllRegionalOfficers(state: state);
      
      if (result['success']) {
        setState(() {
          regionalOfficers = List<Map<String, dynamic>>.from(result['officers']);
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
        error = 'Failed to load regional officers: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Regional Officers Management'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddOfficerDialog,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _loadRegionalOfficers(selectedState),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltersSection(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : error != null
                ? _buildErrorWidget()
                : _buildOfficersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search officers by name, email, or ID...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
          SizedBox(height: 12),
          
          // State Filter
          DropdownButtonFormField<String>(
            value: selectedState,
            decoration: InputDecoration(
              labelText: 'Filter by State',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: indianStates.map((state) {
              return DropdownMenuItem(
                value: state == 'ALL' ? null : state,
                child: Text(state),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedState = value;
              });
              _loadRegionalOfficers(value);
            },
          ),
        ],
      ),
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
              'Error Loading Officers',
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
              onPressed: () => _loadRegionalOfficers(selectedState),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficersList() {
    final filteredOfficers = regionalOfficers.where((officer) {
      if (searchQuery.isEmpty) return true;
      
      final name = (officer['fullName'] ?? '').toLowerCase();
      final email = (officer['email'] ?? '').toLowerCase();
      final officerId = (officer['officerId'] ?? '').toLowerCase();
      
      return name.contains(searchQuery) || 
             email.contains(searchQuery) || 
             officerId.contains(searchQuery);
    }).toList();

    if (filteredOfficers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 80, color: Colors.grey.shade400),
            SizedBox(height: 20),
            Text(
              'No Regional Officers Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              searchQuery.isNotEmpty 
                  ? 'No officers match your search criteria'
                  : 'No regional officers registered yet',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showAddOfficerDialog,
              icon: Icon(Icons.add),
              label: Text('Add Regional Officer'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredOfficers.length,
      itemBuilder: (context, index) {
        final officer = filteredOfficers[index];
        return _buildOfficerCard(officer);
      },
    );
  }

  Widget _buildOfficerCard(Map<String, dynamic> officer) {
    final isActive = officer['isActive'] ?? true;
    
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
        border: isActive ? null : Border.all(color: Colors.red.shade300),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isActive ? Colors.blue.shade100 : Colors.red.shade100,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: isActive ? Colors.blue.shade600 : Colors.red.shade600,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        officer['fullName'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.grey.shade800 : Colors.red.shade600,
                        ),
                      ),
                      Text(
                        'ID: ${officer['officerId'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isActive)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'INACTIVE',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleOfficerAction(value, officer),
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'view', child: Text('View Details')),
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    if (isActive)
                      PopupMenuItem(value: 'deactivate', child: Text('Deactivate'))
                    else
                      PopupMenuItem(value: 'activate', child: Text('Activate')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.email,
                    'Email',
                    officer['email'] ?? 'N/A',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    Icons.phone,
                    'Phone',
                    officer['phone'] ?? 'N/A',
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.location_on,
                    'State',
                    officer['state'] ?? 'N/A',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    Icons.work,
                    'Designation',
                    officer['designation'] ?? 'N/A',
                  ),
                ),
              ],
            ),
            
            if (officer['lastLogin'] != null) ...[
              SizedBox(height: 8),
              Text(
                'Last Login: ${_formatDate(officer['lastLogin'])}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleOfficerAction(String action, Map<String, dynamic> officer) {
    switch (action) {
      case 'view':
        _showOfficerDetails(officer);
        break;
      case 'edit':
        _showEditOfficerDialog(officer);
        break;
      case 'deactivate':
        _deactivateOfficer(officer['officerId']);
        break;
      case 'activate':
        _activateOfficer(officer['officerId']);
        break;
    }
  }

  void _showAddOfficerDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddRegionalOfficerDialog(
        states: indianStates.where((state) => state != 'ALL').toList(),
        onOfficerAdded: () {
          _loadRegionalOfficers(selectedState);
        },
      ),
    );
  }

  void _showEditOfficerDialog(Map<String, dynamic> officer) {
    showDialog(
      context: context,
      builder: (context) => _EditRegionalOfficerDialog(
        officer: officer,
        states: indianStates.where((state) => state != 'ALL').toList(),
        onOfficerUpdated: () {
          _loadRegionalOfficers(selectedState);
        },
      ),
    );
  }

  void _showOfficerDetails(Map<String, dynamic> officer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Regional Officer Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', officer['fullName']),
              _buildDetailRow('Officer ID', officer['officerId']),
              _buildDetailRow('Email', officer['email']),
              _buildDetailRow('Phone', officer['phone']),
              _buildDetailRow('State', officer['state']),
              _buildDetailRow('Designation', officer['designation']),
              _buildDetailRow('Status', officer['isActive'] ? 'Active' : 'Inactive'),
              if (officer['registrationDate'] != null)
                _buildDetailRow('Registered', _formatDate(officer['registrationDate'])),
              if (officer['lastLogin'] != null)
                _buildDetailRow('Last Login', _formatDate(officer['lastLogin'])),
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

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value?.toString() ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  Future<void> _deactivateOfficer(String officerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Deactivate Officer'),
        content: Text('Are you sure you want to deactivate this regional officer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await WhoService.deactivateRegionalOfficer(officerId);
        
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Officer deactivated successfully')),
          );
          _loadRegionalOfficers(selectedState);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${result['message']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deactivating officer: $e')),
        );
      }
    }
  }

  Future<void> _activateOfficer(String officerId) async {
    try {
      final result = await WhoService.updateRegionalOfficer(
        officerId: officerId,
        updates: {'isActive': true},
      );
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Officer activated successfully')),
        );
        _loadRegionalOfficers(selectedState);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error activating officer: $e')),
      );
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

class _AddRegionalOfficerDialog extends StatefulWidget {
  final List<String> states;
  final VoidCallback onOfficerAdded;

  const _AddRegionalOfficerDialog({
    required this.states,
    required this.onOfficerAdded,
  });

  @override
  _AddRegionalOfficerDialogState createState() => _AddRegionalOfficerDialogState();
}

class _AddRegionalOfficerDialogState extends State<_AddRegionalOfficerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _officerIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _designationController = TextEditingController();
  final _passwordController = TextEditingController();
  String? selectedState;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Regional Officer'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _officerIdController,
                decoration: InputDecoration(
                  labelText: 'Officer ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter officer ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedState,
                decoration: InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
                items: widget.states.map((state) {
                  return DropdownMenuItem(value: state, child: Text(state));
                }).toList(),
                onChanged: (value) => setState(() => selectedState = value),
                validator: (value) {
                  if (value == null) {
                    return 'Please select state';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _designationController,
                decoration: InputDecoration(
                  labelText: 'Designation',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter designation';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _addOfficer,
          child: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Add Officer'),
        ),
      ],
    );
  }

  Future<void> _addOfficer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final result = await WhoService.addRegionalOfficer(
        officerId: _officerIdController.text.trim(),
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        state: selectedState!,
        designation: _designationController.text.trim(),
        password: _passwordController.text,
      );

      if (result['success']) {
        Navigator.pop(context);
        widget.onOfficerAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Regional officer added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding officer: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}

class _EditRegionalOfficerDialog extends StatefulWidget {
  final Map<String, dynamic> officer;
  final List<String> states;
  final VoidCallback onOfficerUpdated;

  const _EditRegionalOfficerDialog({
    required this.officer,
    required this.states,
    required this.onOfficerUpdated,
  });

  @override
  _EditRegionalOfficerDialogState createState() => _EditRegionalOfficerDialogState();
}

class _EditRegionalOfficerDialogState extends State<_EditRegionalOfficerDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _designationController;
  String? selectedState;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.officer['fullName']);
    _emailController = TextEditingController(text: widget.officer['email']);
    _phoneController = TextEditingController(text: widget.officer['phone']);
    _designationController = TextEditingController(text: widget.officer['designation']);
    selectedState = widget.officer['state'];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Regional Officer'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedState,
                decoration: InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
                items: widget.states.map((state) {
                  return DropdownMenuItem(value: state, child: Text(state));
                }).toList(),
                onChanged: (value) => setState(() => selectedState = value),
                validator: (value) {
                  if (value == null) {
                    return 'Please select state';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _designationController,
                decoration: InputDecoration(
                  labelText: 'Designation',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter designation';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _updateOfficer,
          child: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Update'),
        ),
      ],
    );
  }

  Future<void> _updateOfficer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final updates = {
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'state': selectedState!,
        'designation': _designationController.text.trim(),
      };

      final result = await WhoService.updateRegionalOfficer(
        officerId: widget.officer['officerId'],
        updates: updates,
      );

      if (result['success']) {
        Navigator.pop(context);
        widget.onOfficerUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Regional officer updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating officer: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}