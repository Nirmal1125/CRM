import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isRailExtended = false; // controls expanded/collapsed on hover

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
        return _DashboardGrid(isWide: isWide);
      case 1:
        return const Center(child: Text('Customers screen goes here'));
      case 2:
        return const Center(child: Text('Leads screen goes here'));
      case 3:
        return const Center(child: Text('Tasks screen goes here'));
      case 4:
        return const Center(child: Text('Settings screen goes here'));
      default:
        return _DashboardGrid(isWide: isWide);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isWide = width > 900; // still used for grid layout

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
        centerTitle: false,
      ),
      body: Row(
        children: [
          // SIDE NAV WITH HOVER BEHAVIOUR
          MouseRegion(
            onEnter: (_) {
              setState(() => _isRailExtended = true);
            },
            onExit: (_) {
              setState(() => _isRailExtended = false);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: _isRailExtended ? 200 : 72,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(color: Color(0xFFE4E1EC), width: 1),
                ),
              ),
              child: NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                backgroundColor: Colors.white,
                extended: _isRailExtended, // <-- key part
                minExtendedWidth: 190,
                selectedIconTheme: const IconThemeData(
                  color: Color(0xFF3F51B5), // Indigo
                ),
                unselectedIconTheme: const IconThemeData(
                  color: Color(0xFF7A7A7A),
                ),
                selectedLabelTextStyle: const TextStyle(
                  color: Color(0xFF3F51B5),
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelTextStyle: const TextStyle(
                  color: Color(0xFF7A7A7A),
                ),
                leading: Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    bottom: 24,
                    left: 8,
                    right: 8,
                  ),
                  child:
                      _isRailExtended
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
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: Text('Settings'),
                  ),
                ],
              ),
            ),
          ),

          // MAIN CONTENT
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
}

class _DashboardGrid extends StatelessWidget {
  final bool isWide;

  const _DashboardGrid({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = isWide ? 3 : 2;

    return SingleChildScrollView(
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.2,
        children: const [
          _DashboardCard(
            icon: Icons.people_outline,
            title: 'Total Customers',
            value: '1,234',
            color: Color(0xFF3F51B5), // Indigo
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
    );
  }
}

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
        color: const Color(0xFFF8F9FF), // light indigo-tinted card
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0xFFE4E1EC)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF262626),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFF262626),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
