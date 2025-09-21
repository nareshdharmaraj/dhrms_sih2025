const { DISTRICT_MAPPING } = require('./districtMockDataService');
const fs = require('fs');
const path = require('path');

// Load real state/district data
const stateDistrictData = JSON.parse(
  fs.readFileSync(path.join(__dirname, '../data/indian_states_districts.json'), 'utf8')
);

// Configuration for district population density classification
const DISTRICT_CLASSIFICATION = {
  // Dense districts require multiple RHOs with specific area assignments
  DENSE_DISTRICTS: {
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Salem', 'Tiruppur'],
    'Karnataka': ['Bengaluru Urban', 'Mysuru', 'Hubli-Dharwad'],
    'Maharashtra': ['Mumbai City', 'Mumbai Suburban', 'Pune', 'Thane'],
    'Kerala': ['Ernakulam', 'Thiruvananthapuram', 'Thrissur'],
    'Andhra Pradesh': ['Visakhapatnam', 'Vijayawada', 'Guntur'],
    'Telangana': ['Hyderabad', 'Warangal'],
    'West Bengal': ['Kolkata', 'Howrah'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara']
  },
  
  // Population threshold for dense district classification
  DENSE_POPULATION_THRESHOLD: 2000000, // 2 million
  
  // Area threshold for dense district classification (km²)
  DENSE_AREA_THRESHOLD: 1000
};

// Detailed area mappings for dense districts
const DISTRICT_AREA_MAPPINGS = {
  'Chennai': {
    areas: [
      {
        name: 'Ambattur',
        code: 'AMB',
        subDistricts: ['Ambattur', 'Avadi'],
        blocks: ['Ambattur Block', 'Avadi Block'],
        villages: ['Ambattur Village', 'Korattur', 'Mogappair'],
        population: 900000,
        areaKm2: 85,
        ruralPopulation: 50000,
        urbanPopulation: 850000
      },
      {
        name: 'Sholinganallur',
        code: 'SGL',
        subDistricts: ['Sholinganallur', 'Perungudi'],
        blocks: ['Sholinganallur Block', 'Perungudi Block'],
        villages: ['Sholinganallur Village', 'Navalur', 'Sithalapakkam'],
        population: 800000,
        areaKm2: 75,
        ruralPopulation: 30000,
        urbanPopulation: 770000
      },
      {
        name: 'Central Chennai',
        code: 'CEN',
        subDistricts: ['Chennai Central', 'Egmore'],
        blocks: ['Central Block', 'Egmore Block'],
        villages: ['George Town', 'Purasawalkam', 'Chetpet'],
        population: 1200000,
        areaKm2: 95,
        ruralPopulation: 20000,
        urbanPopulation: 1180000
      },
      {
        name: 'South Chennai',
        code: 'STH',
        subDistricts: ['Alandur', 'Tambaram'],
        blocks: ['Alandur Block', 'Tambaram Block'],
        villages: ['Alandur Village', 'Pallavaram', 'Chrompet'],
        population: 1100000,
        areaKm2: 90,
        ruralPopulation: 80000,
        urbanPopulation: 1020000
      },
      {
        name: 'North Chennai',
        code: 'NTH',
        subDistricts: ['Tiruvottiyur', 'Manali'],
        blocks: ['Tiruvottiyur Block', 'Manali Block'],
        villages: ['Tiruvottiyur Village', 'Ennore', 'Madhavaram'],
        population: 846732,
        areaKm2: 81,
        ruralPopulation: 100000,
        urbanPopulation: 746732
      }
    ]
  },
  
  'Coimbatore': {
    areas: [
      {
        name: 'Coimbatore North',
        code: 'CBN',
        subDistricts: ['Coimbatore North', 'Singanallur'],
        blocks: ['North Block', 'Singanallur Block'],
        villages: ['Ganapathy', 'Saravanampatti', 'Thudiyalur'],
        population: 1200000,
        areaKm2: 2500,
        ruralPopulation: 600000,
        urbanPopulation: 600000
      },
      {
        name: 'Coimbatore South',
        code: 'CBS',
        subDistricts: ['Coimbatore South', 'Pollachi'],
        blocks: ['South Block', 'Pollachi Block'],
        villages: ['Sarkar Periyapalayam', 'Kinathukadavu', 'Anaikatti'],
        population: 1100000,
        areaKm2: 2800,
        ruralPopulation: 700000,
        urbanPopulation: 400000
      },
      {
        name: 'Pollachi-Valparai',
        code: 'PLV',
        subDistricts: ['Pollachi', 'Valparai'],
        blocks: ['Pollachi Block', 'Valparai Block'],
        villages: ['Pollachi Town', 'Udumalaipettai', 'Valparai Estate'],
        population: 1158045,
        areaKm2: 2169,
        ruralPopulation: 900000,
        urbanPopulation: 258045
      }
    ]
  },
  
  'Bengaluru Urban': {
    areas: [
      {
        name: 'Bangalore North',
        code: 'BLN',
        subDistricts: ['Bangalore North', 'Yelahanka'],
        blocks: ['Yelahanka Block', 'Devanahalli Block'],
        villages: ['Yelahanka', 'Devanahalli', 'Bagalur'],
        population: 2500000,
        areaKm2: 800,
        ruralPopulation: 200000,
        urbanPopulation: 2300000
      },
      {
        name: 'Bangalore South',
        code: 'BLS',
        subDistricts: ['Bangalore South', 'Anekal'],
        blocks: ['Anekal Block', 'Bommanahalli Block'],
        villages: ['Anekal', 'Electronic City', 'Bannerghatta'],
        population: 2300000,
        areaKm2: 750,
        ruralPopulation: 300000,
        urbanPopulation: 2000000
      },
      {
        name: 'Bangalore East',
        code: 'BLE',
        subDistricts: ['Bangalore East', 'Whitefield'],
        blocks: ['Whitefield Block', 'Hosakote Block'],
        villages: ['Whitefield', 'Marathahalli', 'Brookefield'],
        population: 2200000,
        areaKm2: 700,
        ruralPopulation: 250000,
        urbanPopulation: 1950000
      }
    ]
  },
  
  'Mumbai City': {
    areas: [
      {
        name: 'South Mumbai',
        code: 'MBS',
        subDistricts: ['South Mumbai', 'Fort'],
        blocks: ['Colaba Block', 'Fort Block'],
        villages: ['Colaba', 'Cuffe Parade', 'Nariman Point'],
        population: 1000000,
        areaKm2: 70,
        ruralPopulation: 5000,
        urbanPopulation: 995000
      },
      {
        name: 'Central Mumbai',
        code: 'MBC',
        subDistricts: ['Central Mumbai', 'Dadar'],
        blocks: ['Dadar Block', 'Parel Block'],
        villages: ['Dadar', 'Parel', 'Worli'],
        population: 1200000,
        areaKm2: 80,
        ruralPopulation: 10000,
        urbanPopulation: 1190000
      },
      {
        name: 'North Mumbai',
        code: 'MBN',
        subDistricts: ['North Mumbai', 'Andheri'],
        blocks: ['Andheri Block', 'Borivali Block'],
        villages: ['Andheri', 'Borivali', 'Malad'],
        population: 1300000,
        areaKm2: 90,
        ruralPopulation: 15000,
        urbanPopulation: 1285000
      }
    ]
  }
};

// Service functions
class AreaAssignmentService {
  
  /**
   * Check if a district is classified as dense (requires multiple RHOs)
   */
  static isDenseDistrict(state, district) {
    const denseDistricts = DISTRICT_CLASSIFICATION.DENSE_DISTRICTS[state] || [];
    return denseDistricts.includes(district);
  }
  
  /**
   * Get available areas for a dense district
   */
  static getDistrictAreas(district) {
    return DISTRICT_AREA_MAPPINGS[district] || null;
  }
  
  /**
   * Get area by name within a district
   */
  static getAreaByName(district, areaName) {
    const districtData = DISTRICT_AREA_MAPPINGS[district];
    if (!districtData) return null;
    
    return districtData.areas.find(area => area.name === areaName) || null;
  }
  
  /**
   * Get all available areas for district selection
   */
  static getAreaOptions(district) {
    const districtData = DISTRICT_AREA_MAPPINGS[district];
    if (!districtData) return [];
    
    return districtData.areas.map(area => ({
      name: area.name,
      code: area.code,
      population: area.population,
      areaKm2: area.areaKm2
    }));
  }
  
  /**
   * Check if an area is already assigned to another RHO
   */
  static async isAreaAssigned(district, areaName, excludeRhoId = null) {
    const RegionalHealthOfficer = require('../models/RegionalHealthOfficer');
    
    const query = {
      assignedDistrict: district,
      'assignedAreas.name': areaName,
      isActive: true
    };
    
    if (excludeRhoId) {
      query.officerId = { $ne: excludeRhoId };
    }
    
    const existingRHO = await RegionalHealthOfficer.findOne(query);
    return !!existingRHO;
  }
  
  /**
   * Generate RHO ID with area information for dense districts
   */
  static async generateAreaBasedRHOId(state, district, areaName = null) {
    const RegionalHealthOfficer = require('../models/RegionalHealthOfficer');
    
    try {
      let query = { 
        assignedState: state,
        assignedDistrict: district 
      };
      
      // For dense districts with specific area assignment
      if (areaName && this.isDenseDistrict(state, district)) {
        query['assignedAreas.name'] = areaName;
      }
      
      const count = await RegionalHealthOfficer.countDocuments(query);
      const number = String(count + 1).padStart(3, '0');
      
      // Generate different formats based on district type
      if (areaName && this.isDenseDistrict(state, district)) {
        const areaData = this.getAreaByName(district, areaName);
        const areaCode = areaData ? areaData.code : areaName.substring(0, 3).toUpperCase();
        return `RHO_${district.toUpperCase()}_${number}-${areaCode}`;
      } else {
        // For sparse districts or when no specific area
        return `RHO_${district}_${number}`;
      }
      
    } catch (error) {
      console.error('Error generating area-based RHO ID:', error);
      throw new Error('Failed to generate RHO ID');
    }
  }
  
  /**
   * Get assignment strategy for a district
   */
  static getAssignmentStrategy(state, district) {
    const isDense = this.isDenseDistrict(state, district);
    const areas = this.getDistrictAreas(district);
    
    return {
      isDense,
      requiresAreaSelection: isDense && !!areas,
      availableAreas: areas ? areas.areas : [],
      assignmentType: isDense ? 'area-specific' : 'full-district',
      maxRHOsRecommended: areas ? areas.areas.length : 1
    };
  }
  
  /**
   * Validate area assignment for RHO creation
   */
  static async validateAreaAssignment(state, district, assignedAreas = []) {
    const strategy = this.getAssignmentStrategy(state, district);
    const errors = [];
    
    // If dense district, require area assignment
    if (strategy.isDense && strategy.requiresAreaSelection) {
      if (!assignedAreas || assignedAreas.length === 0) {
        errors.push('Dense districts require specific area assignment');
        return { isValid: false, errors };
      }
      
      // Validate each assigned area
      for (const areaName of assignedAreas) {
        const areaData = this.getAreaByName(district, areaName);
        if (!areaData) {
          errors.push(`Invalid area '${areaName}' for district '${district}'`);
          continue;
        }
        
        // Check if area is already assigned
        const isAssigned = await this.isAreaAssigned(district, areaName);
        if (isAssigned) {
          errors.push(`Area '${areaName}' is already assigned to another RHO`);
        }
      }
    }
    
    return {
      isValid: errors.length === 0,
      errors,
      strategy
    };
  }
  
  /**
   * Get coverage data for assigned areas
   */
  static getCoverageForAreas(district, assignedAreas = []) {
    const districtData = this.getDistrictAreas(district);
    if (!districtData) {
      return {
        subDistricts: [],
        blocks: [],
        villages: [],
        population: 0,
        areaKm2: 0,
        ruralPopulation: 0,
        urbanPopulation: 0
      };
    }
    
    let totalCoverage = {
      subDistricts: [],
      blocks: [],
      villages: [],
      population: 0,
      areaKm2: 0,
      ruralPopulation: 0,
      urbanPopulation: 0
    };
    
    assignedAreas.forEach(areaName => {
      const areaData = districtData.areas.find(area => area.name === areaName);
      if (areaData) {
        totalCoverage.subDistricts.push(...areaData.subDistricts);
        totalCoverage.blocks.push(...areaData.blocks);
        totalCoverage.villages.push(...areaData.villages);
        totalCoverage.population += areaData.population;
        totalCoverage.areaKm2 += areaData.areaKm2;
        totalCoverage.ruralPopulation += areaData.ruralPopulation;
        totalCoverage.urbanPopulation += areaData.urbanPopulation;
      }
    });
    
    // Remove duplicates
    totalCoverage.subDistricts = [...new Set(totalCoverage.subDistricts)];
    totalCoverage.blocks = [...new Set(totalCoverage.blocks)];
    totalCoverage.villages = [...new Set(totalCoverage.villages)];
    
    return totalCoverage;
  }

  /**
   * Get all available states from real data
   */
  static getAvailableStates() {
    return stateDistrictData.map(state => ({
      name: state.state,
      code: state.state_code,
      districts: state.districts.length
    }));
  }

  /**
   * Get districts for a specific state
   */
  static getDistrictsForState(stateName) {
    const stateData = stateDistrictData.find(state => state.state === stateName);
    if (!stateData) {
      throw new Error(`State '${stateName}' not found`);
    }
    
    return stateData.districts.map(district => ({
      name: district.district,
      state: stateName,
      isDense: this.isDenseDistrict(stateName, district.district),
      subdistricts: district.subdistricts || [],
      hasAreas: district.subdistricts && district.subdistricts.length > 0
    }));
  }

  /**
   * Get district assignment information with real data
   */
  static getDistrictAssignmentInfoWithRealData(districtName) {
    // Find which state this district belongs to
    let districtState = null;
    let districtInfo = null;
    
    for (const state of stateDistrictData) {
      const district = state.districts.find(d => d.district === districtName);
      if (district) {
        districtState = state.state;
        districtInfo = district;
        break;
      }
    }
    
    if (!districtInfo) {
      throw new Error(`District '${districtName}' not found`);
    }

    const isDense = this.isDenseDistrict(districtState, districtName);
    
    if (isDense) {
      // Get predefined areas if available, otherwise create from subdistricts
      const predefinedAreas = DISTRICT_AREA_MAPPINGS[districtName];
      let areas = [];
      
      if (predefinedAreas) {
        areas = predefinedAreas.areas;
      } else {
        // Create areas from subdistricts for dense districts
        areas = this.createAreasFromSubdistricts(districtName, districtInfo.subdistricts);
      }
      
      return {
        district: districtName,
        state: districtState,
        type: 'dense',
        areas: areas,
        requiresAreaSelection: true,
        subdistricts: districtInfo.subdistricts
      };
    } else {
      return {
        district: districtName,
        state: districtState,
        type: 'sparse',
        areas: [{
          name: `${districtName} (Full District)`,
          code: `${districtName.toUpperCase().replace(/\s+/g, '_')}_FULL`,
          subDistricts: districtInfo.subdistricts,
          population: this.estimateDistrictPopulation(districtInfo.subdistricts),
          ruralPopulation: 0,
          urbanPopulation: 0
        }],
        requiresAreaSelection: false,
        subdistricts: districtInfo.subdistricts
      };
    }
  }

  /**
   * Create areas from subdistricts for districts not in predefined mappings
   */
  static createAreasFromSubdistricts(districtName, subdistricts) {
    if (!subdistricts || subdistricts.length === 0) {
      return [{
        name: `${districtName} (Full District)`,
        code: `${districtName.toUpperCase().replace(/\s+/g, '_')}_FULL`,
        subDistricts: [],
        population: 500000
      }];
    }

    // Group subdistricts into logical areas (e.g., by 3-4 subdistricts per area)
    const areas = [];
    const subdistrictsPerArea = Math.max(1, Math.ceil(subdistricts.length / 3));
    
    for (let i = 0; i < subdistricts.length; i += subdistrictsPerArea) {
      const areaSubdistricts = subdistricts.slice(i, i + subdistrictsPerArea);
      const areaName = areaSubdistricts.length === 1 
        ? areaSubdistricts[0] 
        : `${districtName} Zone ${Math.floor(i / subdistrictsPerArea) + 1}`;
      
      areas.push({
        name: areaName,
        code: `${districtName.toUpperCase().replace(/\s+/g, '_')}_${i / subdistrictsPerArea + 1}`,
        subDistricts: areaSubdistricts,
        blocks: areaSubdistricts,
        villages: [],
        population: 400000,
        areaKm2: 50,
        ruralPopulation: 100000,
        urbanPopulation: 300000
      });
    }
    
    return areas;
  }

  /**
   * Estimate population for a district based on subdistricts
   */
  static estimateDistrictPopulation(subdistricts) {
    // Basic estimation: 100k per subdistrict
    return (subdistricts || []).length * 100000 || 500000;
  }
}

module.exports = {
  AreaAssignmentService,
  DISTRICT_CLASSIFICATION,
  DISTRICT_AREA_MAPPINGS
};