import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/design_system.dart';

class GeographicDataPoint {
  final String location;
  final double value;
  final Color color;
  final double? latitude;
  final double? longitude;

  GeographicDataPoint({
    required this.location,
    required this.value,
    required this.color,
    this.latitude,
    this.longitude,
  });
}

class GBGeographicChart extends StatefulWidget {
  final List<GeographicDataPoint> data;
  final String title;
  final bool showMap;

  const GBGeographicChart({
    Key? key,
    required this.data,
    this.title = 'Geographic Distribution',
    this.showMap = false,
  }) : super(key: key);

  @override
  State<GBGeographicChart> createState() => _GBGeographicChartState();
}

class _GBGeographicChartState extends State<GBGeographicChart> {
  int _selectedIndex = -1;
  bool _showAsMap = false;

  @override
  void initState() {
    super.initState();
    _showAsMap = widget.showMap;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (widget.data.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: isDark ? DesignSystem.neutral800 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? DesignSystem.neutral700 : DesignSystem.neutral200,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                size: 48,
                color: isDark ? DesignSystem.neutral500 : DesignSystem.neutral400,
              ),
              const SizedBox(height: 12),
              Text(
                'No geographic data available',
                style: TextStyle(
                  color: isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DesignSystem.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? DesignSystem.neutral700 : DesignSystem.neutral200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.bar_chart,
                        color: !_showAsMap ? DesignSystem.primaryBlue : DesignSystem.neutral500,
                      ),
                      onPressed: () => setState(() => _showAsMap = false),
                      tooltip: 'Bar Chart View',
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.map,
                        color: _showAsMap ? DesignSystem.primaryBlue : DesignSystem.neutral500,
                      ),
                      onPressed: () => setState(() => _showAsMap = true),
                      tooltip: 'Map View',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Chart content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _showAsMap ? _buildMapView(isDark) : _buildBarChart(isDark),
            ),
          ),
          
          // Legend
          _buildLegend(isDark),
        ],
      ),
    );
  }

  Widget _buildBarChart(bool isDark) {
    final maxValue = widget.data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: isDark ? DesignSystem.neutral700 : DesignSystem.neutral100,
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dataPoint = widget.data[groupIndex];
              return BarTooltipItem(
                '${dataPoint.location}\n${dataPoint.value.toInt()} donations',
                TextStyle(
                  color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            setState(() {
              if (barTouchResponse?.spot != null) {
                _selectedIndex = barTouchResponse!.spot!.touchedBarGroupIndex;
              } else {
                _selectedIndex = -1;
              }
            });
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < widget.data.length) {
                  final location = widget.data[value.toInt()].location;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      location.length > 8 ? '${location.substring(0, 8)}...' : location,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark ? DesignSystem.neutral700 : DesignSystem.neutral200,
              strokeWidth: 1,
            );
          },
        ),
        barGroups: widget.data.asMap().entries.map((entry) {
          final index = entry.key;
          final dataPoint = entry.value;
          final isSelected = index == _selectedIndex;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: dataPoint.value,
                color: isSelected 
                    ? dataPoint.color.withOpacity(1.0)
                    : dataPoint.color.withOpacity(0.8),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMapView(bool isDark) {
    // Simple map-like visualization using positioned containers
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? DesignSystem.neutral900 : DesignSystem.neutral50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Background grid to simulate map
          CustomPaint(
            size: Size.infinite,
            painter: MapGridPainter(isDark: isDark),
          ),
          
          // Location markers
          ...widget.data.asMap().entries.map((entry) {
            final index = entry.key;
            final dataPoint = entry.value;
            
            // Simple positioning based on location name hash for demo
            final hash = dataPoint.location.hashCode;
            final left = ((hash % 300) + 50).toDouble();
            final top = (((hash ~/ 300) % 200) + 50).toDouble();
            
            return Positioned(
              left: left,
              top: top,
              child: GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: Container(
                  width: 20 + (dataPoint.value / 10), // Size based on value
                  height: 20 + (dataPoint.value / 10),
                  decoration: BoxDecoration(
                    color: dataPoint.color.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: dataPoint.color.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      dataPoint.value.toInt().toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          
          // Selected location info
          if (_selectedIndex >= 0 && _selectedIndex < widget.data.length)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? DesignSystem.neutral800 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.data[_selectedIndex].location,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.data[_selectedIndex].value.toInt()} donations',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? DesignSystem.neutral700 : DesignSystem.neutral200,
          ),
        ),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: widget.data.take(6).map((dataPoint) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: dataPoint.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${dataPoint.location} (${dataPoint.value.toInt()})',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? DesignSystem.neutral300 : DesignSystem.neutral700,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class MapGridPainter extends CustomPainter {
  final bool isDark;

  MapGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark 
          ? DesignSystem.neutral700.withOpacity(0.3)
          : DesignSystem.neutral300.withOpacity(0.3)
      ..strokeWidth = 1;

    // Draw grid lines
    for (int i = 0; i < size.width; i += 40) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }

    for (int i = 0; i < size.height; i += 40) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}