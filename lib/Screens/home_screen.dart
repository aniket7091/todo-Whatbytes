import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/Screens/calendar_tasks_screen.dart';
import 'package:todo/Screens/task_list_screen.dart';
import 'package:todo/core/constants/app_colors.dart';
import 'package:todo/components/task_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    TaskListScreen(),
    CalendarTasksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // Main Body
      body: Column(
        children: [
          // Custom Header Component
          const TaskHeader(),

          // Main Screen Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: screens[currentIndex],
            ),
          ),
        ],
      ),

      // Custom Bottom Navigation
      bottomNavigationBar: SizedBox(
        height: 100,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Navigation Bar Background
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 77,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(22),
                  ),
                  border: Border.all(
                    color: const Color(0xFFF0F0F3),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 18,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildNavItem(
                        icon: CupertinoIcons.list_bullet,
                        index: 0,
                      ),
                    ),

                    const SizedBox(width: 75),

                    Expanded(
                      child: _buildNavItem(
                        icon: CupertinoIcons.calendar,
                        index: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating Add Button
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: () {
                  context.push('/add-task');
                },
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.pencil,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation Item
  Widget _buildNavItem({
    required IconData icon,
    required int index,
  }) {
    final bool isSelected = currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.09)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected
                  ? AppColors.primary
                  : const Color(0xFFB5B7C3),
            ),
          ),
        ),
      ),
    );
  }
}
