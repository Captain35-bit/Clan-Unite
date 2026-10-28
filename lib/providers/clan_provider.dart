import 'package:flutter/foundation.dart';

import '../models/clan_model.dart';
import '../services/firestore_service.dart';

class ClanProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ClanModel> _clans = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ClanModel> get clans => _clans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadClans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _clans = await _firestoreService.getClans();
    } catch (e) {
      _errorMessage = 'Failed to load clans';
      debugPrint('ClanProvider.loadClans error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createClan({
    required String name,
    required String description,
    required String createdByUserId,
    String? location,
  }) async {
    if (name.trim().isEmpty) {
      _errorMessage = 'Clan name is required';
      notifyListeners();
      return false;
    }

    final now = DateTime.now();
    final clan = ClanModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      description: description.trim(),
      createdByUserId: createdByUserId,
      memberIds: [createdByUserId],
      createdAt: now,
      updatedAt: now,
      location: location,
      balance: 0.0,
    );

    try {
      await _firestoreService.createClan(clan);
      await loadClans();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create clan';
      debugPrint('ClanProvider.createClan error: $e');
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
