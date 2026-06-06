import 'package:flutter/foundation.dart';

import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService reviewService;

  ReviewProvider({required this.reviewService});

  bool _isLoading = false;
  String? _errorMessage;
  List<ReviewModel> _reviews = [];
  ReviewModel? _selectedReview;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ReviewModel> get reviews => _reviews;
  ReviewModel? get selectedReview => _selectedReview;

  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reviews = await reviewService.findAll();
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadByProfessionalId(int professionalId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reviews = await reviewService.findByProfessionalId(professionalId);
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedReview = await reviewService.findById(id);
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> create(ReviewModel review) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await reviewService.create(review);
      _reviews.add(created);
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> update(int id, ReviewModel review) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await reviewService.update(id, review);
      final index = _reviews.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reviews[index] = updated;
      }
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> delete(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await reviewService.delete(id);
      _reviews.removeWhere((r) => r.id == id);
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearState() {
    _isLoading = false;
    _errorMessage = null;
    _reviews = [];
    _selectedReview = null;
    notifyListeners();
  }

  String _formatError(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return 'Erro ao carregar dados.';
  }
}
