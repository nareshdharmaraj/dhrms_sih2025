const Zone = require('../models/Zone');
const RegionalHealthOfficer = require('../models/RegionalHealthOfficer');

/**
 * Service for determining hospital zone assignments based on location
 */
class HospitalZoneAssignmentService {
  
  /**
   * Determine zone assignment for a hospital based on its location
   * @param {Object} hospitalLocation - Hospital location data
   * @param {string} hospitalLocation.state - State name
   * @param {string} hospitalLocation.district - District name  
   * @param {string} hospitalLocation.city - City name
   * @param {string} hospitalLocation.pincode - Pincode
   * @param {string} hospitalLocation.address - Full address
   * @returns {Promise<Object>} Zone assignment result
   */
  static async determineZoneAssignment(hospitalLocation) {
    try {
      const { state, district, city, pincode, address } = hospitalLocation;
      
      console.log(`🔍 Determining zone assignment for hospital in ${city}, ${district}, ${state}`);
      
      // Get all zones in the district
      const zones = await Zone.find({
        state: state,
        district: district,
        isActive: true
      }).populate('assignedRHO.rhoId');
      
      if (zones.length === 0) {
        console.log(`⚠️ No zones found for ${district}, ${state}`);
        return {
          success: false,
          message: `No zones configured for ${district} district`,
          assignmentMethod: 'none'
        };
      }
      
      console.log(`📋 Found ${zones.length} zones in ${district}, ${state}`);
      
      // For single zone districts (non-dense)
      if (zones.length === 1) {
        const zone = zones[0];
        console.log(`📍 Single zone district - assigning to ${zone.zoneName}`);
        
        return {
          success: true,
          zoneId: zone.zoneId,
          zoneName: zone.zoneName,
          area: zone.areas.length > 0 ? zone.areas[0].areaName : district,
          assignedRHO: zone.assignedRHO?.rhoId || null,
          assignmentMethod: 'single-zone'
        };
      }
      
      // For multiple zone districts (dense districts)
      // Try to match by area name patterns
      const areaMatches = this.findAreaMatches(city, address, zones);
      
      if (areaMatches.length > 0) {
        const bestMatch = areaMatches[0];
        console.log(`🎯 Area match found - assigning to ${bestMatch.zoneName} (area: ${bestMatch.area})`);
        
        return {
          success: true,
          zoneId: bestMatch.zoneId,
          zoneName: bestMatch.zoneName,
          area: bestMatch.area,
          assignedRHO: bestMatch.assignedRHO,
          assignmentMethod: 'area-match'
        };
      }
      
      // Try pincode-based assignment
      const pincodeMatch = await this.findPincodeMatch(pincode, zones);
      
      if (pincodeMatch) {
        console.log(`📮 Pincode match found - assigning to ${pincodeMatch.zoneName}`);
        
        return {
          success: true,
          zoneId: pincodeMatch.zoneId,
          zoneName: pincodeMatch.zoneName,
          area: pincodeMatch.area,
          assignedRHO: pincodeMatch.assignedRHO,
          assignmentMethod: 'pincode-based'
        };
      }
      
      // Fallback: Assign to first available zone with RHO
      const availableZone = zones.find(zone => zone.assignedRHO && zone.assignedRHO.rhoId);
      
      if (availableZone) {
        console.log(`🔄 Fallback assignment to ${availableZone.zoneName}`);
        
        return {
          success: true,
          zoneId: availableZone.zoneId,
          zoneName: availableZone.zoneName,
          area: availableZone.areas.length > 0 ? availableZone.areas[0].areaName : district,
          assignedRHO: availableZone.assignedRHO.rhoId,
          assignmentMethod: 'fallback'
        };
      }
      
      // No zones with assigned RHOs
      console.log(`⚠️ No zones with assigned RHOs found in ${district}`);
      
      return {
        success: false,
        message: `No RHO assigned to any zone in ${district} district`,
        assignmentMethod: 'no-rho'
      };
      
    } catch (error) {
      console.error('Error determining zone assignment:', error);
      return {
        success: false,
        message: 'Error determining zone assignment',
        error: error.message
      };
    }
  }
  
  /**
   * Find area matches based on city name and address
   * @param {string} city - Hospital city
   * @param {string} address - Hospital address
   * @param {Array} zones - Available zones
   * @returns {Array} Matching zones with scores
   */
  static findAreaMatches(city, address, zones) {
    const matches = [];
    
    zones.forEach(zone => {
      zone.areas.forEach(area => {
        let score = 0;
        
        // Direct city match with area name
        if (city.toLowerCase().includes(area.areaName.toLowerCase()) || 
            area.areaName.toLowerCase().includes(city.toLowerCase())) {
          score += 10;
        }
        
        // Address contains area name
        if (address.toLowerCase().includes(area.areaName.toLowerCase())) {
          score += 5;
        }
        
        // Partial matches
        const cityWords = city.toLowerCase().split(/\s+/);
        const areaWords = area.areaName.toLowerCase().split(/\s+/);
        
        cityWords.forEach(cityWord => {
          areaWords.forEach(areaWord => {
            if (cityWord.includes(areaWord) || areaWord.includes(cityWord)) {
              score += 2;
            }
          });
        });
        
        if (score > 0) {
          matches.push({
            zoneId: zone.zoneId,
            zoneName: zone.zoneName,
            area: area.areaName,
            assignedRHO: zone.assignedRHO?.rhoId || null,
            score: score
          });
        }
      });
    });
    
    // Sort by score (highest first)
    return matches.sort((a, b) => b.score - a.score);
  }
  
