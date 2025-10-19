import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

/// Bar Chart Component for GivingBridge
///
/// A professional bar chart for comparing categories or groups.
///
/// Features:
/// - Vertical or horizontal orientation
/// - Multiple bar groups support
/// - Interactive touch tooltips
/// - Gradient bar colors
/// - Grid lines and labels
/// - Customizable colors and styling
///
/// Usage:
/// ```dart
/// GBBarChart(
///   data: [
///     GBBarChartData(
///       label: 'Food',
///       value: 45,
///       color: DesignSystem.primaryBlue,
///     ),
///     GBBarChartData(
///       label: 'Clothing',
///       value: 30,
///       color: DesignSystem.secondaryGreen,
///     ),
///   ],
///   title: 'Donations by Category',
/// )
/// ```
class GBBarChart extends StatefulWidget {
  /// List of bars to display
  final List<GBBarChartData> data;

  /// Chart title (optional)
  final String? title;

  /// Chart height
  final double height;

  /// Whether to show grid lines
  final bool showGrid;

  /// Whether to show values on bars
  final bool showValues;

  /// Enable touch interaction
  final bool enableTouch;

  /// Horizontal orientation (default is vertical)
  final bool horizontal;

  /// Maximum value (auto-calculated if null)
  final double? maxValue;

  const GBBarChart({
    Key? key,
    required this.data,
    this.title,
    this.height = 300,
    this.showGrid = true,
    this.showValues = true,
    this.enableTouch = true,
    this.horizontal = false,
    this.maxValue,
  }) : super(key: key);

  @override
  State<GBBarChart> createState() => _GBBarChartState();
}

class _GBBarChartState extends State<GBBarChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return SizedBox(
        height: widget.height,
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
          height: widget.height,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
            child: BarChart(
              BarChartData(
                maxY: widget.maxValue ?? _calculateMaxValue(),
                barGroups: _buildBarGroups(),
                titlesData: _buildTitles(),
                gridData: _buildGridData(),
                borderData: _buildBorderData(),
                barTouchData: widget.enableTouch
                    ? _buildTouchData()
                    : BarTouchData(enabled: false),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = _touchedIndex == index;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.value,
            color: item.color,
            width: isTouched ? 28 : 22,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            gradient: LinearGradient(
              colors: [
                item.color,
                item.color.withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: widget.maxValue ?? _calculateMaxValue(),
              color: DesignSystem.neutral200.withOpacity(0.3),
            ),
          ),
        ],
        showingTooltipIndicators: isTouched ? [0] : [],
      );
    }).toList();
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: DesignSystem.bodySmall(context).copyWith(
                color: DesignSystem.textSecondary,
                fontSize: 11,
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < widget.data.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  widget.data[index].label,
                  style: DesignSystem.bodySmall(context).copyWith(
                    color: DesignSystem.textSecondary,
                    fontSize: 11,
                    fontWeight: _touchedIndex == index
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: widget.showGrid,
      drawVerticalLine: false,
      horizontalInterval: _calculateInterval(),
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: DesignSystem.border.withOpacity(0.3),
          strokeWidth: 1,
        );
      },
    );
  }

  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border(
        left: BorderSide(color: DesignSystem.border, width: 1),
        bottom: BorderSide(color: DesignSystem.border, width: 1),
      ),
    );
  }

  BarTouchData _buildTouchData() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem(
            '${widget.data[groupIndex].label}\n',
            DesignSystem.bodySmall(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: rod.toY.toStringAsFixed(0),
                style: DesignSystem.bodyMedium(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
        },
      ),
      touchCallback: (event, response) {
        setState(() {
          if (response != null && response.spot != null) {
            _touchedIndex = response.spot!.touchedBarGroupIndex;
          } else {
            _touchedIndex = null;
          }
        });
      },
    );
  }

  double _calculateMaxValue() {
    if (widget.data.isEmpty) return 100;

    double max = 0;
    for (var item in widget.data) {
      if (item.value > max) max = item.value;
    }

    // Round up to nearest 10 and add 20% padding
    return ((max * 1.2) / 10).ceil() * 10.0;
  }

  double _calculateInterval() {
    final maxValue = widget.maxValue ?? _calculateMaxValue();
    return maxValue / 5; // 5 grid lines
  }
}

/// Data model for a single bar
class GBBarChartData {
  final String label;
  final double value;
  final Color color;
  final String? subtitle;

  GBBarChartData({
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  /// Factory for category data
  factory GBBarChartData.category({
    required String name,
    required double count,
    required Color color,
  }) {
    return GBBarChartData(
      label: name,
      value: count,
      color: color,
    );
  }

  /// Factory for status data
  factory GBBarChartData.status({
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

    return GBBarChartData(
      label: status,
      value: count,
      color: color,
    );
  }

  /// Factory for role data
  factory GBBarChartData.userRole({
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

    return GBBarChartData(
      label: role,
      value: count,
      color: color,
    );
  }
}
