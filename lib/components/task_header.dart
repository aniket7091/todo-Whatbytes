import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:todo/core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';

class TaskHeader extends StatefulWidget {
  const TaskHeader({super.key});

  @override
  State<TaskHeader> createState() => _TaskHeaderState();
}

class _TaskHeaderState extends State<TaskHeader> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  void _showUserProfile(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final taskProvider = context.read<TaskProvider>();
    final userEmail = authProvider.user?.email ?? 'User';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E4EA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Avatar & Email
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: Text(
                    userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  userEmail,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Firebase Account',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.lightText,
                  ),
                ),

                const SizedBox(height: 20),

                // Quick stats row
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Total', taskProvider.totalCount.toString()),
                      Container(height: 28, width: 1, color: const Color(0xFFE0E0E8)),
                      _buildStatItem('Pending', taskProvider.pendingCount.toString()),
                      Container(height: 28, width: 1, color: const Color(0xFFE0E0E8)),
                      _buildStatItem('Done', taskProvider.completedCount.toString()),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: Color(0xFFFFD5D5), width: 1.2),
                      backgroundColor: const Color(0xFFFFF7F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(CupertinoIcons.square_arrow_right, size: 18),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    onPressed: () async {
                      Navigator.pop(bottomSheetContext);
                      _confirmLogout(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.lightText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.darkText),
        ),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.lightText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF9291F5),
              Color(0xFF7776E9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Large Decorative Circle
            Positioned(
              left: -30,
              top: 60,
              child: Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Header Content
            Padding(
              padding: EdgeInsets.fromLTRB(18, topPadding + 10, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row
                  Row(
                    children: [
                      // Grid Icon / Brand
                      const Icon(
                        CupertinoIcons.square_grid_2x2,
                        color: Colors.white,
                        size: 22,
                      ),

                      const SizedBox(width: 14),

                      // Search Bar
                      Expanded(
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              context.read<TaskProvider>().setSearchQuery(val);
                            },
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.darkText,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search tasks...',
                              hintStyle: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB5B5B5),
                              ),
                              prefixIcon: const Icon(
                                CupertinoIcons.search,
                                size: 16,
                                color: Color(0xFFAAAAAA),
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        CupertinoIcons.clear_circled_solid,
                                        size: 16,
                                        color: Color(0xFFAAAAAA),
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        context.read<TaskProvider>().setSearchQuery('');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 9),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Profile / More Button
                      GestureDetector(
                        onTap: () => _showUserProfile(context),
                        child: Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.person_crop_circle,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Date
                  Text(
                    'Today, ${DateTime.now().day} ${_getMonth(DateTime.now().month)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE8E8FF),
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 2),

                  // Heading
                  Consumer<TaskProvider>(
                    builder: (context, provider, _) {
                      final pending = provider.pendingCount;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Tasks',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          if (pending > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$pending pending',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
