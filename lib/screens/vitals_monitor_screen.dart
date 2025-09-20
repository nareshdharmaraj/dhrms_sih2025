import 'package:flutter/material.dart';

class VitalsMonitorScreen extends StatefulWidget {
  final Map<String, dynamic>? patientData;

  const VitalsMonitorScreen({super.key, this.patientData});

  @override
  State<VitalsMonitorScreen> createState() => _VitalsMonitorScreenState();
}

class _VitalsMonitorScreenState extends State<VitalsMonitorScreen> {
  final List<Map<String, dynamic>> _vitalRecords = [];
  String _selectedPeriod = '7 days';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vitals Monitor'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '24 hours', child: Text('Last 24 Hours')),
              const PopupMenuItem(value: '7 days', child: Text('Last 7 Days')),
              const PopupMenuItem(value: '30 days', child: Text('Last 30 Days')),
              const PopupMenuItem(value: '3 months', child: Text('Last 3 Months')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade50, Colors.white],
          ),
        ),
        child: _vitalRecords.isEmpty ? _buildEmptyState() : _buildVitalsList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVitalDialog,
        backgroundColor: Colors.red.shade600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Reading', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.monitor_heart_outlined,
            size: 120,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Vital Records',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Track your vital signs and health metrics',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _loadSampleData,
                icon: const Icon(Icons.refresh),
                label: const Text('Load Sample'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddVitalDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Reading'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsList() {
    return Column(
      children: [
        _buildVitalsSummary(),
        Expanded(child: _buildVitalsHistory()),
      ],
    );
  }

  Widget _buildVitalsSummary() {
    if (_vitalRecords.isEmpty) return const SizedBox.shrink();

    final latest = _vitalRecords.first;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest Reading',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildVitalCard('Blood Pressure', '${latest['systolic']}/${latest['diastolic']}', 'mmHg', Icons.favorite, Colors.red),
              _buildVitalCard('Heart Rate', '${latest['heartRate']}', 'bpm', Icons.monitor_heart, Colors.pink),
              _buildVitalCard('Temperature', '${latest['temperature']}', '°F', Icons.thermostat, Colors.orange),
              _buildVitalCard('Weight', '${latest['weight']}', 'lbs', Icons.monitor_weight, Colors.blue),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Recorded on ${latest['date']} at ${latest['time']}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCard(String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsHistory() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'History ($_selectedPeriod)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _vitalRecords.length,
              itemBuilder: (context, index) {
                final record = _vitalRecords[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.monitor_heart,
                              color: Colors.red.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${record['date']} - ${record['time']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            PopupMenuButton(
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _deleteRecord(index);
                                } else if (value == 'edit') {
                                  _editRecord(index);
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
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMiniVitalCard('BP', '${record['systolic']}/${record['diastolic']}', Colors.red),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMiniVitalCard('HR', '${record['heartRate']} bpm', Colors.pink),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMiniVitalCard('Temp', '${record['temperature']}°F', Colors.orange),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMiniVitalCard('Weight', '${record['weight']} lbs', Colors.blue),
                            ),
                          ],
                        ),
                        if (record['notes'] != null && record['notes'].isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Notes: ${record['notes']}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniVitalCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddVitalDialog() {
    _showVitalDialog();
  }

  void _editRecord(int index) {
    final record = _vitalRecords[index];
    _showVitalDialog(isEdit: true, index: index, initialData: record);
  }

  void _showVitalDialog({
    bool isEdit = false,
    int? index,
    Map<String, dynamic>? initialData,
  }) {
    final systolicController = TextEditingController(text: initialData?['systolic']?.toString() ?? '');
    final diastolicController = TextEditingController(text: initialData?['diastolic']?.toString() ?? '');
    final heartRateController = TextEditingController(text: initialData?['heartRate']?.toString() ?? '');
    final temperatureController = TextEditingController(text: initialData?['temperature']?.toString() ?? '');
    final weightController = TextEditingController(text: initialData?['weight']?.toString() ?? '');
    final notesController = TextEditingController(text: initialData?['notes'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Vital Reading' : 'Add Vital Reading'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: systolicController,
                      decoration: const InputDecoration(
                        labelText: 'Systolic BP',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: diastolicController,
                      decoration: const InputDecoration(
                        labelText: 'Diastolic BP',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: heartRateController,
                decoration: const InputDecoration(
                  labelText: 'Heart Rate (bpm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: temperatureController,
                      decoration: const InputDecoration(
                        labelText: 'Temperature (°F)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight (lbs)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (systolicController.text.isNotEmpty &&
                  diastolicController.text.isNotEmpty &&
                  heartRateController.text.isNotEmpty &&
                  temperatureController.text.isNotEmpty &&
                  weightController.text.isNotEmpty) {
                
                if (isEdit && index != null) {
                  _updateRecord(
                    index,
                    int.parse(systolicController.text),
                    int.parse(diastolicController.text),
                    int.parse(heartRateController.text),
                    double.parse(temperatureController.text),
                    double.parse(weightController.text),
                    notesController.text,
                  );
                } else {
                  _addRecord(
                    int.parse(systolicController.text),
                    int.parse(diastolicController.text),
                    int.parse(heartRateController.text),
                    double.parse(temperatureController.text),
                    double.parse(weightController.text),
                    notesController.text,
                  );
                }
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _addRecord(int systolic, int diastolic, int heartRate, double temperature, double weight, String notes) {
    final now = DateTime.now();
    setState(() {
      _vitalRecords.insert(0, {
        'systolic': systolic,
        'diastolic': diastolic,
        'heartRate': heartRate,
        'temperature': temperature,
        'weight': weight,
        'notes': notes,
        'date': '${now.day}/${now.month}/${now.year}',
        'time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        'timestamp': now,
      });
    });
  }

  void _updateRecord(int index, int systolic, int diastolic, int heartRate, double temperature, double weight, String notes) {
    setState(() {
      _vitalRecords[index] = {
        ..._vitalRecords[index],
        'systolic': systolic,
        'diastolic': diastolic,
        'heartRate': heartRate,
        'temperature': temperature,
        'weight': weight,
        'notes': notes,
      };
    });
  }

  void _deleteRecord(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this vital record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _vitalRecords.removeAt(index);
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

  void _loadSampleData() {
    setState(() {
      _vitalRecords.clear();
      final now = DateTime.now();
      
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        _vitalRecords.add({
          'systolic': 120 + (i * 2),
          'diastolic': 80 + i,
          'heartRate': 72 + (i * 3),
          'temperature': 98.6 + (i * 0.1),
          'weight': 150.0 + (i * 0.5),
          'notes': i == 0 ? 'Feeling good today' : '',
          'date': '${date.day}/${date.month}/${date.year}',
          'time': '${(8 + i).toString().padLeft(2, '0')}:00',
          'timestamp': date,
        });
      }
    });
  }
}