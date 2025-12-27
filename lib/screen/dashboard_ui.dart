import 'package:crm/screens/customer_list_screen.dart';
import 'package:crm/screens/leads_list_screen.dart';
import 'package:crm/utils/responsive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
      case 0:
        return 'Dashboard';
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
      case 0:
        return SizedBox.expand(
          child: _DashboardGrid(isWide: isWide),
        );
      case 1:
        return const CustomerListScreen();
      case 2:
        return const LeadsListScreen();
      case 3:
        return const Center(child: Text('Tasks screen goes here'));
      case 4:
        return const Center(child: Text('Settings screen goes here'));
      default:
        return SizedBox.expand(
          child: _DashboardGrid(isWide: isWide),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);
    final isWide = MediaQuery.of(context).size.width >= 900;
    final enableHover = kIsWeb && isDesktop;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF262626),
        title: Text(
          'CRM – $_title',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),

      bottomNavigationBar: isMobile ? _buildBottomNav() : null,

      body: isMobile
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildBody(false),
              ),
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
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildBody(isWide),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // =========================
  // NAVIGATION RAIL
  // =========================
  Widget _buildNavigationRail() {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: _isRailExtended ? 200 : 72,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(
        right: BorderSide(color: Color(0xFFE4E1EC)),
      ),
    ),
    child: NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
      },
      extended: _isRailExtended,
      backgroundColor: Colors.white,
      minExtendedWidth: 190,
      labelType: NavigationRailLabelType.none,

      leading: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        child: _isRailExtended
            ? const Text(
                'CRM Panel',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF262626),
                ),
              )
            : const Icon(
                Icons.dashboard_outlined,
                color: Color(0xFF3F51B5),
              ),
      ),

      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.space_dashboard_outlined),
          selectedIcon: Icon(Icons.space_dashboard),
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
    ),
  );
}


  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF3F51B5),
      unselectedItemColor: const Color(0xFF7A7A7A),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.space_dashboard_outlined),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          label: 'Customers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.scatter_plot_outlined),
          label: 'Leads',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.task_alt_outlined),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
    );
  }
}

// =========================
// DASHBOARD GRID
// =========================
class _DashboardGrid extends StatelessWidget {
  final bool isWide;
  const _DashboardGrid({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 3 : 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        const cards = [
          _DashboardCard(
            icon: Icons.people_outline,
            title: 'Total Customers',
            value: '1,234',
            color: Color(0xFF3F51B5),
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
        ];
        return cards[index];
      },
    );
  }
}

// =========================
// DASHBOARD CARD
// =========================
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E1EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title)),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
