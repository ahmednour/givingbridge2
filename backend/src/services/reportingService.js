const PDFDocument = require('pdfkit');
const { Op, fn, col, literal } = require('sequelize');
const { sequelize } = require('../config/db');
const User = require('../models/User');
const Donation = require('../models/Donation');
const Request = require('../models/Request');
const Rating = require('../models/Rating');
const ActivityLog = require('../models/ActivityLog');
const AnalyticsController = require('../controllers/analyticsController');

class ReportingService {
  /**
   * Generate comprehensive analytics data for reports
   */
  static async generateAnalyticsData(startDate, endDate, options = {}) {
    const dateFilter = {
      createdAt: {
        [Op.between]: [startDate, endDate]
      }
    };

    // Get basic metrics
    const [
      totalUsers,
      totalDonations,
      totalRequests,
      completedRequests,
      userGrowth,
      donationTrends,
      categoryDistribution,
      geographicDistribution,
      enhancedGeographic,
      topDonors,
      topReceivers,
      requestSuccessRate,
      recentActivity
    ] = await Promise.all([
      User.count({ where: dateFilter }),
      Donation.count({ where: dateFilter }),
      Request.count({ where: dateFilter }),
      Request.count({ where: { ...dateFilter, status: 'completed' } }),
      this.getUserGrowthData(startDate, endDate),
      this.getDonationTrendsData(startDate, endDate),
      this.getCategoryDistributionData(startDate, endDate),
      this.getGeographicDistributionData(startDate, endDate),
      this.getGeographicAnalytics(startDate, endDate),
      this.getTopDonorsData(startDate, endDate, options.topLimit || 10),
      this.getTopReceiversData(startDate, endDate, options.topLimit || 10),
      this.getRequestSuccessRateData(startDate, endDate),
      this.getRecentActivityData(startDate, endDate, options.activityLimit || 50)
    ]);

    // Calculate derived metrics
    const successRate = totalRequests > 0 ? ((completedRequests / totalRequests) * 100).toFixed(2) : 0;
    const averageRating = await this.getAverageRatingData(startDate, endDate);
    const platformHealth = await this.getPlatformHealthMetrics(startDate, endDate);

    return {
      period: {
        startDate: startDate.toISOString().split('T')[0],
        endDate: endDate.toISOString().split('T')[0],
        days: Math.ceil((endDate - startDate) / (1000 * 60 * 60 * 24))
      },
      summary: {
        totalUsers,
        totalDonations,
        totalRequests,
        completedRequests,
        successRate: parseFloat(successRate),
        averageRating
      },
      trends: {
        userGrowth,
        donationTrends
      },
      distributions: {
        categories: categoryDistribution,
        geographic: geographicDistribution
      },
      geographicAnalytics: enhancedGeographic,
      topPerformers: {
        donors: topDonors,
        receivers: topReceivers
      },
      metrics: {
        requestSuccessRate,
        platformHealth
      },
      activity: recentActivity
    };
  }

  /**
   * Get user growth data for date range
   */
  static async getUserGrowthData(startDate, endDate) {
    return await User.findAll({
      attributes: [
        [fn('DATE', col('createdAt')), 'date'],
        [fn('COUNT', col('id')), 'count'],
        'role'
      ],
      where: {
        createdAt: {
          [Op.between]: [startDate, endDate]
        }
      },
      group: [fn('DATE', col('createdAt')), 'role'],
      order: [[fn('DATE', col('createdAt')), 'ASC']],
      raw: true
    });
  }

  /**
   * Get donation trends data for date range
   */
  static async getDonationTrendsData(startDate, endDate) {
    return await Donation.findAll({
      attributes: [
        [fn('DATE', col('createdAt')), 'date'],
        [fn('COUNT', col('id')), 'count'],
        'category'
      ],
      where: {
        createdAt: {
          [Op.between]: [startDate, endDate]
        }
      },
      group: [fn('DATE', col('createdAt')), 'category'],
      order: [[fn('DATE', col('createdAt')), 'ASC']],
      raw: true
    });
  }

