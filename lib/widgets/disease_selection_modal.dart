import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DiseaseSelectionModal extends StatefulWidget {
  final List<Map<String, dynamic>> initialSelectedDiseases;
  final Function(Map<String, dynamic>) onDiseasesSelected;

  const DiseaseSelectionModal({
    super.key,
    required this.initialSelectedDiseases,
    required this.onDiseasesSelected,
  });

  @override
  State<DiseaseSelectionModal> createState() => _DiseaseSelectionModalState();
}

class _DiseaseSelectionModalState extends State<DiseaseSelectionModal> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customDiseaseController =
      TextEditingController();
  final TextEditingController _recoveryDaysController = TextEditingController();

  List<String> _allDiseases = [];
  List<String> _filteredDiseases = [];
  List<Map<String, dynamic>> _selectedDiseases = [];
  bool _isLoading = true;
  bool _showCustomInput = false;
  String _errorMessage = '';
  String _diseaseType = 'not_communicable';
  int? _expectedRecoveryDays;

  @override
  void initState() {
    super.initState();
    _selectedDiseases = List.from(widget.initialSelectedDiseases);
    _fetchDiseases();
    _searchController.addListener(_filterDiseases);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customDiseaseController.dispose();
    _recoveryDaysController.dispose();
    super.dispose();
  }

  Future<void> _fetchDiseases() async {
    try {
      const String apiUrl = 'http://localhost:3000/api/diseases';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _allDiseases = List<String>.from(data['data']);
          _filteredDiseases = List.from(_allDiseases);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load diseases';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: Unable to fetch diseases';
        _isLoading = false;
      });
    }
  }

  void _filterDiseases() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredDiseases = List.from(_allDiseases);
      } else {
        _filteredDiseases = _allDiseases
            .where((disease) => disease.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _toggleDiseaseSelection(String diseaseName) {
    setState(() {
      final existingIndex = _selectedDiseases.indexWhere(
        (disease) => disease['name'] == diseaseName,
      );

      if (existingIndex >= 0) {
        _selectedDiseases.removeAt(existingIndex);
      } else {
        _selectedDiseases.add({'name': diseaseName, 'isCustom': false});
      }
    });
  }

  void _addCustomDisease() {
    final customDisease = _customDiseaseController.text.trim();
    if (customDisease.isEmpty) return;

    setState(() {
      // Check if already exists
      final existingIndex = _selectedDiseases.indexWhere(
        (disease) =>
            disease['name'].toLowerCase() == customDisease.toLowerCase(),
      );

      if (existingIndex < 0) {
        _selectedDiseases.add({'name': customDisease, 'isCustom': true});
      }
      _customDiseaseController.clear();
      _showCustomInput = false;
    });
  }

  void _removeSelectedDisease(int index) {
    setState(() {
      _selectedDiseases.removeAt(index);
    });
  }

  bool _isDiseaseSelected(String diseaseName) {
    return _selectedDiseases.any((disease) => disease['name'] == diseaseName);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.medical_information, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Select Diseases',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search diseases...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // Selected Diseases Chips
            if (_selectedDiseases.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selected (${_selectedDiseases.length}):',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedDiseases.length,
                  itemBuilder: (context, index) {
                    final disease = _selectedDiseases[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(
                          disease['name'],
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: disease['isCustom']
                            ? Colors.orange.shade100
                            : Colors.blue.shade100,
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeSelectedDisease(index),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Diseases List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error,
                            size: 48,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red.shade600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchDiseases,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount:
                          _filteredDiseases.length +
                          1, // +1 for "Others" option
                      itemBuilder: (context, index) {
                        if (index == _filteredDiseases.length) {
                          // "Others" option
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            child: ListTile(
                              leading: Icon(
                                Icons.add,
                                color: Colors.orange.shade600,
                              ),
                              title: const Text(
                                'Others (Enter Manually)',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                              onTap: () {
                                setState(() {
                                  _showCustomInput = !_showCustomInput;
                                });
                              },
                            ),
                          );
                        }

                        final disease = _filteredDiseases[index];
                        final isSelected = _isDiseaseSelected(disease);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          color: isSelected ? Colors.blue.shade50 : null,
                          child: ListTile(
                            leading: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: isSelected
                                  ? Colors.blue.shade700
                                  : Colors.grey,
                            ),
                            title: Text(
                              disease,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected ? Colors.blue.shade700 : null,
                              ),
                            ),
                            onTap: () => _toggleDiseaseSelection(disease),
                          ),
                        );
                      },
                    ),
            ),

            // Custom Disease Input
            if (_showCustomInput) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _customDiseaseController,
                      decoration: const InputDecoration(
                        hintText: 'Enter custom disease name...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _addCustomDisease(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showCustomInput = false;
                              _customDiseaseController.clear();
                            });
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addCustomDisease,
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Disease Type Selection
            if (_selectedDiseases.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Disease Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Communicable'),
                      value: 'communicable',
                      groupValue: _diseaseType,
                      onChanged: (value) {
                        setState(() {
                          _diseaseType = value!;
                          if (value == 'not_communicable') {
                            _recoveryDaysController.clear();
                            _expectedRecoveryDays = 0;
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Non-Communicable'),
                      value: 'not_communicable',
                      groupValue: _diseaseType,
                      onChanged: (value) {
                        setState(() {
                          _diseaseType = value!;
                          _recoveryDaysController.clear();
                          _expectedRecoveryDays = 0;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              // Expected Recovery Days for Communicable Diseases
              if (_diseaseType == 'communicable') ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _recoveryDaysController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Expected Recovery Days',
                    hintText: 'Enter number of days (1-100)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                    helperText: 'Required for communicable diseases',
                  ),
                ),
              ],
            ],

            // Action Buttons
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedDiseases.isEmpty
                        ? null
                        : () {
                            // Validate recovery days for communicable diseases
                            if (_diseaseType == 'communicable') {
                              final days = int.tryParse(
                                _recoveryDaysController.text,
                              );
                              if (days == null || days < 1 || days > 100) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Please enter valid recovery days (1-100) for communicable diseases',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              _expectedRecoveryDays = days;
                            } else {
                              // Set default value for non-communicable diseases
                              _expectedRecoveryDays = 0;
                            }

                            final result = {
                              'diseases': _selectedDiseases,
                              'diseaseType': _diseaseType,
                              'expectedRecoveryDays': _expectedRecoveryDays,
                            };

                            widget.onDiseasesSelected(result);
                            Navigator.of(context).pop();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Confirm (${_selectedDiseases.length})'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
