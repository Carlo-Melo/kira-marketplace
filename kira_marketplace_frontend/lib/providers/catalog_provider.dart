import 'package:flutter/foundation.dart';

import '../models/service_model.dart';
import '../services/catalog_service.dart';

class CatalogProvider extends ChangeNotifier {
  final CatalogService catalogService;

  CatalogProvider({required this.catalogService});

  bool _isLoading = false;
  String? _errorMessage;
  List<ServiceModel> _services = [];
  ServiceModel? _selectedService;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ServiceModel> get services => _services;
  ServiceModel? get selectedService => _selectedService;

  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _services = await catalogService.findAll();
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
      _services = await catalogService.findByProfessionalId(professionalId);
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _services = await catalogService.search(query);
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
      _selectedService = await catalogService.findById(id);
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> create(ServiceModel service) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await catalogService.create(service);
      _services.add(created);
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> update(int id, ServiceModel service) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await catalogService.update(id, service);
      final index = _services.indexWhere((s) => s.id == id);
      if (index != -1) {
        _services[index] = updated;
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
      await catalogService.delete(id);
      _services.removeWhere((s) => s.id == id);
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
    _services = [];
    _selectedService = null;
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
