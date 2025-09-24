import 'package:flutter/material.dart';
import '../../services/zone_management_service.dart';
import '../../models/sho.dart';
import '../../widgets/create_zone_dialog.dart';
import '../../data/indian_states_districts_data.dart';

/// Screen for SHOs to manage RHO zone assignments in densely populated districts
/// Shows available areas and allows creation of zone-wise RHO assignments
/// State is auto-detected based on SHO profile
class ZoneManagementScreen extends StatefulWidget {
  final SHO sho;
  
  const ZoneManagementScreen({super.key, required this.sho});

  @override
  State<ZoneManagementScreen> createState() => _ZoneManagementScreenState();
}

class _ZoneManagementScreenState extends State<ZoneManagementScreen> {
  String? selectedState;
  String? selectedDistrict;
  ZoneAvailableAreasResult? availableAreasResult;
  bool isLoading = false;
  bool isLoadingSHOProfile = true;
  Map<String, dynamic>? shoProfile;
  
  final List<String> denselyPopulatedStates = ['Maharashtra', 'Tamil Nadu', 'Karnataka', 'Gujarat', 'West Bengal', 'Kerala', 'Andhra Pradesh'];

  @override
  void initState() {
    super.initState();
    _loadSHOProfile();
  }

  Future<void> _loadSHOProfile() async {
    setState(() {
      isLoadingSHOProfile = true;
    });

    try {
      // Use the passed SHO object directly instead of making API call
      setState(() {
        shoProfile = {
          'shoId': widget.sho.id,
          'name': widget.sho.fullName,
          'state': widget.sho.assignedState, // Real state from logged-in SHO
          'district': '', // District not needed for zone management
        };
        selectedState = widget.sho.assignedState;
        isLoadingSHOProfile = false;
      });
      
      print('🔍 SHO Profile loaded - State: $selectedState');
      print('🔍 SHO Profile data: $shoProfile');
    } catch (e) {
      setState(() {
        isLoadingSHOProfile = false;
      });
      _showErrorSnackBar('Error loading SHO profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zone Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: isLoadingSHOProfile
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading SHO profile...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info Card
                  _buildHeaderInfoCard(),
                  const SizedBox(height: 16),
                  
                  // State and District Selection Card
                  _buildLocationSelectionCard(),
                  const SizedBox(height: 16),
                  
                  // Available Areas Results
                  if (availableAreasResult != null) ...[
                    _buildZoneManagementContent(availableAreasResult!),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Zone Management Workflow',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                _buildWorkflowStep('1', 'Create zones by defining areas/sub-districts'),
                _buildWorkflowStep('2', 'Create RHOs who will select zones to manage'),
                _buildWorkflowStep('3', 'Zone assignment happens during RHO creation'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowStep(String step, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelectionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location Selection',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            
            // State Display
            _buildStateDisplay(),
            
            if (selectedState != null && !denselyPopulatedStates.contains(selectedState)) ...[
              const SizedBox(height: 16),
              _buildNonDenseStateInfo(),
            ],
            
            if (selectedState != null && denselyPopulatedStates.contains(selectedState)) ...[
              const SizedBox(height: 20),
              _buildDistrictSelection(),
              
              if (selectedDistrict != null) ...[
                const SizedBox(height: 20),
                _buildLoadAreasButton(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStateDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Assigned State',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                selectedState ?? 'Loading...',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (selectedState != null && denselyPopulatedStates.contains(selectedState))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Zone Management Available',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNonDenseStateInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.amber.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zone Management Not Required',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your state ($selectedState) uses direct RHO assignment. Zone management is only available for densely populated states.',
                  style: TextStyle(
                    color: Colors.amber.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select District',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<String>>(
          future: _getDenselyPopulatedDistricts(selectedState!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Loading districts...'),
                  ],
                ),
              );
            }
            
            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Error: ${snapshot.error}'),
              );
            }
            
            final districts = snapshot.data ?? [];
            
            return DropdownButtonFormField<String>(
              initialValue: selectedDistrict,
              decoration: InputDecoration(
                hintText: 'Choose a densely populated district',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.location_city),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: districts.map((district) {
                return DropdownMenuItem(
                  value: district,
                  child: Text(district),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDistrict = value;
                  availableAreasResult = null;
                });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadAreasButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : _loadAvailableAreas,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.search),
        label: Text(
          isLoading ? 'Loading Sub-districts...' : 'Load Available Sub-districts',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildZoneManagementContent(ZoneAvailableAreasResult result) {
    return Column(
      children: [
        // Zone Management Actions
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Create New Zone',
                subtitle: '${result.unassignedAreas.length} areas available',
                icon: Icons.add_location_alt,
                color: Colors.green,
                onTap: () => _showCreateZoneDialog(result.unassignedAreas),
                isEnabled: result.unassignedAreas.isNotEmpty,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'View All Zones',
                subtitle: '${result.existingZoneAssignments.length} zones total',
                icon: Icons.grid_view,
                color: Colors.blue,
                onTap: () => _showAllZonesDialog(result.existingZoneAssignments),
                isEnabled: result.existingZoneAssignments.isNotEmpty,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Statistics Overview
        _buildStatisticsCard(result),
        
        const SizedBox(height: 20),
        
        // Available Areas Section
        if (result.unassignedAreas.isNotEmpty) 
          _buildAvailableAreasSection(result.unassignedAreas),
        
        const SizedBox(height: 16),
        
        // Existing Zones Section
        if (result.existingZoneAssignments.isNotEmpty)
          _buildExistingZonesSection(result.existingZoneAssignments),
          
        // Empty state if no data
        if (result.unassignedAreas.isEmpty && result.existingZoneAssignments.isEmpty)
          _buildEmptyState(),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEnabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isEnabled ? color : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios, 
                  color: isEnabled ? color : Colors.grey, 
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isEnabled 
                    ? (color is MaterialColor ? color.shade800 : color)
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: isEnabled 
                    ? (color is MaterialColor ? color.shade600 : color)
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(ZoneAvailableAreasResult result) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.purple.shade600, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Zone Management Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    title: 'Available Areas',
                    value: result.unassignedAreas.length.toString(),
                    icon: Icons.location_city,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    title: 'Total Zones',
                    value: result.existingZoneAssignments.length.toString(),
                    icon: Icons.group_work,
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    title: 'Coverage',
                    value: '${result.coveragePercentage.toStringAsFixed(0)}%',
                    icon: Icons.pie_chart,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color is MaterialColor ? color.shade700 : color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color is MaterialColor ? color.shade600 : color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableAreasSection(List<String> availableAreas) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_city, color: Colors.green.shade600, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Available Sub-districts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${availableAreas.length} available',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'These sub-districts are not yet assigned to any zone and can be grouped together.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableAreas.map((area) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.place, size: 16, color: Colors.green.shade600),
                          const SizedBox(width: 6),
                          Text(
                            area,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingZonesSection(List<ZoneAreaAssignment> zones) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.group_work, color: Colors.blue.shade600, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Existing Zones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${zones.length} zones',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: zones.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final zone = zones[index];
                return _buildZoneCard(zone);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneCard(ZoneAreaAssignment zone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.group_work, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.zoneName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Text(
                      'RHO: ${zone.rhoName} • ${zone.assignedAreas.length} sub-districts',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showZoneDetailsDialog(zone),
                    icon: Icon(Icons.info_outline, color: Colors.blue.shade600),
                    tooltip: 'View Zone Details',
                  ),
                  IconButton(
                    onPressed: () => _showDeleteZoneDialog(zone),
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade600),
                    tooltip: 'Delete Zone',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...zone.assignedAreas.take(3).map((area) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.shade300),
                  ),
                  child: Text(
                    area,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                );
              }),
              if (zone.assignedAreas.length > 3)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+${zone.assignedAreas.length - 3} more',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Zone Data Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No zone data available for this district. Check back later or create new zones.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _getDenselyPopulatedDistricts(String stateName) async {
    // Get districts for the state that are densely populated
    final districts = IndianStatesDistrictsData.getDistrictsForState(stateName);
    return districts
        .where((district) => district.isDenselyPopulated)
        .map((district) => district.name)
        .toList();
  }

  Future<void> _loadAvailableAreas() async {
    if (selectedState == null || selectedDistrict == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final result = await ZoneManagementService.getAvailableAreasForDistrict(
        stateName: selectedState!,
        districtName: selectedDistrict!,
      );

      setState(() {
        availableAreasResult = result;
        isLoading = false;
      });

      if (!result.success) {
        _showErrorSnackBar(result.message ?? 'Failed to load areas');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Error loading areas: $e');
    }
  }


  void _showCreateZoneDialog(List<String> availableAreas) {
    showDialog(
      context: context,
      builder: (context) => CreateZoneDialog(
        stateName: selectedState!,
        districtName: selectedDistrict!,
        availableAreas: availableAreas,
        shoId: widget.sho.id,
        onZoneCreated: () {
          _loadAvailableAreas(); // Refresh data
        },
      ),
    );
  }

  void _showAllZonesDialog(List<ZoneAreaAssignment> zones) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('All Zones (${zones.length})'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.separated(
            itemCount: zones.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final zone = zones[index];
              return ListTile(
                title: Text(zone.zoneName),
                subtitle: Text('RHO: ${zone.rhoName}\n${zone.assignedAreas.length} areas'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info, color: Colors.blue),
                      onPressed: () => _showZoneDetailsDialog(zone),
                      tooltip: 'View Details',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteZoneDialog(zone),
                      tooltip: 'Delete Zone',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showZoneDetailsDialog(ZoneAreaAssignment zone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(zone.zoneName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('RHO: ${zone.rhoName}'),
              const SizedBox(height: 8),
              Text('District: ${zone.districtName}'),
              const SizedBox(height: 8),
              if (zone.zoneDescription != null && zone.zoneDescription!.isNotEmpty) ...[
                Text('Description: ${zone.zoneDescription}'),
                const SizedBox(height: 8),
              ],
              Text('Areas (${zone.assignedAreas.length}):'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: zone.assignedAreas.map((area) => Chip(
                  label: Text(area),
                  backgroundColor: Colors.blue.shade100,
                )).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteZoneDialog(ZoneAreaAssignment assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade600, size: 24),
            const SizedBox(width: 12),
            const Text('Delete Zone'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete the zone "${assignment.zoneName}"?',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'This will:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Unassign RHO: ${assignment.rhoName}',
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                  Text(
                    '• Free up ${assignment.assignedAreas.length} sub-districts',
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                  Text(
                    '• Deactivate the zone permanently',
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Note: The areas will become available for new zone assignments.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteZone(assignment),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Zone'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteZone(ZoneAreaAssignment assignment) async {
    Navigator.pop(context); // Close dialog
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Deleting zone "${assignment.zoneName}"...'),
          ],
        ),
      ),
    );
    
    try {
      final result = await ZoneManagementService.deleteRHOZoneAssignment(
        zoneId: assignment.id,
        deletedBySHOId: widget.sho.id, // Use actual SHO ID
      );
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      if (result.success) {
        _showSuccessSnackBar('Zone "${assignment.zoneName}" deleted successfully');
        _loadAvailableAreas(); // Refresh data to show updated state
      } else {
        _showErrorSnackBar(result.message);
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      _showErrorSnackBar('Error deleting zone: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Include the CreateZoneDialog here with sub-district based creation
// (This would be the same as previously implemented)