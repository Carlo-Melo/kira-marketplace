import 'package:flutter/foundation.dart';

import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService bookingService;

  BookingProvider({required this.bookingService});

  bool _isLoading = false;
  String? _errorMessage;
  List<BookingModel> _bookings = [];
  BookingModel? _selectedBooking;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BookingModel> get bookings => _bookings;
  BookingModel? get selectedBooking => _selectedBooking;

  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bookings = await bookingService.findAll();
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadByClientId(int clientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bookings = await bookingService.findByClientId(clientId);
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
      _bookings = await bookingService.findByProfessionalId(professionalId);
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
      _selectedBooking = await bookingService.findById(id);
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> create(BookingModel booking) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await bookingService.create(booking);
      _bookings.add(created);
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> update(int id, BookingModel booking) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await bookingService.update(id, booking);
      final index = _bookings.indexWhere((b) => b.id == id);
      if (index != -1) {
        _bookings[index] = updated;
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
      await bookingService.delete(id);
      _bookings.removeWhere((b) => b.id == id);
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
    _bookings = [];
    _selectedBooking = null;
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
