import 'package:flutter/foundation.dart';

import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService paymentService;

  PaymentProvider({required this.paymentService});

  bool _isLoading = false;
  String? _errorMessage;
  List<PaymentModel> _payments = [];
  PaymentModel? _selectedPayment;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PaymentModel> get payments => _payments;
  PaymentModel? get selectedPayment => _selectedPayment;

  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _payments = await paymentService.findAll();
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadByBookingId(int bookingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payment = await paymentService.findByBookingId(bookingId);
      _payments = [payment];
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
      _selectedPayment = await paymentService.findById(id);
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> create(PaymentModel payment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await paymentService.create(payment);
      _payments.add(created);
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> update(int id, PaymentModel payment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await paymentService.update(id, payment);
      final index = _payments.indexWhere((p) => p.id == id);
      if (index != -1) {
        _payments[index] = updated;
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
      await paymentService.delete(id);
      _payments.removeWhere((p) => p.id == id);
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
    _payments = [];
    _selectedPayment = null;
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
