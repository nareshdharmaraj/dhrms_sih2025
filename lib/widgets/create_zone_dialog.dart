import 'package:flutter/material.dart';
import '../services/zone_management_service.dart';

class CreateZoneDialog extends StatefulWidget {
  final String stateName;
  final String districtName;
  final List<String> availableAreas;
  final String shoId;
  final VoidCallback onZoneCreated;

  const CreateZoneDialog({
    super.key,
    required this.stateName,
    required this.districtName,
    required this.availableAreas,
    required this.shoId,
    required this.onZoneCreated,
  });

  @override
  State<CreateZoneDialog> createState() => _CreateZoneDialogState();
}

class _CreateZoneDialogState extends State<CreateZoneDialog> {
  final _formKey = GlobalKey<FormState>();
  final _zoneNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<String> selectedAreas = [];
  bool isCreatingZone = false;

  @override
  void dispose() {
    _zoneNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _createZone() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedAreas.isEmpty) {
      _showErrorSnackBar('Please select at least one area for the zone');
      return;
    }

    setState(() {
      isCreatingZone = true;
    });

    try {
      // Create zone without RHO assignment
      final result = await ZoneManagementService.createRHOZoneAssignment(
        rhoId: '', // No RHO assignment during creation
        rhoName: '', // No RHO assignment during creation
        stateName: widget.stateName,
        districtName: widget.districtName,
        assignedAreas: selectedAreas,
        zoneName: _zoneNameController.text.trim(),
        zoneDescription: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        createdBySHOId: widget.shoId,
      );

      if (result.success) {
        _showSuccessSnackBar('Zone created successfully! RHOs can now select this zone during their creation.');
        widget.onZoneCreated();
        Navigator.of(context).pop();
      } else {
        _showErrorSnackBar(result.message);
      }
    } catch (e) {
      _showErrorSnackBar('Error creating zone: $e');
    } finally {
      setState(() {
        isCreatingZone = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_location, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create New Zone',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.districtName}, ${widget.stateName}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          'RHO assignment will be done separately',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Zone Name
                      TextFormField(
                        controller: _zoneNameController,
                        decoration: const InputDecoration(
                          labelText: 'Zone Name *',
                          hintText: 'e.g., North Zone, Central Zone',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Zone name is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Brief description of the zone coverage',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Available Areas Selection
                      Text(
                        'Select Sub-districts for Zone * (${widget.districtName})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose which sub-districts this zone will include',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // Select All / Clear All buttons
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text('${selectedAreas.length} of ${widget.availableAreas.length} sub-districts selected'),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedAreas = List.from(widget.availableAreas);
                                      });
                                    },
                                    child: const Text('Select All'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedAreas.clear();
                                      });
                                    },
                                    child: const Text('Clear All'),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Areas list
                            Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: widget.availableAreas.length,
                                itemBuilder: (context, index) {
                                  final area = widget.availableAreas[index];
                                  final isSelected = selectedAreas.contains(area);
                                  
                                  return CheckboxListTile(
                                    title: Text(area),
                                    value: isSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedAreas.add(area);
                                        } else {
                                          selectedAreas.remove(area);
                                        }
                                      });
                                    },
                                    dense: true,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Info about RHO assignment
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Zones define administrative areas only. RHO assignment happens when creating RHOs - they will select which zone to manage during their creation process.',
                                style: TextStyle(color: Colors.blue),
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
            
            // Footer Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isCreatingZone ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isCreatingZone ? null : _createZone,
                      child: isCreatingZone
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('Creating...'),
                              ],
                            )
                          : const Text('Create Zone'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}