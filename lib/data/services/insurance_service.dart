import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/storage_helper.dart';

class InsuranceService {
  static const String baseUrl = ApiConstants.baseUrl;

  // Add new insurance policy
  static Future<Map<String, dynamic>> addPolicy({
    required String policyNumber,
    required Map<String, dynamic> insuranceProvider,
    required Map<String, dynamic> policyDetails,
    required Map<String, dynamic> policyDates,
    Map<String, dynamic>? coverage,
    List<Map<String, dynamic>>? beneficiaries,
    List<Map<String, dynamic>>? documents,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.insurancePolicies}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'policyNumber': policyNumber,
          'insuranceProvider': insuranceProvider,
          'policyDetails': policyDetails,
          'policyDates': policyDates,
          if (coverage != null) 'coverage': coverage,
          if (beneficiaries != null) 'beneficiaries': beneficiaries,
          if (documents != null) 'documents': documents,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to add policy');
      }
    } catch (e) {
      throw Exception('Error adding policy: $e');
    }
  }

  // Get user's insurance policies
  static Future<Map<String, dynamic>> getPolicies({String? status}) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl${ApiConstants.insurancePolicies}').replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to get policies');
      }
    } catch (e) {
      throw Exception('Error getting policies: $e');
    }
  }

  // Get specific policy details
  static Future<Map<String, dynamic>> getPolicyDetails(String policyId) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.insurancePolicies}/$policyId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to get policy details');
      }
    } catch (e) {
      throw Exception('Error getting policy details: $e');
    }
  }

  // Submit insurance claim
  static Future<Map<String, dynamic>> submitClaim({
    required String policyId,
    required String claimType,
    required Map<String, dynamic> treatmentDetails,
    required Map<String, dynamic> financialDetails,
    List<Map<String, dynamic>>? documents,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.insuranceClaims}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'policyId': policyId,
          'claimType': claimType,
          'treatmentDetails': treatmentDetails,
          'financialDetails': financialDetails,
          if (documents != null) 'documents': documents,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to submit claim');
      }
    } catch (e) {
      throw Exception('Error submitting claim: $e');
    }
  }

  // Get insurance claims
  static Future<Map<String, dynamic>> getClaims({
    String? status,
    String? claimType,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
        if (claimType != null) 'claimType': claimType,
      };

      final uri = Uri.parse('$baseUrl${ApiConstants.insuranceClaims}').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to get claims');
      }
    } catch (e) {
      throw Exception('Error getting claims: $e');
    }
  }

  // Submit pre-authorization request
  static Future<Map<String, dynamic>> submitPreAuthorization({
    required String policyId,
    required Map<String, dynamic> treatmentDetails,
    required Map<String, dynamic> hospital,
    Map<String, dynamic>? doctor,
    List<Map<String, dynamic>>? documents,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.insurancePreAuth}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'policyId': policyId,
          'treatmentDetails': treatmentDetails,
          'hospital': hospital,
          if (doctor != null) 'doctor': doctor,
          if (documents != null) 'documents': documents,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to submit pre-authorization');
      }
    } catch (e) {
      throw Exception('Error submitting pre-authorization: $e');
    }
  }

  // Get pre-authorization requests
  static Future<Map<String, dynamic>> getPreAuthorizations({String? status}) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl${ApiConstants.insurancePreAuth}').replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to get pre-authorizations');
      }
    } catch (e) {
      throw Exception('Error getting pre-authorizations: $e');
    }
  }

  // Check insurance eligibility
  static Future<Map<String, dynamic>> checkEligibility({
    required String policyId,
    String? treatmentType,
    double? estimatedCost,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final queryParams = <String, String>{};
      if (treatmentType != null) queryParams['treatmentType'] = treatmentType;
      if (estimatedCost != null) queryParams['estimatedCost'] = estimatedCost.toString();

      final uri = Uri.parse('$baseUrl${ApiConstants.insuranceEligibility}/$policyId').replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to check eligibility');
      }
    } catch (e) {
      throw Exception('Error checking eligibility: $e');
    }
  }

  // Get network hospitals
  static Future<Map<String, dynamic>> getNetworkHospitals({
    String? insuranceProvider,
    String? city,
    String? specialization,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final queryParams = <String, String>{};
      if (insuranceProvider != null) queryParams['insuranceProvider'] = insuranceProvider;
      if (city != null) queryParams['city'] = city;
      if (specialization != null) queryParams['specialization'] = specialization;

      final uri = Uri.parse('$baseUrl${ApiConstants.insuranceNetworkHospitals}').replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to get network hospitals');
      }
    } catch (e) {
      throw Exception('Error getting network hospitals: $e');
    }
  }
}

// Insurance Policy Model
class InsurancePolicy {
  final String id;
  final String policyNumber;
  final String providerName;
  final String policyType;
  final double sumInsured;
  final double premium;
  final double deductible;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> coverage;
  final List<Beneficiary> beneficiaries;

  InsurancePolicy({
    required this.id,
    required this.policyNumber,
    required this.providerName,
    required this.policyType,
    required this.sumInsured,
    required this.premium,
    required this.deductible,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.coverage,
    required this.beneficiaries,
  });

