import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  UserModel? _currentUserModel;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // Getters
  User? get currentUser => _currentUser;
  UserModel? get currentUserModel => _currentUserModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _initializeAuthListener();
  }

  // Initialize auth state listener
  void _initializeAuthListener() {
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      _isAuthenticated = user != null;
      if (user != null) {
        _loadUserProfile(user.uid);
      } else {
        _currentUserModel = null;
      }
      notifyListeners();
    });
  }

  // Load user profile from Firestore
  Future<void> _loadUserProfile(String uid) async {
    try {
      _currentUserModel = await _authService.getUserProfile(uid);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load user profile';
      notifyListeners();
    }
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password cannot be empty');
      }

      if (password != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      if (firstName.isEmpty || lastName.isEmpty) {
        throw Exception('First name and last name cannot be empty');
      }

      // Call auth service
      UserCredential? result = await _authService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      _isLoading = false;
      notifyListeners();
      return result != null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password cannot be empty');
      }

      UserCredential? result = await _authService.login(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return result != null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (email.isEmpty) {
        throw Exception('Email cannot be empty');
      }

      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      _currentUser = null;
      _currentUserModel = null;
      _isAuthenticated = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to logout';
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    if (_currentUser == null) {
      _errorMessage = 'No user logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateUserProfile(
        uid: _currentUser!.uid,
        updates: updates,
      );
      await _loadUserProfile(_currentUser!.uid);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    if (_currentUser == null) {
      _errorMessage = 'No user logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      String uid = _currentUser!.uid;
      await _authService.deleteUserAccount(uid);
      _currentUser = null;
      _currentUserModel = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete account';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}