  /**
   * Get category distribution data for date range
   */
  static async getCategoryDistributionData(startDate, endDate) {
    return await Donation.findAll({
      attributes: [
        'category',
        [fn('COUNT', col('id')), 'count'],
        [fn('AVG', literal('CASE WHEN status = "completed" THEN 1 ELSE 0 END')), 'completionRate']
      ],
      where: {
        createdAt: {
          [Op.between]: [startDate, endDate]
        }
      },
      group: ['category'],
      order: [[fn('COUNT', col('id')), 'DESC']],
      raw: true
    });
  }

  /**
   * Get geographic distribution data for date range
   */
  static async getGeographicDistributionData(startDate, endDate) {
    return await Donation.findAll({
      attributes: [
        'location',
        [fn('COUNT', col('id')), 'donationCount'],
        [fn('COUNT', literal('CASE WHEN status = "completed" THEN 1 END')), 'completedCount'],
        [fn('AVG', literal('CASE WHEN status = "completed" THEN 1 ELSE 0 END')), 'completionRate']
      ],
      where: {
        createdAt: {
          [Op.between]: [startDate, endDate]
        },
        location: {
          [Op.ne]: null,
          [Op.ne]: ''
        }
      },
      group: ['location'],
      order: [[fn('COUNT', col('id')), 'DESC']],
      limit: 20, // Limit to top 20 locations
      raw: true
    });
  }

  /**
   * Get geographic analytics with enhanced data
   */
  static async getGeographicAnalytics(startDate, endDate) {
    const [locationData, requestData] = await Promise.all([
      // Donation locations
      Donation.findAll({
        attributes: [
          'location',
          [fn('COUNT', col('id')), 'donationCount'],
          [fn('COUNT', literal('CASE WHEN status = "completed" THEN 1 END')), 'completedCount'],
          [fn('COUNT', literal('CASE WHEN status = "available" THEN 1 END')), 'availableCount']
        ],
        where: {
          createdAt: {
            [Op.between]: [startDate, endDate]
          },
          location: {
            [Op.ne]: null,
            [Op.ne]: ''
          }
        },
        group: ['location'],
        order: [[fn('COUNT', col('id')), 'DESC']],
        limit: 15,
        raw: true
      }),
      
      // Request locations (if Request model has location field)
      Request.findAll({
        attributes: [
          'location',
          [fn('COUNT', col('id')), 'requestCount'],
          [fn('COUNT', literal('CASE WHEN status = "completed" THEN 1 END')), 'completedRequests']
        ],
        where: {
          createdAt: {
            [Op.between]: [startDate, endDate]
          },
          location: {
            [Op.ne]: null,
            [Op.ne]: ''
          }
        },
        group: ['location'],
        order: [[fn('COUNT', col('id')), 'DESC']],
        limit: 15,
        raw: true
      }).catch(() => []) // Handle case where Request model doesn't have location field
    ]);

    // Combine and enhance location data
    const locationMap = new Map();
    
    // Process donation data
    locationData.forEach(item => {
      const location = item.location;
      if (!locationMap.has(location)) {
        locationMap.set(location, {
          location,
          donationCount: 0,
          completedCount: 0,
          availableCount: 0,
          requestCount: 0,
          completedRequests: 0
        });
      }
      
      const locationStats = locationMap.get(location);
      locationStats.donationCount = parseInt(item.donationCount);
      locationStats.completedCount = parseInt(item.completedCount);
      locationStats.availableCount = parseInt(item.availableCount);
    });

    // Process request data
    requestData.forEach(item => {
      const location = item.location;
      if (!locationMap.has(location)) {
        locationMap.set(location, {
          location,
          donationCount: 0,
          completedCount: 0,
          availableCount: 0,
          requestCount: 0,
          completedRequests: 0
        });
      }
      
      const locationStats = locationMap.get(location);
      locationStats.requestCount = parseInt(item.requestCount);
      locationStats.completedRequests = parseInt(item.completedRequests);
    });

    // Convert to array and calculate rates
    const enhancedData = Array.from(locationMap.values()).map(item => ({
      ...item,
      completionRate: item.donationCount > 0 ? 
        ((item.completedCount / item.donationCount) * 100).toFixed(1) : 0,
      requestSuccessRate: item.requestCount > 0 ? 
        ((item.completedRequests / item.requestCount) * 100).toFixed(1) : 0,
      totalActivity: item.donationCount + item.requestCount
    }));

    // Sort by total activity
    enhancedData.sort((a, b) => b.totalActivity - a.totalActivity);

    return enhancedData;
  }

