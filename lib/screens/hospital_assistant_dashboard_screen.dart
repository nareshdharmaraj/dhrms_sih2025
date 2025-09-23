import 'package:flutter/material.dart';
import '../services/hospital_api_service.dart';
import '../widgets/app_branding.dart';

class HospitalAssistantDashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? assistantData;

  const HospitalAssistantDashboardScreen({super.key, this.assistantData});

  @override
  _HospitalAssistantDashboardScreenState createState() =>
      _HospitalAssistantDashboardScreenState();
}

class _HospitalAssistantDashboardScreenState
    extends State<HospitalAssistantDashboardScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoading = false;
  Map<String, dynamic>? _assistantData;
  List<dynamic> _assignedTasks = [];
  List<dynamic> _patientRecords = [];
  List<dynamic> _todayTasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAssistantData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadAssistantData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await HospitalApiService.getAssistantDashboard();
      setState(() {
        _assistantData = data['data'];
        _assignedTasks = data['data']['assignedTasks'] ?? [];
        _patientRecords = data['data']['patientRecords'] ?? [];
        _todayTasks = data['data']['todayTasks'] ?? [];
      });
    } catch (e) {
      _showError('Error loading assistant dashboard: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // App Branding Header
          AppBranding(backgroundColor: Colors.purple[700], height: 100),

          // Content Area
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.purple[700]!,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading Assistant Dashboard...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDashboardTab(),
                      _buildTasksTab(),
                      _buildPatientRecordsTab(),
                      _buildProfileTab(),
                    ],
                  ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purple[700],
          labelColor: Colors.purple[700],
          unselectedLabelColor: Colors.grey[500],
          indicatorWeight: 3,
          tabs: [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.assignment), text: 'Tasks'),
            Tab(icon: Icon(Icons.folder_shared), text: 'Records'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    if (_assistantData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please refresh to load dashboard data',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAssistantData,
              icon: Icon(Icons.refresh),
              label: Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    final assistant = _assistantData!['assistant'] ?? {};
    final hospital = _assistantData!['hospital'] ?? {};
    final stats = _assistantData!['stats'] ?? {};
    final assignedDoctor = assistant['assignedDoctor'];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Assistant Info & Quick Actions Row
          Row(
            children: [
              // Welcome Card
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple[600]!, Colors.purple[400]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        assistant['assistantName'] ?? 'Assistant',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        assistant['department'] ?? 'Department',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        hospital['hospitalName'] ?? 'Hospital',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 16),

              // Quick Actions
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildQuickActionCard(
                      'Refresh',
                      Icons.refresh,
                      Colors.blue,
                      () => _loadAssistantData(),
                    ),
                    SizedBox(height: 12),
                    _buildQuickActionCard(
                      'Logout',
                      Icons.logout,
                      Colors.red,
                      () async {
                        await HospitalApiService.logout();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Assigned Doctor Info (if any)
          if (assignedDoctor != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.local_hospital, color: Colors.blue[700]),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assigned to Dr. ${assignedDoctor['doctorName'] ?? 'Doctor'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[800],
                          ),
                        ),
                        Text(
                          assignedDoctor['specialization'] ?? 'Specialist',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.verified, color: Colors.blue[700]),
                ],
              ),
            ),

          SizedBox(height: 24),

          // Today's Overview
          Text(
            "Today's Overview",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Today\'s Tasks',
                  '${_todayTasks.length}',
                  Icons.assignment,
                  Colors.purple,
                  Colors.purple[50]!,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Tasks',
                  '${stats['totalTasks'] ?? 0}',
                  Icons.task_alt,
                  Colors.blue,
                  Colors.blue[50]!,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  '${stats['completedTasks'] ?? 0}',
                  Icons.check_circle,
                  Colors.green,
                  Colors.green[50]!,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Patient Records',
                  '${_patientRecords.length}',
                  Icons.folder,
                  Colors.orange,
                  Colors.orange[50]!,
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Today's Tasks
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.today, color: Colors.purple[700], size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Today\'s Tasks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                if (_todayTasks.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No tasks for today',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                  )
                else
                  ...(_todayTasks
                      .take(3)
                      .map((task) => _buildTaskCard(task))
                      .toList()),
                if (_todayTasks.length > 3)
                  TextButton(
                    onPressed: () {
                      _tabController?.animateTo(1); // Go to tasks tab
                    },
                    child: Text('View all tasks'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Color backgroundColor,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getTaskPriorityColor(
              task['priority'],
            ).withOpacity(0.2),
            child: Icon(
              Icons.assignment,
              color: _getTaskPriorityColor(task['priority']),
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'] ?? 'Unknown Task',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                if (task['description'] != null)
                  Text(
                    task['description'],
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  'Due: ${task['dueTime'] ?? 'Not specified'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTaskStatusColor(task['status']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task['status'] ?? 'Pending',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTaskPriorityColor(
                    task['priority'],
                  ).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task['priority'] ?? 'Normal',
                  style: TextStyle(
                    color: _getTaskPriorityColor(task['priority']),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTaskStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color _getTaskPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Widget _buildTasksTab() {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.assignment, color: Colors.purple[700]),
              SizedBox(width: 8),
              Text(
                'My Tasks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: _loadAssistantData,
                icon: Icon(Icons.refresh, color: Colors.purple[700]),
              ),
            ],
          ),
        ),

        // Tasks List
        Expanded(
          child: _assignedTasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No tasks assigned',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tasks will appear here when assigned',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _assignedTasks.length,
                  itemBuilder: (context, index) {
                    final task = _assignedTasks[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: _getTaskPriorityColor(
                            task['priority'],
                          ).withOpacity(0.2),
                          child: Icon(
                            Icons.assignment,
                            color: _getTaskPriorityColor(task['priority']),
                          ),
                        ),
                        title: Text(
                          task['title'] ?? 'Unknown Task',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            if (task['description'] != null)
                              Text(
                                task['description'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            SizedBox(height: 4),
                            Text('Due: ${task['dueDate'] ?? 'Not specified'}'),
                            if (task['assignedBy'] != null)
                              Text('Assigned by: ${task['assignedBy']}'),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getTaskStatusColor(
                                      task['status'],
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    task['status'] ?? 'Pending',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getTaskStatusColor(
                                        task['status'],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getTaskPriorityColor(
                                      task['priority'],
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    task['priority'] ?? 'Normal',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getTaskPriorityColor(
                                        task['priority'],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, size: 18),
                                  SizedBox(width: 8),
                                  Text('View Details'),
                                ],
                              ),
                            ),
                            if (task['status'] != 'completed')
                              PopupMenuItem(
                                value: 'start',
                                child: Row(
                                  children: [
                                    Icon(Icons.play_arrow, size: 18),
                                    SizedBox(width: 8),
                                    Text('Start Task'),
                                  ],
                                ),
                              ),
                            if (task['status'] == 'in_progress')
                              PopupMenuItem(
                                value: 'complete',
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, size: 18),
                                    SizedBox(width: 8),
                                    Text('Mark Complete'),
                                  ],
                                ),
                              ),
                          ],
                          onSelected: (value) {
                            if (value == 'view') {
                              _showTaskDetails(task);
                            } else if (value == 'start') {
                              _updateTaskStatus(task['_id'], 'in_progress');
                            } else if (value == 'complete') {
                              _updateTaskStatus(task['_id'], 'completed');
                            }
                          },
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPatientRecordsTab() {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.folder_shared, color: Colors.purple[700]),
              SizedBox(width: 8),
              Text(
                'Patient Records',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: _loadAssistantData,
                icon: Icon(Icons.refresh, color: Colors.purple[700]),
              ),
            ],
          ),
        ),

        // Patient Records List
        Expanded(
          child: _patientRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No patient records found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Records will appear here when assigned',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _patientRecords.length,
                  itemBuilder: (context, index) {
                    final record = _patientRecords[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple[100],
                          child: Icon(Icons.folder, color: Colors.purple[700]),
                        ),
                        title: Text(
                          record['patientName'] ?? 'Unknown Patient',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text('UHID: ${record['uhid'] ?? 'N/A'}'),
                            Text(
                              'Record Type: ${record['recordType'] ?? 'General'}',
                            ),
                            Text('Date: ${record['recordDate'] ?? 'N/A'}'),
                            if (record['notes'] != null)
                              Text(
                                'Notes: ${record['notes']}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.visibility,
                            color: Colors.purple[700],
                          ),
                          onPressed: () => _showRecordDetails(record),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    if (_assistantData == null) {
      return Center(child: CircularProgressIndicator());
    }

    final assistant = _assistantData!['assistant'] ?? {};
    final hospital = _assistantData!['hospital'] ?? {};
    final assignedDoctor = assistant['assignedDoctor'];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[600]!, Colors.purple[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.people,
                    size: 50,
                    color: Colors.purple[700],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  assistant['assistantName'] ?? 'Assistant',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  assistant['department'] ?? 'Department',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    assistant['isActive'] ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Professional Information
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Professional Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),
                _buildProfileRow('Assistant ID', assistant['assistantId']),
                _buildProfileRow('Department', assistant['department']),
                _buildProfileRow('Qualification', assistant['qualification']),
                _buildProfileRow(
                  'Experience',
                  '${assistant['experienceYears'] ?? 0} years',
                ),
                if (assignedDoctor != null)
                  _buildProfileRow(
                    'Assigned to',
                    'Dr. ${assignedDoctor['doctorName']}',
                  ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Contact Information
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),
                _buildProfileRow('Email', assistant['email']),
                _buildProfileRow('Phone', assistant['contactNumber']),
                _buildProfileRow('Username', assistant['username']),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Hospital Information
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hospital Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),
                _buildProfileRow('Hospital', hospital['hospitalName']),
                _buildProfileRow('Hospital ID', hospital['hospitalId']),
                _buildProfileRow('Type', hospital['hospitalType']),
                _buildProfileRow('Contact', hospital['contactNumber']),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await HospitalApiService.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Task Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Title', task['title']),
              _buildDetailRow('Description', task['description']),
              _buildDetailRow('Status', task['status']),
              _buildDetailRow('Priority', task['priority']),
              _buildDetailRow('Due Date', task['dueDate']),
              _buildDetailRow('Due Time', task['dueTime']),
              _buildDetailRow('Assigned By', task['assignedBy']),
              _buildDetailRow('Created', task['createdAt']),
              if (task['notes'] != null)
                _buildDetailRow('Notes', task['notes']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Patient Record Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Patient Name', record['patientName']),
              _buildDetailRow('UHID', record['uhid']),
              _buildDetailRow('Record Type', record['recordType']),
              _buildDetailRow('Record Date', record['recordDate']),
              _buildDetailRow('Notes', record['notes']),
              _buildDetailRow('Created By', record['createdBy']),
              _buildDetailRow('Last Updated', record['updatedAt']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value?.toString() ?? 'N/A')),
        ],
      ),
    );
  }

  Future<void> _updateTaskStatus(String taskId, String status) async {
    try {
      await HospitalApiService.updateTaskStatus(taskId, status);
      _loadAssistantData(); // Refresh data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task status updated successfully')),
      );
    } catch (e) {
      _showError('Error updating task status: $e');
    }
  }
}
