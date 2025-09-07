import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoggedIn = false;
  String _selectedRole = '';
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  String get selectedRole => _selectedRole;
  bool get isLoading => _isLoading;

  // Authentication token management
  String? _authToken;
  String? get authToken => _authToken;

  // Initialize auth state from stored preferences
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      _isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
      _selectedRole = prefs.getString(AppConstants.keyUserRole) ?? '';
      _authToken = prefs.getString('auth_token');

      if (_isLoggedIn && _authToken != null) {
        // Try to restore user session
        final userId = prefs.getString(AppConstants.keyUserId);
        if (userId != null) {
          // For now, create a basic user model until we implement user profile API
          _currentUser = UserModel(
            id: userId,
            role: _selectedRole,
            username: prefs.getString('username') ?? '',
            password: '', // Don't store password
            profile: const UserProfile(
              name: 'User', // Will be loaded from API
              phone: '', // Will be loaded from API
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      _isLoggedIn = false;
      _currentUser = null;
      _authToken = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set selected role
  void setSelectedRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  // Login with username and password
  Future<bool> login(String username, String password, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Map frontend roles to backend roles
      String backendRole = _mapFrontendRoleToBackend(role);

      // Call authentication API
      final response = await _apiService.authenticate(
        username,
        password,
        backendRole,
      );

      if (response['success'] == true) {
        _authToken = response['token'];
        final userData = response['user'];

        // Create user model from API response
        _currentUser = UserModel(
          id: userData['id'] ?? userData['_id'],
          role: role,
          username: username,
          password: '', // Don't store password
          profile: UserProfile(
            name: userData['name'] ?? 'Unknown User',
            phone: userData['phone'] ?? '',
            email: userData['email'],
            // Add other fields based on role
            hospitalName: role == AppConstants.roleHospital
                ? userData['hospitalName']
                : null,
            department: role == AppConstants.roleHospital
                ? userData['department']
                : null,
            specialization: userData['specialization'],
            licenseNumber: userData['licenseNumber'],
            region: role == AppConstants.roleRegionalOfficer
                ? userData['region']
                : null,
            designation: role == AppConstants.roleRegionalOfficer
                ? userData['designation']
                : null,
            aadhaarLast4: userData['aadhaarLast4'],
            uniqueHealthId: userData['uniqueHealthId'],
            bloodGroup: userData['bloodGroup'],
            address: userData['address'],
          ),
        );

        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.keyIsLoggedIn, true);
        await prefs.setString(AppConstants.keyUserRole, role);
        await prefs.setString(AppConstants.keyUserId, _currentUser!.id);
        await prefs.setString('auth_token', _authToken!);
        await prefs.setString('username', username);

        _isLoggedIn = true;
        _selectedRole = role;

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Login error: $e');
      return false;
    }
  }

  // Map frontend roles to backend roles
  String _mapFrontendRoleToBackend(String frontendRole) {
    switch (frontendRole) {
      case AppConstants.roleNormalUser:
        return 'user';
      case AppConstants.roleHospital:
        return 'hospital';
      case AppConstants.roleRegionalOfficer:
        return 'regional';
      default:
        return frontendRole;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyIsLoggedIn);
      await prefs.remove(AppConstants.keyUserRole);
      await prefs.remove(AppConstants.keyUserId);
      await prefs.remove('auth_token');
      await prefs.remove('username');

      _currentUser = null;
      _isLoggedIn = false;
      _selectedRole = '';
      _authToken = null;
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile(UserProfile updatedProfile) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement API call to update user profile
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = _currentUser!.copyWith(profile: updatedProfile);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Profile update error: $e');
      return false;
    }
  }

  // Validate login credentials without logging in
  Future<bool> validateCredentials(
    String username,
    String password,
    String role,
  ) async {
    try {
      String backendRole = _mapFrontendRoleToBackend(role);
      final response = await _apiService.authenticate(
        username,
        password,
        backendRole,
      );
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
