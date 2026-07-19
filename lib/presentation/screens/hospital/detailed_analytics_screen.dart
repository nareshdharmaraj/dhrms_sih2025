import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_styles.dart';

class DetailedAnalyticsScreen extends StatefulWidget {
  const DetailedAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<DetailedAnalyticsScreen> createState() => _DetailedAnalyticsScreenState();
}

class _DetailedAnalyticsScreenState extends State<DetailedAnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeFrame = 'This Month';
  bool _isLoading = false;

  final List<String> _timeFrames = [
    'Today',
    'This Week',
    'This Month',
    'Last 3 Months',
    'This Year'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Healthcare Analytics'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.calendar_today),
            onSelected: (value) {
              setState(() => _selectedTimeFrame = value);
              _loadAnalyticsData();
            },
            itemBuilder: (context) => _timeFrames
                .map((frame) => PopupMenuItem(
                      value: frame,
                      child: Text(frame),
                    ))
                .toList(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.people), text: 'Patients'),
            Tab(icon: Icon(Icons.local_hospital), text: 'Departments'),
            Tab(icon: Icon(Icons.timeline), text: 'Trends'),
            Tab(icon: Icon(Icons.assessment), text: 'Reports'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  color: AppColors.lightBlue,
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: AppColors.primaryBlue),
                      SizedBox(width: 8),
                      Text(
                        'Analytics for: $_selectedTimeFrame',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Last updated: ${DateTime.now().toString().substring(0, 16)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPatientsAnalytics(),
                      _buildDepartmentsAnalytics(),
                      _buildTrendsAnalytics(),
                      _buildReportsAnalytics(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPatientsAnalytics() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildStatsCard(
          'Patient Overview',
          [
            _StatItem('Total Patients', '1,245', Colors.blue, Icons.people),
            _StatItem('New Admissions', '89', Colors.green, Icons.person_add),
            _StatItem('Discharges', '76', Colors.orange, Icons.exit_to_app),
            _StatItem('Critical Cases', '12', Colors.red, Icons.warning),
          ],
        ),
        SizedBox(height: 16),
        _buildChartCard(
          'Patient Admissions Trend',
          _buildLineChart(),
        ),
        SizedBox(height: 16),
        _buildChartCard(
          'Age Distribution',
          _buildPieChart(),
        ),
        SizedBox(height: 16),
        _buildTableCard(
          'Recent Admissions',
          _buildRecentAdmissionsTable(),
        ),
      ],
    );
  }

  Widget _buildDepartmentsAnalytics() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildStatsCard(
          'Department Overview',
          [
            _StatItem('Total Departments', '15', Colors.purple, Icons.business),
            _StatItem('Active Departments', '14', Colors.green, Icons.check_circle),
            _StatItem('Bed Occupancy', '78%', Colors.orange, Icons.bed),
            _StatItem('Available Beds', '156', Colors.blue, Icons.hotel),
          ],
        ),
        SizedBox(height: 16),
        _buildChartCard(
          'Department Utilization',
          _buildBarChart(),
        ),
        SizedBox(height: 16),
        _buildTableCard(
          'Department Performance',
          _buildDepartmentTable(),
        ),
      ],
    );
  }

  Widget _buildTrendsAnalytics() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildStatsCard(
          'Health Trends',
          [
            _StatItem('Avg. Length of Stay', '4.2 days', Colors.indigo, Icons.timer),
            _StatItem('Patient Satisfaction', '94%', Colors.green, Icons.sentiment_very_satisfied),
            _StatItem('Readmission Rate', '8.5%', Colors.orange, Icons.refresh),
            _StatItem('Mortality Rate', '2.1%', Colors.red, Icons.favorite_border),
          ],
        ),
        SizedBox(height: 16),
        _buildChartCard(
          'Monthly Trends Comparison',
          _buildMultiLineChart(),
        ),
        SizedBox(height: 16),
        _buildChartCard(
          'Disease Distribution',
          _buildDoughnutChart(),
        ),
      ],
    );
  }

  Widget _buildReportsAnalytics() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildStatsCard(
          'Financial Overview',
          [
            _StatItem('Total Revenue', '₹2.45M', Colors.green, Icons.account_balance),
            _StatItem('Operating Costs', '₹1.85M', Colors.red, Icons.money_off),
            _StatItem('Net Profit', '₹0.60M', Colors.blue, Icons.trending_up),
            _StatItem('Insurance Claims', '₹1.20M', Colors.orange, Icons.security),
          ],
        ),
        SizedBox(height: 16),
        _buildReportCard('Monthly Financial Report', Icons.bar_chart, () {
          // Generate monthly financial report
          _showReportDialog('Monthly Financial Report Generated');
        }),
        SizedBox(height: 8),
        _buildReportCard('Patient Demographics Report', Icons.people_outline, () {
          // Generate demographics report
          _showReportDialog('Patient Demographics Report Generated');
        }),
        SizedBox(height: 8),
        _buildReportCard('Department Efficiency Report', Icons.business_center, () {
          // Generate efficiency report
          _showReportDialog('Department Efficiency Report Generated');
        }),
        SizedBox(height: 8),
        _buildReportCard('Quality Metrics Report', Icons.star_rate, () {
          // Generate quality report
          _showReportDialog('Quality Metrics Report Generated');
        }),
      ],
    );
  }

  Widget _buildStatsCard(String title, List<_StatItem> stats) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                final stat = stats[index];
                return Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: stat.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: stat.color.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(stat.icon, color: stat.color, size: 24),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              stat.value,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: stat.color,
                              ),
                            ),
                            Text(
                              stat.label,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(height: 250, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCard(String title, Widget table) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: 16),
            table,
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(title),
        subtitle: Text('Click to generate and download'),
        trailing: Icon(Icons.download, color: AppColors.primaryBlue),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                if (value.toInt() < titles.length) {
                  return Text(titles[value.toInt()]);
                }
                return Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 120),
              FlSpot(1, 145),
              FlSpot(2, 130),
              FlSpot(3, 165),
              FlSpot(4, 155),
              FlSpot(5, 180),
            ],
            isCurved: true,
            color: AppColors.primaryBlue,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: 35,
            title: '18-30\n35%',
            color: AppColors.primaryBlue,
            radius: 50,
          ),
          PieChartSectionData(
            value: 25,
            title: '31-45\n25%',
            color: AppColors.primaryGreen,
            radius: 50,
          ),
          PieChartSectionData(
            value: 20,
            title: '46-60\n20%',
            color: AppColors.primaryOrange,
            radius: 50,
          ),
          PieChartSectionData(
            value: 20,
            title: '60+\n20%',
            color: AppColors.primaryRed,
            radius: 50,
          ),
        ],
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const departments = ['Card', 'Neur', 'Orth', 'Pedi', 'Gen'];
                if (value.toInt() < departments.length) {
                  return Text(departments[value.toInt()]);
                }
                return Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 85, color: AppColors.primaryBlue)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 92, color: AppColors.primaryGreen)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 78, color: AppColors.primaryOrange)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 88, color: AppColors.primaryRed)]),
          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 95, color: AppColors.primaryBlue)]),
        ],
      ),
    );
  }

  Widget _buildMultiLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                if (value.toInt() < months.length) {
                  return Text(months[value.toInt()]);
                }
                return Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [FlSpot(0, 120), FlSpot(1, 145), FlSpot(2, 130), FlSpot(3, 165), FlSpot(4, 155), FlSpot(5, 180)],
            isCurved: true,
            color: AppColors.primaryBlue,
            barWidth: 3,
          ),
          LineChartBarData(
            spots: [FlSpot(0, 80), FlSpot(1, 95), FlSpot(2, 110), FlSpot(3, 125), FlSpot(4, 135), FlSpot(5, 150)],
            isCurved: true,
            color: AppColors.primaryGreen,
            barWidth: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildDoughnutChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 30, title: 'Cardio\n30%', color: AppColors.primaryBlue, radius: 60),
          PieChartSectionData(value: 25, title: 'Respiratory\n25%', color: AppColors.primaryGreen, radius: 60),
          PieChartSectionData(value: 20, title: 'Neurological\n20%', color: AppColors.primaryOrange, radius: 60),
          PieChartSectionData(value: 15, title: 'Orthopedic\n15%', color: AppColors.primaryRed, radius: 60),
          PieChartSectionData(value: 10, title: 'Other\n10%', color: AppColors.grey500, radius: 60),
        ],
        centerSpaceRadius: 80,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildRecentAdmissionsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Patient ID')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Age')),
          DataColumn(label: Text('Department')),
          DataColumn(label: Text('Admission Date')),
        ],
        rows: [
          DataRow(cells: [
            DataCell(Text('P001')),
            DataCell(Text('John Doe')),
            DataCell(Text('45')),
            DataCell(Text('Cardiology')),
            DataCell(Text('2024-01-15')),
          ]),
          DataRow(cells: [
            DataCell(Text('P002')),
            DataCell(Text('Jane Smith')),
            DataCell(Text('32')),
            DataCell(Text('General')),
            DataCell(Text('2024-01-14')),
          ]),
          DataRow(cells: [
            DataCell(Text('P003')),
            DataCell(Text('Bob Johnson')),
            DataCell(Text('58')),
            DataCell(Text('Orthopedics')),
            DataCell(Text('2024-01-13')),
          ]),
        ],
      ),
    );
  }

  Widget _buildDepartmentTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Department')),
          DataColumn(label: Text('Total Beds')),
          DataColumn(label: Text('Occupied')),
          DataColumn(label: Text('Occupancy %')),
          DataColumn(label: Text('Avg. Stay')),
        ],
        rows: [
          DataRow(cells: [
            DataCell(Text('Cardiology')),
            DataCell(Text('50')),
            DataCell(Text('42')),
            DataCell(Text('84%')),
            DataCell(Text('5.2 days')),
          ]),
          DataRow(cells: [
            DataCell(Text('General Medicine')),
            DataCell(Text('80')),
            DataCell(Text('65')),
            DataCell(Text('81%')),
            DataCell(Text('3.8 days')),
          ]),
          DataRow(cells: [
            DataCell(Text('Orthopedics')),
            DataCell(Text('40')),
            DataCell(Text('28')),
            DataCell(Text('70%')),
            DataCell(Text('6.5 days')),
          ]),
        ],
      ),
    );
  }

  void _showReportDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Generation'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  _StatItem(this.label, this.value, this.color, this.icon);
}