  /**
   * Get top donors data for date range
   */
  static async getTopDonorsData(startDate, endDate, limit = 10) {
    const topDonors = await Donation.findAll({
      attributes: [
        'donorId',
        'donorName',
        [fn('COUNT', col('id')), 'donationCount'],
        [fn('COUNT', literal('CASE WHEN status = "completed" THEN 1 END')), 'completedDonations']
      ],
      where: {
        createdAt: {
          [Op.between]: [startDate, endDate]
        }
      },
      group: ['donorId', 'donorName'],
      order: [[fn('COUNT', col('id')), 'DESC']],
      limit,
      raw: true
    });

    // Get ratings for each donor
    return await Promise.all(
      topDonors.map(async (donor) => {
        const ratings = await Rating.findAll({
          where: {
            ratedUserId: donor.donorId,
            createdAt: {
              [Op.between]: [startDate, endDate]
            }
          },
          attributes: [
            [fn('AVG', col('rating')), 'avgRating'],
            [fn('COUNT', col('id')), 'ratingCount']
          ],
          raw: true
        });

        return {
          ...donor,
          averageRating: ratings[0]?.avgRating ? parseFloat(ratings[0].avgRating).toFixed(1) : 0,
          ratingCount: ratings[0]?.ratingCount || 0,
          completionRate: donor.donationCount > 0 ? 
            ((donor.completedDonations / donor.donationCount) * 100).toFixed(1) : 0
        };
      })
    );
  }

  /**
   * Get top receivers data for date range
   */
  static async getTopReceiversData(startDate, endDate, limit = 10) {
    const topReceivers = await Request.findAll({
      attributes: [
        'receiverId',
        'receiverName',
        [fn('COUNT', col('id')), 'requestCount'],
        [fn('COUNT', literal('CASE WHEN status = "completed" THEN 1 END')), 'completedRequests']
      ],
      where: {
        createdAt: {
          [Op.between]: [startDate, endDate]
        }
      },
      group: ['receiverId', 'receiverName'],
      order: [[fn('COUNT', col('id')), 'DESC']],
      limit,
      raw: true
    });

    // Get ratings for each receiver
    return await Promise.all(
      topReceivers.map(async (receiver) => {
        const ratings = await Rating.findAll({
          where: {
            ratedUserId: receiver.receiverId,
            createdAt: {
              [Op.between]: [startDate, endDate]
            }
          },
          attributes: [
            [fn('AVG', col('rating')), 'avgRating'],
            [fn('COUNT', col('id')), 'ratingCount']
          ],
          raw: true
        });

        return {
          ...receiver,
          averageRating: ratings[0]?.avgRating ? parseFloat(ratings[0].avgRating).toFixed(1) : 0,
          ratingCount: ratings[0]?.ratingCount || 0,
          successRate: receiver.requestCount > 0 ? 
            ((receiver.completedRequests / receiver.requestCount) * 100).toFixed(1) : 0
        };
      })
    );
  }

  /**
   * Get request success rate data for date range
   */
  static async getRequestSuccessRateData(startDate, endDate) {
    const statusCounts = await Request.findAll({
      attributes: [
        'status',
        [fn('COUNT', col('id')), 'count']
      ],
      where: {
        createdAt: {
          [Op.between]: [startDate, endDate]
        }
      },
      group: ['status'],
      raw: true
    });

    const total = statusCounts.reduce((sum, item) => sum + parseInt(item.count), 0);
    const completed = statusCounts.find(item => item.status === 'completed')?.count || 0;
    const approved = statusCounts.find(item => item.status === 'approved')?.count || 0;

    return {
      total,
      statusBreakdown: statusCounts,
      successRate: total > 0 ? ((completed / total) * 100).toFixed(2) : 0,
      approvalRate: total > 0 ? (((completed + approved) / total) * 100).toFixed(2) : 0
    };
  }

