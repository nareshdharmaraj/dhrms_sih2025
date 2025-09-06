import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoggedIn = false;
  String _selectedRole = '';
  bool _isLoading = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  String get selectedRole => _selectedRole;
  bool get isLoading => _isLoading;

  // Mock credentials for demonstration
  final List<UserModel> _mockUsers = [
    UserModel(
      id: 'user_001',
      role: AppConstants.roleNormalUser,
      username: 'migrant001',
      password: 'password123',
      profile: const UserProfile(
        name: 'Rajesh Kumar',
        aadhaarLast4: '2345',
        uniqueHealthId: 'RAJESH2345',
        phone: '+91-9876543210',
        address: 'Construction Site, Kochi, Kerala',
        employer: 'ABC Construction Pvt Ltd',
        emergencyContact: '+91-9876543211',
        bloodGroup: 'B+',
        dateOfBirth: '1985-05-15',
        occupation: 'Construction Worker',
      ),
    ),
    UserModel(
      id: 'hospital_001',
      role: AppConstants.roleHospital,
      username: 'medical.officer',
      password: 'hospital@123',
      profile: const UserProfile(
        name: 'Dr. Sarah Joseph',
        hospitalName: 'Kochi General Hospital',
        hospitalId: 'KGH001',
        licenseNumber: 'KER-DOC-12345',
        department: 'General Medicine',
        phone: '+91-484-2345678',
        email: 'sarah.joseph@kochigeneral.in',
        specialization: 'Internal Medicine',
      ),
    ),
    UserModel(
      id: 'regional_001',
      role: AppConstants.roleRegionalOfficer,
      username: 'regional.admin',
      password: 'regional@123',
      profile: const UserProfile(
        name: 'K. R. Nair',
        designation: 'Regional Health Officer',
        region: 'Ernakulam District',
        employeeId: 'RHO-ERN-001',
        phone: '+91-484-1234567',
        email: 'kr.nair@health.kerala.gov.in',
        officeAddress: 'District Health Office, Ernakulam',
      ),
    ),
  ];

  // Initialize auth state from stored preferences
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      _isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
      _selectedRole = prefs.getString(AppConstants.keyUserRole) ?? '';

      if (_isLoggedIn) {
        final userId = prefs.getString(AppConstants.keyUserId);
        if (userId != null) {
          _currentUser = _mockUsers.firstWhere(
            (user) => user.id == userId,
            orElse: () => _mockUsers.first,
          );
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      _isLoggedIn = false;
      _currentUser = null;
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
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Find user with matching credentials
      final user = _mockUsers.firstWhere(
        (user) =>
            user.username == username &&
            user.password == password &&
            user.role == role,
        orElse: () => throw Exception('Invalid credentials'),
      );

      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setString(AppConstants.keyUserRole, role);
      await prefs.setString(AppConstants.keyUserId, user.id);

      _currentUser = user;
      _isLoggedIn = true;
      _selectedRole = role;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Login error: $e');
      return false;
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

      _currentUser = null;
      _isLoggedIn = false;
      _selectedRole = '';
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
      // Simulate API call
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

  // Get available users for a role (for demo purposes)
  List<UserModel> getUsersForRole(String role) {
    return _mockUsers.where((user) => user.role == role).toList();
  }

  // Validate login credentials without logging in
  bool validateCredentials(String username, String password, String role) {
    try {
      _mockUsers.firstWhere(
        (user) =>
            user.username == username &&
            user.password == password &&
            user.role == role,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
