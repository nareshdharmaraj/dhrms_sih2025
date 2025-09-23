# RHO Management and Hospital Registration - Role-Based Access Control

## Role Hierarchy and Permissions

### 1. WHO Admin
- **Primary Role**: Manage State Health Officers (SHOs)
- **Permissions**: 
  - `canManageStateOfficers: true`
  - `canViewStateOfficers: true`
  - Can view but NOT directly manage RHOs
- **Access Level**: Global/National

### 2. State Health Officer (SHO)
- **Primary Role**: Manage Regional Health Officers (RHOs) within their assigned state
- **Permissions**:
  - `canManageRegionalOfficers: true`
  - `canViewRegionalOfficers: true`
  - `canManageHospitals: true`
- **Access Level**: State-specific
- **Key Responsibility**: **ONLY SHOs can create new RHO entities**

### 3. Regional Health Officer (RHO)
- **Primary Role**: Manage hospitals and health facilities in assigned districts/areas
- **Access Level**: District/Area-specific
- **Relationship**: Created and managed by SHOs

## Hospital Registration Design

### Core Principle: Assignment Only, No Creation
The hospital registration system is designed to **ONLY ASSIGN** hospitals to existing RHOs. It does **NOT** create new RHO entities.

### Location-Based Assignment Logic
1. **State Selection** → Find SHO for state
2. **District Selection** → Find available RHOs in district  
3. **Sub-district Selection** (for dense districts) → Automatic assignment based on area mapping
4. **Assignment** → Hospital assigned to appropriate existing RHO

### RHO Assignment Rules
- **Non-dense Districts**: Direct assignment to district RHO
- **Dense Districts with Area Mapping**: Automatic assignment based on sub-district
- **Dense Districts without Sub-district**: Require sub-district selection first
- **No Manual Creation**: Hospital registration cannot create new RHOs

## Security and Access Control

### RHO Creation Restrictions
- **WHO Admin**: Cannot create RHOs (only manages SHOs)
- **SHO**: Can create RHOs within their assigned state
- **Hospital Registration**: Cannot create RHOs (assignment only)
- **RHO**: Cannot create other RHOs

### Data Integrity
- All RHOs must be pre-created by SHOs before hospital registration
- Hospital assignment validates against existing RHO entities
- Location hierarchy ensures proper geographical assignment

## Implementation Notes

### Services
- `RHOAssignmentService`: Handles assignment logic only
- `RegionalHealthOfficerService`: Includes creation methods (SHO access only)
- `LocationService`: Provides hierarchical location selection

### UI Components
- Hospital Registration Screen: Shows assignment preview, no creation options
- RHO Assignment Card: Displays automatic or manual assignment options
- Loading States: Shows progress during assignment operations

### Error Handling
- Validates RHO existence before assignment
- Prevents assignment to inactive RHOs
- Requires proper location hierarchy completion

This design ensures proper role separation and prevents unauthorized RHO creation while maintaining efficient hospital-to-RHO assignment based on geographical hierarchy.