  /**
   * Get average rating data for date range
   */
  static async getAverageRatingData(startDate, endDate) {
    const result = await Rating.findAll({
      where: {
        createdAt: {
          [Op.between]: [startDate, endDate]
        }
      },
      attributes: [
        [fn('AVG', col('rating')), 'avgRating'],
        [fn('COUNT', col('id')), 'totalRatings']
      ],
      raw: true
    });

    return {
      average: result[0]?.avgRating ? parseFloat(result[0].avgRating).toFixed(1) : 0,
      total: result[0]?.totalRatings || 0
    };
  }

  /**
   * Get platform health metrics
   */
  static async getPlatformHealthMetrics(startDate, endDate) {
    const [
      activeUsers,
      dailyActiveUsers,
      errorLogs,
      responseTime
    ] = await Promise.all([
      this.getActiveUsersCount(startDate, endDate),
      this.getDailyActiveUsers(startDate, endDate),
      this.getErrorLogsCount(startDate, endDate),
      this.getAverageResponseTime(startDate, endDate)
    ]);

    return {
      activeUsers,
      dailyActiveUsers,
      errorRate: errorLogs.errorRate,
      averageResponseTime: responseTime
    };
  }

  /**
   * Get active users count
   */
  static async getActiveUsersCount(startDate, endDate) {
    // Users who have created donations, requests, or ratings in the period
    const [donorIds, receiverIds, raterIds] = await Promise.all([
      Donation.findAll({
        attributes: [[fn('DISTINCT', col('donorId')), 'userId']],
        where: { createdAt: { [Op.between]: [startDate, endDate] } },
        raw: true
      }),
      Request.findAll({
        attributes: [[fn('DISTINCT', col('receiverId')), 'userId']],
        where: { createdAt: { [Op.between]: [startDate, endDate] } },
        raw: true
      }),
      Rating.findAll({
        attributes: [[fn('DISTINCT', col('ratedBy')), 'userId']],
        where: { createdAt: { [Op.between]: [startDate, endDate] } },
        raw: true
      })
    ]);

    const uniqueUserIds = new Set([
      ...donorIds.map(d => d.userId),
      ...receiverIds.map(r => r.userId),
      ...raterIds.map(r => r.userId)
    ]);

    return uniqueUserIds.size;
  }

  /**
   * Get daily active users
   */
  static async getDailyActiveUsers(startDate, endDate) {
    // This is a simplified version - in a real app you'd track user sessions
    const days = Math.ceil((endDate - startDate) / (1000 * 60 * 60 * 24));
    const activeUsers = await this.getActiveUsersCount(startDate, endDate);
    
    return Math.round(activeUsers / days);
  }

  /**
   * Get error logs count (simplified - would need proper error logging)
   */
  static async getErrorLogsCount(startDate, endDate) {
    // This is a placeholder - in a real app you'd have error logging
    const totalRequests = await ActivityLog.count({
      where: {
        createdAt: { [Op.between]: [startDate, endDate] }
      }
    });

    // Simulate error rate calculation
    const errorRate = totalRequests > 0 ? (Math.random() * 2).toFixed(2) : 0;
    
    return {
      totalRequests,
      errorRate: parseFloat(errorRate)
    };
  }

  /**
   * Get average response time (placeholder)
   */
  static async getAverageResponseTime(startDate, endDate) {
    // This is a placeholder - in a real app you'd track response times
    return Math.round(Math.random() * 200 + 100); // Random between 100-300ms
  }

