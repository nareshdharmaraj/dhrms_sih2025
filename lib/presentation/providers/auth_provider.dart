import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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

  // User authentication state (simplified - no JWT)
  String? _userId;
  String? get userId => _userId;

  // Initialize auth state from stored preferences
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      _isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
      _selectedRole = prefs.getString(AppConstants.keyUserRole) ?? '';
      _userId = prefs.getString('user_id');

      if (_isLoggedIn && _userId != null) {
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
      _userId = null;
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

  // TEMPORARY: Bypass login for development - login with role only
  Future<bool> loginWithRoleOnly(String role) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Validate input role
      if (role.isEmpty) {
        throw Exception('Role cannot be empty');
      }

      // Create a mock user for the selected role
      _userId = 'mock_user_${role}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Create mock user data based on role
      UserProfile mockProfile;
      switch (role) {
        case AppConstants.roleHospital:
          mockProfile = const UserProfile(
            name: 'Dr. Sarah Wilson',
            phone: '+91 9876543210',
            email: 'sarah.wilson@hospital.com',
            hospitalName: 'Kerala General Hospital',
            department: 'Emergency Medicine',
            specialization: 'Emergency Medicine',
            licenseNumber: 'MED12345',
          );
          break;
        case AppConstants.roleRegionalOfficer:
          mockProfile = const UserProfile(
            name: 'Officer Rajesh Kumar',
            phone: '+91 9876543211',
            email: 'rajesh.kumar@health.kerala.gov.in',
            region: 'Kochi District',
            designation: 'Regional Health Officer',
          );
          break;
        case AppConstants.roleNormalUser:
        default: // Normal User/Migrant Worker
          mockProfile = const UserProfile(
            name: 'John Doe',
            phone: '+91 9876543212',
            email: 'john.doe@worker.com',
            aadhaarLast4: '1234',
            uniqueHealthId: 'UHI123456789',
            bloodGroup: 'O+',
            address: 'Worker Colony, Kochi, Kerala',
          );
      }

      // Create user model with null safety
      _currentUser = UserModel(
        id: _userId ?? 'unknown_id',
        role: role,
        username: 'demo_user',
        password: '',
        profile: mockProfile,
      );

      // Save login state with null checks
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setString(AppConstants.keyUserRole, role);
      
      if (_currentUser?.id != null) {
        await prefs.setString(AppConstants.keyUserId, _currentUser!.id);
      }
      if (_userId != null) {
        await prefs.setString('user_id', _userId!);
      }
      await prefs.setString('username', 'demo_user');

      _isLoggedIn = true;
      _selectedRole = role;

      return true;
    } catch (e) {
      debugPrint('Mock login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Original login method (disabled for now)
  Future<bool> login(String username, String password, String role) async {
    // For now, redirect to role-only login
    return loginWithRoleOnly(role);
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
      await prefs.remove('user_id');
      await prefs.remove('username');

      _currentUser = null;
      _isLoggedIn = false;
      _selectedRole = '';
      _userId = null;
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

  // Register new user
  Future<bool> register(
    String username,
    String password,
    String email,
    String role,
    String firstName,
    String lastName,
    String phone,
    Map<String, dynamic> additionalData,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      String backendRole = _mapFrontendRoleToBackend(role);
      
      final response = await ApiService.register(
        username,
        password,
        email,
        backendRole,
        firstName,
        lastName,
        phone,
        additionalData,
      );

      if (response['success'] == true) {
        _userId = response['userId'];
        final userData = response['user'];

        // Create user model from API response
        _currentUser = UserModel(
          id: userData['id'] ?? userData['_id'],
          role: role,
          username: username,
          password: '', // Don't store password
          profile: UserProfile(
            name: userData['name'] ?? '$firstName $lastName',
            phone: userData['phone'] ?? phone,
            email: userData['email'] ?? email,
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
        await prefs.setString('user_id', _userId!);
        await prefs.setString('user_data', json.encode({
          'id': _currentUser!.id,
          'role': _currentUser!.role,
          'username': _currentUser!.username,
          'profile': _currentUser!.profile.toJson(),
        }));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Registration error: $e');
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
