import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

/// Pie Chart Component for GivingBridge
///
/// A professional pie/donut chart for showing distribution and percentages.
///
/// Features:
/// - Pie or donut mode
/// - Interactive touch highlights
/// - Percentage labels
/// - Color-coded segments
/// - Legend with values
/// - Center label for donut mode
///
/// Usage:
/// ```dart
/// GBPieChart(
///   data: [
///     GBPieChartData(
///       label: 'Food',
///       value: 45,
///       color: DesignSystem.primaryBlue,
///     ),
///     GBPieChartData(
///       label: 'Clothing',
///       value: 30,
///       color: DesignSystem.secondaryGreen,
///     ),
///   ],
///   title: 'Distribution by Category',
/// )
/// ```
class GBPieChart extends StatefulWidget {
  /// List of pie segments
  final List<GBPieChartData> data;

  /// Chart title (optional)
  final String? title;

  /// Chart size (diameter)
  final double size;

  /// Show as donut chart (hollow center)
  final bool isDonut;

  /// Show percentage on segments
  final bool showPercentages;

  /// Show legend
  final bool showLegend;

  /// Enable touch interaction
  final bool enableTouch;

  /// Center label text (for donut mode)
  final String? centerLabel;

  const GBPieChart({
    Key? key,
    required this.data,
    this.title,
    this.size = 200,
    this.isDonut = true,
    this.showPercentages = true,
    this.showLegend = true,
    this.enableTouch = true,
    this.centerLabel,
  }) : super(key: key);

  @override
  State<GBPieChart> createState() => _GBPieChartState();
}

class _GBPieChartState extends State<GBPieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return SizedBox(
        height: widget.size,
        child: Center(
          child: Text(
            'No data available',
            style: DesignSystem.bodyMedium(context).copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        if (widget.title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              widget.title!,
              style: DesignSystem.titleMedium(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],

        // Chart
        SizedBox(
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: _buildSections(),
                  sectionsSpace: 2,
                  centerSpaceRadius: widget.isDonut ? widget.size / 4 : 0,
                  pieTouchData: widget.enableTouch
                      ? _buildTouchData()
                      : PieTouchData(enabled: false),
                ),
              ),
              // Center label for donut
              if (widget.isDonut && widget.centerLabel != null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.centerLabel!,
                      style: DesignSystem.headlineLarge(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: DesignSystem.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Total',
                      style: DesignSystem.bodySmall(context).copyWith(
                        color: DesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Legend
        if (widget.showLegend) ...[
          const SizedBox(height: DesignSystem.spaceM),
          _buildLegend(),
        ],
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    final total = widget.data.fold<double>(0, (sum, item) => sum + item.value);

    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = _touchedIndex == index;
      final percentage = (item.value / total * 100);

      return PieChartSectionData(
        value: item.value,
        color: item.color,
        title:
            widget.showPercentages ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? (widget.size / 3) : (widget.size / 3.5),
        titleStyle: DesignSystem.bodyMedium(context).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: isTouched ? 14 : 12,
        ),
        badgeWidget: isTouched
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: DesignSystem.elevation2,
                ),
                child: Text(
                  item.label,
                  style: DesignSystem.bodySmall(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: item.color,
                  ),
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  PieTouchData _buildTouchData() {
    return PieTouchData(
      touchCallback: (event, response) {
        setState(() {
          if (response != null && response.touchedSection != null) {
            _touchedIndex = response.touchedSection!.touchedSectionIndex;
          } else {
            _touchedIndex = null;
          }
        });
      },
    );
  }

  Widget _buildLegend() {
    final total = widget.data.fold<double>(0, (sum, item) => sum + item.value);

    return Wrap(
      spacing: DesignSystem.spaceM,
      runSpacing: DesignSystem.spaceS,
      children: widget.data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final percentage = (item.value / total * 100);
        final isTouched = _touchedIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              _touchedIndex = _touchedIndex == index ? null : index;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color:
                  isTouched ? item.color.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              border: Border.all(
                color: isTouched ? item.color : DesignSystem.border,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: DesignSystem.spaceXS),
                Text(
                  item.label,
                  style: DesignSystem.bodySmall(context).copyWith(
                    color: DesignSystem.textPrimary,
                    fontWeight: isTouched ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: DesignSystem.spaceXS),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: DesignSystem.bodySmall(context).copyWith(
                    color: DesignSystem.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: DesignSystem.spaceXS),
                Text(
                  '(${item.value.toInt()})',
                  style: DesignSystem.bodySmall(context).copyWith(
                    color: DesignSystem.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Data model for a pie chart segment
class GBPieChartData {
  final String label;
  final double value;
  final Color color;

  GBPieChartData({
    required this.label,
    required this.value,
    required this.color,
  });

  /// Factory for category distribution
  factory GBPieChartData.category({
    required String name,
    required double count,
    required Color color,
  }) {
    return GBPieChartData(
      label: name,
      value: count,
      color: color,
    );
  }

  /// Factory for status distribution
  factory GBPieChartData.status({
    required String status,
    required double count,
  }) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = DesignSystem.warning;
        break;
      case 'approved':
        color = DesignSystem.primaryBlue;
        break;
      case 'completed':
        color = DesignSystem.success;
        break;
      case 'declined':
        color = DesignSystem.error;
        break;
      default:
        color = DesignSystem.neutral600;
    }

    return GBPieChartData(
      label: status,
      value: count,
      color: color,
    );
  }

  /// Factory for role distribution
  factory GBPieChartData.userRole({
    required String role,
    required double count,
  }) {
    Color color;
    switch (role.toLowerCase()) {
      case 'donor':
        color = DesignSystem.accentPink;
        break;
      case 'receiver':
        color = DesignSystem.secondaryGreen;
        break;
      case 'admin':
        color = DesignSystem.warning;
        break;
      default:
        color = DesignSystem.neutral600;
    }

    return GBPieChartData(
      label: role,
      value: count,
      color: color,
    );
  }
}