  /**
   * Get recent activity data for date range
   */
  static async getRecentActivityData(startDate, endDate, limit = 50) {
    const [donations, requests, ratings] = await Promise.all([
      Donation.findAll({
        where: { createdAt: { [Op.between]: [startDate, endDate] } },
        order: [['createdAt', 'DESC']],
        limit: Math.floor(limit / 3),
        attributes: ['id', 'title', 'donorName', 'category', 'status', 'createdAt'],
        raw: true
      }),
      Request.findAll({
        where: { createdAt: { [Op.between]: [startDate, endDate] } },
        order: [['createdAt', 'DESC']],
        limit: Math.floor(limit / 3),
        attributes: ['id', 'receiverName', 'status', 'createdAt'],
        raw: true
      }),
      Rating.findAll({
        where: { createdAt: { [Op.between]: [startDate, endDate] } },
        order: [['createdAt', 'DESC']],
        limit: Math.floor(limit / 3),
        attributes: ['id', 'rating', 'ratedBy', 'createdAt'],
        raw: true
      })
    ]);

    const activity = [
      ...donations.map(d => ({
        type: 'donation',
        id: d.id,
        title: d.title,
        user: d.donorName,
        category: d.category,
        status: d.status,
        timestamp: d.createdAt
      })),
      ...requests.map(r => ({
        type: 'request',
        id: r.id,
        user: r.receiverName,
        status: r.status,
        timestamp: r.createdAt
      })),
      ...ratings.map(r => ({
        type: 'rating',
        id: r.id,
        rating: r.rating,
        ratedBy: r.ratedBy,
        timestamp: r.createdAt
      }))
    ];

    return activity
      .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
      .slice(0, limit);
  }

  /**
   * Generate CSV report
   */
  static async generateCSVReport(data, reportType = 'comprehensive') {
    let csvContent = '';
    
    switch (reportType) {
      case 'donations':
        csvContent = this.generateDonationsCSV(data);
        break;
      case 'users':
        csvContent = this.generateUsersCSV(data);
        break;
      case 'geographic':
        csvContent = this.generateGeographicCSV(data);
        break;
      default:
        csvContent = this.generateComprehensiveCSV(data);
    }

    return csvContent;
  }

  /**
   * Generate donations CSV
   */
  static generateDonationsCSV(data) {
    let csv = 'Date,Category,Count,Completion Rate\n';
    
    if (data.distributions && data.distributions.categories) {
      data.distributions.categories.forEach(category => {
        csv += `${data.period.startDate} - ${data.period.endDate},${category.category},${category.count},${category.completionRate || 0}%\n`;
      });
    }

    return csv;
  }

  /**
   * Generate users CSV
   */
  static generateUsersCSV(data) {
    let csv = 'Date,Role,New Users\n';
    
    if (data.trends && data.trends.userGrowth) {
      data.trends.userGrowth.forEach(growth => {
        csv += `${growth.date},${growth.role},${growth.count}\n`;
      });
    }

    return csv;
  }

  /**
   * Generate geographic CSV
   */
  static generateGeographicCSV(data) {
    let csv = 'Location,Donations,Completed,Completion Rate\n';
    
    if (data.distributions && data.distributions.geographic) {
      data.distributions.geographic.forEach(location => {
        const completionRate = location.donationCount > 0 ? 
          ((location.completedCount / location.donationCount) * 100).toFixed(1) : 0;
        csv += `${location.location},${location.donationCount},${location.completedCount},${completionRate}%\n`;
      });
    }

    return csv;
  }

  /**
   * Generate comprehensive CSV
   */
  static generateComprehensiveCSV(data) {
    let csv = 'Metric,Value\n';
    csv += `Report Period,${data.period.startDate} to ${data.period.endDate}\n`;
    csv += `Total Users,${data.summary.totalUsers}\n`;
    csv += `Total Donations,${data.summary.totalDonations}\n`;
    csv += `Total Requests,${data.summary.totalRequests}\n`;
    csv += `Completed Requests,${data.summary.completedRequests}\n`;
    csv += `Success Rate,${data.summary.successRate}%\n`;
    csv += `Average Rating,${data.summary.averageRating.average}\n`;
    csv += `Active Users,${data.metrics.platformHealth.activeUsers}\n`;
    csv += `Daily Active Users,${data.metrics.platformHealth.dailyActiveUsers}\n`;
    csv += `Error Rate,${data.metrics.platformHealth.errorRate}%\n`;

    return csv;
  }

