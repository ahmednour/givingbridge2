import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

/// Line Chart Component for GivingBridge
///
/// A professional line chart for visualizing trends over time.
///
/// Features:
/// - Multiple data series support
/// - Interactive touch tooltips
/// - Gradient fills under lines
/// - Grid lines and labels
/// - Customizable colors and styling
/// - Responsive to container size
///
/// Usage:
/// ```dart
/// GBLineChart(
///   data: [
///     GBLineChartData(
///       name: 'Donations',
///       points: [
///         GBChartPoint(x: 1, y: 10),
///         GBChartPoint(x: 2, y: 15),
///       ],
///       color: DesignSystem.primaryBlue,
///     ),
///   ],
///   xLabels: ['Mon', 'Tue', 'Wed'],
///   yAxisTitle: 'Count',
/// )
/// ```
class GBLineChart extends StatefulWidget {
  /// List of data series to display
  final List<GBLineChartData> data;

  /// Labels for X-axis points
  final List<String> xLabels;

  /// Title for Y-axis (optional)
  final String? yAxisTitle;

  /// Title for X-axis (optional)
  final String? xAxisTitle;

  /// Whether to show grid lines
  final bool showGrid;

  /// Whether to show dots on data points
  final bool showDots;

  /// Whether to fill area under line
  final bool fillArea;

  /// Chart height
  final double height;

  /// Enable touch interaction
  final bool enableTouch;

  /// Minimum Y value (auto-calculated if null)
  final double? minY;

  /// Maximum Y value (auto-calculated if null)
  final double? maxY;

  const GBLineChart({
    Key? key,
    required this.data,
    required this.xLabels,
    this.yAxisTitle,
    this.xAxisTitle,
    this.showGrid = true,
    this.showDots = true,
    this.fillArea = true,
    this.height = 300,
    this.enableTouch = true,
    this.minY,
    this.maxY,
  }) : super(key: key);

  @override
  State<GBLineChart> createState() => _GBLineChartState();
}

class _GBLineChartState extends State<GBLineChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty || widget.xLabels.isEmpty) {
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
        // Y-axis title
        if (widget.yAxisTitle != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              widget.yAxisTitle!,
              style: DesignSystem.bodySmall(context).copyWith(
                color: DesignSystem.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],

        // Chart
        SizedBox(
          height: widget.height,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
            child: LineChart(
              LineChartData(
                minY: widget.minY ?? _calculateMinY(),
                maxY: widget.maxY ?? _calculateMaxY(),
                lineBarsData: _buildLineBars(),
                titlesData: _buildTitles(),
                gridData: _buildGridData(),
                borderData: _buildBorderData(),
                lineTouchData: widget.enableTouch
                    ? _buildTouchData()
                    : LineTouchData(enabled: false),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ),

        // X-axis title
        if (widget.xAxisTitle != null) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.xAxisTitle!,
                style: DesignSystem.bodySmall(context).copyWith(
                  color: DesignSystem.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],

        // Legend
        const SizedBox(height: DesignSystem.spaceM),
        _buildLegend(),
      ],
    );
  }

  List<LineChartBarData> _buildLineBars() {
    return widget.data.map((series) {
      return LineChartBarData(
        spots: series.points.map((point) => FlSpot(point.x, point.y)).toList(),
        isCurved: true,
        color: series.color,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: widget.showDots,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: series.color,
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: widget.fillArea
            ? BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    series.color.withOpacity(0.3),
                    series.color.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              )
            : BarAreaData(show: false),
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
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < widget.xLabels.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  widget.xLabels[index],
                  style: DesignSystem.bodySmall(context).copyWith(
                    color: DesignSystem.textSecondary,
                    fontSize: 11,
                  ),
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
      drawVerticalLine: true,
      horizontalInterval: 1,
      verticalInterval: 1,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: DesignSystem.border.withOpacity(0.3),
          strokeWidth: 1,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: DesignSystem.border.withOpacity(0.2),
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

  LineTouchData _buildTouchData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final seriesIndex = spot.barIndex;
            final series = widget.data[seriesIndex];
            return LineTooltipItem(
              '${series.name}\n${spot.y.toStringAsFixed(1)}',
              DesignSystem.bodySmall(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList();
        },
      ),
      handleBuiltInTouches: true,
      getTouchLineStart: (_, __) => 0,
      getTouchLineEnd: (_, __) => double.infinity,
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: DesignSystem.spaceM,
      runSpacing: DesignSystem.spaceS,
      children: widget.data.map((series) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                color: series.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: DesignSystem.spaceXS),
            Text(
              series.name,
              style: DesignSystem.bodySmall(context).copyWith(
                color: DesignSystem.textSecondary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  double _calculateMinY() {
    if (widget.data.isEmpty) return 0;

    double min = double.infinity;
    for (var series in widget.data) {
      for (var point in series.points) {
        if (point.y < min) min = point.y;
      }
    }

    // Add some padding below minimum
    return (min - (min * 0.1)).floorToDouble();
  }

  double _calculateMaxY() {
    if (widget.data.isEmpty) return 10;

    double max = double.negativeInfinity;
    for (var series in widget.data) {
      for (var point in series.points) {
        if (point.y > max) max = point.y;
      }
    }

    // Add some padding above maximum
    return (max + (max * 0.1)).ceilToDouble();
  }
}

/// Data model for a single line series
class GBLineChartData {
  final String name;
  final List<GBChartPoint> points;
  final Color color;

  GBLineChartData({
    required this.name,
    required this.points,
    required this.color,
  });

  /// Factory for donation trends
  factory GBLineChartData.donationTrend({
    required List<GBChartPoint> points,
  }) {
    return GBLineChartData(
      name: 'Donations',
      points: points,
      color: DesignSystem.primaryBlue,
    );
  }

  /// Factory for request trends
  factory GBLineChartData.requestTrend({
    required List<GBChartPoint> points,
  }) {
    return GBLineChartData(
      name: 'Requests',
      points: points,
      color: DesignSystem.secondaryGreen,
    );
  }

  /// Factory for user growth
  factory GBLineChartData.userGrowth({
    required List<GBChartPoint> points,
  }) {
    return GBLineChartData(
      name: 'Users',
      points: points,
      color: DesignSystem.accentPurple,
    );
  }
}

/// Data point for charts
class GBChartPoint {
  final double x;
  final double y;

  GBChartPoint({
    required this.x,
    required this.y,
  });
}
