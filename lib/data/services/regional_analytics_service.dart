import 'dart:math';
import '../models/regional_analytics_model.dart';

class RegionalAnalyticsService {
  static final RegionalAnalyticsService _instance = RegionalAnalyticsService._internal();
  factory RegionalAnalyticsService() => _instance;
  RegionalAnalyticsService._internal();

  // Mock data storage - replace with actual API calls
  RegionalAnalytics? _cachedAnalytics;
  DateTime? _lastFetchTime;

  // Cache duration - 30 minutes
  static const Duration _cacheDuration = Duration(minutes: 30);

  Future<RegionalAnalytics> getRegionalAnalytics(String regionId) async {
    // Check if we have fresh cached data
    if (_cachedAnalytics != null && 
        _lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedAnalytics!;
    }

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate mock analytics data
    final analytics = _generateMockAnalytics(regionId);
    
    // Cache the result
    _cachedAnalytics = analytics;
    _lastFetchTime = DateTime.now();

    return analytics;
  }

  Future<List<TrendData>> getMonthlyTrends(String regionId, int months) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final trends = <TrendData>[];
    final now = DateTime.now();
    
    for (int i = months - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final random = Random();
      
      trends.add(TrendData(
        month: _getMonthName(date.month),
        date: date,
        totalCases: 200 + random.nextInt(150),
        newCases: 20 + random.nextInt(30),
        recoveries: 180 + random.nextInt(120),
        deaths: random.nextInt(5),
        mortalityRate: 0.5 + random.nextDouble() * 2,
      ));
    }
    
