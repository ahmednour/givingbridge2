const SearchService = require('../services/searchService');

// Mock the database dependencies
jest.mock('../config/db', () => ({
  sequelize: {
    query: jest.fn(),
  }
}));

jest.mock('../models/Donation', () => ({
  findAll: jest.fn(),
}));

jest.mock('../models/User', () => ({
  findAll: jest.fn(),
}));

const { sequelize } = require('../config/db');
const Donation = require('../models/Donation');
const User = require('../models/User');

describe('SearchService - Suggestions and History', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getSearchSuggestions', () => {
    it('should return empty suggestions for short terms', async () => {
      const result = await SearchService.getSearchSuggestions('a');
      expect(result.suggestions).toEqual([]);
    });

    it('should return donation suggestions', async () => {
      const mockDonations = [
        { title: 'Winter Clothes' },
        { title: 'Winter Boots' }
      ];

      Donation.findAll.mockResolvedValue(mockDonations);
      User.findAll.mockResolvedValue([]);

      const result = await SearchService.getSearchSuggestions('winter', 'donations');
      
      expect(Donation.findAll).toHaveBeenCalled();
      expect(result.suggestions).toHaveLength(2);
      expect(result.suggestions[0].text).toBe('Winter Clothes');
      expect(result.suggestions[0].type).toBe('donation_title');
    });

    it('should return user suggestions', async () => {
      const mockUsers = [
        { name: 'John Smith', location: 'New York' }
      ];

      Donation.findAll.mockResolvedValue([]);
      User.findAll.mockResolvedValue(mockUsers);

      const result = await SearchService.getSearchSuggestions('john', 'users');
      
      expect(User.findAll).toHaveBeenCalled();
      expect(result.suggestions).toHaveLength(1);
      expect(result.suggestions[0].text).toBe('John Smith');
      expect(result.suggestions[0].type).toBe('user_name');
    });
  });

  describe('getUserSearchHistory', () => {
    it('should return user search history', async () => {
      const mockHistory = [
        { search_term: 'winter clothes', last_searched: new Date() }
      ];

      sequelize.query.mockResolvedValue(mockHistory);

      const result = await SearchService.getUserSearchHistory(1);
      
      expect(sequelize.query).toHaveBeenCalled();
      expect(result).toHaveLength(1);
      expect(result[0].term).toBe('winter clothes');
    });
  });

  describe('getPopularSearchTerms', () => {
    it('should return popular search terms', async () => {
      const mockTerms = [
        { search_term: 'clothes', search_count: 10 },
        { search_term: 'food', search_count: 8 }
      ];

      sequelize.query.mockResolvedValue(mockTerms);

      const result = await SearchService.getPopularSearchTerms();
      
      expect(sequelize.query).toHaveBeenCalled();
      expect(result).toHaveLength(2);
      expect(result[0].search_term).toBe('clothes');
      expect(result[0].search_count).toBe(10);
    });
  });

  describe('logSearchQuery', () => {
    it('should log search query successfully', async () => {
      sequelize.query
        .mockResolvedValueOnce() // CREATE TABLE IF NOT EXISTS
        .mockResolvedValueOnce(); // INSERT

      await SearchService.logSearchQuery(1, 'test query', 'donations', 5);
      
      expect(sequelize.query).toHaveBeenCalledTimes(2);
    });

    it('should handle logging errors gracefully', async () => {
      sequelize.query.mockRejectedValue(new Error('Database error'));

      // Should not throw error
      await expect(SearchService.logSearchQuery(1, 'test', 'donations', 0))
        .resolves.toBeUndefined();
    });
  });

  describe('clearUserSearchHistory', () => {
    it('should clear user search history successfully', async () => {
      sequelize.query.mockResolvedValue();

      const result = await SearchService.clearUserSearchHistory(1);
      
      expect(sequelize.query).toHaveBeenCalled();
      expect(result).toBe(true);
    });

    it('should handle clear history errors', async () => {
      sequelize.query.mockRejectedValue(new Error('Database error'));

      const result = await SearchService.clearUserSearchHistory(1);
      
      expect(result).toBe(false);
    });
  });

  describe('getSearchAnalytics', () => {
    it('should return search analytics', async () => {
      const mockAnalytics = [
        [{ total_searches: 100 }],
        [{ unique_users: 25 }],
        [{ search_term: 'clothes', search_count: 10 }],
        [{ search_date: '2023-10-01', search_count: 5, unique_users: 3 }]
      ];

      sequelize.query
        .mockResolvedValueOnce(mockAnalytics[0])
        .mockResolvedValueOnce(mockAnalytics[1])
        .mockResolvedValueOnce(mockAnalytics[2])
        .mockResolvedValueOnce(mockAnalytics[3]);

      const result = await SearchService.getSearchAnalytics();
      
      expect(result.totalSearches).toBe(100);
      expect(result.uniqueUsers).toBe(25);
      expect(result.topTerms).toHaveLength(1);
      expect(result.searchTrends).toHaveLength(1);
      expect(result.averageSearchesPerUser).toBe('4.00');
    });
  });
});