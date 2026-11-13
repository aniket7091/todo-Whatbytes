import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/core/constants/app_colors.dart';

class TaskDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const TaskDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  Future<void> _openCalendar(BuildContext context) async {
    DateTime tempDate = selectedDate ?? DateTime.now();

    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 4,
                      width: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4E4EA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Choose Due Date',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(CupertinoIcons.xmark),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9FC),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: AppColors.darkText,
                          ),
                        ),
                        child: CalendarDatePicker(
                          initialDate: tempDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2035),
                          onDateChanged: (date) {
                            setModalState(() {
                              tempDate = date;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, tempDate);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Apply Date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      onDateSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate == null
        ? 'Select due date'
        : '${selectedDate!.day.toString().padLeft(2, '0')}/'
        '${selectedDate!.month.toString().padLeft(2, '0')}/'
        '${selectedDate!.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Due Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF34415B),
          ),
        ),
        const SizedBox(height: 9),
        InkWell(
          onTap: () => _openCalendar(context),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 17,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEAEAF0)),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.calendar,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dateText,
                    style: TextStyle(
                      fontSize: 13,
                      color: selectedDate == null
                          ? const Color(0xFF9CA3AF)
                          : AppColors.darkText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_down,
                  size: 16,
                  color: Color(0xFF9299A8),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}