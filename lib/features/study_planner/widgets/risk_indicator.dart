import 'package:flutter/material.dart';
import '../study_planner_logic.dart';

class RiskIndicator extends StatelessWidget {
  final RiskLevel riskLevel;
  final String message;

  const RiskIndicator({
    super.key,
    required this.riskLevel,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (riskLevel) {
      RiskLevel.none => (Colors.green, Icons.check_circle, 'On Track'),
      RiskLevel.tight => (Colors.orange, Icons.warning_amber, 'Tight'),
      RiskLevel.high => (Colors.deepOrange, Icons.error_outline, 'High Risk'),
      RiskLevel.critical => (Colors.red, Icons.dangerous, 'Critical'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
