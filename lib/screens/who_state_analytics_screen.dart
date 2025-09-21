import 'package:flutter/material.dart';
import '../models/who_admin.dart';
import '../services/who_service.dart';

class WhoStateAnalyticsScreen extends StatefulWidget {
  final WhoAdmin whoAdmin;

  const WhoStateAnalyticsScreen({super.key, required this.whoAdmin});

  @override
  _WhoStateAnalyticsScreenState createState() => _WhoStateAnalyticsScreenState();
}

class _WhoStateAnalyticsScreenState extends State<WhoStateAnalyticsScreen> 
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  List<StateStatistics> stateStats = [];
  String? error;
  String? selectedState;
  late TabController _tabController;

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
    _tabController = TabController(length: 4, vsync: this);
    _loadStateStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStateStatistics() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final result = await WhoService.getAllStatesStatistics();
      
      if (result['success']) {
        setState(() {
          stateStats = result['stateStats'];
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
        error = 'Failed to load state statistics: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('State Analytics'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadStateStatistics,
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _showExportDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Hospitals'),
            Tab(text: 'Patients'),
            Tab(text: 'Demographics'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildStateSelector(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : error != null
                ? _buildErrorWidget()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildHospitalsTab(),
                      _buildPatientsTab(),
                      _buildDemographicsTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: DropdownButtonFormField<String>(
        initialValue: selectedState,
        decoration: InputDecoration(
          labelText: 'Select State for Detailed View',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items: ['ALL', ...indianStates.where((s) => s != 'ALL')].map((state) {
          return DropdownMenuItem(
            value: state == 'ALL' ? null : state,
            child: Text(state),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedState = value;
          });
        },
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
              'Error Loading Analytics',
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
              onPressed: _loadStateStatistics,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final filteredStats = selectedState != null 
        ? stateStats.where((stat) => stat.state == selectedState).toList()
        : stateStats;

    if (filteredStats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 80, color: Colors.grey.shade400),
            SizedBox(height: 20),
            Text(
              'No Statistics Available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              selectedState != null 
                  ? 'No data found for $selectedState'
                  : 'No state statistics available',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedState != null) ...[
            _buildStateOverviewCard(filteredStats.first),
            SizedBox(height: 20),
          ] else ...[
            _buildSummaryCards(),
            SizedBox(height: 20),
            _buildTopPerformingStates(),
            SizedBox(height: 20),
          ],
          _buildQuickComparison(filteredStats),
        ],
      ),
    );
  }

  Widget _buildStateOverviewCard(StateStatistics stat) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.state,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'State Health Overview',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildOverviewStat(
                  'Hospitals',
                  '${stat.totalHospitals}',
                  Icons.local_hospital,
                ),
              ),
              Expanded(
                child: _buildOverviewStat(
                  'Patients',
                  '${stat.totalPatients}',
                  Icons.people,
                ),
              ),
              Expanded(
                child: _buildOverviewStat(
                  'Officers',
                  '${stat.totalRegionalOfficers}',
                  Icons.admin_panel_settings,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
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
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final totalHospitals = stateStats.fold(0, (sum, stat) => sum + stat.totalHospitals);
    final totalPatients = stateStats.fold(0, (sum, stat) => sum + stat.totalPatients);
    final averageAge = stateStats.isNotEmpty 
        ? stateStats.fold(0.0, (sum, stat) => sum + stat.averagePatientAge) / stateStats.length
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'National Summary',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total States',
                '${stateStats.length}',
                Icons.location_on,
                Colors.green,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Hospitals',
                '$totalHospitals',
                Icons.local_hospital,
                Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Patients',
                '$totalPatients',
                Icons.people,
                Colors.orange,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Avg. Age',
                averageAge.toStringAsFixed(1),
                Icons.cake,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformingStates() {
    final sortedStates = List<StateStatistics>.from(stateStats)
      ..sort((a, b) => b.totalHospitals.compareTo(a.totalHospitals));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Performing States',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Container(
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
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: sortedStates.take(5).length,
            itemBuilder: (context, index) {
              final stat = sortedStates[index];
              return _buildStateRankingItem(stat, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStateRankingItem(StateStatistics stat, int rank) {
    return ListTile(
      leading: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: rank <= 3 ? Colors.amber.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            '$rank',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: rank <= 3 ? Colors.amber.shade800 : Colors.grey.shade600,
            ),
          ),
        ),
      ),
      title: Text(
        stat.state,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('${stat.totalPatients} patients'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${stat.totalHospitals}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade600,
            ),
          ),
          Text(
            'hospitals',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickComparison(List<StateStatistics> stats) {
    if (stats.length < 2) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedState != null ? 'State Breakdown' : 'State Comparison',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Container(
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
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: stats.take(10).length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              return _buildComparisonItem(stat);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonItem(StateStatistics stat) {
    return ListTile(
      title: Text(
        stat.state,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Row(
        children: [
          Text('${stat.totalHospitals} hospitals'),
          SizedBox(width: 16),
          Text('${stat.totalPatients} patients'),
        ],
      ),
      trailing: Icon(Icons.chevron_right),
      onTap: () {
        setState(() {
          selectedState = stat.state;
        });
      },
    );
  }

  Widget _buildHospitalsTab() {
    return Center(child: Text('Hospital Analytics Coming Soon'));
  }

  Widget _buildPatientsTab() {
    return Center(child: Text('Patient Analytics Coming Soon'));
  }

  Widget _buildDemographicsTab() {
    return Center(child: Text('Demographics Analytics Coming Soon'));
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Analytics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose export format:'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _exportData('pdf');
                  },
                  icon: Icon(Icons.picture_as_pdf),
                  label: Text('PDF'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _exportData('excel');
                  },
                  icon: Icon(Icons.table_chart),
                  label: Text('Excel'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _exportData(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting analytics in $format format...')),
    );
    // TODO: Implement actual export functionality
  }
}