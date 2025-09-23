const Zone = require('../models/Zone');
const { validationResult } = require('express-validator');

class ZoneManagementController {
  
  /**
   * Create a new zone with areas
   */
  static async createZone(req, res) {
    try {
      console.log('🔥 Zone creation request received:', JSON.stringify(req.body, null, 2));
      
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        console.log('❌ Validation errors:', errors.array());
        return res.status(400).json({
          success: false,
          message: 'Validation errors',
          errors: errors.array()
        });
      }

      const {
        zoneName,
        state,
        district,
        areas,
        zoneType,
        priority,
        metadata,
        createdBy
      } = req.body;

      console.log('📝 Creating zone with data:', {
        zoneName,
        state,
        district,
        areasCount: areas ? areas.length : 0,
        zoneType,
        priority,
        createdBy
      });

      // Generate unique zone ID
      const zoneId = `ZONE_${state}_${district}_${Date.now()}`.toUpperCase().replace(/\s+/g, '_');
      console.log('🆔 Generated zone ID:', zoneId);

      // Create new zone
      const newZone = new Zone({
        zoneId,
        zoneName,
        state,
        district,
        areas: areas || [],
        zoneType: zoneType || 'urban',
        priority: priority || 'medium',
        metadata: metadata || {},
        createdBy,
        isActive: true
      });

      console.log('💾 Attempting to save zone...');
      const savedZone = await newZone.save();
      console.log('✅ Zone saved successfully with ID:', savedZone._id);

      res.status(201).json({
        success: true,
        message: 'Zone created successfully',
        data: savedZone
      });

    } catch (error) {
      console.error('❌ Error creating zone:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to create zone',
        error: error.message
      });
    }
  }

  /**
   * Get zones by district
   */
  static async getZonesByDistrict(req, res) {
    try {
      const { state, district } = req.params;

      if (!state || !district) {
        return res.status(400).json({
          success: false,
          message: 'State and district are required'
        });
      }

      const zones = await Zone.findByDistrict(state, district);
      const stats = await Zone.getDistrictStats(state, district);

      res.status(200).json({
        success: true,
        message: 'Zones retrieved successfully',
        data: {
          zones,
          statistics: stats[0] || {
            totalZones: 0,
            assignedZones: 0,
            unassignedZones: 0,
            assignmentPercentage: 0,
            totalAreas: 0,
            coveredAreas: 0,
            coveragePercentage: 0
          }
        }
      });

    } catch (error) {
      console.error('Error fetching zones by district:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch zones',
        error: error.message
      });
    }
  }

  /**
   * Get zones assigned to a specific RHO
   */
  static async getZonesByRHO(req, res) {
    try {
      const { rhoId } = req.params;

      if (!rhoId) {
        return res.status(400).json({
          success: false,
          message: 'RHO ID is required'
        });
      }

      const zones = await Zone.findByRHO(rhoId);

      res.status(200).json({
        success: true,
        message: 'RHO zones retrieved successfully',
        data: zones
      });

    } catch (error) {
      console.error('Error fetching zones by RHO:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch RHO zones',
        error: error.message
      });
    }
  }

  /**
   * Get unassigned zones for a district
   */
  static async getUnassignedZones(req, res) {
    try {
      const { state, district } = req.params;

      if (!state || !district) {
        return res.status(400).json({
          success: false,
          message: 'State and district are required'
        });
      }

      const unassignedZones = await Zone.findUnassigned(state, district);

      res.status(200).json({
        success: true,
        message: 'Unassigned zones retrieved successfully',
        data: unassignedZones
      });

    } catch (error) {
      console.error('Error fetching unassigned zones:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch unassigned zones',
        error: error.message
      });
    }
  }

  /**
   * Get available areas for a district (not yet assigned to any zone)
   */
  static async getAvailableAreas(req, res) {
    try {
      const { state, district } = req.params;

      if (!state || !district) {
        return res.status(400).json({
          success: false,
          message: 'State and district are required'
        });
      }

      // Get all zones in the district
      const existingZones = await Zone.find({ 
        state, 
        district, 
        isActive: true 
      });

      // Extract all assigned areas
      const assignedAreas = [];
      existingZones.forEach(zone => {
        zone.areas.forEach(area => {
          assignedAreas.push(area.areaName.toLowerCase());
        });
      });

      // Get actual sub-districts from area assignment service instead of hardcoded data
      const AreaAssignmentService = require('../services/areaAssignmentService');
      let allPossibleAreas = [];

      try {
        // Check if district is dense and get actual assignment info
        const isDense = AreaAssignmentService.isDenseDistrict(state, district);
        
        if (isDense) {
          // Get real district assignment info with sub-districts
          const districtInfo = AreaAssignmentService.getDistrictAssignmentInfoWithRealData(district);
          
          if (districtInfo && districtInfo.subdistricts && districtInfo.subdistricts.length > 0) {
            // Use actual sub-districts from the district data
            allPossibleAreas = districtInfo.subdistricts.map(subdistrict => ({
              areaName: subdistrict,
              areaCode: `${subdistrict.toUpperCase().replace(/\s+/g, '_')}_001`,
              population: 25000 + Math.floor(Math.random() * 50000), // Estimated population
              isDenselyPopulated: true,
              isSubdistrict: true
            }));
          } else {
            // Fallback to predefined areas if available
            const districtAreas = AreaAssignmentService.getDistrictAreas(district);
            if (districtAreas && districtAreas.areas) {
              allPossibleAreas = districtAreas.areas.map(area => ({
                areaName: area.name,
                areaCode: area.code,
                population: area.population || 25000,
                isDenselyPopulated: true,
                isSubdistrict: false
              }));
            }
          }
        } else {
          // For non-dense districts, return the whole district as one area
          allPossibleAreas = [{
            areaName: `${district} (Full District)`,
            areaCode: `${district.toUpperCase().replace(/\s+/g, '_')}_FULL`,
            population: 200000,
            isDenselyPopulated: false,
            isSubdistrict: false
          }];
        }
      } catch (error) {
        console.log(`No specific data found for ${district}, using sub-districts from general data`);
        
        // Fallback: try to get sub-districts from the general state-district data
        const fs = require('fs');
        const path = require('path');
        
        try {
          const stateDistrictData = JSON.parse(
            fs.readFileSync(path.join(__dirname, '../data/indian_states_districts.json'), 'utf8')
          );
          
          const stateData = stateDistrictData.find(s => s.state === state);
          if (stateData) {
            const districtData = stateData.districts.find(d => d.district === district);
            if (districtData && districtData.subdistricts && districtData.subdistricts.length > 0) {
              allPossibleAreas = districtData.subdistricts.map(subdistrict => ({
                areaName: subdistrict,
                areaCode: `${subdistrict.toUpperCase().replace(/\s+/g, '_')}_001`,
                population: 25000 + Math.floor(Math.random() * 50000),
                isDenselyPopulated: true,
                isSubdistrict: true
              }));
            }
          }
        } catch (fileError) {
          console.log('Could not load state-district data file, using fallback');
        }
      }

      // If still no areas found, provide some default areas as last resort
      if (allPossibleAreas.length === 0) {
        allPossibleAreas = [
          { areaName: 'City Center', areaCode: 'CC01', population: 50000, isDenselyPopulated: true, isSubdistrict: false },
          { areaName: 'Industrial Area', areaCode: 'IA01', population: 30000, isDenselyPopulated: true, isSubdistrict: false },
          { areaName: 'Residential Zone A', areaCode: 'RZA01', population: 25000, isDenselyPopulated: false, isSubdistrict: false },
          { areaName: 'Residential Zone B', areaCode: 'RZB01', population: 20000, isDenselyPopulated: false, isSubdistrict: false },
          { areaName: 'Commercial District', areaCode: 'CD01', population: 40000, isDenselyPopulated: true, isSubdistrict: false }
        ];
      }

      // Filter out already assigned areas
      const availableAreas = allPossibleAreas.filter(area => 
        !assignedAreas.includes(area.areaName.toLowerCase())
      );

      res.status(200).json({
        success: true,
        message: 'Available areas retrieved successfully',
        data: availableAreas,
        meta: {
          totalAreas: allPossibleAreas.length,
          availableAreas: availableAreas.length,
          assignedAreas: assignedAreas.length,
          district: district,
          state: state,
          usingSubdistricts: allPossibleAreas.some(area => area.isSubdistrict)
        }
      });

    } catch (error) {
      console.error('Error fetching available areas:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch available areas',
        error: error.message
      });
    }
  }

  /**
   * Assign RHO to a zone
   */
  static async assignRHOToZone(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: 'Validation errors',
          errors: errors.array()
        });
      }

      const { zoneId } = req.params;
      const { rhoId, rhoName, assignedBy } = req.body;

      const zone = await Zone.findOne({ zoneId, isActive: true });
      if (!zone) {
        return res.status(404).json({
          success: false,
          message: 'Zone not found'
        });
      }

      // Check if RHO is already assigned to another zone in the same district
      const existingAssignment = await Zone.findOne({
        'assignedRHO.rhoId': rhoId,
        state: zone.state,
        district: zone.district,
        isActive: true,
        zoneId: { $ne: zoneId }
      });

      if (existingAssignment) {
        return res.status(400).json({
          success: false,
          message: `RHO is already assigned to zone: ${existingAssignment.zoneName}`,
          conflictingZone: existingAssignment.zoneName
        });
      }

      await zone.assignRHO(rhoId, rhoName, assignedBy);

      res.status(200).json({
        success: true,
        message: 'RHO assigned to zone successfully',
        data: zone
      });

    } catch (error) {
      console.error('Error assigning RHO to zone:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to assign RHO to zone',
        error: error.message
      });
    }
  }

  /**
   * Unassign RHO from a zone
   */
  static async unassignRHOFromZone(req, res) {
    try {
      const { zoneId } = req.params;

      const zone = await Zone.findOne({ zoneId, isActive: true });
      if (!zone) {
        return res.status(404).json({
          success: false,
          message: 'Zone not found'
        });
      }

      if (!zone.assignedRHO || !zone.assignedRHO.rhoId) {
        return res.status(400).json({
          success: false,
          message: 'No RHO assigned to this zone'
        });
      }

      await zone.unassignRHO();

      res.status(200).json({
        success: true,
        message: 'RHO unassigned from zone successfully',
        data: zone
      });

    } catch (error) {
      console.error('Error unassigning RHO from zone:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to unassign RHO from zone',
        error: error.message
      });
    }
  }

  /**
   * Update zone details
   */
  static async updateZone(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: 'Validation errors',
          errors: errors.array()
        });
      }

      const { zoneId } = req.params;
      const updateData = req.body;

      // Remove fields that shouldn't be updated directly
      delete updateData.zoneId;
      delete updateData.createdBy;
      delete updateData.assignedRHO;

      const zone = await Zone.findOneAndUpdate(
        { zoneId, isActive: true },
        { $set: updateData },
        { new: true, runValidators: true }
      );

      if (!zone) {
        return res.status(404).json({
          success: false,
          message: 'Zone not found'
        });
      }

      res.status(200).json({
        success: true,
        message: 'Zone updated successfully',
        data: zone
      });

    } catch (error) {
      console.error('Error updating zone:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update zone',
        error: error.message
      });
    }
  }

  /**
   * Add area to zone
   */
  static async addAreaToZone(req, res) {
    try {
      const { zoneId } = req.params;
      const { area } = req.body;

      if (!area || !area.areaName) {
        return res.status(400).json({
          success: false,
          message: 'Area data with areaName is required'
        });
      }

      const zone = await Zone.findOne({ zoneId, isActive: true });
      if (!zone) {
        return res.status(404).json({
          success: false,
          message: 'Zone not found'
        });
      }

      // Check if area already exists in this zone
      const existingArea = zone.areas.find(a => a.areaName === area.areaName);
      if (existingArea) {
        return res.status(400).json({
          success: false,
          message: 'Area already exists in this zone'
        });
      }

      await zone.addArea(area);

      res.status(200).json({
        success: true,
        message: 'Area added to zone successfully',
        data: zone
      });

    } catch (error) {
      console.error('Error adding area to zone:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to add area to zone',
        error: error.message
      });
    }
  }

  /**
   * Remove area from zone
   */
  static async removeAreaFromZone(req, res) {
    try {
      const { zoneId, areaName } = req.params;

      const zone = await Zone.findOne({ zoneId, isActive: true });
      if (!zone) {
        return res.status(404).json({
          success: false,
          message: 'Zone not found'
        });
      }

      const areaExists = zone.areas.find(a => a.areaName === areaName);
      if (!areaExists) {
        return res.status(404).json({
          success: false,
          message: 'Area not found in this zone'
        });
      }

      await zone.removeArea(areaName);

      res.status(200).json({
        success: true,
        message: 'Area removed from zone successfully',
        data: zone
      });

    } catch (error) {
      console.error('Error removing area from zone:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to remove area from zone',
        error: error.message
      });
    }
  }

  /**
   * Delete (deactivate) a zone
   */
  static async deleteZone(req, res) {
    try {
      const { zoneId } = req.params;

      const zone = await Zone.findOneAndUpdate(
        { zoneId, isActive: true },
        { $set: { isActive: false } },
        { new: true }
      );

      if (!zone) {
        return res.status(404).json({
          success: false,
          message: 'Zone not found'
        });
      }

      res.status(200).json({
        success: true,
        message: 'Zone deleted successfully',
        data: zone
      });

    } catch (error) {
      console.error('Error deleting zone:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to delete zone',
        error: error.message
      });
    }
  }

  /**
   * Get RHO assignment for a specific area
   */
  static async getRHOForArea(req, res) {
    try {
      const { state, district, areaName } = req.params;

      if (!state || !district || !areaName) {
        return res.status(400).json({
          success: false,
          message: 'State, district, and area name are required'
        });
      }

      const zone = await Zone.findOne({
        state,
        district,
        'areas.areaName': areaName,
        isActive: true
      });

      if (!zone) {
        return res.status(404).json({
          success: false,
          message: 'No zone found for this area',
          data: null
        });
      }

      const areaData = zone.areas.find(area => area.areaName === areaName);

      res.status(200).json({
        success: true,
        message: 'RHO information retrieved successfully',
        data: {
          zone: {
            zoneId: zone.zoneId,
            zoneName: zone.zoneName,
            zoneType: zone.zoneType,
            priority: zone.priority
          },
          area: areaData,
          assignedRHO: zone.assignedRHO || null
        }
      });

    } catch (error) {
      console.error('Error getting RHO for area:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get RHO for area',
        error: error.message
      });
    }
  }

  /**
   * Get comprehensive zone management dashboard data
   */
  static async getZoneManagementDashboard(req, res) {
    try {
      const { state, district } = req.params;

      if (!state || !district) {
        return res.status(400).json({
          success: false,
          message: 'State and district are required'
        });
      }

      // Get all zones for the district
      const zones = await Zone.findByDistrict(state, district);
      
      // Get unassigned zones
      const unassignedZones = await Zone.findUnassigned(state, district);
      
      // Get district statistics
      const stats = await Zone.getDistrictStats(state, district);

      // Get zone distribution by type and priority
      const zoneDistribution = await Zone.aggregate([
        { 
          $match: { 
            state: state, 
            district: district, 
            isActive: true 
          } 
        },
        {
          $group: {
            _id: {
              type: "$zoneType",
              priority: "$priority"
            },
            count: { $sum: 1 }
          }
        }
      ]);

      res.status(200).json({
        success: true,
        message: 'Zone management dashboard data retrieved successfully',
        data: {
          zones,
          unassignedZones,
          statistics: stats[0] || {
            totalZones: 0,
            assignedZones: 0,
            unassignedZones: 0,
            assignmentPercentage: 0,
            totalAreas: 0,
            coveredAreas: 0,
            coveragePercentage: 0
          },
          distribution: zoneDistribution
        }
      });

    } catch (error) {
      console.error('Error getting zone management dashboard:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get zone management dashboard',
        error: error.message
      });
    }
  }
}

module.exports = ZoneManagementController;