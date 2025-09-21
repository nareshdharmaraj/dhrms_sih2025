import 'package:flutter/material.dart';

class MedicationsScreen extends StatefulWidget {
  final Map<String, dynamic>? patientData;

  const MedicationsScreen({super.key, this.patientData});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final List<Map<String, dynamic>> _medications = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medications'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality can be added here
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: _medications.isEmpty
            ? _buildEmptyState()
            : _buildMedicationsList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMedicationDialog,
        backgroundColor: Colors.teal.shade600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Medication',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 120,
            color: Colors.teal.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Medications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Keep track of your medications and dosages',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddMedicationDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Medication'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _medications.length,
      itemBuilder: (context, index) {
        final medication = _medications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.medication,
                        color: Colors.teal.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${medication['dosage']} - ${medication['frequency']}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editMedication(index);
                        } else if (value == 'delete') {
                          _deleteMedication(index);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Edit'),
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
                    ),
                  ],
                ),
                if (medication['notes'] != null &&
                    medication['notes'].isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      medication['notes'],
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Chip(
                      label: Text(medication['type']),
                      backgroundColor: Colors.teal.shade50,
                      labelStyle: TextStyle(color: Colors.teal.shade700),
                    ),
                    const Spacer(),
                    Text(
                      'Started: ${medication['startDate']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddMedicationDialog() {
    _showMedicationDialog();
  }

  void _editMedication(int index) {
    final medication = _medications[index];
    _showMedicationDialog(isEdit: true, index: index, initialData: medication);
  }

  void _showMedicationDialog({
    bool isEdit = false,
    int? index,
    Map<String, dynamic>? initialData,
  }) {
    final nameController = TextEditingController(
      text: initialData?['name'] ?? '',
    );
    final dosageController = TextEditingController(
      text: initialData?['dosage'] ?? '',
    );
    final notesController = TextEditingController(
      text: initialData?['notes'] ?? '',
    );
    String selectedFrequency = initialData?['frequency'] ?? 'Once daily';
    String selectedType = initialData?['type'] ?? 'Tablet';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Medication' : 'Add Medication'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medication Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage (e.g., 500mg)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedFrequency,
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Once daily',
                      child: Text('Once daily'),
                    ),
                    DropdownMenuItem(
                      value: 'Twice daily',
                      child: Text('Twice daily'),
                    ),
                    DropdownMenuItem(
                      value: 'Three times daily',
                      child: Text('Three times daily'),
                    ),
                    DropdownMenuItem(
                      value: 'Four times daily',
                      child: Text('Four times daily'),
                    ),
                    DropdownMenuItem(
                      value: 'As needed',
                      child: Text('As needed'),
                    ),
                    DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedFrequency = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Tablet', child: Text('Tablet')),
                    DropdownMenuItem(value: 'Capsule', child: Text('Capsule')),
                    DropdownMenuItem(value: 'Liquid', child: Text('Liquid')),
                    DropdownMenuItem(
                      value: 'Injection',
                      child: Text('Injection'),
                    ),
                    DropdownMenuItem(
                      value: 'Cream/Ointment',
                      child: Text('Cream/Ointment'),
                    ),
                    DropdownMenuItem(value: 'Inhaler', child: Text('Inhaler')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  dosageController.text.isNotEmpty) {
                if (isEdit && index != null) {
                  _updateMedication(
                    index,
                    nameController.text,
                    dosageController.text,
                    selectedFrequency,
                    selectedType,
                    notesController.text,
                  );
                } else {
                  _addMedication(
                    nameController.text,
                    dosageController.text,
                    selectedFrequency,
                    selectedType,
                    notesController.text,
                  );
                }
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _addMedication(
    String name,
    String dosage,
    String frequency,
    String type,
    String notes,
  ) {
    setState(() {
      _medications.add({
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'type': type,
        'notes': notes,
        'startDate': DateTime.now().toString().split(' ')[0],
      });
    });
  }

  void _updateMedication(
    int index,
    String name,
    String dosage,
    String frequency,
    String type,
    String notes,
  ) {
    setState(() {
      _medications[index] = {
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'type': type,
        'notes': notes,
        'startDate':
            _medications[index]['startDate'], // Keep original start date
      };
    });
  }

  void _deleteMedication(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content: const Text('Are you sure you want to delete this medication?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _medications.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
