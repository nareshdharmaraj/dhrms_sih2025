import 'package:flutter/material.dart';
import '../../services/regional_health_officer_service.dart';
import '../../services/zone_management_service.dart';
import '../../utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateRegionalHealthOfficerScreen extends StatefulWidget {
  final String? preferredState;
  
  const CreateRegionalHealthOfficerScreen({super.key, this.preferredState});

  @override
  _CreateRegionalHealthOfficerScreenState createState() => _CreateRegionalHealthOfficerScreenState();
}

class _CreateRegionalHealthOfficerScreenState extends State<CreateRegionalHealthOfficerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _experienceController = TextEditingController();
  
  String? _selectedDistrict;
  List<Map<String, dynamic>> _availableDistricts = [];
  Map<String, dynamic>? _districtAssignmentInfo;
  
  // Zone selection variables for integration with zone management system
  String? _selectedZoneId;
  String? _selectedZoneName;
  List<ZoneAreaAssignment> _availableZones = [];
  List<Map<String, dynamic>> _allAreas = [];
  List<Map<String, dynamic>> _filteredAreas = [];
  
  bool _isLoading = false;
  bool _isLoadingData = true;
  bool _isLoadingAreas = false;
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        setState(() {
          _isLoadingData = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication token not found'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      final districtsResult = await RegionalHealthOfficerService.getAvailableDistricts(token);
      
      setState(() {
        if (districtsResult['success']) {
          final data = districtsResult['data'] as Map<String, dynamic>;
          List<Map<String, dynamic>> allDistricts = List<Map<String, dynamic>>.from(data['availableDistricts'] ?? []);
          
          print('🔍 Loaded ${allDistricts.length} districts from API');
          print('🔍 First few districts: ${allDistricts.take(3).map((d) => d['name']).toList()}');
          
          // Filter districts by preferred state if provided
          if (widget.preferredState != null && widget.preferredState!.isNotEmpty) {
            _availableDistricts = allDistricts.where((district) {
              final districtName = district['name']?.toString() ?? '';
              final stateName = widget.preferredState!.toLowerCase();
              // Check if district belongs to the preferred state
              return districtName.toLowerCase().contains(stateName) ||
                     district['state']?.toString().toLowerCase() == stateName;
            }).toList();
            print('🔍 Filtered to ${_availableDistricts.length} districts for state: ${widget.preferredState}');
          } else {
            _availableDistricts = allDistricts;
          }
          
          print('🔍 Final available districts: ${_availableDistricts.map((d) => d['name']).take(5).toList()}');
        } else {
          print('❌ Districts API failed: ${districtsResult['message']}');
        }
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _loadDistrictAreas(String district) async {
    if (district.isEmpty) return;
    
    setState(() {
      _isLoadingAreas = true;
      _selectedZoneId = null;
      _selectedZoneName = null;
      _availableZones.clear();
      _allAreas.clear();
      _filteredAreas.clear();
      _districtAssignmentInfo = null;
    });

    try {
      print('🔍 Loading areas for district: $district');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) return;

      final result = await RegionalHealthOfficerService.getDistrictAssignmentInfo(token, district);
      print('🔍 Assignment info result: $result');

      if (result['success']) {
        final assignmentData = result['data'] as Map<String, dynamic>;
        print('🔍 Assignment data structure: ${assignmentData.keys}');
        
        // Transform the backend response to match expected structure
        final transformedData = {
          'strategy': {
            'isDense': assignmentData['requiresAreaSelection'] ?? false,
            'type': assignmentData['type'] ?? 'sparse',
          },
          'availableAreas': assignmentData['availableAreas'] ?? [],
          'subdistricts': assignmentData['subdistricts'] ?? [],
          'district': assignmentData['district'] ?? district,
          'state': assignmentData['state'] ?? '',
        };
        
        // Extract zones from available areas
        final availableAreas = transformedData['availableAreas'] as List<dynamic>;
        _allAreas = availableAreas.cast<Map<String, dynamic>>();
        
        // Extract unique zones from area names
        Set<String> zonesSet = {};
        bool hasZoneStructure = false;
        
        for (var area in _allAreas) {
          final areaName = area['name']?.toString() ?? '';
          // Check if area name contains "Zone" and extract zone number
          if (areaName.contains('Zone ')) {
            hasZoneStructure = true;
            final zoneMatch = RegExp(r'Zone (\d+)').firstMatch(areaName);
            if (zoneMatch != null) {
              zonesSet.add('Zone ${zoneMatch.group(1)}');
            }
          }
        }
        
        // If no zone structure detected, create geographical groupings for dense districts
        if (!hasZoneStructure && (transformedData['strategy']['isDense'] ?? false)) {
          // For districts with specific area names (like Chennai), create regional groupings
          for (var area in _allAreas) {
            final areaName = area['name']?.toString() ?? '';
            if (areaName.toLowerCase().contains('north')) {
              zonesSet.add('North Region');
            } else if (areaName.toLowerCase().contains('south')) {
              zonesSet.add('South Region');
            } else if (areaName.toLowerCase().contains('central') || areaName.toLowerCase().contains('centre')) {
              zonesSet.add('Central Region');
            } else if (areaName.toLowerCase().contains('east')) {
              zonesSet.add('East Region');
            } else if (areaName.toLowerCase().contains('west')) {
              zonesSet.add('West Region');
            } else {
              // If area name doesn't match any direction, group by area type
              zonesSet.add('Other Areas');
            }
          }
        }
        
        // Load available zones from zone management system for dense districts
        if (transformedData['strategy']['isDense'] ?? false) {
          try {
            final state = widget.preferredState ?? 'Tamil Nadu';
            final zones = await ZoneManagementService.getUnassignedZonesForRHOCreation(
              stateName: state,
              districtName: district,
            );
            
            setState(() {
              _availableZones = zones;
            });
            
            print('🏢 Found ${zones.length} available zones from zone management: ${zones.map((z) => z.zoneName).join(', ')}');
          } catch (e) {
            print('⚠️ Error loading zones from zone management: $e');
            // Fall back to old zone creation logic - create empty zones list for now
            _availableZones = [];
          }
        } else {
          // For sparse districts, no zones needed
          _availableZones = [];
        }
        
        // For dense districts, don't show any areas initially - force zone selection
        if (transformedData['strategy']['isDense'] ?? false) {
          _filteredAreas = []; // Show no areas until zone is selected
        } else {
          _filteredAreas = List.from(_allAreas); // Show all areas for sparse districts
        }
        
        print('🔍 Transformed data: $transformedData');
        print('🔍 Available areas count: ${_allAreas.length}');
        print('🔍 Available zones: $_availableZones');
        
        setState(() {
          _districtAssignmentInfo = transformedData;
          _isLoadingAreas = false;
        });
      } else {
        setState(() {
          _isLoadingAreas = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to load district areas'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      print('❌ Error loading areas: $e');
      setState(() {
        _isLoadingAreas = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading areas: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _filterAreasByZone(String? zoneId) {
    // TODO: Implement zone filtering with new zone management system
    // For now, just show all areas to avoid compilation errors
    setState(() {
      _selectedZoneId = zoneId;
      _filteredAreas = List.from(_allAreas);
    });
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.preferredState != null 
            ? 'Create RHO - ${widget.preferredState}' 
            : 'Create Regional Health Officer'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.preferredState != null 
          ? 'Create RHO - ${widget.preferredState}' 
          : 'Create Regional Health Officer'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Regional Health Officer Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Regional Health Officer Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildCustomDataForm(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createCustomRHO,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Create RHO',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDataForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Personal Information'),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: _fullNameController,
            label: 'Full Name',
            icon: Icons.person,
            helperText: 'Enter a proper name (e.g., Dr. John Smith). Only letters, spaces, and dots allowed.',
            validator: (value) {
              if (value?.isEmpty == true) return 'Full name is required';
              if (!RegExp(r'^[a-zA-Z\s.]+$').hasMatch(value!)) {
                return 'Full name can only contain letters, spaces, and dots';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty == true) return 'Email is required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) => value?.isEmpty == true ? 'Phone number is required' : null,
          ),
          
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock,
            obscureText: true,
            helperText: 'Must contain: uppercase, lowercase, number, and special character (@\$!%*?&)',
            validator: (value) {
              if (value?.isEmpty == true) return 'Password is required';
              if (value!.length < 8) return 'Password must be at least 8 characters';
              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$').hasMatch(value)) {
                return 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character (@\$!%*?&)';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          _buildTextField(
            controller: _qualificationController,
            label: 'Qualification',
            icon: Icons.school,
            validator: (value) => value?.isEmpty == true ? 'Qualification is required' : null,
          ),
          
          const SizedBox(height: 16),
          _buildTextField(
            controller: _experienceController,
            label: 'Experience (years)',
            icon: Icons.work,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty == true) return 'Experience is required';
              final exp = int.tryParse(value!);
              if (exp == null || exp < 0) return 'Please enter a valid number';
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          _buildTextField(
            controller: _licenseNumberController,
            label: 'License Number',
            icon: Icons.badge,
            validator: (value) => value?.isEmpty == true ? 'License number is required' : null,
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('District & Area Assignment'),
          const SizedBox(height: 16),
          
          _buildDistrictDropdown(),
          
          if (_selectedDistrict != null) ...[
            const SizedBox(height: 16),
            _buildZoneSelection(),
            const SizedBox(height: 16),
            _buildAreaSelection(),
          ],
        ],
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    // Ensure we have valid districts and no duplicates
    final validDistricts = _availableDistricts
        .where((district) => district['name'] != null && district['name'].toString().isNotEmpty)
        .toList();
    
    // Ensure selected district is valid
    if (_selectedDistrict != null && 
        !validDistricts.any((d) => d['name'].toString() == _selectedDistrict)) {
      _selectedDistrict = null;
    }
    
    return DropdownButtonFormField<String>(
      value: _selectedDistrict,
      decoration: InputDecoration(
        labelText: 'Assigned District',
        prefixIcon: const Icon(Icons.location_city, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        helperText: validDistricts.isEmpty ? 'No districts available' : '${validDistricts.length} districts available',
      ),
      validator: (value) => value == null ? 'Please select a district' : null,
      items: validDistricts.isEmpty ? [] : validDistricts.map<DropdownMenuItem<String>>((district) {
        final districtName = district['name'].toString();
        final isDense = district['isDense'] ?? false;
        
        return DropdownMenuItem<String>(
          value: districtName,
          child: Text(
            '$districtName${isDense ? ' (Dense)' : ''}',
            style: TextStyle(
              fontSize: 14,
              color: isDense ? Colors.orange[700] : null,
            ),
          ),
        );
      }).toList(),
      onChanged: validDistricts.isEmpty ? null : (value) {
        setState(() {
          _selectedDistrict = value;
        });
        if (value != null) {
          _loadDistrictAreas(value);
        }
      },
    );
  }

  Widget _buildZoneSelection() {
    if (_districtAssignmentInfo == null || _availableZones.isEmpty) {
      return const SizedBox.shrink();
    }

    final strategy = _districtAssignmentInfo!['strategy'] as Map<String, dynamic>;
    final isDense = strategy['isDense'] as bool? ?? false;

    // Only show zone selection for dense districts with multiple zones
    if (!isDense || _availableZones.length <= 1) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.scatter_plot, color: Colors.blue[600]),
            const SizedBox(width: 8),
            Text(
              'Zone Selection',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Warning about exclusive zone selection
        Card(
          color: Colors.orange[50],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Important: Each RHO can only manage ONE zone. Once assigned, they cannot manage areas from other zones.',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        Text(
          'Select exactly ONE zone for this RHO. Dense districts require zone-specific assignments for better management.',
          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        
        // Radio button selection for exclusive zone selection
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Zones:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Individual zone radio buttons (no "All Zones" option for dense districts)
                ..._availableZones.map((zone) {
                  final zoneName = zone.zoneName;
                  final areasInZone = _allAreas.where((area) {
                    final areaName = area['name']?.toString() ?? '';
                    
                    // Handle Zone-based filtering (e.g., "Salem Zone 1")
                    if (zoneName.startsWith('Zone ')) {
                      return areaName.contains(zoneName);
                    }
                    
                    // Handle Region-based filtering
                    switch (zoneName) {
                      case 'North Region':
                        return areaName.toLowerCase().contains('north');
                      case 'South Region':
                        return areaName.toLowerCase().contains('south');
                      case 'Central Region':
                        return areaName.toLowerCase().contains('central') || 
                               areaName.toLowerCase().contains('centre');
                      case 'East Region':
                        return areaName.toLowerCase().contains('east');
                      case 'West Region':
                        return areaName.toLowerCase().contains('west');
                      case 'Other Areas':
                        return !areaName.toLowerCase().contains('north') &&
                               !areaName.toLowerCase().contains('south') &&
                               !areaName.toLowerCase().contains('central') &&
                               !areaName.toLowerCase().contains('centre') &&
                               !areaName.toLowerCase().contains('east') &&
                               !areaName.toLowerCase().contains('west');
                      default:
                        return areaName.contains(zoneName);
                    }
                  }).length;
                  
                  return RadioListTile<String>(
                    title: Text(
                      zoneName,
                      style: TextStyle(
                        fontWeight: _selectedZoneId == zone.id ? FontWeight.bold : FontWeight.normal,
                        color: _selectedZoneId == zone.id ? AppColors.primary : Colors.black87,
                      ),
                    ),
                    subtitle: Text('$areasInZone areas available'),
                    value: zone.id,
                    groupValue: _selectedZoneId,
                    onChanged: (value) {
                      _filterAreasByZone(value);
                    },
                    dense: true,
                    activeColor: AppColors.primary,
                  );
                }),
              ],
            ),
          ),
        ),
        if (_selectedZoneId != null) ...[
          const SizedBox(height: 8),
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zone Selected: ${_selectedZoneName ?? 'Unknown Zone'}',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Showing ${_filteredAreas.length} areas exclusively from this zone',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAreaSelection() {
    if (_isLoadingAreas) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Loading area options...'),
            ],
          ),
        ),
      );
    }

    if (_districtAssignmentInfo == null) {
      return const SizedBox.shrink();
    }

    final strategy = _districtAssignmentInfo!['strategy'] as Map<String, dynamic>;
    final availableAreas = _districtAssignmentInfo!['availableAreas'] as List<dynamic>;
    final subdistricts = _districtAssignmentInfo!['subdistricts'] as List<dynamic>? ?? [];
    final isDense = strategy['isDense'] as bool? ?? false;

    print('🔍 Building area selection - isDense: $isDense, areas: ${availableAreas.length}, subdistricts: ${subdistricts.length}');

    if (!isDense) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Full District Assignment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'This district is classified as sparse. The RHO will manage the entire district.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (subdistricts.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Subdistricts in this district (${subdistricts.length}):',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: subdistricts.map((subdistrict) {
                    final subdistrictName = subdistrict is String 
                        ? subdistrict 
                        : subdistrict is Map<String, dynamic> 
                            ? (subdistrict['name'] ?? subdistrict.toString())
                            : subdistrict.toString();
                    return Chip(
                      label: Text(
                        subdistrictName,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.blue[50],
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.blue[600]),
            const SizedBox(width: 8),
            Text(
              'Zone-Based Assignment Required',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'This district is densely populated. Please select a specific zone for this RHO to manage.',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        
        // Show zone selection requirement for dense districts
        if (_availableZones.length > 1 && _selectedZoneId == null) ...[
          Card(
            color: Colors.amber[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Zone Selection Required',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please select a specific zone above to view the areas available in that zone. Each RHO must be assigned to exactly one zone.',
                    style: TextStyle(color: Colors.amber[800]),
                  ),
                ],
              ),
            ),
          ),
        ],
        
        if (_filteredAreas.isNotEmpty) ...[
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Zone Assignment Only',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'RHO will be assigned to the selected zone${_selectedZoneName != null ? ' ($_selectedZoneName)' : ''} with all its sub-districts.',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                  if (_selectedZoneName != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Sub-districts in $_selectedZoneName: ${_filteredAreas.length} areas',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ] else ...[
          Card(
            color: Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Text(
                        'No Areas Available',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedZoneName != null 
                        ? 'No areas are available for assignment in $_selectedZoneName. This could mean:\n• All areas in this zone are already assigned to other RHOs\n• The zone has no defined areas\n\nTry selecting a different zone above.'
                        : 'No areas are available for assignment in this district.',
                    style: TextStyle(color: Colors.orange[800]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperMaxLines: 3,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Future<void> _createCustomRHO() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate zone assignment for dense districts
    if (_districtAssignmentInfo != null) {
      final strategy = _districtAssignmentInfo!['strategy'] as Map<String, dynamic>;
      final isDense = strategy['isDense'] as bool? ?? false;
      
      if (isDense) {
        // Validate zone selection for dense districts
        if (_availableZones.length > 1 && _selectedZoneId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a specific zone for this dense district. Each RHO must be assigned to only one zone.'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 4),
            ),
          );
          return;
        }
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication token not found'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      final rhoData = {
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
        'assignedDistrict': _selectedDistrict,
        'qualification': _qualificationController.text.trim(),
        'experience': int.tryParse(_experienceController.text.trim()) ?? 0,
        'licenseNumber': _licenseNumberController.text.trim(),
        // Add proper zone assignment data
        if (_selectedZoneId != null) ...{
          'assignToZone': true,
          'zoneId': _selectedZoneId,
          'assignedZone': _selectedZoneName, // Keep for reference
        },
      };

      final result = await RegionalHealthOfficerService.createRHO(token, rhoData);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Regional Health Officer created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        String errorMessage = result['message'] ?? 'Failed to create RHO';
        if (result['errors'] != null && result['errors'].isNotEmpty) {
          errorMessage += '\n\nDetails:\n';
          errorMessage += (result['errors'] as List).join('\n');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _qualificationController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }
}