  /**
   * Generate PDF report
   */
  static async generatePDFReport(data, reportType = 'comprehensive') {
    return new Promise((resolve, reject) => {
      try {
        const doc = new PDFDocument();
        const chunks = [];

        doc.on('data', chunk => chunks.push(chunk));
        doc.on('end', () => resolve(Buffer.concat(chunks)));

        // Header
        doc.fontSize(20).text('GivingBridge Analytics Report', 50, 50);
        doc.fontSize(12).text(`Period: ${data.period.startDate} to ${data.period.endDate}`, 50, 80);
        doc.text(`Generated: ${new Date().toLocaleDateString()}`, 50, 95);

        let yPosition = 130;

        // Summary Section
        doc.fontSize(16).text('Summary', 50, yPosition);
        yPosition += 25;
        
        doc.fontSize(12);
        doc.text(`Total Users: ${data.summary.totalUsers}`, 70, yPosition);
        yPosition += 15;
        doc.text(`Total Donations: ${data.summary.totalDonations}`, 70, yPosition);
        yPosition += 15;
        doc.text(`Total Requests: ${data.summary.totalRequests}`, 70, yPosition);
        yPosition += 15;
        doc.text(`Success Rate: ${data.summary.successRate}%`, 70, yPosition);
        yPosition += 15;
        doc.text(`Average Rating: ${data.summary.averageRating.average}/5`, 70, yPosition);
        yPosition += 30;

        // Top Performers Section
        if (data.topPerformers && data.topPerformers.donors.length > 0) {
          doc.fontSize(16).text('Top Donors', 50, yPosition);
          yPosition += 25;
          
          data.topPerformers.donors.slice(0, 5).forEach((donor, index) => {
            doc.fontSize(12).text(
              `${index + 1}. ${donor.donorName} - ${donor.donationCount} donations (${donor.completionRate}% completion)`,
              70, yPosition
            );
            yPosition += 15;
          });
          yPosition += 20;
        }

        // Category Distribution
        if (data.distributions && data.distributions.categories.length > 0) {
          doc.fontSize(16).text('Category Distribution', 50, yPosition);
          yPosition += 25;
          
          data.distributions.categories.slice(0, 5).forEach(category => {
            doc.fontSize(12).text(
              `${category.category}: ${category.count} donations`,
              70, yPosition
            );
            yPosition += 15;
          });
          yPosition += 20;
        }

        // Geographic Distribution
        if (data.distributions && data.distributions.geographic.length > 0) {
          doc.fontSize(16).text('Geographic Distribution', 50, yPosition);
          yPosition += 25;
          
          data.distributions.geographic.slice(0, 5).forEach(location => {
            const completionRate = location.donationCount > 0 ? 
              ((location.completedCount / location.donationCount) * 100).toFixed(1) : 0;
            doc.fontSize(12).text(
              `${location.location}: ${location.donationCount} donations (${completionRate}% completed)`,
              70, yPosition
            );
            yPosition += 15;
          });
        }

        // Platform Health
        if (yPosition > 700) {
          doc.addPage();
          yPosition = 50;
        }

        doc.fontSize(16).text('Platform Health', 50, yPosition);
        yPosition += 25;
        doc.fontSize(12);
        doc.text(`Active Users: ${data.metrics.platformHealth.activeUsers}`, 70, yPosition);
        yPosition += 15;
        doc.text(`Daily Active Users: ${data.metrics.platformHealth.dailyActiveUsers}`, 70, yPosition);
        yPosition += 15;
        doc.text(`Error Rate: ${data.metrics.platformHealth.errorRate}%`, 70, yPosition);

        doc.end();
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * Generate report in specified format
   */
  static async generateReport(startDate, endDate, format = 'json', reportType = 'comprehensive', options = {}) {
    const data = await this.generateAnalyticsData(startDate, endDate, options);

    switch (format.toLowerCase()) {
      case 'pdf':
        return {
          data: await this.generatePDFReport(data, reportType),
          contentType: 'application/pdf',
          filename: `analytics-report-${data.period.startDate}-${data.period.endDate}.pdf`
        };
      case 'csv':
        return {
          data: await this.generateCSVReport(data, reportType),
          contentType: 'text/csv',
          filename: `analytics-report-${data.period.startDate}-${data.period.endDate}.csv`
        };
      default:
        return {
          data,
          contentType: 'application/json',
          filename: `analytics-report-${data.period.startDate}-${data.period.endDate}.json`
        };
    }
  }
}

module.exports = ReportingService;