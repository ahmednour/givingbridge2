import 'package:flutter/material.dart';
import '../services/rating_service.dart';

/// Provider for managing ratings
class RatingProvider extends ChangeNotifier {
  Map<int, RatingsWithAverage> _donorRatings = {};
  Map<int, RatingsWithAverage> _receiverRatings = {};
  Map<int, Rating?> _requestRatings = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get donor ratings with average
  RatingsWithAverage? getDonorRatings(int donorId) {
    return _donorRatings[donorId];
  }

  /// Get receiver ratings with average
  RatingsWithAverage? getReceiverRatings(int receiverId) {
    return _receiverRatings[receiverId];
  }

  /// Get rating for a specific request
  Rating? getRequestRating(int requestId) {
    return _requestRatings[requestId];
  }

  /// Submit a new rating
  Future<bool> submitRating({
    required int requestId,
    required int rating,
    String? feedback,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await RatingService.createRating(
        requestId: requestId,
        rating: rating,
        feedback: feedback,
      );

      if (response.success && response.data != null) {
        _requestRatings[requestId] = response.data;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to submit rating';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error submitting rating: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Update an existing rating
  Future<bool> updateRating({
    required int requestId,
    required int rating,
    String? feedback,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await RatingService.updateRating(
        requestId: requestId,
        rating: rating,
        feedback: feedback,
      );

      if (response.success && response.data != null) {
        _requestRatings[requestId] = response.data;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to update rating';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error updating rating: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Load donor ratings with average
  Future<void> loadDonorRatings(int donorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await RatingService.getDonorRatings(donorId);

      if (response.success && response.data != null) {
        _donorRatings[donorId] = response.data!;
        notifyListeners();
      } else {
        _error = response.error ?? 'Failed to load donor ratings';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error loading donor ratings: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  /// Load receiver ratings with average
  Future<void> loadReceiverRatings(int receiverId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await RatingService.getReceiverRatings(receiverId);

      if (response.success && response.data != null) {
        _receiverRatings[receiverId] = response.data!;
        notifyListeners();
      } else {
        _error = response.error ?? 'Failed to load receiver ratings';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error loading receiver ratings: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  /// Load rating for a specific request
  Future<void> loadRequestRating(int requestId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await RatingService.getRatingByRequest(requestId);

      if (response.success && response.data != null) {
        _requestRatings[requestId] = response.data;
        notifyListeners();
      } else if (response.error?.contains('No rating found') == true) {
        // No rating found is not an error, just set to null
        _requestRatings[requestId] = null;
        notifyListeners();
      } else {
        _error = response.error ?? 'Failed to load request rating';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error loading request rating: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  /// Get donor average rating only
  Future<AverageRating?> getDonorAverageRating(int donorId) async {
    try {
      final response = await RatingService.getDonorAverageRating(donorId);
      return response.success ? response.data : null;
    } catch (e) {
      debugPrint('Error getting donor average rating: $e');
      return null;
    }
  }

  /// Get receiver average rating only
  Future<AverageRating?> getReceiverAverageRating(int receiverId) async {
    try {
      final response = await RatingService.getReceiverAverageRating(receiverId);
      return response.success ? response.data : null;
    } catch (e) {
      debugPrint('Error getting receiver average rating: $e');
      return null;
    }
  }

  /// Delete a rating
  Future<bool> deleteRating(int requestId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await RatingService.deleteRating(requestId);

      if (response.success) {
        _requestRatings.remove(requestId);
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to delete rating';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error deleting rating: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Check if user can rate a request (based on request status)
  Future<bool> canRateRequest(int requestId, int userId) async {
    // This would typically check if the request is completed and if the user
    // is either the donor or receiver involved in the request
    // For now, we'll just check if there's already a rating
    await loadRequestRating(requestId);
    return _requestRatings[requestId] == null;
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _donorRatings.clear();
    _receiverRatings.clear();
    _requestRatings.clear();
    _error = null;
    notifyListeners();
  }
}
