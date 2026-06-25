import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile/core/utils/app_colors.dart';
import 'package:mobile/features/reports/presentation/widgets/animated_weekly_bar_chart.dart';
import 'package:mobile/features/reports/presentation/widgets/report_section_header.dart';

class _WeeklyMetric {
  const _WeeklyMetric({
    required this.label,
    required this.values,
    required this.insight,
    required this.selectedDayMessage,
  });

  final String label;
  final List<int> values;
  final String insight;
  final String Function(int dayIndex, int value) selectedDayMessage;
}

const List<_WeeklyMetric> _mockMetrics = [
  _WeeklyMetric(
    label: 'Cảnh báo',
    values: [0, 1, 0, 2, 0, 1, 0],
    insight: 'Không có cảnh báo khẩn cấp trong tuần này.',
    selectedDayMessage: _formatAlertMessage,
  ),
  _WeeklyMetric(
    label: 'Khẩn cấp',
    values: [0, 0, 0, 1, 0, 0, 0],
    insight: 'Không có sự kiện khẩn cấp nào ngoại trừ thứ 5.',
    selectedDayMessage: _formatEmergencyMessage,
  ),
  _WeeklyMetric(
    label: 'Phản hồi',
    values: [0, 1, 0, 2, 0, 1, 0],
    insight: 'Các phản hồi giúp hệ thống cải thiện độ chính xác.',
    selectedDayMessage: _formatFeedbackMessage,
  ),
  _WeeklyMetric(
    label: 'Thời gian',
    values: [0, 35, 0, 42, 0, 28, 0],
    insight: 'Thời gian phản hồi trung bình đang ổn định.',
    selectedDayMessage: _formatTimeMessage,
  ),
];

String _getDayName(int index) =>
    const ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][index];

String _formatAlertMessage(int dayIndex, int value) {
  if (value == 0) return 'Không có cảnh báo trong ngày này.';
  return '${_getDayName(dayIndex)} có $value cảnh báo được ghi nhận.';
}

String _formatEmergencyMessage(int dayIndex, int value) {
  if (value == 0) return 'Không có cảnh báo khẩn cấp trong ngày này.';
  return '${_getDayName(dayIndex)} có $value cảnh báo khẩn cấp.';
}

String _formatFeedbackMessage(int dayIndex, int value) {
  if (value == 0) return 'Không có phản hồi trong ngày này.';
  return '${_getDayName(dayIndex)} có $value phản hồi từ gia đình.';
}

String _formatTimeMessage(int dayIndex, int value) {
  if (value == 0) return 'Không có dữ liệu thời gian trong ngày này.';
  return 'Thời gian phản hồi trung bình ${_getDayName(dayIndex)} là $value giây.';
}

class WeeklyTrendChartCard extends StatefulWidget {
  const WeeklyTrendChartCard({super.key});

  @override
  State<WeeklyTrendChartCard> createState() => _WeeklyTrendChartCardState();
}

class _WeeklyTrendChartCardState extends State<WeeklyTrendChartCard> {
  int _selectedMetricIndex = 0;
  int _selectedDayIndex = 3; // Default to Thursday based on mock data max
  String _selectedWeekScope = 'Tuần này';

  void _onMetricChanged(int index) {
    if (_selectedMetricIndex == index) return;
    setState(() {
      _selectedMetricIndex = index;
      // Auto-select the day with highest value for the new metric
      final values = _mockMetrics[index].values;
      int maxVal = -1;
      int maxIdx = 6; // default to today (sunday)
      for (int i = 0; i < values.length; i++) {
        if (values[i] > maxVal) {
          maxVal = values[i];
          maxIdx = i;
        }
      }
      _selectedDayIndex = maxIdx;
    });
  }

  void _onDaySelected(int index) {
    setState(() => _selectedDayIndex = index);
  }

  void _onWeekScopeChanged(String scope) {
    setState(() => _selectedWeekScope = scope);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final metric = _mockMetrics[_selectedMetricIndex];
    final maxValue = metric.values.reduce(max);
    final selectedDayValue = metric.values[_selectedDayIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportSectionHeader(
          title: 'Xu hướng 7 ngày',
          actionWidget: PopupMenuButton<String>(
            initialValue: _selectedWeekScope,
            onSelected: _onWeekScopeChanged,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            position: PopupMenuPosition.under,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedWeekScope,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark
                          ? theme.colorScheme.onSurface
                          : AppColors.darkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: isDark
                        ? theme.colorScheme.onSurfaceVariant
                        : AppColors.mutedText,
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Tuần này', child: Text('Tuần này')),
              PopupMenuItem(value: 'Tuần trước', child: Text('Tuần trước')),
              PopupMenuItem(
                value: '7 ngày gần nhất',
                child: Text('7 ngày gần nhất'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: List.generate(_mockMetrics.length, (index) {
              final isSelected = _selectedMetricIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () => _onMetricChanged(index),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                                ? theme.colorScheme.surfaceContainerHighest
                                : Colors.transparent),
                      border: isSelected || isDark
                          ? null
                          : Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: theme.textTheme.labelLarge!.copyWith(
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? theme.colorScheme.onSurfaceVariant
                                  : AppColors.mutedText),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                      child: Text(_mockMetrics[index].label),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface : AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: isDark
                ? Border.all(color: theme.colorScheme.outline)
                : Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedWeeklyBarChart(
                values: metric.values,
                maxValue: maxValue,
                selectedIndex: _selectedDayIndex,
                onDaySelected: _onDaySelected,
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  key: ValueKey<String>(
                    '$_selectedMetricIndex-$_selectedDayIndex',
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.surfaceContainerHighest
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    metric.selectedDayMessage(
                      _selectedDayIndex,
                      selectedDayValue,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? theme.colorScheme.onSurface
                          : AppColors.darkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  metric.insight,
                  key: ValueKey<String>(metric.insight),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? theme.colorScheme.onSurfaceVariant
                        : AppColors.mutedText,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
