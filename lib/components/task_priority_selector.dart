import 'package:flutter/material.dart';

class TaskPrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final ValueChanged<String> onChanged;

  const TaskPrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onChanged,
  });

  Widget _priorityButton(String priority, Color color) {
    final isSelected = selectedPriority == priority;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(priority),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.13) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? color
                  : const Color(0xFFEAEAF0),
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  priority,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? color
                        : const Color(0xFF9299A8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF34415B),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _priorityButton('Low', const Color(0xFF62B98A)),
            const SizedBox(width: 10),
            _priorityButton('Medium', const Color(0xFFE7A844)),
            const SizedBox(width: 10),
            _priorityButton('High', const Color(0xFFE47777)),
          ],
        ),
      ],
    );
  }
}