  /**
   * Find zone based on pincode mapping
   * @param {string} pincode - Hospital pincode
   * @param {Array} zones - Available zones
   * @returns {Object|null} Matching zone or null
   */
  static async findPincodeMatch(pincode, zones) {
    // Simple pincode-based assignment logic
    // This can be enhanced with actual pincode-to-area mapping data
    
    // For Kerala Ernakulam example:
    const pincodeAreaMap = {
      '682001': 'Ernakulam',
      '682002': 'Ernakulam', 
      '682003': 'Ernakulam',
      '682004': 'Ernakulam',
      '682005': 'Ernakulam',
      '682006': 'Ernakulam',
      '682011': 'Ernakulam',
      '682012': 'Ernakulam',
      '682013': 'Ernakulam',
      '682014': 'Ernakulam',
      '682015': 'Ernakulam',
      '682016': 'Ernakulam',
      '682017': 'Ernakulam',
      '682018': 'Ernakulam',
      '682019': 'Ernakulam',
      '682020': 'Ernakulam',
      '682021': 'Ernakulam',
      '682022': 'Ernakulam',
      '682023': 'Ernakulam',
      '682024': 'Ernakulam',
      '682025': 'Ernakulam',
      '682026': 'Ernakulam',
      '682027': 'Ernakulam',
      '682028': 'Ernakulam',
      '682029': 'Ernakulam',
      '682030': 'Ernakulam',
      '682031': 'Ernakulam',
      '682032': 'Ernakulam',
      '682033': 'Ernakulam',
      '682034': 'Ernakulam',
      '682035': 'Ernakulam',
      '682036': 'Ernakulam',
      '682037': 'Ernakulam',
      '682038': 'Ernakulam',
      '682039': 'Ernakulam',
      '682040': 'Ernakulam',
      '682041': 'Ernakulam',
      '682042': 'Ernakulam',
      '682301': 'Kothamangalam',
      '682302': 'Kothamangalam',
      '682303': 'Kothamangalam',
      '683101': 'Aluva',
      '683102': 'Aluva',
      '683103': 'Aluva',
      '683104': 'Aluva',
      '683105': 'Aluva',
      '683106': 'Aluva',
      '683501': 'Paravur',
      '683502': 'Paravur',
      '683503': 'Paravur',
      '683504': 'Paravur',
      '683520': 'Paravur',
      '683572': 'Thrikkakara',
      '683573': 'Thrikkakara'
    };
    
    const mappedArea = pincodeAreaMap[pincode];
    
    if (mappedArea) {
      // Find zone that contains this area
      const matchingZone = zones.find(zone => 
        zone.areas.some(area => 
          area.areaName.toLowerCase().includes(mappedArea.toLowerCase())
        )
      );
      
      if (matchingZone) {
        const matchedArea = matchingZone.areas.find(area => 
          area.areaName.toLowerCase().includes(mappedArea.toLowerCase())
        );
        
        return {
          zoneId: matchingZone.zoneId,
          zoneName: matchingZone.zoneName,
          area: matchedArea.areaName,
          assignedRHO: matchingZone.assignedRHO?.rhoId || null
        };
      }
    }
    
    return null;
  }
  
  /**
   * Get RHO assigned to a specific hospital's zone
   * @param {Object} hospital - Hospital document
   * @returns {Promise<Object|null>} RHO data or null
   */
  static async getRHOForHospital(hospital) {
    try {
      if (!hospital.zoneAssignment || !hospital.zoneAssignment.assignedRHO) {
        return null;
      }
      
      const rho = await RegionalHealthOfficer.findOne({
        officerId: hospital.zoneAssignment.assignedRHO
      });
      
      return rho;
    } catch (error) {
      console.error('Error getting RHO for hospital:', error);
      return null;
    }
  }
  
  /**
   * Update hospital zone assignment
   * @param {Object} hospital - Hospital document  
   * @returns {Promise<Object>} Updated hospital with zone assignment
   */
  static async updateHospitalZoneAssignment(hospital) {
    try {
      const locationData = {
        state: hospital.location.state,
        district: hospital.location.district,
        city: hospital.location.city,
        pincode: hospital.location.pincode,
        address: hospital.location.address
      };
      
      const zoneAssignment = await this.determineZoneAssignment(locationData);
      
      if (zoneAssignment.success) {
        hospital.zoneAssignment = {
          area: zoneAssignment.area,
          zoneId: zoneAssignment.zoneId,
          zoneName: zoneAssignment.zoneName,
          assignedRHO: zoneAssignment.assignedRHO,
          assignmentMethod: zoneAssignment.assignmentMethod,
          lastUpdated: new Date()
        };
        
        await hospital.save();
        console.log(`✅ Updated zone assignment for ${hospital.name}: ${zoneAssignment.zoneName} (${zoneAssignment.area})`);
      }
      
      return hospital;
    } catch (error) {
      console.error('Error updating hospital zone assignment:', error);
      throw error;
    }
  }
}

module.exports = HospitalZoneAssignmentService;