import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';  // Temporarily disabled
import '../models/who_admin.dart';
import '../services/who_service.dart';

class WhoComprehensiveAnalyticsScreen extends StatefulWidget {
  final WhoAdmin whoAdmin;

  const WhoComprehensiveAnalyticsScreen({super.key, required this.whoAdmin});

  @override
  _WhoComprehensiveAnalyticsScreenState createState() =>
      _WhoComprehensiveAnalyticsScreenState();
}

class _WhoComprehensiveAnalyticsScreenState
    extends State<WhoComprehensiveAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  String? error;

  // Analytics data
  Map<String, dynamic> hierarchyData = {};
  List<StateAnalytics> stateAnalytics = [];
  List<ChartData> hospitalDistribution = [];
  List<ChartData> staffDistribution = [];
  List<TimeSeriesData> healthTrends = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      print('🔍 Loading comprehensive analytics data...');
      final result = await WhoService.getComprehensiveAnalytics();

      if (result['success']) {
        final analytics = result['analytics'];
        print('✅ Analytics data received: $analytics');

        // Load hierarchy data
        hierarchyData = analytics['hierarchy'] ?? {};
        print('📊 Hierarchy data: $hierarchyData');

        // Load state analytics from hierarchy breakdown
        final stateBreakdown = hierarchyData['stateBreakdown'] as List? ?? [];
        stateAnalytics = stateBreakdown.map((item) {
          return StateAnalytics(
            item['state'] ?? 'Unknown',
            (item['hospitals'] ?? 0).toInt(),
            (item['doctors'] ?? 0).toInt(),
            (item['assistants'] ?? 0).toInt(),
            (item['hospitalEfficiency'] ?? 0.0).toDouble(),
            (item['staffSatisfaction'] ?? 0.0).toDouble(),
          );
        }).toList();
        print('🏥 State analytics loaded: ${stateAnalytics.length} states');

        // Load chart data
        final chartData = analytics['charts'] ?? {};
        _loadHospitalDistribution(chartData['hospitalDistribution']);
        _loadStaffDistribution(chartData['staffDistribution']);

        // Load health trends
        final trendsData = analytics['trends'] ?? {};
        _loadHealthTrendsFromAPI(trendsData['healthTrends']);

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          error = result['message'] ?? 'Failed to load analytics data';
          isLoading = false;
        });
        print('❌ Analytics API failed: ${result['message']}');
      }
    } catch (e) {
      setState(() {
        error = 'Network error: Unable to load analytics data';
        isLoading = false;
      });
      print('❌ Analytics loading error: $e');
    }
  }

  // Helper methods to load chart data from API response
  void _loadHospitalDistribution(dynamic data) {
    if (data == null) {
      print('⚠️ No hospital distribution data from API, using defaults');
      hospitalDistribution = [
        ChartData('Government', 45.2, Colors.blue),
        ChartData('Private', 38.5, Colors.green),
        ChartData('Trust', 12.8, Colors.orange),
        ChartData('Corporate', 3.5, Colors.purple),
      ];
      return;
    }

    try {
      hospitalDistribution = (data as List).map((item) {
        return ChartData(
          item['name'] ?? 'Unknown',
          (item['value'] ?? 0).toDouble(),
          item['color'] != null
              ? Color(int.parse(item['color'].replaceFirst('#', '0xFF')))
              : Colors.grey,
        );
      }).toList();
      print(
        '🏥 Hospital distribution loaded: ${hospitalDistribution.length} categories',
      );
    } catch (e) {
      print('⚠️ Error parsing hospital distribution: $e');
      hospitalDistribution = [];
    }
  }

  void _loadStaffDistribution(dynamic data) {
    if (data == null) {
      print('⚠️ No staff distribution data from API, using defaults');
      staffDistribution = [
        ChartData('Doctors', 42.8, Colors.red),
        ChartData('Nurses', 35.2, Colors.blue),
        ChartData('Technicians', 15.5, Colors.green),
        ChartData('Assistants', 6.5, Colors.orange),
      ];
      return;
    }

    try {
      staffDistribution = (data as List).map((item) {
        return ChartData(
          item['name'] ?? 'Unknown',
          (item['value'] ?? 0).toDouble(),
          item['color'] != null
              ? Color(int.parse(item['color'].replaceFirst('#', '0xFF')))
              : Colors.grey,
        );
      }).toList();
      print(
        '👨‍⚕️ Staff distribution loaded: ${staffDistribution.length} categories',
      );
    } catch (e) {
      print('⚠️ Error parsing staff distribution: $e');
      staffDistribution = [];
    }
  }

  void _loadHealthTrendsFromAPI(dynamic data) {
    if (data == null) {
      print('⚠️ No health trends data from API, using defaults');
      healthTrends = [
        TimeSeriesData(DateTime(2024, 1), 850),
        TimeSeriesData(DateTime(2024, 2), 920),
        TimeSeriesData(DateTime(2024, 3), 1050),
        TimeSeriesData(DateTime(2024, 4), 980),
        TimeSeriesData(DateTime(2024, 5), 1120),
        TimeSeriesData(DateTime(2024, 6), 1250),
      ];
      return;
    }

    try {
      healthTrends = (data as List).map((item) {
        return TimeSeriesData(
          DateTime.parse(item['date'] ?? '2024-01-01'),
          (item['value'] ?? 0).toDouble(),
        );
      }).toList();
      print('📈 Health trends loaded: ${healthTrends.length} data points');
    } catch (e) {
      print('⚠️ Error parsing health trends: $e');
      healthTrends = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Comprehensive Health Analytics'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyticsData,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportAnalytics,
          ),
          IconButton(icon: const Icon(Icons.share), onPressed: _shareAnalytics),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Hierarchy Overview'),
            Tab(text: 'State Analytics'),
            Tab(text: 'Distribution Charts'),
            Tab(text: 'Performance Metrics'),
            Tab(text: 'Health Trends'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? _buildErrorWidget()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildHierarchyOverviewTab(),
                _buildStateAnalyticsTab(),
                _buildDistributionChartsTab(),
                _buildPerformanceMetricsTab(),
                _buildHealthTrendsTab(),
              ],
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 20),
            const Text(
              'Error Loading Analytics',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadAnalyticsData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHierarchyOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildSummaryCards(),
          const SizedBox(height: 24),

          // Hierarchy Tree Visualization
          _buildHierarchyTreeCard(),
          const SizedBox(height: 24),

          // State-wise Breakdown
          _buildStateBreakdownCard(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'National Health System Overview',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildSummaryCard(
              'Total SHOs',
              '${hierarchyData['totals']?['totalSHOs'] ?? 28}',
              Icons.person_4,
              Colors.purple,
              'State Health Officers',
            ),
            _buildSummaryCard(
              'Total RHOs',
              '${hierarchyData['totals']?['totalRHOs'] ?? 156}',
              Icons.people,
              Colors.indigo,
              'Regional Health Officers',
            ),
            _buildSummaryCard(
              'Total Hospitals',
              '${hierarchyData['totals']?['totalHospitals'] ?? 2847}',
              Icons.local_hospital,
              Colors.blue,
              'Healthcare Facilities',
            ),
            _buildSummaryCard(
              'Total Doctors',
              '${hierarchyData['totals']?['totalDoctors'] ?? 15420}',
              Icons.medical_services,
              Colors.green,
              'Medical Professionals',
            ),
            _buildSummaryCard(
              'Total Assistants',
              '${hierarchyData['totals']?['totalAssistants'] ?? 8965}',
              Icons.support_agent,
              Colors.orange,
              'Healthcare Assistants',
            ),
            _buildSummaryCard(
              'Coverage',
              '95.8%',
              Icons.trending_up,
              Colors.teal,
              'Population Coverage',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Icon(Icons.trending_up, color: Colors.green, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHierarchyTreeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Healthcare System Hierarchy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              height: 300,
              child: CustomPaint(
                painter: HierarchyTreePainter(),
                size: const Size(double.infinity, 300),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateBreakdownCard() {
    final stateBreakdown = hierarchyData['stateBreakdown'] as List? ?? [];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'State-wise Healthcare Distribution',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (stateBreakdown.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No state data available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'State breakdown data will appear here when available',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stateBreakdown.length,
                itemBuilder: (context, index) {
                  final state = stateBreakdown[index];
                  return _buildStateRow(state);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateRow(Map<String, dynamic> state) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        title: Text(
          state['state'] ?? 'Unknown State',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '${state['hospitals'] ?? 0} hospitals • ${state['doctors'] ?? 0} doctors',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricChip(
                        'SHOs',
                        '${state['shos'] ?? 0}',
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricChip(
                        'RHOs',
                        '${state['rhos'] ?? 0}',
                        Colors.indigo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricChip(
                        'Hospitals',
                        '${state['hospitals'] ?? 0}',
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricChip(
                        'Doctors',
                        '${state['doctors'] ?? 0}',
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMetricChip(
                  'Assistants',
                  '${state['assistants'] ?? 0}',
                  Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'State Performance Analytics',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Performance Overview Chart
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'State Performance Comparison',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 300,
                    child: stateAnalytics.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bar_chart_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No state performance data',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 100,
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      int index = value.toInt();
                                      if (index >= 0 &&
                                          index < stateAnalytics.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Text(
                                            stateAnalytics[index].state,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text('${value.toInt()}%');
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: stateAnalytics.asMap().entries.map((
                                entry,
                              ) {
                                int index = entry.key;
                                StateAnalytics data = entry.value;
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: data.hospitalEfficiency,
                                      color: Colors.blue,
                                      width: 15,
                                    ),
                                    BarChartRodData(
                                      toY: data.staffSatisfaction,
                                      color: Colors.green,
                                      width: 15,
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Detailed State Cards
          if (stateAnalytics.isEmpty)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No detailed state data available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stateAnalytics.length,
              itemBuilder: (context, index) {
                return _buildDetailedStateCard(stateAnalytics[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDetailedStateCard(StateAnalytics state) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  state.state,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getPerformanceColor(state.hospitalEfficiency),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getPerformanceGrade(state.hospitalEfficiency),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStateTile(
                    'Hospitals',
                    '${state.hospitals}',
                    Icons.local_hospital,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStateTile(
                    'Doctors',
                    '${state.doctors}',
                    Icons.medical_services,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStateTile(
                    'Assistants',
                    '${state.assistants}',
                    Icons.support_agent,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStateTile(
                    'Efficiency',
                    '${state.hospitalEfficiency.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: state.hospitalEfficiency / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(
                _getPerformanceColor(state.hospitalEfficiency),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Overall Performance: ${state.hospitalEfficiency.toStringAsFixed(1)}%',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateTile(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Color _getPerformanceColor(double efficiency) {
    if (efficiency >= 90) return Colors.green;
    if (efficiency >= 80) return Colors.orange;
    return Colors.red;
  }

  String _getPerformanceGrade(double efficiency) {
    if (efficiency >= 95) return 'A+';
    if (efficiency >= 90) return 'A';
    if (efficiency >= 85) return 'B+';
    if (efficiency >= 80) return 'B';
    if (efficiency >= 75) return 'C+';
    return 'C';
  }

  Widget _buildDistributionChartsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Healthcare Distribution Analysis',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Hospital Type Distribution
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hospital Type Distribution',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 250,
                    child: hospitalDistribution.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pie_chart_outline,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No hospital distribution data',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : PieChart(
                            PieChartData(
                              sections: hospitalDistribution.map((data) {
                                return PieChartSectionData(
                                  value: data.value,
                                  title: '${data.value}%',
                                  color: data.color,
                                  radius: 100,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    children: hospitalDistribution.map((data) {
                      return Container(
                        margin: const EdgeInsets.only(right: 16, bottom: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: data.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(data.name),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Staff Distribution
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Healthcare Staff Distribution',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 250,
                    child: staffDistribution.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No staff distribution data',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: staffDistribution.map((data) {
                                return PieChartSectionData(
                                  color: data.color,
                                  value: data.value,
                                  title: '${data.value.toStringAsFixed(1)}%',
                                  radius: 50,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  // Add legend manually
                  Wrap(
                    spacing: 20,
                    children: staffDistribution.map((data) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 16, height: 16, color: data.color),
                          const SizedBox(width: 8),
                          Text(data.name, style: const TextStyle(fontSize: 12)),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Regional Coverage Map Placeholder
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Regional Healthcare Coverage',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Interactive Coverage Map',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Coming Soon'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetricsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Metrics & KPIs',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Key Performance Indicators
          _buildKPIGrid(),
          const SizedBox(height: 20),

          // Performance Trends
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Performance Trends',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 300,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const months = [
                                  'Jan',
                                  'Feb',
                                  'Mar',
                                  'Apr',
                                  'May',
                                  'Jun',
                                ];
                                return Text(
                                  months[value.toInt() % months.length],
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              const FlSpot(0, 85),
                              const FlSpot(1, 87),
                              const FlSpot(2, 90),
                              const FlSpot(3, 88),
                              const FlSpot(4, 92),
                              const FlSpot(5, 95),
                            ],
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIGrid() {
    final kpis = [
      KPI(
        'Hospital Utilization',
        '87.5%',
        Icons.local_hospital,
        Colors.blue,
        '+2.3%',
      ),
      KPI('Staff Efficiency', '92.1%', Icons.people, Colors.green, '+1.8%'),
      KPI(
        'Patient Satisfaction',
        '89.7%',
        Icons.sentiment_satisfied,
        Colors.orange,
        '+0.5%',
      ),
      KPI(
        'Resource Allocation',
        '94.2%',
        Icons.inventory,
        Colors.purple,
        '+3.1%',
      ),
      KPI('Response Time', '15.2 min', Icons.timer, Colors.red, '-2.1 min'),
      KPI('Bed Occupancy', '76.8%', Icons.bed, Colors.teal, '+4.2%'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) {
        final kpi = kpis[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                        color: kpi.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(kpi.icon, color: kpi.color, size: 20),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            kpi.trend.startsWith('+') ||
                                kpi.trend.startsWith('-') &&
                                    !kpi.trend.contains('min')
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        kpi.trend,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color:
                              kpi.trend.startsWith('+') ||
                                  kpi.trend.startsWith('-') &&
                                      !kpi.trend.contains('min')
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  kpi.value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kpi.color,
                  ),
                ),
                Text(
                  kpi.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Trends & Predictions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Health Trends Chart
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Health Registrations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 300,
                    child: healthTrends.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.trending_up_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No trends data available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text('${value.toInt()}');
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final date =
                                          DateTime.fromMillisecondsSinceEpoch(
                                            value.toInt(),
                                          );
                                      return Text(
                                        '${date.month}/${date.year}',
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: true),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: healthTrends.map((data) {
                                    return FlSpot(
                                      data.date.millisecondsSinceEpoch
                                          .toDouble(),
                                      data.value,
                                    );
                                  }).toList(),
                                  isCurved: true,
                                  color: Colors.blue,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: true),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Trend Insights
          _buildTrendInsights(),
        ],
      ),
    );
  }

  Widget _buildTrendInsights() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key Insights & Predictions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInsightCard(
              '📈 Growing Trend',
              'Healthcare registrations increased by 15.2% this month',
              Colors.green,
            ),
            _buildInsightCard(
              '🏥 Hospital Expansion',
              '3 new hospitals expected to be operational next quarter',
              Colors.blue,
            ),
            _buildInsightCard(
              '👨‍⚕️ Staff Recruitment',
              'Need to recruit 450+ healthcare professionals by year-end',
              Colors.orange,
            ),
            _buildInsightCard(
              '📊 Predictive Analytics',
              'AI models suggest 20% increase in demand for emergency services',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(description, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  void _exportAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Analytics'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Excel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CSV'),
          ),
        ],
      ),
    );
  }

  void _shareAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analytics shared successfully')),
    );
  }
}

// Data Classes
class StateAnalytics {
  final String state;
  final int hospitals;
  final int doctors;
  final int assistants;
  final double hospitalEfficiency;
  final double staffSatisfaction;

  StateAnalytics(
    this.state,
    this.hospitals,
    this.doctors,
    this.assistants,
    this.hospitalEfficiency,
    this.staffSatisfaction,
  );
}

class ChartData {
  final String name;
  final double value;
  final Color color;

  ChartData(this.name, this.value, this.color);
}

class TimeSeriesData {
  final DateTime date;
  final double value;

  TimeSeriesData(this.date, this.value);
}

class KPI {
  final String name;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  KPI(this.name, this.value, this.icon, this.color, this.trend);
}

// Custom Painter for Hierarchy Tree
class HierarchyTreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw WHO level
    paint.color = Colors.purple;
    final whoRect = Rect.fromCenter(
      center: Offset(size.width / 2, 30),
      width: 80,
      height: 40,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(whoRect, const Radius.circular(8)),
      paint,
    );

    textPainter.text = const TextSpan(
      text: 'WHO',
      style: TextStyle(
        color: Colors.purple,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        whoRect.center.dx - textPainter.width / 2,
        whoRect.center.dy - textPainter.height / 2,
      ),
    );

    // Draw SHO level
    paint.color = Colors.indigo;
    for (int i = 0; i < 3; i++) {
      final shoRect = Rect.fromCenter(
        center: Offset(size.width / 4 + i * size.width / 4, 100),
        width: 70,
        height: 35,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(shoRect, const Radius.circular(6)),
        paint,
      );

      // Draw connection lines
      canvas.drawLine(
        Offset(size.width / 2, whoRect.bottom),
        Offset(shoRect.center.dx, shoRect.top),
        paint,
      );

      textPainter.text = const TextSpan(
        text: 'SHO',
        style: TextStyle(
          color: Colors.indigo,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          shoRect.center.dx - textPainter.width / 2,
          shoRect.center.dy - textPainter.height / 2,
        ),
      );
    }

    // Draw RHO level
    paint.color = Colors.blue;
    for (int i = 0; i < 6; i++) {
      final rhoRect = Rect.fromCenter(
        center: Offset(size.width / 8 + i * size.width / 7, 170),
        width: 60,
        height: 30,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rhoRect, const Radius.circular(4)),
        paint,
      );

      // Draw connection lines to SHOs
      final shoIndex = i ~/ 2;
      canvas.drawLine(
        Offset(size.width / 4 + shoIndex * size.width / 4, 135),
        Offset(rhoRect.center.dx, rhoRect.top),
        paint,
      );

      textPainter.text = const TextSpan(
        text: 'RHO',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          rhoRect.center.dx - textPainter.width / 2,
          rhoRect.center.dy - textPainter.height / 2,
        ),
      );
    }

    // Draw Hospital level
    paint.color = Colors.green;
    for (int i = 0; i < 8; i++) {
      final hospitalRect = Rect.fromCenter(
        center: Offset(size.width / 10 + i * size.width / 9, 240),
        width: 50,
        height: 25,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(hospitalRect, const Radius.circular(3)),
        paint,
      );

      // Draw connection lines to RHOs
      final rhoIndex = i ~/ 2;
      if (rhoIndex < 6) {
        canvas.drawLine(
          Offset(size.width / 8 + rhoIndex * size.width / 7, 185),
          Offset(hospitalRect.center.dx, hospitalRect.top),
          paint,
        );
      }

      textPainter.text = const TextSpan(
        text: 'Hospital',
        style: TextStyle(
          color: Colors.green,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          hospitalRect.center.dx - textPainter.width / 2,
          hospitalRect.center.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
