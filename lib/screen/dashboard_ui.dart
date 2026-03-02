import 'package:crm/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../provider/dashboard_provider.dart';
import '../screens/pdf_export_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/customer_list_screen.dart';
import '../screens/leads_list_screen.dart';
import '../screens/task_list_screen.dart';
import '../utils/responsive.dart';

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
        return _DashboardContent(isWide: isWide);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);
    final isWide = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
        title: Text('CRM – $_title'),
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.redAccent),
                  tooltip: 'Export PDF',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PdfExportScreen(),
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      bottomNavigationBar: isMobile ? _buildBottomNav(context) : null,
      body: isMobile
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: _buildBody(false),
            )
          : Row(
              children: [
                _buildNavigationRail(context),
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

  // ================= NAVIGATION RAIL =================

  Widget _buildNavigationRail(BuildContext context) {
    final theme = Theme.of(context);

    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      minWidth: 80,
      minExtendedWidth: 220,
      extended: _isRailExtended,
      backgroundColor: theme.colorScheme.surface,
      useIndicator: true,
      indicatorColor: theme.colorScheme.primary.withOpacity(0.15),
      leading: IconButton(
        icon:
            Icon(_isRailExtended ? Icons.chevron_left : Icons.chevron_right),
        onPressed: () =>
            setState(() => _isRailExtended = !_isRailExtended),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: Text('Customers'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.scatter_plot_outlined),
          selectedIcon: Icon(Icons.scatter_plot),
          label: Text('Leads'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.task_alt_outlined),
          selectedIcon: Icon(Icons.task_alt),
          label: Text('Tasks'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.surface,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor:
          theme.colorScheme.onSurface.withOpacity(0.6),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(
            icon: Icon(Icons.people), label: 'Customers'),
        BottomNavigationBarItem(
            icon: Icon(Icons.scatter_plot), label: 'Leads'),
        BottomNavigationBarItem(
            icon: Icon(Icons.task_alt), label: 'Tasks'),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}

// ================= DASHBOARD CONTENT =================

class _DashboardContent extends StatelessWidget {
  final bool isWide;
  const _DashboardContent({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>(); // ✅ ADD

    return Consumer<DashboardProvider>(
      builder: (_, p, __) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DashboardGrid(isWide: isWide),

              // ================= REMINDERS =================
              if (settings.taskReminders) ...[
                const SizedBox(height: 32),
                _ReminderList(
                  title: "Today's Follow-ups",
                  tasks: p.todayTasks,
                  filter: TaskFilter.today,
                ),

                const SizedBox(height: 32),
                _ReminderList(
                  title: "Overdue Tasks",
                  tasks: p.overdueTasks,
                  filter: TaskFilter.overdue,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ================= REMINDERS =================

class _ReminderList extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final TaskFilter filter; // ✅ NEW

  const _ReminderList({
    required this.title,
    required this.tasks,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, yyyy');
    final timeFmt = DateFormat('h:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),

        if (tasks.isEmpty) const Text("No reminders"),

        ...tasks.map((task) {
          final due = task.dueDate;
          final dueText = due == null
              ? 'No due date'
              : '${dateFmt.format(due)} · ${timeFmt.format(due)}';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.notifications_active,
                color: Colors.orange,
              ),
              title: Text(
                task.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('Due: $dueText'),

              // ✅ FILTERED NAVIGATION
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TasksListScreen(
                      showBack: true,
                      initialFilter: filter,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
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
    final p = context.watch<DashboardProvider>();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isWide ? 3 : 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.05,
      children: [
        _stat(context, 'Customers', Icons.people,
            Colors.indigo, p.customers),
        _stat(context, 'Leads', Icons.trending_up,
            Colors.green, p.leads),
        _stat(context, 'Won Deals', Icons.check_circle,
            Colors.teal, p.wonLeads),
        _stat(context, 'Lost Deals', Icons.cancel,
            Colors.redAccent, p.lostLeads),
        _stat(context, 'Tasks', Icons.task_alt,
            Colors.orange, p.tasksCount),
        _stat(context, 'Completed', Icons.done_all,
            Colors.green, p.completedTasksCount),
      ],
    );
  }

  Widget _stat(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    int value,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // ✅ OLD UI RESTORED
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(title),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
