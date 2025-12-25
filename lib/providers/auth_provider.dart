import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/user_profile.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  User? _user;
  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _user = _supabaseService.currentUser;
    if (_user != null) {
      _loadProfile();
    }

    _supabaseService.authStateChanges.listen((data) {
      final session = data.session;
      _user = session?.user;
      if (_user != null) {
        _loadProfile();
      } else {
        _profile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadProfile() async {
    try {
      _profile = await _supabaseService.getProfile();
      notifyListeners();
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('📝 Attempting signup for: $email');
      final response = await _supabaseService.signUp(email, password);
      
      if (response.user != null) {
        _user = response.user;
        print('✅ Signup successful! User ID: ${_user!.id}');
        await _loadProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      print('⚠️ Signup failed: No user returned');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Signup error: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('🔐 Attempting login for: $email');
      final response = await _supabaseService.signIn(email, password);
      
      if (response.user != null) {
        _user = response.user;
        print('✅ Login successful! User ID: ${_user!.id}');
        await _loadProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      print('⚠️ Login failed: No user returned');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Login error: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      _user = null;
      _profile = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProfile(String username, String? avatarUrl) async {
    try {
      await _supabaseService.updateProfile(username, avatarUrl);
      await _loadProfile();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
