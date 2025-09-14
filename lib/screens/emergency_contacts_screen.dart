import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class EmergencyContactsScreen extends StatefulWidget {
  final Map<String, dynamic>? patientData;
  
  const EmergencyContactsScreen({super.key, this.patientData});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<EmergencyContact> _emergencyContacts = [];
  bool _isLoading = true;

  final List<PredefinedEmergencyService> _emergencyServices = [
    PredefinedEmergencyService(
      name: 'Ambulance Service',
      phone: '108',
      icon: Icons.local_hospital,
      color: Colors.red,
      description: 'Emergency medical services',
    ),
    PredefinedEmergencyService(
      name: 'Police Emergency',
      phone: '100',
      icon: Icons.local_police,
      color: Colors.blue,
      description: 'Police emergency services',
    ),
    PredefinedEmergencyService(
      name: 'Fire Department',
      phone: '101',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      description: 'Fire emergency services',
    ),
    PredefinedEmergencyService(
      name: 'Health Helpline',
      phone: '104',
      icon: Icons.health_and_safety,
      color: Colors.green,
      description: 'Health advisory services',
    ),
    PredefinedEmergencyService(
      name: 'National Emergency',
      phone: '112',
      icon: Icons.phone_in_talk,
      color: Colors.purple,
      description: 'National emergency number',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _loadEmergencyContacts();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadEmergencyContacts() {
    setState(() {
      _isLoading = true;
      _emergencyContacts.clear();
    });

    try {
      print('=== DEBUG: Loading Emergency Contacts ===');
      print('Patient data available: ${widget.patientData != null}');
      
      if (widget.patientData != null) {
        print('Patient data keys: ${widget.patientData!.keys.toList()}');
        
        // Check for single emergency contact from registration
        print('emergencyContact field: ${widget.patientData!['emergencyContact']}');
        if (widget.patientData!['emergencyContact'] != null) {
          final emergencyContact = widget.patientData!['emergencyContact'];
          print('Found registration emergency contact: $emergencyContact');
          
          _emergencyContacts.add(
            EmergencyContact(
              id: '1',
              name: emergencyContact['name'] ?? 'Unknown',
              phone: emergencyContact['phone'] ?? '',
              relationship: emergencyContact['relationship'] ?? '',
              type: _getContactType(emergencyContact['relationship'] ?? ''),
              isActive: true,
            ),
          );
          print('Added registration contact to list');
        } else {
          print('No emergencyContact field found in patient data');
        }

        // Check for multiple emergency contacts array
        print('emergencyContacts field: ${widget.patientData!['emergencyContacts']}');
        if (widget.patientData!['emergencyContacts'] != null) {
          final contacts = widget.patientData!['emergencyContacts'] as List;
          print('Found emergencyContacts array with ${contacts.length} contacts');
          
          for (int i = 0; i < contacts.length; i++) {
            final contact = contacts[i];
            print('Processing contact $i: $contact');
            
            _emergencyContacts.add(
              EmergencyContact(
                id: '${i + 2}', // Start from 2 to avoid ID conflicts
                name: contact['name'] ?? 'Unknown',
                phone: contact['phone'] ?? '',
                relationship: contact['relationship'] ?? '',
                type: _getContactType(contact['relationship'] ?? ''),
                isActive: true,
              ),
            );
          }
        } else {
          print('No emergencyContacts array found in patient data');
        }
        
        print('Total contacts loaded: ${_emergencyContacts.length}');
      } else {
        print('No patient data available');
      }
    } catch (e) {
      print('Error loading emergency contacts: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  EmergencyContactType _getContactType(String relationship) {
    final relationshipLower = relationship.toLowerCase();
    if (relationshipLower.contains('spouse') || relationshipLower.contains('husband') || 
        relationshipLower.contains('wife') || relationshipLower.contains('family') ||
        relationshipLower.contains('mother') || relationshipLower.contains('father') ||
        relationshipLower.contains('sister') || relationshipLower.contains('brother') ||
        relationshipLower.contains('son') || relationshipLower.contains('daughter')) {
      return EmergencyContactType.family;
    } else if (relationshipLower.contains('doctor') || relationshipLower.contains('physician') ||
               relationshipLower.contains('medical')) {
      return EmergencyContactType.doctor;
    } else if (relationshipLower.contains('friend')) {
      return EmergencyContactType.friend;
    } else if (relationshipLower.contains('colleague') || relationshipLower.contains('coworker')) {
      return EmergencyContactType.colleague;
    } else if (relationshipLower.contains('neighbor')) {
      return EmergencyContactType.neighbor;
    } else {
      return EmergencyContactType.other;
    }
  }

  Future<void> _saveEmergencyContactsToDatabase() async {
    if (widget.patientData == null) {
      print('Cannot save emergency contacts: No patient data available');
      return;
    }

    // Use the same logic as patient dashboard to find patient ID
    final patientId = widget.patientData!['uhid'] ?? 
                     widget.patientData!['patientId'] ??
                     widget.patientData!['patient_id'] ??
                     widget.patientData!['unique_id'] ??
                     widget.patientData!['healthId'] ??
                     widget.patientData!['health_id'] ??
                     widget.patientData!['UHID'] ??
                     widget.patientData!['_id'] ??
                     widget.patientData!['id'];

    if (patientId == null) {
      print('Cannot save emergency contacts: No patient ID found in data fields');
      print('Available fields: ${widget.patientData!.keys.toList()}');
      return;
    }

    try {
      // Get the first emergency contact (for database compatibility)
      EmergencyContact? primaryContact;
      if (_emergencyContacts.isNotEmpty) {
        primaryContact = _emergencyContacts.first;
      }

      if (primaryContact == null) {
        print('No emergency contacts to save');
        return;
      }

      // Save the first contact to emergencyContact field (for database compatibility)
      widget.patientData!['emergencyContact'] = {
        'name': primaryContact.name,
        'phone': primaryContact.phone,
        'relationship': primaryContact.relationship,
      };

      // Also save all contacts for local access - they're all equal now
      widget.patientData!['emergencyContacts'] = _emergencyContacts.map((contact) => {
        'name': contact.name,
        'phone': contact.phone,
        'relationship': contact.relationship,
        'type': contact.type.label,
        'isActive': contact.isActive,
      }).toList();

      print('Emergency contacts saved locally for patient ID: $patientId');
      print('All ${_emergencyContacts.length} contacts saved - no priority system');

      // Future: Add database persistence here when backend API is available
      // For now, contacts are saved in local session data
      
    } catch (e) {
      print('Error saving emergency contacts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade50,
              Colors.white,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: CustomScrollView(
                    slivers: [
                      _buildAppBar(),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildEmergencyServicesSection(),
                              const SizedBox(height: 30),
                              _buildPersonalContactsSection(),
                              const SizedBox(height: 100), // Space for FAB
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddContactDialog,
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Contact'),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.red.shade700,
                Colors.red.shade600,
                Colors.orange.shade500,
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red.shade700.withOpacity(0.9),
                      Colors.red.shade600.withOpacity(0.8),
                      Colors.orange.shade500.withOpacity(0.9),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.emergency,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Emergency Contacts',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Manage your emergency contacts',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.phone, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '${_emergencyContacts.where((c) => c.isActive).length} Active Contacts',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
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
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_hospital, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Emergency Services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          'Government emergency services available 24/7',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: _emergencyServices.length,
          itemBuilder: (context, index) {
            return _buildEmergencyServiceCard(_emergencyServices[index]);
          },
        ),
      ],
    );
  }

  Widget _buildEmergencyServiceCard(PredefinedEmergencyService service) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            service.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: service.color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: service.color.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _makeEmergencyCall(service.phone, service.name),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: service.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(service.icon, color: service.color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  service.phone,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: service.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Personal Emergency Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Emergency calls will be made to all your contacts in sequence',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Your trusted contacts who will be notified during emergencies',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 15),
        if (_isLoading)
          _buildLoadingCard()
        else if (_emergencyContacts.isEmpty)
          _buildEmptyContactsCard()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _emergencyContacts.length,
            itemBuilder: (context, index) {
              return _buildPersonalContactCard(_emergencyContacts[index], index);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyContactsCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.person_add_disabled, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Emergency Contacts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add trusted contacts who can be reached during emergencies',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showAddContactDialog,
            icon: const Icon(Icons.person_add),
            label: const Text('Add Your First Contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Emergency Contacts...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fetching your emergency contact information',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalContactCard(EmergencyContact contact, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: contact.isActive ? contact.type.color.withOpacity(0.3) : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: contact.isActive 
                ? contact.type.color.withOpacity(0.1) 
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: contact.isActive 
                    ? contact.type.color.withOpacity(0.1) 
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                contact.type.icon,
                color: contact.isActive ? contact.type.color : Colors.grey.shade400,
                size: 24,
              ),
            ),
          ],
        ),
        title: Text(
          contact.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: contact.isActive ? Colors.grey.shade800 : Colors.grey.shade500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact.phone,
              style: TextStyle(
                color: contact.isActive ? contact.type.color : Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: contact.isActive 
                        ? contact.type.color.withOpacity(0.1) 
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    contact.type.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: contact.isActive ? contact.type.color : Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (contact.relationship.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    contact.relationship,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleContactAction(value, contact, index),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'call',
              child: Row(
                children: [
                  Icon(Icons.phone, color: Colors.green.shade600, size: 18),
                  const SizedBox(width: 8),
                  const Text('Call'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue.shade600, size: 18),
                  const SizedBox(width: 8),
                  const Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: contact.isActive ? 'deactivate' : 'activate',
              child: Row(
                children: [
                  Icon(
                    contact.isActive ? Icons.visibility_off : Icons.visibility,
                    color: contact.isActive ? Colors.orange.shade600 : Colors.green.shade600,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(contact.isActive ? 'Deactivate' : 'Activate'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red.shade600, size: 18),
                  const SizedBox(width: 8),
                  const Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: contact.isActive ? () => _makeEmergencyCall(contact.phone, contact.name) : null,
      ),
    );
  }

  void _handleContactAction(String action, EmergencyContact contact, int index) {
    switch (action) {
      case 'call':
        _makeEmergencyCall(contact.phone, contact.name);
        break;
      case 'edit':
        _showEditContactDialog(contact, index);
        break;
      case 'activate':
      case 'deactivate':
        _toggleContactStatus(index);
        break;
      case 'delete':
        _showDeleteConfirmation(index);
        break;
    }
  }

  void _makeEmergencyCall(String phone, String name) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $name at $phone...'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Cancel',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _toggleContactStatus(int index) {
    setState(() {
      _emergencyContacts[index] = _emergencyContacts[index].copyWith(
        isActive: !_emergencyContacts[index].isActive,
      );
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _emergencyContacts[index].isActive
              ? 'Contact activated'
              : 'Contact deactivated',
        ),
        backgroundColor: _emergencyContacts[index].isActive ? Colors.green : Colors.orange,
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text(
          'Are you sure you want to delete ${_emergencyContacts[index].name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _emergencyContacts.removeAt(index);
              });
              
              // Save to database
              await _saveEmergencyContactsToDatabase();
              
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddContactDialog() {
    _showContactDialog();
  }

  void _showEditContactDialog(EmergencyContact contact, int index) {
    _showContactDialog(contact: contact, index: index);
  }

  void _showContactDialog({EmergencyContact? contact, int? index}) {
    final isEditing = contact != null;
    final nameController = TextEditingController(text: contact?.name ?? '');
    final phoneController = TextEditingController(text: contact?.phone ?? '');
    final relationshipController = TextEditingController(text: contact?.relationship ?? '');
    EmergencyContactType selectedType = contact?.type ?? EmergencyContactType.family;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isEditing ? Icons.edit : Icons.person_add,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isEditing ? 'Edit Contact' : 'Add Emergency Contact',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: relationshipController,
                        decoration: const InputDecoration(
                          labelText: 'Relationship (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.family_restroom),
                          hintText: 'e.g., Spouse, Father, Doctor',
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Contact Type',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        children: EmergencyContactType.values.map((type) {
                          return ChoiceChip(
                            label: Text(type.label),
                            selected: selectedType == type,
                            onSelected: (selected) {
                              if (selected) {
                                setDialogState(() {
                                  selectedType = type;
                                });
                              }
                            },
                            selectedColor: type.color.withOpacity(0.2),
                            checkmarkColor: type.color,
                          );
                        }).toList(),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                              final newContact = EmergencyContact(
                                id: contact?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                name: nameController.text,
                                phone: phoneController.text,
                                type: selectedType,
                                relationship: relationshipController.text,
                                isActive: true,
                              );

                              setState(() {
                                if (isEditing && index != null) {
                                  _emergencyContacts[index] = newContact;
                                } else {
                                  _emergencyContacts.add(newContact);
                                }
                                // No sorting needed since no priority system
                              });

                              // Save to database
                              await _saveEmergencyContactsToDatabase();

                              Navigator.pop(context);
                              HapticFeedback.lightImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEditing ? 'Contact updated successfully' : 'Contact added successfully',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(isEditing ? 'Update Contact' : 'Add Contact'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Data models
class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final EmergencyContactType type;
  final String relationship;
  final bool isActive;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    this.relationship = '',
    this.isActive = true,
  });

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phone,
    EmergencyContactType? type,
    String? relationship,
    bool? isActive,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      relationship: relationship ?? this.relationship,
      isActive: isActive ?? this.isActive,
    );
  }
}

enum EmergencyContactType {
  family(label: 'Family', icon: Icons.family_restroom, color: Colors.blue),
  friend(label: 'Friend', icon: Icons.people, color: Colors.green),
  doctor(label: 'Doctor', icon: Icons.medical_services, color: Colors.red),
  colleague(label: 'Colleague', icon: Icons.work, color: Colors.orange),
  neighbor(label: 'Neighbor', icon: Icons.home, color: Colors.purple),
  other(label: 'Other', icon: Icons.person, color: Colors.grey);

  const EmergencyContactType({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

class PredefinedEmergencyService {
  final String name;
  final String phone;
  final IconData icon;
  final Color color;
  final String description;

  const PredefinedEmergencyService({
    required this.name,
    required this.phone,
    required this.icon,
    required this.color,
    required this.description,
  });
}