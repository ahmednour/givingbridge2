import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/theme/design_system.dart';
import '../core/config/api_config.dart';
import '../providers/analytics_provider.dart';
import '../services/api_service.dart';
import '../widgets/common/gb_button.dart';
import '../widgets/common/gb_line_chart.dart';
import '../widgets/common/gb_bar_chart.dart';
import '../widgets/common/gb_pie_chart.dart';
import '../widgets/common/gb_dashboard_components.dart';
import '../widgets/common/gb_geographic_chart.dart';

class AnalyticsDashboardEnhanced extends StatefulWidget {
  const AnalyticsDashboardEnhanced({Key? key}) : super(key: key);

  @override
  State<AnalyticsDashboardEnhanced> createState() => _AnalyticsDashboardEnhancedState();
}

class _AnalyticsDashboardEnhancedState extends State<AnalyticsDashboardEnhanced> {
  Timer? _realtimeTimer;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
  Map<String, dynamic>? _advancedAnalytics;
  Map<String, dynamic>? _realtimeData;
  bool _isLoading = false;
  bool _isRealtimeEnabled = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAdvancedAnalytics();
    if (_isRealtimeEnabled) {
      _startRealtimeUpdates();
    }
  }

  @override
  void dispose() {
    _realtimeTimer?.cancel();
    super.dispose();
  }

  void _startRealtimeUpdates() {
    _realtimeTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _isRealtimeEnabled) {
        _loadRealtimeData();
      }
    });
    // Load initial realtime data
    _loadRealtimeData();
  }

  void _stopRealtimeUpdates() {
    _realtimeTimer?.cancel();
    _realtimeTimer = null;
  }

  Future<void> _loadAdvancedAnalytics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final headers = await _getHeaders();
      final startDateStr = _startDate.toIso8601String().split('T')[0];
      final endDateStr = _endDate.toIso8601String().split('T')[0];
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/analytics/advanced?startDate=$startDateStr&endDate=$endDateStr'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _advancedAnalytics = data['data'];
            _isLoading = false;
          });
        }
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _error = error['message'] ?? 'Failed to load analytics';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Network error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadRealtimeData() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/analytics/realtime'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _realtimeData = data['data'];
          });
        }
      }
    } catch (e) {
      // Silently fail for realtime updates
      debugPrint('Realtime update failed: $e');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    String? token = await ApiService.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<void> _downloadReport(String format) async {
    try {
      final headers = await _getHeaders();
      final startDateStr = _startDate.toIso8601String().split('T')[0];
      final endDateStr = _endDate.toIso8601String().split('T')[0];
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/analytics/reports/generate?startDate=$startDateStr&endDate=$endDateStr&format=$format'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Handle file download based on format
        if (format == 'json') {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Report generated successfully'),
              backgroundColor: DesignSystem.success,
            ),
          );
        } else {
          // For PDF/CSV, you would typically save the file
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$format report downloaded'),
              backgroundColor: DesignSystem.success,
            ),
          );
        }
      } else {
        throw Exception('Failed to generate report');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download report: $e'),
          backgroundColor: DesignSystem.error,
        ),
      );
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: DesignSystem.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadAdvancedAnalytics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? DesignSystem.neutral900 : DesignSystem.neutral100,
      appBar: AppBar(
        backgroundColor: isDark ? DesignSystem.neutral900 : Colors.white,
        elevation: 0,
        title: Text(
          'Advanced Analytics',
          style: TextStyle(
            color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Realtime toggle
          IconButton(
            icon: Icon(
              _isRealtimeEnabled ? Icons.pause : Icons.play_arrow,
              color: _isRealtimeEnabled ? DesignSystem.success : DesignSystem.neutral500,
            ),
            onPressed: () {
              setState(() {
                _isRealtimeEnabled = !_isRealtimeEnabled;
              });
              if (_isRealtimeEnabled) {
                _startRealtimeUpdates();
              } else {
                _stopRealtimeUpdates();
              }
            },
            tooltip: _isRealtimeEnabled ? 'Pause real-time updates' : 'Enable real-time updates',
          ),
          // Date range selector
          IconButton(
            icon: Icon(
              Icons.date_range,
              color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
            ),
            onPressed: _selectDateRange,
            tooltip: 'Select date range',
          ),
          // Export menu
          PopupMenuButton<String>(
            icon: Icon(
              Icons.download,
              color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
            ),
            onSelected: _downloadReport,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Download PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Download CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'json',
                child: Row(
                  children: [
                    Icon(Icons.code, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('View JSON'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading && _advancedAnalytics == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(DesignSystem.primaryBlue),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading advanced analytics...',
              style: TextStyle(
                color: isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null && _advancedAnalytics == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: DesignSystem.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load analytics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
                ),
              ),
              const SizedBox(height: 24),
              GBButton(
                text: 'Retry',
                variant: GBButtonVariant.primary,
                onPressed: _loadAdvancedAnalytics,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAdvancedAnalytics,
      color: DesignSystem.primaryBlue,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date range indicator
            _buildDateRangeCard(isDark),
            const SizedBox(height: 16),
            
            // Real-time status indicator
            if (_isRealtimeEnabled) _buildRealtimeIndicator(isDark),
            
            // Summary metrics
            if (_advancedAnalytics != null) _buildSummaryMetrics(isDark),
            const SizedBox(height: 24),
            
            // Charts section
            if (_advancedAnalytics != null) _buildChartsSection(isDark),
            const SizedBox(height: 24),
            
            // Top performers
            if (_advancedAnalytics != null) _buildTopPerformers(isDark),
            const SizedBox(height: 24),
            
            // Platform health
            if (_advancedAnalytics != null) _buildPlatformHealth(isDark),
            const SizedBox(height: 24),
            
            // Geographic analytics
            if (_advancedAnalytics != null) _buildGeographicAnalytics(isDark),
            const SizedBox(height: 24),
            
            // Recent activity
            if (_advancedAnalytics != null) _buildRecentActivity(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DesignSystem.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? DesignSystem.neutral700 : DesignSystem.neutral200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.date_range,
            color: DesignSystem.primaryBlue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis Period',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_startDate.day}/${_startDate.month}/${_startDate.year} - ${_endDate.day}/${_endDate.month}/${_endDate.year}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
                  ),
                ),
              ],
            ),
          ),
          GBButton(
            text: 'Change',
            variant: GBButtonVariant.secondary,
            size: GBButtonSize.small,
            onPressed: _selectDateRange,
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeIndicator(bool isDark) {
    final lastUpdate = _realtimeData?['timestamp'] != null 
        ? DateTime.parse(_realtimeData!['timestamp'])
        : null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignSystem.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignSystem.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: DesignSystem.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Real-time updates enabled',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DesignSystem.success,
            ),
          ),
          if (lastUpdate != null) ...[
            const Spacer(),
            Text(
              'Last update: ${lastUpdate.hour.toString().padLeft(2, '0')}:${lastUpdate.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 11,
                color: DesignSystem.success.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryMetrics(bool isDark) {
    final summary = _advancedAnalytics!['summary'] as Map<String, dynamic>;
    final period = _advancedAnalytics!['period'] as Map<String, dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary (${period['days']} days)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            GBStatCard(
              title: 'Total Users',
              value: summary['totalUsers'].toString(),
              icon: Icons.people,
              color: DesignSystem.primaryBlue,
              isLoading: false,
            ),
            GBStatCard(
              title: 'Total Donations',
              value: summary['totalDonations'].toString(),
              icon: Icons.volunteer_activism,
              color: DesignSystem.secondaryGreen,
              isLoading: false,
            ),
            GBStatCard(
              title: 'Success Rate',
              value: '${summary['successRate'].toStringAsFixed(1)}%',
              icon: Icons.trending_up,
              color: DesignSystem.success,
              isLoading: false,
            ),
            GBStatCard(
              title: 'Avg Rating',
              value: '${summary['averageRating']['average']}/5',
              icon: Icons.star,
              color: DesignSystem.warning,
              isLoading: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartsSection(bool isDark) {
    final trends = _advancedAnalytics!['trends'] as Map<String, dynamic>;
    final distributions = _advancedAnalytics!['distributions'] as Map<String, dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trends & Distributions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
          ),
        ),
        const SizedBox(height: 16),
        
        // User growth chart
        if (trends['userGrowth'] != null && (trends['userGrowth'] as List).isNotEmpty)
          _buildChartCard(
            isDark: isDark,
            title: 'User Growth',
            child: GBLineChart(
              data: [
                GBLineChartData(
                  name: 'User Growth',
                  points: (trends['userGrowth'] as List).asMap().entries.map((entry) => 
                    GBChartPoint(
                      x: entry.key.toDouble(),
                      y: (entry.value['count'] as num).toDouble(),
                    )
                  ).toList(),
                  color: DesignSystem.primaryBlue,
                ),
              ],
              xLabels: (trends['userGrowth'] as List).map((item) => item['date'].toString()).toList(),
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Category distribution
        if (distributions['categories'] != null && (distributions['categories'] as List).isNotEmpty)
          _buildChartCard(
            isDark: isDark,
            title: 'Category Distribution',
            child: GBPieChart(
              data: (distributions['categories'] as List).map((item) => 
                GBPieChartData(
                  label: item['category'],
                  value: (item['count'] as num).toDouble(),
                  color: _getCategoryColor(item['category']),
                )
              ).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildChartCard({
    required bool isDark,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformers(bool isDark) {
    final topPerformers = _advancedAnalytics!['topPerformers'] as Map<String, dynamic>;
    final donors = topPerformers['donors'] as List;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Performers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
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
              Text(
                'Top Donors',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
                ),
              ),
              const SizedBox(height: 12),
              ...donors.take(5).map((donor) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: DesignSystem.primaryBlue.withOpacity(0.1),
                      child: Text(
                        donor['donorName'][0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: DesignSystem.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            donor['donorName'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
                            ),
                          ),
                          Text(
                            '${donor['donationCount']} donations • ${donor['completionRate']}% completion',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (donor['averageRating'] != null && donor['averageRating'] != '0')
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: DesignSystem.warning,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            donor['averageRating'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? DesignSystem.neutral200 : DesignSystem.neutral700,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              )).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformHealth(bool isDark) {
    final metrics = _advancedAnalytics!['metrics'] as Map<String, dynamic>;
    final platformHealth = metrics['platformHealth'] as Map<String, dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Platform Health',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            GBStatCard(
              title: 'Active Users',
              value: platformHealth['activeUsers'].toString(),
              icon: Icons.people_alt,
              color: DesignSystem.success,
              isLoading: false,
            ),
            GBStatCard(
              title: 'Daily Active',
              value: platformHealth['dailyActiveUsers'].toString(),
              icon: Icons.today,
              color: DesignSystem.info,
              isLoading: false,
            ),
            GBStatCard(
              title: 'Error Rate',
              value: '${platformHealth['errorRate']}%',
              icon: Icons.error_outline,
              color: platformHealth['errorRate'] > 5 ? DesignSystem.error : DesignSystem.success,
              isLoading: false,
            ),
            GBStatCard(
              title: 'Avg Response',
              value: '${platformHealth['averageResponseTime']}ms',
              icon: Icons.speed,
              color: platformHealth['averageResponseTime'] > 500 ? DesignSystem.warning : DesignSystem.success,
              isLoading: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(bool isDark) {
    final activity = _advancedAnalytics!['activity'] as List;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? DesignSystem.neutral800 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? DesignSystem.neutral700 : DesignSystem.neutral200,
            ),
          ),
          child: Column(
            children: activity.take(10).map((item) {
              final timestamp = DateTime.parse(item['timestamp']);
              final timeAgo = _formatTimeAgo(timestamp);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getActivityColor(item['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getActivityIcon(item['type']),
                        size: 16,
                        color: _getActivityColor(item['type']),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getActivityDescription(item),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
                            ),
                          ),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return DesignSystem.success;
      case 'clothes':
        return DesignSystem.primaryBlue;
      case 'books':
        return DesignSystem.warning;
      case 'electronics':
        return DesignSystem.accentPurple;
      default:
        return DesignSystem.neutral500;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'donation':
        return Icons.volunteer_activism;
      case 'request':
        return Icons.inbox;
      case 'rating':
        return Icons.star;
      default:
        return Icons.circle;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'donation':
        return DesignSystem.secondaryGreen;
      case 'request':
        return DesignSystem.primaryBlue;
      case 'rating':
        return DesignSystem.warning;
      default:
        return DesignSystem.neutral500;
    }
  }

  String _getActivityDescription(Map<String, dynamic> item) {
    switch (item['type']) {
      case 'donation':
        return '${item['user']} created donation: ${item['title'] ?? 'Untitled'}';
      case 'request':
        return '${item['user']} created a request';
      case 'rating':
        return '${item['ratedBy']} left a ${item['rating']}-star rating';
      default:
        return 'Unknown activity';
    }
  }

  Widget _buildGeographicAnalytics(bool isDark) {
    final distributions = _advancedAnalytics!['distributions'] as Map<String, dynamic>;
    final geographic = distributions['geographic'] as List;
    
    if (geographic.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? DesignSystem.neutral800 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? DesignSystem.neutral700 : DesignSystem.neutral200,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.map_outlined,
              size: 48,
              color: isDark ? DesignSystem.neutral500 : DesignSystem.neutral400,
            ),
            const SizedBox(height: 12),
            Text(
              'No Geographic Data Available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? DesignSystem.neutral300 : DesignSystem.neutral700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Location data will appear here when donations include location information.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
              ),
            ),
          ],
        ),
      );
    }

    // Convert geographic data to chart format
    final geographicData = geographic.map((location) {
      return GeographicDataPoint(
        location: location['location'] ?? 'Unknown',
        value: (location['donationCount'] as num).toDouble(),
        color: _getLocationColor(location['location'] ?? 'Unknown'),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Geographic Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: DesignSystem.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${geographic.length} locations',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DesignSystem.info,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Geographic chart with map toggle
        SizedBox(
          height: 400,
          child: GBGeographicChart(
            data: geographicData,
            title: 'Donations by Location',
            showMap: true,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Geographic insights
        Container(
          padding: const EdgeInsets.all(16),
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
              Text(
                'Geographic Insights',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
                ),
              ),
              const SizedBox(height: 12),
              
              // Top locations
              ...geographic.take(3).map((location) {
                final completionRate = location['donationCount'] > 0 
                    ? ((location['completedCount'] / location['donationCount']) * 100).toStringAsFixed(1)
                    : '0.0';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getLocationColor(location['location']),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          location['location'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? DesignSystem.neutral200 : DesignSystem.neutral800,
                          ),
                        ),
                      ),
                      Text(
                        '${location['donationCount']} donations',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: double.parse(completionRate) > 50 
                              ? DesignSystem.success.withOpacity(0.1)
                              : DesignSystem.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$completionRate%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: double.parse(completionRate) > 50 
                                ? DesignSystem.success
                                : DesignSystem.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Color _getLocationColor(String location) {
    // Generate consistent colors for locations
    final colors = [
      DesignSystem.primaryBlue,
      DesignSystem.secondaryGreen,
      DesignSystem.warning,
      DesignSystem.accentPurple,
      DesignSystem.accentPink,
      DesignSystem.info,
      DesignSystem.success,
    ];
    
    return colors[location.hashCode % colors.length];
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}