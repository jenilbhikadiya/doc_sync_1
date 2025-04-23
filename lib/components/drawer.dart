// animated_drawer.dart
import 'package:doc_sync_1/Screens/operations/task_history.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math; // For clamping
// Import the new page
import '../Screens/home_screen.dart';
// import '../Screens/masters/client_master.dart';
import '../Screens/masters/client_master.dart';
import '../Screens/operations/add_new_task/add_new_task.dart';
import '../Screens/operations/admin_verification.dart';
import '../Screens/operations/task_created.dart';

// Define theme colors based on the image
const Color _drawerBackgroundColor = Color(0xFFF0F4F8); // Light grayish blue
const Color _iconTextColor = Color(0xFF0D47A1); // Dark Blue (adjust as needed)
const Color _selectedBackgroundColor = Color(
  0xFFE3F2FD,
); // Light Blue for selection/hover (used for sub-items now)
const Color _arrowColor = Color(0xFF64B5F6); // Lighter blue for arrows

class AnimatedDrawer extends StatefulWidget {
  const AnimatedDrawer({super.key});

  @override
  _AnimatedDrawerState createState() => _AnimatedDrawerState();
}

class _AnimatedDrawerState extends State<AnimatedDrawer>
    with TickerProviderStateMixin {
  late AnimationController _drawerOpenController;

  // State to control expansion tiles
  bool _isOperationsExpanded = false;
  // *** CHANGE HERE: Set Masters to closed initially ***
  bool _isMastersExpanded = false;
  bool _isUserLogsExpanded = false;
  bool _isReportsExpanded = false;

  // Define durations for staggering top-level items
  static const Duration _initialDelay = Duration(milliseconds: 50);
  static const Duration _itemFadeDuration = Duration(milliseconds: 300);
  static const Duration _staggerDelay = Duration(milliseconds: 60);
  static const Duration _drawerOpenDuration = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    _drawerOpenController = AnimationController(
      vsync: this,
      duration: _drawerOpenDuration,
    );
    _drawerOpenController.forward();
  }

  @override
  void dispose() {
    _drawerOpenController.dispose();
    super.dispose();
  }

  // --- Helper for Animated Top-Level Items (ListTile or ExpansionTile Header) ---
  Widget _buildAnimatedTopLevelItem({
    required int index,
    required Widget child,
  }) {
    final double totalDurationMs =
        _drawerOpenController.duration!.inMilliseconds.toDouble();
    final double itemStartMs =
        (_initialDelay + _staggerDelay * index).inMilliseconds.toDouble();
    final double itemDurationMs = _itemFadeDuration.inMilliseconds.toDouble();

    final double start = math.min(itemStartMs / totalDurationMs, 1.0);
    final double end = math.min(
      (itemStartMs + itemDurationMs) / totalDurationMs,
      1.0,
    );
    final validStart = math.min(start, end);

    final Animation<double> itemFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _drawerOpenController,
        curve: Interval(validStart, end, curve: Curves.easeOut),
      ),
    );

    final Animation<Offset> itemSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.2, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _drawerOpenController,
        curve: Interval(validStart, end, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: itemFadeAnimation,
      child: SlideTransition(position: itemSlideAnimation, child: child),
    );
  }

  // --- Helper for Sub-Items (simple ListTile) ---
  Widget _buildSubMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20, color: _iconTextColor.withOpacity(0.8)),
      title: Text(
        title,
        style: TextStyle(
          color: _iconTextColor.withOpacity(0.9),
          fontSize: 14.5,
          fontWeight: FontWeight.w400,
        ),
      ),
      dense: true,
      onTap: onTap,
      selected: isSelected,
      // Use selected color for sub-item selection feedback if needed
      selectedTileColor: _selectedBackgroundColor.withOpacity(0.5),
      contentPadding: const EdgeInsets.only(left: 45.0, right: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      hoverColor: _selectedBackgroundColor.withOpacity(0.3), // Add hover effect
    );
  }

  @override
  Widget build(BuildContext context) {
    int topLevelIndex = 0;

    return Drawer(
      backgroundColor: _drawerBackgroundColor,
      elevation: 2,
      child: Column(
        children: <Widget>[
          // --- Optional: Drawer Header ---
          SizedBox(
            height: 100,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: _drawerBackgroundColor,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              margin: EdgeInsets.zero,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'MENU',
                  style: TextStyle(
                    color: _iconTextColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // --- Scrollable Content Area ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              children: [
                // 1. Dashboard
                _buildAnimatedTopLevelItem(
                  index: topLevelIndex++,
                  child: ListTile(
                    leading: const Icon(
                      Icons.dashboard_outlined,
                      color: _iconTextColor,
                    ),
                    title: const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: _iconTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.push(
                        // << PUSHING A NEW ROUTE
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const HomeScreen(), // << CREATES A NEW INSTANCE
                        ),
                      );
                      print('Dashboard'); // Typo fixed
                    },
                    selected: false,
                    selectedTileColor:
                        _selectedBackgroundColor, // Keep for potential top-level selection
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hoverColor: _selectedBackgroundColor, // Add hover effect
                  ),
                ),
                const SizedBox(height: 5),

                // 2. Operations (Expandable)
                _buildAnimatedTopLevelItem(
                  index: topLevelIndex++,
                  child: ExpansionTile(
                    leading: const Icon(
                      Icons.settings_outlined,
                      color: _iconTextColor,
                    ),
                    title: const Text(
                      'Operations',
                      style: TextStyle(
                        color: _iconTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      _isOperationsExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: _arrowColor,
                    ),
                    backgroundColor:
                        _drawerBackgroundColor, // Match main background
                    collapsedBackgroundColor:
                        _drawerBackgroundColor, // Match main background
                    collapsedIconColor: _arrowColor,
                    iconColor: _arrowColor,
                    initiallyExpanded: _isOperationsExpanded,
                    onExpansionChanged:
                        (bool expanding) =>
                            setState(() => _isOperationsExpanded = expanding),
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 0,
                    ),
                    childrenPadding: const EdgeInsets.only(
                      bottom: 5,
                      left: 5,
                      right: 5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ), // Applied when expanded
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ), // Applied when collapsed
                    children: <Widget>[
                      _buildSubMenuItem(
                        icon: Icons.add_circle_outline,
                        title: 'Add New Task',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddNewTaskPage(),
                            ),
                          );
                          print('Add New Task Tapped & Navigated');
                        },
                      ),
                      _buildSubMenuItem(
                        icon: Icons.playlist_add_check_circle_outlined,
                        title: 'Task Created',
                        onTap: () {
                          Navigator.pop(context); // Close the drawer
                          Navigator.push(
                            // << PUSHING A NEW ROUTE
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const TaskCreated(), // << CREATES A NEW INSTANCE
                            ),
                          );
                          print(
                            'Task Created Tapped & Navigated',
                          ); // Typo fixed
                        },
                      ),
                      _buildSubMenuItem(
                        icon: Icons.verified_user_outlined,
                        title: 'Admin Verification',
                        onTap: () {
                          Navigator.pop(context); // Close the drawer
                          Navigator.push(
                            // << PUSHING A NEW ROUTE
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const AdminVerification(), // << CREATES A NEW INSTANCE
                            ),
                          );
                          print('Admin Verification'); // Typo fixed
                        },
                      ),
                      _buildSubMenuItem(
                        icon: Icons.history_outlined,
                        title: 'Task History',
                        onTap: () {
                          Navigator.pop(context); // Close the drawer
                          Navigator.push(
                            // << PUSHING A NEW ROUTE
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const TaskHistoryScreen(), // << CREATES A NEW INSTANCE
                            ),
                          );
                          print('Task History'); // Typo fixed
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),

                // 3. Masters (Expandable)
                // *** CHANGE HERE: Removed the Container wrapper ***
                _buildAnimatedTopLevelItem(
                  index: topLevelIndex++,
                  child: ExpansionTile(
                    // Now directly the child
                    leading: const Icon(
                      Icons.settings_suggest_outlined,
                      color: _iconTextColor,
                    ),
                    title: const Text(
                      'Masters',
                      style: TextStyle(
                        color: _iconTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      _isMastersExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: _arrowColor,
                    ),
                    backgroundColor:
                        _drawerBackgroundColor, // Consistent background
                    collapsedBackgroundColor:
                        _drawerBackgroundColor, // Consistent background
                    collapsedIconColor: _arrowColor,
                    iconColor: _arrowColor,
                    initiallyExpanded:
                        _isMastersExpanded, // Will now be false initially
                    onExpansionChanged:
                        (bool expanding) =>
                            setState(() => _isMastersExpanded = expanding),
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 0,
                    ),
                    childrenPadding: const EdgeInsets.only(
                      bottom: 5,
                      left: 5,
                      right: 5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ), // Consistent shape
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ), // Consistent shape
                    children: <Widget>[
                      _buildSubMenuItem(
                        icon: Icons.person_outline,
                        title: 'Client',
                        onTap: () {
                          Navigator.pop(context); // Close the drawer
                          Navigator.push(
                            // << PUSHING A NEW ROUTE
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ClientMaster(),
                            ),
                          );
                          print('Client Masters'); // Typo fixed
                        },
                      ),
                      _buildSubMenuItem(
                        icon: Icons.group_outlined,
                        title: 'Group',
                        onTap: () {
                          Navigator.pop(context);
                          print('Group');
                        },
                      ),
                      _buildSubMenuItem(
                        icon: Icons.task_alt_outlined,
                        title: 'Task Master',
                        onTap: () {
                          Navigator.pop(context);
                          print('Task Master');
                        },
                      ),
                      _buildSubMenuItem(
                        icon: Icons.dynamic_feed_outlined,
                        title: 'Sub Task',
                        onTap: () {
                          Navigator.pop(context);
                          print('Sub Task');
                        },
                      ),
                      _buildSubMenuItem(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Accountant',
                        onTap: () {
                          Navigator.pop(context);
                          print('Accountant');
                        },
                      ),
                      _buildSubMenuItem(
                        icon: Icons.calendar_today_outlined,
                        title: 'Financial year',
                        onTap: () {
                          Navigator.pop(context);
                          print('Financial year');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),

                // 4. User Logs (Expandable - visually)
                _buildAnimatedTopLevelItem(
                  index: topLevelIndex++,
                  child: ExpansionTile(
                    leading: const Icon(
                      Icons.history_toggle_off_outlined,
                      color: _iconTextColor,
                    ),
                    title: const Text(
                      'User Logs',
                      style: TextStyle(
                        color: _iconTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      _isUserLogsExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: _arrowColor,
                    ),
                    backgroundColor: _drawerBackgroundColor,
                    collapsedBackgroundColor: _drawerBackgroundColor,
                    collapsedIconColor: _arrowColor,
                    iconColor: _arrowColor,
                    initiallyExpanded: _isUserLogsExpanded,
                    onExpansionChanged:
                        (bool expanding) =>
                            setState(() => _isUserLogsExpanded = expanding),
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 0,
                    ),
                    childrenPadding: const EdgeInsets.only(
                      bottom: 5,
                      left: 5,
                      right: 5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    children: const <Widget>[], // Add children if needed later
                  ),
                ),
                const SizedBox(height: 5),

                // 5. Reports (Expandable - visually)
                _buildAnimatedTopLevelItem(
                  index: topLevelIndex++,
                  child: ExpansionTile(
                    leading: const Icon(
                      Icons.assessment_outlined,
                      color: _iconTextColor,
                    ),
                    title: const Text(
                      'Reports',
                      style: TextStyle(
                        color: _iconTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      _isReportsExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: _arrowColor,
                    ),
                    backgroundColor: _drawerBackgroundColor,
                    collapsedBackgroundColor: _drawerBackgroundColor,
                    collapsedIconColor: _arrowColor,
                    iconColor: _arrowColor,
                    initiallyExpanded: _isReportsExpanded,
                    onExpansionChanged:
                        (bool expanding) =>
                            setState(() => _isReportsExpanded = expanding),
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 0,
                    ),
                    childrenPadding: const EdgeInsets.only(
                      bottom: 5,
                      left: 5,
                      right: 5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    children: const <Widget>[], // Add children if needed later
                  ),
                ),
              ],
            ),
          ), // End Expanded
          // --- Footer Section ---
          const Divider(
            color: Colors.grey,
            indent: 15,
            endIndent: 15,
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 15.0,
            ),
            child: ListTile(
              leading: const Icon(Icons.logout_outlined, color: _iconTextColor),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: _iconTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                print('Logout tapped');
                // TODO: Implement Logout logic
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hoverColor: _selectedBackgroundColor, // Add hover effect
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
