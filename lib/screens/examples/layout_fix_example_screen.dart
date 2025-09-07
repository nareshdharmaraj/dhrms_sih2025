import 'package:flutter/material.dart';
import '../../utils/layout_fix_utils.dart';

/// Example screen showing how to fix common layout overflow issues
class LayoutFixExampleScreen extends StatelessWidget {
  const LayoutFixExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LayoutFixUtils.responsiveAppBar(
        title: 'Layout Fix Examples',
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: LayoutFixUtils.safeScrollableColumn(
        children: [
          // Section 1: Responsive Text Example
          LayoutPatterns.sectionHeader(
            title: 'Responsive Text',
            subtitle: 'Text that adapts to screen size and prevents overflow',
          ),
          _buildTextExamples(),
          
          const SizedBox(height: 24),
          
          // Section 2: Responsive Row/Column Example
          LayoutPatterns.sectionHeader(
            title: 'Responsive Layout',
            subtitle: 'Rows that become columns on small screens',
          ),
          _buildResponsiveLayoutExample(),
          
          const SizedBox(height: 24),
          
          // Section 3: Responsive Grid Example
          LayoutPatterns.sectionHeader(
            title: 'Responsive Grid',
            subtitle: 'Grid that adapts column count to screen size',
          ),
          _buildResponsiveGridExample(),
          
          const SizedBox(height: 24),
          
          // Section 4: Form Layout Example
          LayoutPatterns.sectionHeader(
            title: 'Form Layout',
            subtitle: 'Properly spaced form with overflow protection',
          ),
          _buildFormLayoutExample(),
          
          const SizedBox(height: 24),
          
          // Section 5: Card Layout Example
          LayoutPatterns.sectionHeader(
            title: 'Responsive Cards',
            subtitle: 'Cards that adapt their layout to screen size',
          ),
          _buildCardLayoutExample(),
          
          const SizedBox(height: 100), // Bottom spacing
        ],
      ),
    );
  }

  Widget _buildTextExamples() {
    return LayoutFixUtils.responsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Before (Overflow Issue):',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 8),
          
          // Example of overflow-prone layout
          Container(
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border.all(color: Colors.red[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'This is a very long text that will definitely cause overflow on smaller screens and create rendering issues',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'After (Fixed with Flexible):',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 8),
          
          // Fixed layout using responsive utils
          Container(
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border.all(color: Colors.green[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                LayoutFixUtils.flexibleText(
                  'This is a very long text that will definitely cause overflow on smaller screens and create rendering issues',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveLayoutExample() {
    return LayoutFixUtils.responsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Responsive Row/Column Layout:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          LayoutFixUtils.responsiveRowColumn(
            children: [
              _buildInfoBox('User Info', Icons.person, Colors.blue),
              _buildInfoBox('Health Data', Icons.favorite, Colors.red),
              _buildInfoBox('Appointments', Icons.calendar_today, Colors.green),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'This layout automatically switches from row to column on screens smaller than 600px',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveGridExample() {
    final gridItems = [
      _buildGridItem('Heart Rate', Icons.favorite, '72 BPM', Colors.red),
      _buildGridItem('Steps', Icons.directions_walk, '8,543', Colors.blue),
      _buildGridItem('Calories', Icons.local_fire_department, '2,156', Colors.orange),
      _buildGridItem('Sleep', Icons.bedtime, '7h 23m', Colors.purple),
      _buildGridItem('Water', Icons.water_drop, '1.8L', Colors.cyan),
      _buildGridItem('Weight', Icons.monitor_weight, '70kg', Colors.green),
    ];

    return LayoutFixUtils.responsiveGrid(
      children: gridItems,
      maxCrossAxisExtent: 150,
      childAspectRatio: 1.2,
    );
  }

  Widget _buildGridItem(String title, IconData icon, String value, Color color) {
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
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFormLayoutExample() {
    return LayoutFixUtils.responsiveCard(
      child: LayoutPatterns.formLayout(
        children: [
          const Text(
            'Patient Registration Form',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          
          LayoutFixUtils.responsiveRowColumn(
            children: [
              Flexible(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
              const SizedBox(width: 16, height: 16),
              Flexible(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: ['Male', 'Female', 'Other']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
          
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
          ),
          
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          
          LayoutFixUtils.responsiveButton(
            onPressed: () {},
            text: 'Register Patient',
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardLayoutExample() {
    return Column(
      children: [
        // Appointment Card
        LayoutFixUtils.responsiveCard(
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calendar_today, color: Colors.blue[600], size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upcoming Appointment',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dr. Sarah Johnson - Cardiology Department',
                      style: TextStyle(color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tomorrow, 10:00 AM - City General Hospital',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        
        // Health Metrics Card
        LayoutFixUtils.responsiveCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today\'s Health Metrics',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              
              LayoutFixUtils.responsiveRowColumn(
                children: [
                  _buildMetricItem('Heart Rate', '72 BPM', Icons.favorite, Colors.red),
                  _buildMetricItem('Blood Pressure', '120/80', Icons.monitor_heart, Colors.blue),
                  _buildMetricItem('Temperature', '98.6°F', Icons.thermostat, Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Layout Fix Guidelines'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Common Layout Overflow Fixes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Use Flexible or Expanded widgets in Rows/Columns'),
                Text('• Set maxLines and overflow properties for Text widgets'),
                Text('• Use SingleChildScrollView for long content'),
                Text('• Implement responsive breakpoints'),
                Text('• Use LayoutBuilder for adaptive layouts'),
                Text('• Constrain widget widths when necessary'),
                SizedBox(height: 16),
                Text(
                  'Best Practices:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Test on different screen sizes'),
                Text('• Use percentage-based padding/margins'),
                Text('• Implement proper text scaling'),
                Text('• Handle orientation changes'),
                Text('• Use SafeArea for system UI overlap'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}
