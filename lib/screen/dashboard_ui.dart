import 'package:crm/screens/pdf_export_screen.dart';
import 'package:crm/screens/settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:crm/screens/customer_list_screen.dart';
import 'package:crm/screens/leads_list_screen.dart';
import 'package:crm/screens/task_list_screen.dart';
import 'package:crm/services/dashboard_service.dart';
import 'package:crm/utils/responsive.dart';
import '../models/task.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isRailExtended = false;

  String get _title {
    switch (_selectedIndex) {
      case 1:
        return 'Customers';
      case 2:
        return 'Leads';
      case 3:
        return 'Tasks';
      case 4:
        return 'Settings';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildBody(bool isWide) {
    switch (_selectedIndex) {
      case 1:
        return const CustomerListScreen();
      case 2:
        return const LeadsListScreen();
      case 3:
        return const TasksListScreen();
      case 4:
        return const SettingsScreen();
      default:
        return _DashboardGrid(isWide: isWide);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);
    final isWide = MediaQuery.of(context).size.width >= 1000;
    final enableHover = kIsWeb && isDesktop;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
  backgroundColor: Colors.white,
  foregroundColor: const Color(0xFF262626),
  elevation: 0,
  title: Text('CRM – $_title'),
  actions: [
    Tooltip(
      message: 'Export CRM Report',
      child: IconButton(
        icon: const Icon(
          Icons.picture_as_pdf,
          color: Colors.redAccent,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PdfExportScreen(),
            ),
          );
        },
      ),
    ),
    const SizedBox(width: 8),
  ],
),

      bottomNavigationBar: isMobile ? _buildBottomNav() : null,
      body: isMobile
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: _buildBody(false),
            )
          : Row(
              children: [
                enableHover
                    ? MouseRegion(
                        onEnter: (_) =>
                            setState(() => _isRailExtended = true),
                        onExit: (_) =>
                            setState(() => _isRailExtended = false),
                        child: _buildNavigationRail(),
                      )
                    : _buildNavigationRail(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildBody(isWide),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNavigationRail() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isRailExtended ? 200 : 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE4E1EC))),
      ),
      child: NavigationRail(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        extended: _isRailExtended,
        backgroundColor: Colors.white,
        destinations: const [
          NavigationRailDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: Text('Dashboard')),
          NavigationRailDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: Text('Customers')),
          NavigationRailDestination(
              icon: Icon(Icons.scatter_plot_outlined),
              selectedIcon: Icon(Icons.scatter_plot),
              label: Text('Leads')),
          NavigationRailDestination(
              icon: Icon(Icons.task_alt_outlined),
              selectedIcon: Icon(Icons.task_alt),
              label: Text('Tasks')),
          NavigationRailDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: Text('Settings')),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
        BottomNavigationBarItem(icon: Icon(Icons.scatter_plot), label: 'Leads'),
        BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Tasks'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}

// ================= DASHBOARD GRID =================

class _DashboardGrid extends StatelessWidget {
  final bool isWide;
  const _DashboardGrid({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final service = DashboardService();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isWide ? 3 : 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.2,
            children: [
              _stat('Customers', Icons.people, Colors.indigo,
                  service.customersCount()),
              _stat('Leads', Icons.trending_up, Colors.green,
                  service.leadsCount()),
              _stat('Won Deals', Icons.check_circle, Colors.teal,
                  service.leadsByStatus('Won')),
              _stat('Lost Deals', Icons.cancel, Colors.redAccent,
                  service.leadsByStatus('Lost')),
              _stat('Tasks', Icons.task_alt, Colors.orange,
                  service.tasksCount()),
              _stat('Completed', Icons.done_all, Colors.green,
                  service.completedTasksCount()),
            ],
          ),
          const SizedBox(height: 32),

          /// TODAY
          _FollowUpSection(
            title: "Today's Follow-ups",
            stream: service.todayTasks(),
            emptyText: "No follow-ups today 🎉",
            filter: TaskFilter.today,
          ),

          const SizedBox(height: 24),

          /// OVERDUE
          _FollowUpSection(
            title: "Overdue Tasks",
            stream: service.overdueTasks(),
            emptyText: "No overdue tasks",
            filter: TaskFilter.overdue,
          ),
        ],
      ),
    );
  }

  Widget _stat(
      String title, IconData icon, Color color, Stream<int> stream) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (_, snap) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 8),
                Text(title),
                Text(
                  (snap.data ?? 0).toString(),
                  style:
                      const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================= FOLLOW-UP SECTION =================

class _FollowUpSection extends StatelessWidget {
  final String title;
  final Stream<List<Task>> stream;
  final String emptyText;
  final TaskFilter filter;

  const _FollowUpSection({
    required this.title,
    required this.stream,
    required this.emptyText,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        StreamBuilder<List<Task>>(
          stream: stream,
          builder: (_, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text(emptyText,
                  style: TextStyle(color: Colors.grey[600]));
            }

            return Column(
              children: snapshot.data!.map((task) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active,
                        color: Colors.orange),
                    title: Text(task.title),
                    subtitle: task.dueDate != null
                        ? Text(
                            'Due: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}')
                        : const Text('No due date'),
                    onTap: () {
                                 Navigator.push(
                                     context,
                                    MaterialPageRoute(
                                builder: (_) => TasksListScreen(
                            showBack: true,        // ✅ SHOW BACK ARROW
                            initialFilter: filter, // ✅ Today / Overdue
                             ),
                            ),
                           );
                         },

                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
