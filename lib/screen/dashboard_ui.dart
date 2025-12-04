import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Make it responsive: 1 column on phone, 2–3 on tablet
    final bool isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'CRM Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isTablet ? 3 : 2, // 3 on tablet, 2 on phone
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.2, // Makes cards taller like iCloud
            children: const [
              _DashboardCard(
                icon: Icons.people_outline,
                title: 'Total Customers',
                value: '1,234',
                color: Colors.blue,
              ),
              _DashboardCard(
                icon: Icons.trending_up,
                title: 'Total Leads',
                value: '856',
                color: Colors.green,
              ),
              _DashboardCard(
                icon: Icons.check_circle_outline,
                title: 'Won Deals',
                value: '342',
                color: Colors.teal,
              ),
              _DashboardCard(
                icon: Icons.cancel_outlined,
                title: 'Lost Deals',
                value: '89',
                color: Colors.redAccent,
              ),
              _DashboardCard(
                icon: Icons.task_alt,
                title: 'Open Tasks',
                value: '67',
                color: Colors.orange,
              ),
              _DashboardCard(
                icon: Icons.schedule,
                title: 'Due Today',
                value: '12',
                color: Colors.purple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable card widget – this is what makes it look exactly like iCloud
class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top: icon + title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            // Bottom: big number
            Text(
              value,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
