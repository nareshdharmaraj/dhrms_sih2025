# Area Assignment System Test Guide

## Prerequisites
1. Backend server running on http://localhost:5000
2. Valid SHO credentials (you should have these from previous testing)

## Test Scenarios

### Test 1: Check District Assignment Strategies

**Dense District (Chennai):**
```
GET /api/rho/districts/Chennai/assignment-info
Authorization: Bearer <SHO_TOKEN>
```
Expected: 
- `strategy.isDense: true`
- `strategy.assignmentType: "area-specific"`
- Multiple areas available (Ambattur, Sholinganallur, Central Chennai, etc.)

**Sparse District (Namakkal):**
```
GET /api/rho/districts/Namakkal/assignment-info
Authorization: Bearer <SHO_TOKEN>
```
Expected:
- `strategy.isDense: false` 
- `strategy.assignmentType: "full-district"`
- Empty or minimal areas array

### Test 2: Create RHO for Dense District (Chennai) with Specific Area

**Request:**
```
POST /api/rho/create
Authorization: Bearer <SHO_TOKEN>
Content-Type: application/json

{
  "fullName": "Dr. Arun Kumar Chennai",
  "email": "arun.kumar.chennai@tn.gov.in",
  "phone": "+91-9876543220",
  "password": "rho123456",
  "assignedDistrict": "Chennai",
  "assignedAreas": ["Ambattur"],
  "qualification": "MBBS, MD",
  "experience": 8,
  "licenseNumber": "TN-MED-2024-TEST-001"
}
```

**Expected Response:**
- Success: true
- Officer ID like: `RHO_CHENNAI_001-AMB`
- Assignment info shows area-specific assignment
- Areas assigned: ["Ambattur"]

### Test 3: Create Another RHO for Different Area in Same District

**Request:**
```
POST /api/rho/create
Authorization: Bearer <SHO_TOKEN>
Content-Type: application/json

{
  "fullName": "Dr. Priya Sharma Chennai",
  "email": "priya.sharma.chennai@tn.gov.in", 
  "phone": "+91-9876543221",
  "password": "rho123456",
  "assignedDistrict": "Chennai",
  "assignedAreas": ["Sholinganallur"],
  "qualification": "MBBS, MPH",
  "experience": 6,
  "licenseNumber": "TN-MED-2024-TEST-002"
}
```

**Expected Response:**
- Success: true
- Officer ID like: `RHO_CHENNAI_002-SGL`
- Different area assignment from Test 2

### Test 4: Try to Create Duplicate Area Assignment (Should Fail)

**Request:**
```
POST /api/rho/create
Authorization: Bearer <SHO_TOKEN>
Content-Type: application/json

{
  "fullName": "Dr. Duplicate Test",
  "email": "duplicate.test@tn.gov.in",
  "phone": "+91-9876543222", 
  "password": "rho123456",
  "assignedDistrict": "Chennai",
  "assignedAreas": ["Ambattur"],
  "qualification": "MBBS",
  "experience": 5,
  "licenseNumber": "TN-MED-2024-TEST-003"
}
```

**Expected Response:**
- Success: false
- Error about area already being assigned

### Test 5: Create RHO for Sparse District (Full District Assignment)

**Request:**
```
POST /api/rho/create
Authorization: Bearer <SHO_TOKEN>
Content-Type: application/json

{
  "fullName": "Dr. Rajesh Kumar Namakkal",
  "email": "rajesh.kumar.namakkal@tn.gov.in",
  "phone": "+91-9876543223",
  "password": "rho123456", 
  "assignedDistrict": "Namakkal",
  "qualification": "MBBS, MD",
  "experience": 10,
  "licenseNumber": "TN-MED-2024-TEST-004"
}
```

**Expected Response:**
- Success: true
- Officer ID like: `RHO_Namakkal_001`
- Assignment type: "full-district"
- Areas assigned: ["Full District"]

### Test 6: Check Area Coverage Details

**Request:**
```
GET /api/rho/districts/Chennai/areas/Ambattur
Authorization: Bearer <SHO_TOKEN>
```

**Expected Response:**
- Area details with population, subDistricts, blocks
- Assignment status showing it's assigned
- Assigned RHO details

### Test 7: List All RHOs to Verify Assignments

**Request:**
```
GET /api/rho/list
Authorization: Bearer <SHO_TOKEN>
```

**Expected Response:**
- List of all created RHOs
- Each RHO should show assigned areas
- Chennai RHOs should have specific areas
- Namakkal RHO should show full district

## Validation Checklist

- [ ] Dense districts require area selection
- [ ] Sparse districts default to full district 
- [ ] Area conflicts are prevented
- [ ] RHO IDs include area codes for dense districts
- [ ] Coverage data is calculated based on assigned areas
- [ ] Area assignment info API works
- [ ] Area coverage details API works
- [ ] All RHOs are listed with correct area assignments

## Expected File Changes Summary

1. **RegionalHealthOfficer.js**: Added `assignedAreas` field
2. **areaAssignmentService.js**: New service for area management
3. **rhoController.js**: Enhanced with area logic and new endpoints
4. **rhoRoutes.js**: Added area-related routes
5. **rhoAccessControl.js**: New middleware for area-based access control

## Testing Notes

- Chennai should be classified as dense (multiple areas)
- Namakkal should be classified as sparse (single RHO for all)
- RHO IDs should reflect area assignments
- Area conflicts should be properly handled
- Access control should filter based on assigned areas