  factory InsurancePolicy.fromJson(Map<String, dynamic> json) {
    return InsurancePolicy(
      id: json['_id'] ?? '',
      policyNumber: json['policyNumber'] ?? '',
      providerName: json['insuranceProvider']['name'] ?? '',
      policyType: json['policyDetails']['policyType'] ?? '',
      sumInsured: (json['policyDetails']['sumInsured'] ?? 0).toDouble(),
      premium: (json['policyDetails']['premium']['annual'] ?? 0).toDouble(),
      deductible: (json['policyDetails']['deductible'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      startDate: DateTime.parse(json['policyDates']['startDate']),
      endDate: DateTime.parse(json['policyDates']['endDate']),
      coverage: Map<String, dynamic>.from(json['coverage'] ?? {}),
      beneficiaries: (json['beneficiaries'] as List?)
              ?.map((b) => Beneficiary.fromJson(b))
              .toList() ??
          [],
    );
  }
}

// Beneficiary Model
class Beneficiary {
  final String name;
  final String relationship;
  final DateTime dateOfBirth;
  final String? aadharNumber;
  final double? sumInsured;

  Beneficiary({
    required this.name,
    required this.relationship,
    required this.dateOfBirth,
    this.aadharNumber,
    this.sumInsured,
  });

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    return Beneficiary(
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      aadharNumber: json['aadharNumber'],
      sumInsured: (json['sumInsured'] ?? 0).toDouble(),
    );
  }
}

// Insurance Claim Model
class InsuranceClaim {
  final String id;
  final String claimNumber;
  final String claimType;
  final String status;
  final double totalBillAmount;
  final double claimedAmount;
  final double? approvedAmount;
  final double? settledAmount;
  final DateTime claimDate;
  final Map<String, dynamic> treatmentDetails;
  final Map<String, dynamic> financialDetails;

  InsuranceClaim({
    required this.id,
    required this.claimNumber,
    required this.claimType,
    required this.status,
    required this.totalBillAmount,
    required this.claimedAmount,
    this.approvedAmount,
    this.settledAmount,
    required this.claimDate,
    required this.treatmentDetails,
    required this.financialDetails,
  });

  factory InsuranceClaim.fromJson(Map<String, dynamic> json) {
    return InsuranceClaim(
      id: json['_id'] ?? '',
      claimNumber: json['claimNumber'] ?? '',
      claimType: json['claimType'] ?? '',
      status: json['status'] ?? '',
      totalBillAmount: (json['financialDetails']['totalBillAmount'] ?? 0).toDouble(),
      claimedAmount: (json['financialDetails']['claimedAmount'] ?? 0).toDouble(),
      approvedAmount: (json['financialDetails']['approvedAmount'] ?? 0).toDouble(),
      settledAmount: (json['financialDetails']['settledAmount'] ?? 0).toDouble(),
      claimDate: DateTime.parse(json['createdAt']),
      treatmentDetails: Map<String, dynamic>.from(json['treatmentDetails'] ?? {}),
      financialDetails: Map<String, dynamic>.from(json['financialDetails'] ?? {}),
    );
  }
}

// Pre-authorization Model
class PreAuthorization {
  final String id;
  final String preAuthNumber;
  final String status;
  final double estimatedCost;
  final double? approvedAmount;
  final DateTime? validityDate;
  final Map<String, dynamic> treatmentDetails;
  final Map<String, dynamic> hospital;

  PreAuthorization({
    required this.id,
    required this.preAuthNumber,
    required this.status,
    required this.estimatedCost,
    this.approvedAmount,
    this.validityDate,
    required this.treatmentDetails,
    required this.hospital,
  });

  factory PreAuthorization.fromJson(Map<String, dynamic> json) {
    return PreAuthorization(
      id: json['_id'] ?? '',
      preAuthNumber: json['preAuthNumber'] ?? '',
      status: json['status'] ?? '',
      estimatedCost: (json['treatmentDetails']['estimatedCost'] ?? 0).toDouble(),
      approvedAmount: (json['approvalDetails']['approvedAmount'] ?? 0).toDouble(),
      validityDate: json['approvalDetails']['validityDate'] != null
          ? DateTime.parse(json['approvalDetails']['validityDate'])
          : null,
      treatmentDetails: Map<String, dynamic>.from(json['treatmentDetails'] ?? {}),
      hospital: Map<String, dynamic>.from(json['hospital'] ?? {}),
    );
  }
}

// Network Hospital Model
class NetworkHospital {
  final String id;
  final String name;
  final String city;
  final String address;
  final String phone;
  final List<String> specializations;
  final List<String> facilities;
  final bool cashlessAvailable;
  final bool preAuthRequired;
  final List<String> insuranceProviders;

  NetworkHospital({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.phone,
    required this.specializations,
    required this.facilities,
    required this.cashlessAvailable,
    required this.preAuthRequired,
    required this.insuranceProviders,
  });

  factory NetworkHospital.fromJson(Map<String, dynamic> json) {
    return NetworkHospital(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      specializations: (json['specializations'] as List?)?.cast<String>() ?? [],
      facilities: (json['facilities'] as List?)?.cast<String>() ?? [],
      cashlessAvailable: json['cashlessAvailable'] ?? false,
      preAuthRequired: json['preAuthRequired'] ?? false,
      insuranceProviders: (json['insuranceProviders'] as List?)?.cast<String>() ?? [],
    );
  }
}