    return trends;
  }

  Future<List<DistrictComparison>> getDistrictComparisons(String regionId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    return [
      DistrictComparison(
        districtName: 'Ernakulam',
        population: 1200000,
        totalCases: 450,
        incidenceRate: 37.5,
        riskLevel: 'Medium',
        vaccinationCoverage: 78.5,
      ),
      DistrictComparison(
        districtName: 'Thrissur',
        population: 950000,
        totalCases: 320,
        incidenceRate: 33.7,
        riskLevel: 'Low',
        vaccinationCoverage: 82.1,
      ),
      DistrictComparison(
        districtName: 'Palakkad',
        population: 800000,
        totalCases: 380,
        incidenceRate: 47.5,
        riskLevel: 'High',
        vaccinationCoverage: 74.2,
      ),
      DistrictComparison(
        districtName: 'Kozhikode',
        population: 1100000,
        totalCases: 290,
        incidenceRate: 26.4,
        riskLevel: 'Low',
        vaccinationCoverage: 85.3,
      ),
    ];
  }

  Future<List<HospitalCapacity>> getHospitalCapacityData(String regionId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    return [
      HospitalCapacity(
        hospitalId: 'HOSP001',
        hospitalName: 'Ernakulam Medical College',
        totalBeds: 500,
        availableBeds: 45,
        icuBeds: 50,
        availableIcuBeds: 8,
        occupancyRate: 91.0,
        status: 'Critical',
      ),
      HospitalCapacity(
        hospitalId: 'HOSP002',
        hospitalName: 'Aster Medcity',
        totalBeds: 300,
        availableBeds: 75,
        icuBeds: 30,
        availableIcuBeds: 12,
        occupancyRate: 75.0,
        status: 'Normal',
      ),
      HospitalCapacity(
        hospitalId: 'HOSP003',
        hospitalName: 'Lakeshore Hospital',
        totalBeds: 250,
        availableBeds: 25,
        icuBeds: 25,
        availableIcuBeds: 2,
        occupancyRate: 90.0,
        status: 'High',
      ),
      HospitalCapacity(
        hospitalId: 'HOSP004',
        hospitalName: 'KIMS Hospital',
        totalBeds: 400,
        availableBeds: 80,
        icuBeds: 40,
        availableIcuBeds: 15,
        occupancyRate: 80.0,
        status: 'Normal',
      ),
    ];
  }

  Future<List<OutbreakInfo>> getActiveOutbreaks(String regionId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    return [
      OutbreakInfo(
        diseaseId: 'DIS001',
        diseaseName: 'Dengue Fever',
        location: 'Kakkanad Area',
        affectedCount: 45,
        startDate: DateTime.now().subtract(const Duration(days: 12)),
        endDate: null,
        severity: 'High',
        status: 'Active',
        latitude: 10.0261,
        longitude: 76.3105,
      ),
      OutbreakInfo(
        diseaseId: 'DIS002',
        diseaseName: 'Chikungunya',
        location: 'Mattancherry',
        affectedCount: 23,
        startDate: DateTime.now().subtract(const Duration(days: 8)),
        endDate: null,
        severity: 'Medium',
        status: 'Contained',
        latitude: 9.9581,
        longitude: 76.2673,
      ),
      OutbreakInfo(
        diseaseId: 'DIS003',
        diseaseName: 'Food Poisoning',
        location: 'Fort Kochi',
        affectedCount: 67,
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        endDate: null,
        severity: 'Critical',
        status: 'Active',
        latitude: 9.9653,
        longitude: 76.2424,
      ),
    ];
  }

  Future<void> refreshAnalytics(String regionId) async {
    _cachedAnalytics = null;
    _lastFetchTime = null;
    await getRegionalAnalytics(regionId);
  }

  RegionalAnalytics _generateMockAnalytics(String regionId) {
    return RegionalAnalytics(
      regionId: regionId,
      regionName: 'Ernakulam District',
      reportDate: DateTime.now(),
      healthMetrics: HealthMetrics(
        totalWorkers: 15247,
        activeCases: 342,
        recoveredCases: 12890,
        criticalCases: 23,
        totalHospitals: 47,
        operationalHospitals: 45,
        mortalityRate: 1.2,
        recoveryRate: 94.8,
        bedOccupancyRate: 78.5,
      ),
      diseaseOutbreaks: DiseaseOutbreakData(
        activeOutbreaks: [],
        recentOutbreaks: [],
        totalAffected: 135,
        riskLevel: 'Medium',
        recommendedMeasures: [
          PreventiveMeasure(
            measureId: 'PM001',
            title: 'Enhanced Surveillance',
            description: 'Increase disease surveillance in affected areas',
            priority: 'High',
            category: 'Monitoring',
            isImplemented: true,
            implementationDate: DateTime.now().subtract(const Duration(days: 5)),
          ),
          PreventiveMeasure(
            measureId: 'PM002',
            title: 'Water Quality Checks',
            description: 'Regular water quality testing and treatment',
            priority: 'Medium',
            category: 'Prevention',
            isImplemented: false,
          ),
        ],
      ),
      hospitalUtilization: HospitalUtilization(
        totalBeds: 1450,
        occupiedBeds: 1138,
        icuBeds: 145,
        occupiedIcuBeds: 107,
        occupancyRate: 78.5,
        icuOccupancyRate: 73.8,
        hospitalDetails: [],
      ),
      workerStats: WorkerHealthStats(
        totalRegisteredWorkers: 15247,
        healthyWorkers: 14782,
        workersUnderTreatment: 342,
        workersInQuarantine: 123,
        demographics: [
          WorkerDemographics(
            category: 'age',
            label: '18-30',
            count: 5500,
            percentage: 36.1,
          ),
          WorkerDemographics(
            category: 'age',
            label: '31-45',
            count: 6200,
            percentage: 40.7,
          ),
          WorkerDemographics(
            category: 'age',
            label: '46-60',
            count: 3547,
            percentage: 23.2,
          ),
        ],
        commonConditions: [
          HealthConditionStat(
            conditionName: 'Hypertension',
            affectedCount: 890,
            prevalenceRate: 5.8,
            trendDirection: 'up',
            trendPercentage: 2.3,
          ),
          HealthConditionStat(
            conditionName: 'Diabetes',
            affectedCount: 567,
            prevalenceRate: 3.7,
            trendDirection: 'stable',
            trendPercentage: 0.1,
          ),
        ],
      ),
      vaccinationData: VaccinationCoverage(
        overallCoverage: 78.5,
        vaccineTypes: [
          VaccineTypeData(
            vaccineType: 'COVID-19',
            administeredDoses: 25450,
            coveragePercentage: 83.6,
            lastUpdate: DateTime.now().subtract(const Duration(days: 1)),
          ),
          VaccineTypeData(
            vaccineType: 'Hepatitis B',
            administeredDoses: 18900,
            coveragePercentage: 62.1,
            lastUpdate: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
        ageGroups: [
          AgeGroupCoverage(
            ageGroup: '18-30',
            population: 5500,
            vaccinated: 4675,
            coveragePercentage: 85.0,
          ),
          AgeGroupCoverage(
            ageGroup: '31-45',
            population: 6200,
            vaccinated: 4834,
            coveragePercentage: 78.0,
          ),
        ],
        totalVaccinated: 11969,
        targetPopulation: 15247,
      ),
      monthlyTrends: [],
      districtComparisons: [],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // Export data methods
  Future<String> exportAnalyticsToCSV(RegionalAnalytics analytics) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock CSV generation
    return 'analytics_${analytics.regionId}_${DateTime.now().millisecondsSinceEpoch}.csv';
  }

  Future<String> exportAnalyticsToPDF(RegionalAnalytics analytics) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock PDF generation
    return 'analytics_report_${analytics.regionId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }

  // Real-time updates simulation
  Stream<RegionalAnalytics> getAnalyticsStream(String regionId) async* {
    while (true) {
      yield await getRegionalAnalytics(regionId);
      await Future.delayed(const Duration(minutes: 5));
    }
  }
}
