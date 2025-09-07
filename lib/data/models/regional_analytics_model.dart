class RegionalAnalytics {
  final String regionId;
  final String regionName;
  final DateTime reportDate;
  final HealthMetrics healthMetrics;
  final DiseaseOutbreakData diseaseOutbreaks;
  final HospitalUtilization hospitalUtilization;
  final WorkerHealthStats workerStats;
  final VaccinationCoverage vaccinationData;
  final List<TrendData> monthlyTrends;
  final List<DistrictComparison> districtComparisons;

  RegionalAnalytics({
    required this.regionId,
    required this.regionName,
    required this.reportDate,
    required this.healthMetrics,
    required this.diseaseOutbreaks,
    required this.hospitalUtilization,
    required this.workerStats,
    required this.vaccinationData,
    required this.monthlyTrends,
    required this.districtComparisons,
  });

  factory RegionalAnalytics.fromJson(Map<String, dynamic> json) {
    return RegionalAnalytics(
      regionId: json['regionId'],
      regionName: json['regionName'],
      reportDate: DateTime.parse(json['reportDate']),
      healthMetrics: HealthMetrics.fromJson(json['healthMetrics']),
      diseaseOutbreaks: DiseaseOutbreakData.fromJson(json['diseaseOutbreaks']),
      hospitalUtilization: HospitalUtilization.fromJson(json['hospitalUtilization']),
      workerStats: WorkerHealthStats.fromJson(json['workerStats']),
      vaccinationData: VaccinationCoverage.fromJson(json['vaccinationData']),
      monthlyTrends: (json['monthlyTrends'] as List)
          .map((item) => TrendData.fromJson(item))
          .toList(),
      districtComparisons: (json['districtComparisons'] as List)
          .map((item) => DistrictComparison.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regionId': regionId,
      'regionName': regionName,
      'reportDate': reportDate.toIso8601String(),
      'healthMetrics': healthMetrics.toJson(),
      'diseaseOutbreaks': diseaseOutbreaks.toJson(),
      'hospitalUtilization': hospitalUtilization.toJson(),
      'workerStats': workerStats.toJson(),
      'vaccinationData': vaccinationData.toJson(),
      'monthlyTrends': monthlyTrends.map((item) => item.toJson()).toList(),
      'districtComparisons': districtComparisons.map((item) => item.toJson()).toList(),
    };
  }
}

class HealthMetrics {
  final int totalWorkers;
  final int activeCases;
  final int recoveredCases;
  final int criticalCases;
  final int totalHospitals;
  final int operationalHospitals;
  final double mortalityRate;
  final double recoveryRate;
  final double bedOccupancyRate;

  HealthMetrics({
    required this.totalWorkers,
    required this.activeCases,
    required this.recoveredCases,
    required this.criticalCases,
    required this.totalHospitals,
    required this.operationalHospitals,
    required this.mortalityRate,
    required this.recoveryRate,
    required this.bedOccupancyRate,
  });

  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    return HealthMetrics(
      totalWorkers: json['totalWorkers'],
      activeCases: json['activeCases'],
      recoveredCases: json['recoveredCases'],
      criticalCases: json['criticalCases'],
      totalHospitals: json['totalHospitals'],
      operationalHospitals: json['operationalHospitals'],
      mortalityRate: json['mortalityRate'].toDouble(),
      recoveryRate: json['recoveryRate'].toDouble(),
      bedOccupancyRate: json['bedOccupancyRate'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalWorkers': totalWorkers,
      'activeCases': activeCases,
      'recoveredCases': recoveredCases,
      'criticalCases': criticalCases,
      'totalHospitals': totalHospitals,
      'operationalHospitals': operationalHospitals,
      'mortalityRate': mortalityRate,
      'recoveryRate': recoveryRate,
      'bedOccupancyRate': bedOccupancyRate,
    };
  }
}

class DiseaseOutbreakData {
  final List<OutbreakInfo> activeOutbreaks;
  final List<OutbreakInfo> recentOutbreaks;
  final int totalAffected;
  final String riskLevel;
  final List<PreventiveMeasure> recommendedMeasures;

  DiseaseOutbreakData({
    required this.activeOutbreaks,
    required this.recentOutbreaks,
    required this.totalAffected,
    required this.riskLevel,
    required this.recommendedMeasures,
  });

  factory DiseaseOutbreakData.fromJson(Map<String, dynamic> json) {
    return DiseaseOutbreakData(
      activeOutbreaks: (json['activeOutbreaks'] as List)
          .map((item) => OutbreakInfo.fromJson(item))
          .toList(),
      recentOutbreaks: (json['recentOutbreaks'] as List)
          .map((item) => OutbreakInfo.fromJson(item))
          .toList(),
      totalAffected: json['totalAffected'],
      riskLevel: json['riskLevel'],
      recommendedMeasures: (json['recommendedMeasures'] as List)
          .map((item) => PreventiveMeasure.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activeOutbreaks': activeOutbreaks.map((item) => item.toJson()).toList(),
      'recentOutbreaks': recentOutbreaks.map((item) => item.toJson()).toList(),
      'totalAffected': totalAffected,
      'riskLevel': riskLevel,
      'recommendedMeasures': recommendedMeasures.map((item) => item.toJson()).toList(),
    };
  }
}

class OutbreakInfo {
  final String diseaseId;
  final String diseaseName;
  final String location;
  final int affectedCount;
  final DateTime startDate;
  final DateTime? endDate;
  final String severity;
  final String status;
  final double latitude;
  final double longitude;

  OutbreakInfo({
    required this.diseaseId,
    required this.diseaseName,
    required this.location,
    required this.affectedCount,
    required this.startDate,
    this.endDate,
    required this.severity,
    required this.status,
    required this.latitude,
    required this.longitude,
  });

  factory OutbreakInfo.fromJson(Map<String, dynamic> json) {
    return OutbreakInfo(
      diseaseId: json['diseaseId'],
      diseaseName: json['diseaseName'],
      location: json['location'],
      affectedCount: json['affectedCount'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      severity: json['severity'],
      status: json['status'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diseaseId': diseaseId,
      'diseaseName': diseaseName,
      'location': location,
      'affectedCount': affectedCount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'severity': severity,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class PreventiveMeasure {
  final String measureId;
  final String title;
  final String description;
  final String priority;
  final String category;
  final bool isImplemented;
  final DateTime? implementationDate;

  PreventiveMeasure({
    required this.measureId,
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    required this.isImplemented,
    this.implementationDate,
  });

  factory PreventiveMeasure.fromJson(Map<String, dynamic> json) {
    return PreventiveMeasure(
      measureId: json['measureId'],
      title: json['title'],
      description: json['description'],
      priority: json['priority'],
      category: json['category'],
      isImplemented: json['isImplemented'],
      implementationDate: json['implementationDate'] != null 
          ? DateTime.parse(json['implementationDate']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'measureId': measureId,
      'title': title,
      'description': description,
      'priority': priority,
      'category': category,
      'isImplemented': isImplemented,
      'implementationDate': implementationDate?.toIso8601String(),
    };
  }
}

class HospitalUtilization {
  final int totalBeds;
  final int occupiedBeds;
  final int icuBeds;
  final int occupiedIcuBeds;
  final double occupancyRate;
  final double icuOccupancyRate;
  final List<HospitalCapacity> hospitalDetails;

  HospitalUtilization({
    required this.totalBeds,
    required this.occupiedBeds,
    required this.icuBeds,
    required this.occupiedIcuBeds,
    required this.occupancyRate,
    required this.icuOccupancyRate,
    required this.hospitalDetails,
  });

  factory HospitalUtilization.fromJson(Map<String, dynamic> json) {
    return HospitalUtilization(
      totalBeds: json['totalBeds'],
      occupiedBeds: json['occupiedBeds'],
      icuBeds: json['icuBeds'],
      occupiedIcuBeds: json['occupiedIcuBeds'],
      occupancyRate: json['occupancyRate'].toDouble(),
      icuOccupancyRate: json['icuOccupancyRate'].toDouble(),
      hospitalDetails: (json['hospitalDetails'] as List)
          .map((item) => HospitalCapacity.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBeds': totalBeds,
      'occupiedBeds': occupiedBeds,
      'icuBeds': icuBeds,
      'occupiedIcuBeds': occupiedIcuBeds,
      'occupancyRate': occupancyRate,
      'icuOccupancyRate': icuOccupancyRate,
      'hospitalDetails': hospitalDetails.map((item) => item.toJson()).toList(),
    };
  }
}

class HospitalCapacity {
  final String hospitalId;
  final String hospitalName;
  final int totalBeds;
  final int availableBeds;
  final int icuBeds;
  final int availableIcuBeds;
  final double occupancyRate;
  final String status;

  HospitalCapacity({
    required this.hospitalId,
    required this.hospitalName,
    required this.totalBeds,
    required this.availableBeds,
    required this.icuBeds,
    required this.availableIcuBeds,
    required this.occupancyRate,
    required this.status,
  });

  factory HospitalCapacity.fromJson(Map<String, dynamic> json) {
    return HospitalCapacity(
      hospitalId: json['hospitalId'],
      hospitalName: json['hospitalName'],
      totalBeds: json['totalBeds'],
      availableBeds: json['availableBeds'],
      icuBeds: json['icuBeds'],
      availableIcuBeds: json['availableIcuBeds'],
      occupancyRate: json['occupancyRate'].toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'totalBeds': totalBeds,
      'availableBeds': availableBeds,
      'icuBeds': icuBeds,
      'availableIcuBeds': availableIcuBeds,
      'occupancyRate': occupancyRate,
      'status': status,
    };
  }
}

class WorkerHealthStats {
  final int totalRegisteredWorkers;
  final int healthyWorkers;
  final int workersUnderTreatment;
  final int workersInQuarantine;
  final List<WorkerDemographics> demographics;
  final List<HealthConditionStat> commonConditions;

  WorkerHealthStats({
    required this.totalRegisteredWorkers,
    required this.healthyWorkers,
    required this.workersUnderTreatment,
    required this.workersInQuarantine,
    required this.demographics,
    required this.commonConditions,
  });

  factory WorkerHealthStats.fromJson(Map<String, dynamic> json) {
    return WorkerHealthStats(
      totalRegisteredWorkers: json['totalRegisteredWorkers'],
      healthyWorkers: json['healthyWorkers'],
      workersUnderTreatment: json['workersUnderTreatment'],
      workersInQuarantine: json['workersInQuarantine'],
      demographics: (json['demographics'] as List)
          .map((item) => WorkerDemographics.fromJson(item))
          .toList(),
      commonConditions: (json['commonConditions'] as List)
          .map((item) => HealthConditionStat.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRegisteredWorkers': totalRegisteredWorkers,
      'healthyWorkers': healthyWorkers,
      'workersUnderTreatment': workersUnderTreatment,
      'workersInQuarantine': workersInQuarantine,
      'demographics': demographics.map((item) => item.toJson()).toList(),
      'commonConditions': commonConditions.map((item) => item.toJson()).toList(),
    };
  }
}

class WorkerDemographics {
  final String category;
  final String label;
  final int count;
  final double percentage;

  WorkerDemographics({
    required this.category,
    required this.label,
    required this.count,
    required this.percentage,
  });

  factory WorkerDemographics.fromJson(Map<String, dynamic> json) {
    return WorkerDemographics(
      category: json['category'],
      label: json['label'],
      count: json['count'],
      percentage: json['percentage'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'label': label,
      'count': count,
      'percentage': percentage,
    };
  }
}

class HealthConditionStat {
  final String conditionName;
  final int affectedCount;
  final double prevalenceRate;
  final String trendDirection;
  final double trendPercentage;

  HealthConditionStat({
    required this.conditionName,
    required this.affectedCount,
    required this.prevalenceRate,
    required this.trendDirection,
    required this.trendPercentage,
  });

  factory HealthConditionStat.fromJson(Map<String, dynamic> json) {
    return HealthConditionStat(
      conditionName: json['conditionName'],
      affectedCount: json['affectedCount'],
      prevalenceRate: json['prevalenceRate'].toDouble(),
      trendDirection: json['trendDirection'],
      trendPercentage: json['trendPercentage'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conditionName': conditionName,
      'affectedCount': affectedCount,
      'prevalenceRate': prevalenceRate,
      'trendDirection': trendDirection,
      'trendPercentage': trendPercentage,
    };
  }
}

class VaccinationCoverage {
  final double overallCoverage;
  final List<VaccineTypeData> vaccineTypes;
  final List<AgeGroupCoverage> ageGroups;
  final int totalVaccinated;
  final int targetPopulation;

  VaccinationCoverage({
    required this.overallCoverage,
    required this.vaccineTypes,
    required this.ageGroups,
    required this.totalVaccinated,
    required this.targetPopulation,
  });

  factory VaccinationCoverage.fromJson(Map<String, dynamic> json) {
    return VaccinationCoverage(
      overallCoverage: json['overallCoverage'].toDouble(),
      vaccineTypes: (json['vaccineTypes'] as List)
          .map((item) => VaccineTypeData.fromJson(item))
          .toList(),
      ageGroups: (json['ageGroups'] as List)
          .map((item) => AgeGroupCoverage.fromJson(item))
          .toList(),
      totalVaccinated: json['totalVaccinated'],
      targetPopulation: json['targetPopulation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallCoverage': overallCoverage,
      'vaccineTypes': vaccineTypes.map((item) => item.toJson()).toList(),
      'ageGroups': ageGroups.map((item) => item.toJson()).toList(),
      'totalVaccinated': totalVaccinated,
      'targetPopulation': targetPopulation,
    };
  }
}

class VaccineTypeData {
  final String vaccineType;
  final int administeredDoses;
  final double coveragePercentage;
  final DateTime lastUpdate;

  VaccineTypeData({
    required this.vaccineType,
    required this.administeredDoses,
    required this.coveragePercentage,
    required this.lastUpdate,
  });

  factory VaccineTypeData.fromJson(Map<String, dynamic> json) {
    return VaccineTypeData(
      vaccineType: json['vaccineType'],
      administeredDoses: json['administeredDoses'],
      coveragePercentage: json['coveragePercentage'].toDouble(),
      lastUpdate: DateTime.parse(json['lastUpdate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vaccineType': vaccineType,
      'administeredDoses': administeredDoses,
      'coveragePercentage': coveragePercentage,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
}

class AgeGroupCoverage {
  final String ageGroup;
  final int population;
  final int vaccinated;
  final double coveragePercentage;

  AgeGroupCoverage({
    required this.ageGroup,
    required this.population,
    required this.vaccinated,
    required this.coveragePercentage,
  });

  factory AgeGroupCoverage.fromJson(Map<String, dynamic> json) {
    return AgeGroupCoverage(
      ageGroup: json['ageGroup'],
      population: json['population'],
      vaccinated: json['vaccinated'],
      coveragePercentage: json['coveragePercentage'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ageGroup': ageGroup,
      'population': population,
      'vaccinated': vaccinated,
      'coveragePercentage': coveragePercentage,
    };
  }
}

class TrendData {
  final String month;
  final DateTime date;
  final int totalCases;
  final int newCases;
  final int recoveries;
  final int deaths;
  final double mortalityRate;

  TrendData({
    required this.month,
    required this.date,
    required this.totalCases,
    required this.newCases,
    required this.recoveries,
    required this.deaths,
    required this.mortalityRate,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      month: json['month'],
      date: DateTime.parse(json['date']),
      totalCases: json['totalCases'],
      newCases: json['newCases'],
      recoveries: json['recoveries'],
      deaths: json['deaths'],
      mortalityRate: json['mortalityRate'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'date': date.toIso8601String(),
      'totalCases': totalCases,
      'newCases': newCases,
      'recoveries': recoveries,
      'deaths': deaths,
      'mortalityRate': mortalityRate,
    };
  }
}

class DistrictComparison {
  final String districtName;
  final int population;
  final int totalCases;
  final double incidenceRate;
  final String riskLevel;
  final double vaccinationCoverage;

  DistrictComparison({
    required this.districtName,
    required this.population,
    required this.totalCases,
    required this.incidenceRate,
    required this.riskLevel,
    required this.vaccinationCoverage,
  });

  factory DistrictComparison.fromJson(Map<String, dynamic> json) {
    return DistrictComparison(
      districtName: json['districtName'],
      population: json['population'],
      totalCases: json['totalCases'],
      incidenceRate: json['incidenceRate'].toDouble(),
      riskLevel: json['riskLevel'],
      vaccinationCoverage: json['vaccinationCoverage'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'districtName': districtName,
      'population': population,
      'totalCases': totalCases,
      'incidenceRate': incidenceRate,
      'riskLevel': riskLevel,
      'vaccinationCoverage': vaccinationCoverage,
    };
  }
}
