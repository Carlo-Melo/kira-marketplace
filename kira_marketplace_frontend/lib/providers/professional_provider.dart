import 'package:flutter/foundation.dart';

import '../models/professional_model.dart';
import '../services/professional_service.dart';

class ProfessionalProvider extends ChangeNotifier {
  final ProfessionalService professionalService;

  ProfessionalProvider({required this.professionalService});

  bool _isLoading = false;
  String? _errorMessage;
  List<ProfessionalModel> _professionals = [];
  ProfessionalModel? _selectedProfessional;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProfessionalModel> get professionals => _professionals;
  ProfessionalModel? get selectedProfessional => _selectedProfessional;

  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _professionals = await professionalService.findAll();
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadByCity(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _professionals = await professionalService.findByCity(city);
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadByMinRating(double minRating) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _professionals = await professionalService.findByMinRating(minRating);
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
      _selectedProfessional = await professionalService.findById(id);
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> create(ProfessionalModel professional) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await professionalService.create(professional);
      _professionals.add(created);
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> update(int id, ProfessionalModel professional) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await professionalService.update(id, professional);
      final index = _professionals.indexWhere((p) => p.id == id);
      if (index != -1) {
        _professionals[index] = updated;
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
      await professionalService.delete(id);
      _professionals.removeWhere((p) => p.id == id);
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
    _professionals = [];
    _selectedProfessional = null;
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
