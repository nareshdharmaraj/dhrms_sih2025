// District mapping data for Indian states
const DISTRICT_MAPPING = {
  'Andhra Pradesh': {
    districts: [
      'Anantapur', 'Chittoor', 'East Godavari', 'Guntur', 'Krishna', 'Kurnool',
      'Nellore', 'Prakasam', 'Srikakulam', 'Visakhapatnam', 'Vizianagaram',
      'West Godavari', 'YSR Kadapa'
    ],
    regions: {
      'Coastal Andhra': ['Srikakulam', 'Vizianagaram', 'Visakhapatnam', 'East Godavari', 'West Godavari', 'Krishna', 'Guntur', 'Prakasam', 'Nellore'],
      'Rayalaseema': ['Anantapur', 'Chittoor', 'Kurnool', 'YSR Kadapa']
    }
  },
  'Tamil Nadu': {
    districts: [
      'Ariyalur', 'Chengalpattu', 'Chennai', 'Coimbatore', 'Cuddalore', 'Dharmapuri',
      'Dindigul', 'Erode', 'Kallakurichi', 'Kanchipuram', 'Kanyakumari', 'Karur',
      'Krishnagiri', 'Madurai', 'Nagapattinam', 'Namakkal', 'Nilgiris', 'Perambalur',
      'Pudukkottai', 'Ramanathapuram', 'Ranipet', 'Salem', 'Sivaganga', 'Tenkasi',
      'Thanjavur', 'Theni', 'Thoothukudi', 'Tiruchirappalli', 'Tirunelveli',
      'Tirupathur', 'Tiruppur', 'Tiruvallur', 'Tiruvannamalai', 'Tiruvarur',
      'Vellore', 'Viluppuram', 'Virudhunagar'
    ],
    regions: {
      'Northern Tamil Nadu': ['Chennai', 'Tiruvallur', 'Kanchipuram', 'Chengalpattu', 'Vellore', 'Tirupathur', 'Ranipet'],
      'Western Tamil Nadu': ['Coimbatore', 'Tiruppur', 'Erode', 'Salem', 'Namakkal', 'Dharmapuri', 'Krishnagiri'],
      'Central Tamil Nadu': ['Tiruchirappalli', 'Karur', 'Dindigul', 'Madurai', 'Theni', 'Sivaganga'],
      'Southern Tamil Nadu': ['Tirunelveli', 'Tenkasi', 'Thoothukudi', 'Virudhunagar', 'Ramanathapuram', 'Kanyakumari'],
      'Delta Region': ['Thanjavur', 'Tiruvarur', 'Nagapattinam', 'Pudukkottai', 'Ariyalur']
    }
  },
  'Karnataka': {
    districts: [
      'Bagalkot', 'Ballari', 'Belagavi', 'Bengaluru Rural', 'Bengaluru Urban',
      'Bidar', 'Chamarajanagar', 'Chikballapur', 'Chikkamagaluru', 'Chitradurga',
      'Dakshina Kannada', 'Davanagere', 'Dharwad', 'Gadag', 'Hassan', 'Haveri',
      'Kalaburagi', 'Kodagu', 'Kolar', 'Koppal', 'Mandya', 'Mysuru', 'Raichur',
      'Ramanagara', 'Shivamogga', 'Tumakuru', 'Udupi', 'Uttara Kannada', 'Vijayapura', 'Yadgir'
    ],
    regions: {
      'Bangalore Division': ['Bengaluru Urban', 'Bengaluru Rural', 'Chikballapur', 'Kolar', 'Ramanagara', 'Tumakuru'],
      'Mysore Division': ['Chamarajanagar', 'Chikkamagaluru', 'Hassan', 'Kodagu', 'Mandya', 'Mysuru'],
      'Belagavi Division': ['Bagalkot', 'Belagavi', 'Bidar', 'Dharwad', 'Gadag', 'Haveri', 'Uttara Kannada', 'Vijayapura'],
      'Kalaburagi Division': ['Ballari', 'Kalaburagi', 'Koppal', 'Raichur', 'Yadgir'],
      'Coastal Karnataka': ['Dakshina Kannada', 'Udupi']
    }
  },
  'Kerala': {
    districts: [
      'Alappuzha', 'Ernakulam', 'Idukki', 'Kannur', 'Kasaragod', 'Kollam',
      'Kottayam', 'Kozhikode', 'Malappuram', 'Palakkad', 'Pathanamthitta',
      'Thiruvananthapuram', 'Thrissur', 'Wayanad'
    ],
    regions: {
      'Northern Kerala': ['Kasaragod', 'Kannur', 'Wayanad', 'Kozhikode', 'Malappuram'],
      'Central Kerala': ['Palakkad', 'Thrissur', 'Ernakulam', 'Idukki', 'Kottayam'],
      'Southern Kerala': ['Alappuzha', 'Pathanamthitta', 'Kollam', 'Thiruvananthapuram']
    }
  },
  'Maharashtra': {
    districts: [
      'Ahmednagar', 'Akola', 'Amravati', 'Aurangabad', 'Beed', 'Bhandara',
      'Buldhana', 'Chandrapur', 'Dhule', 'Gadchiroli', 'Gondia', 'Hingoli',
      'Jalgaon', 'Jalna', 'Kolhapur', 'Latur', 'Mumbai City', 'Mumbai Suburban',
      'Nagpur', 'Nanded', 'Nandurbar', 'Nashik', 'Osmanabad', 'Palghar',
      'Parbhani', 'Pune', 'Raigad', 'Ratnagiri', 'Sangli', 'Satara',
      'Sindhudurg', 'Solapur', 'Thane', 'Wardha', 'Washim', 'Yavatmal'
    ],
    regions: {
      'Western Maharashtra': ['Mumbai City', 'Mumbai Suburban', 'Thane', 'Palghar', 'Raigad', 'Pune', 'Satara', 'Sangli', 'Kolhapur'],
      'Marathwada': ['Aurangabad', 'Beed', 'Hingoli', 'Jalna', 'Latur', 'Nanded', 'Osmanabad', 'Parbhani'],
      'Vidarbha': ['Akola', 'Amravati', 'Bhandara', 'Buldhana', 'Chandrapur', 'Gadchiroli', 'Gondia', 'Nagpur', 'Wardha', 'Washim', 'Yavatmal'],
      'North Maharashtra': ['Ahmednagar', 'Dhule', 'Jalgaon', 'Nandurbar', 'Nashik'],
      'Konkan': ['Ratnagiri', 'Sindhudurg']
    }
  },
  'Gujarat': {
    districts: [
      'Ahmedabad', 'Amreli', 'Anand', 'Aravalli', 'Banaskantha', 'Bharuch',
      'Bhavnagar', 'Botad', 'Chhota Udepur', 'Dahod', 'Dang', 'Devbhoomi Dwarka',
      'Gandhinagar', 'Gir Somnath', 'Jamnagar', 'Junagadh', 'Kheda', 'Kutch',
      'Mahisagar', 'Mehsana', 'Morbi', 'Narmada', 'Navsari', 'Panchmahal',
      'Patan', 'Porbandar', 'Rajkot', 'Sabarkantha', 'Surat', 'Surendranagar',
      'Tapi', 'Vadodara', 'Valsad'
    ],
    regions: {
      'North Gujarat': ['Ahmedabad', 'Gandhinagar', 'Mehsana', 'Patan', 'Sabarkantha', 'Banaskantha', 'Aravalli'],
      'Central Gujarat': ['Anand', 'Kheda', 'Vadodara', 'Mahisagar', 'Panchmahal', 'Dahod', 'Chhota Udepur'],
      'South Gujarat': ['Surat', 'Bharuch', 'Narmada', 'Tapi', 'Navsari', 'Valsad', 'Dang'],
      'Saurashtra': ['Rajkot', 'Jamnagar', 'Porbandar', 'Junagadh', 'Amreli', 'Bhavnagar', 'Botad', 'Morbi', 'Surendranagar', 'Gir Somnath', 'Devbhoomi Dwarka'],
      'Kutch': ['Kutch']
    }
  },
  'Rajasthan': {
    districts: [
      'Ajmer', 'Alwar', 'Banswara', 'Baran', 'Barmer', 'Bharatpur', 'Bhilwara',
      'Bikaner', 'Bundi', 'Chittorgarh', 'Churu', 'Dausa', 'Dholpur', 'Dungarpur',
      'Ganganagar', 'Hanumangarh', 'Jaipur', 'Jaisalmer', 'Jalore', 'Jhalawar',
      'Jhunjhunu', 'Jodhpur', 'Karauli', 'Kota', 'Nagaur', 'Pali', 'Pratapgarh',
      'Rajsamand', 'Sawai Madhopur', 'Sikar', 'Sirohi', 'Tonk', 'Udaipur'
    ],
    regions: {
      'Eastern Rajasthan': ['Jaipur', 'Alwar', 'Bharatpur', 'Dausa', 'Dholpur', 'Karauli', 'Sawai Madhopur', 'Tonk'],
      'Western Rajasthan': ['Jodhpur', 'Barmer', 'Jaisalmer', 'Bikaner', 'Churu', 'Ganganagar', 'Hanumangarh', 'Nagaur'],
      'Southern Rajasthan': ['Udaipur', 'Chittorgarh', 'Rajsamand', 'Dungarpur', 'Banswara', 'Pratapgarh', 'Bhilwara', 'Ajmer'],
      'Southeastern Rajasthan': ['Kota', 'Bundi', 'Baran', 'Jhalawar']
    }
  },
  'West Bengal': {
    districts: [
      'Alipurduar', 'Bankura', 'Birbhum', 'Cooch Behar', 'Dakshin Dinajpur',
      'Darjeeling', 'Hooghly', 'Howrah', 'Jalpaiguri', 'Jhargram', 'Kalimpong',
      'Kolkata', 'Malda', 'Murshidabad', 'Nadia', 'North 24 Parganas',
      'Paschim Bardhaman', 'Paschim Medinipur', 'Purba Bardhaman',
      'Purba Medinipur', 'Purulia', 'South 24 Parganas', 'Uttar Dinajpur'
    ],
    regions: {
      'North Bengal': ['Darjeeling', 'Kalimpong', 'Jalpaiguri', 'Cooch Behar', 'Alipurduar', 'Uttar Dinajpur', 'Dakshin Dinajpur', 'Malda'],
      'Central Bengal': ['Murshidabad', 'Birbhum', 'Nadia', 'Purba Bardhaman', 'Paschim Bardhaman'],
      'South Bengal': ['Kolkata', 'Howrah', 'Hooghly', 'North 24 Parganas', 'South 24 Parganas', 'Purba Medinipur', 'Paschim Medinipur'],
      'Western Bengal': ['Purulia', 'Bankura', 'Jhargram']
    }
  }
};

// Mock RHO data with realistic Indian names and districts
const MOCK_RHO_DATA = {
  'Tamil Nadu': [
    {
      fullName: 'Dr. Rajesh Kumar',
      email: 'rajesh.kumar@tn.gov.in',
      phone: '+91-9876543210',
      assignedDistrict: 'Chennai',
      assignedRegion: 'Northern Tamil Nadu',
      regionCode: 'TN-N',
      districtCode: 'CHE',
      qualification: 'MBBS, MD (Community Medicine)',
      experience: 12,
      licenseNumber: 'TN-MED-2024-001',
      specialization: ['Public Health', 'Epidemiology'],
      coverage: {
        primaryDistrict: 'Chennai',
        subDistricts: ['Ambattur', 'Alandur', 'Sholinganallur', 'Perungudi'],
        blocks: ['Tambaram', 'Pallavaram', 'Chrompet'],
        population: 4646732,
        areaKm2: 426,
        ruralPopulation: 200000,
        urbanPopulation: 4446732
      }
    },
    {
      fullName: 'Dr. Priya Sharma',
      email: 'priya.sharma@tn.gov.in',
      phone: '+91-9876543211',
      assignedDistrict: 'Coimbatore',
      assignedRegion: 'Western Tamil Nadu',
      regionCode: 'TN-W',
      districtCode: 'CBE',
      qualification: 'MBBS, MPH',
      experience: 8,
      licenseNumber: 'TN-MED-2024-002',
      specialization: ['Maternal Health', 'Child Health'],
      coverage: {
        primaryDistrict: 'Coimbatore',
        subDistricts: ['Coimbatore North', 'Coimbatore South', 'Pollachi', 'Valparai'],
        blocks: ['Annur', 'Madukkarai', 'Sulthanpet'],
        population: 3458045,
        areaKm2: 7469,
        ruralPopulation: 1500000,
        urbanPopulation: 1958045
      }
    }
  ],
  'Karnataka': [
    {
      fullName: 'Dr. Suresh Reddy',
      email: 'suresh.reddy@ka.gov.in',
      phone: '+91-9876543212',
      assignedDistrict: 'Bengaluru Urban',
      assignedRegion: 'Bangalore Division',
      regionCode: 'KA-BG',
      districtCode: 'BLR',
      qualification: 'MBBS, MD (Public Health)',
      experience: 15,
      licenseNumber: 'KA-MED-2024-001',
      specialization: ['Urban Health', 'Health Policy'],
      coverage: {
        primaryDistrict: 'Bengaluru Urban',
        subDistricts: ['Bangalore North', 'Bangalore South', 'Bangalore East', 'Anekal'],
        blocks: ['Yelahanka', 'KR Puram', 'Mahadevapura'],
        population: 9621551,
        areaKm2: 2190,
        ruralPopulation: 1000000,
        urbanPopulation: 8621551
      }
    },
    {
      fullName: 'Dr. Lakshmi Narayana',
      email: 'lakshmi.narayana@ka.gov.in',
      phone: '+91-9876543213',
      assignedDistrict: 'Mysuru',
      assignedRegion: 'Mysore Division',
      regionCode: 'KA-MY',
      districtCode: 'MYS',
      qualification: 'MBBS, DPH',
      experience: 10,
      licenseNumber: 'KA-MED-2024-002',
      specialization: ['Rural Health', 'Communicable Diseases'],
      coverage: {
        primaryDistrict: 'Mysuru',
        subDistricts: ['Mysuru North', 'Mysuru South', 'Hunsur', 'Nanjangud'],
        blocks: ['KR Nagar', 'Tirumakudal Narsipur', 'Periyapatna'],
        population: 3001127,
        areaKm2: 6308,
        ruralPopulation: 1800000,
        urbanPopulation: 1201127
      }
    }
  ],
  'Maharashtra': [
    {
      fullName: 'Dr. Amit Patil',
      email: 'amit.patil@mh.gov.in',
      phone: '+91-9876543214',
      assignedDistrict: 'Mumbai City',
      assignedRegion: 'Western Maharashtra',
      regionCode: 'MH-W',
      districtCode: 'MUM',
      qualification: 'MBBS, MD (Community Medicine)',
      experience: 18,
      licenseNumber: 'MH-MED-2024-001',
      specialization: ['Urban Health', 'Emergency Medicine'],
      coverage: {
        primaryDistrict: 'Mumbai City',
        subDistricts: ['South Mumbai', 'Central Mumbai', 'North Mumbai'],
        blocks: ['Colaba', 'Fort', 'Marine Lines'],
        population: 3085411,
        areaKm2: 157,
        ruralPopulation: 0,
        urbanPopulation: 3085411
      }
    },
    {
      fullName: 'Dr. Sunita Joshi',
      email: 'sunita.joshi@mh.gov.in',
      phone: '+91-9876543215',
      assignedDistrict: 'Pune',
      assignedRegion: 'Western Maharashtra',
      regionCode: 'MH-W',
      districtCode: 'PUN',
      qualification: 'MBBS, MPH, PhD',
      experience: 14,
      licenseNumber: 'MH-MED-2024-002',
      specialization: ['Health Systems', 'Nutrition'],
      coverage: {
        primaryDistrict: 'Pune',
        subDistricts: ['Pune City', 'Pimpri-Chinchwad', 'Maval', 'Mulshi'],
        blocks: ['Ambegaon', 'Khed', 'Junnar'],
        population: 9429408,
        areaKm2: 15642,
        ruralPopulation: 5000000,
        urbanPopulation: 4429408
      }
    }
  ]
};

// Generate realistic mock staff data
const generateMockStaffData = (rhoId, district, count = 25) => {
  const staffTypes = ['Doctor', 'Nurse', 'Lab Technician', 'Pharmacist', 'Administrator'];
  const firstNames = [
    'Arun', 'Bharti', 'Chandra', 'Deepak', 'Esha', 'Farhan', 'Gayatri', 'Harsh',
    'Indira', 'Jagan', 'Kavya', 'Latha', 'Mohan', 'Nisha', 'Om', 'Priyanka',
    'Qasim', 'Radha', 'Sunil', 'Tara', 'Usha', 'Vikram', 'Wasim', 'Ximena', 'Yash', 'Zara'
  ];
  const lastNames = [
    'Agarwal', 'Bhat', 'Chopra', 'Das', 'Eswaran', 'Fernandes', 'Gupta', 'Hegde',
    'Iyer', 'Jain', 'Kumar', 'Lal', 'Mehta', 'Nair', 'Oberoi', 'Patel',
    'Qureshi', 'Rao', 'Singh', 'Thakur', 'Upadhyay', 'Verma', 'Wilson', 'Xavier', 'Yadav', 'Zafar'
  ];

  return Array.from({ length: count }, (_, index) => {
    const firstName = firstNames[Math.floor(Math.random() * firstNames.length)];
    const lastName = lastNames[Math.floor(Math.random() * lastNames.length)];
    const staffType = staffTypes[Math.floor(Math.random() * staffTypes.length)];
    
    return {
      id: `staff_${rhoId}_${index + 1}`,
      staffId: `${district.substring(0, 3).toUpperCase()}-${staffType.substring(0, 3).toUpperCase()}-${String(index + 1).padStart(3, '0')}`,
      staffType,
      fullName: `${firstName} ${lastName}`,
      email: `${firstName.toLowerCase()}.${lastName.toLowerCase()}@${district.toLowerCase()}.gov.in`,
      phone: `+91-${9000000000 + Math.floor(Math.random() * 999999999)}`,
      qualification: staffType === 'Doctor' ? 'MBBS' : staffType === 'Nurse' ? 'BSc Nursing' : `Diploma in ${staffType}`,
      experience: {
        years: Math.floor(Math.random() * 15) + 1,
        months: Math.floor(Math.random() * 12)
      },
      licenseNumber: `${district.substring(0, 3).toUpperCase()}-${staffType.substring(0, 3).toUpperCase()}-${2024}-${String(index + 1).padStart(3, '0')}`,
      specialization: staffType === 'Doctor' ? ['General Medicine'] : [staffType],
      assignedRegion: district,
      assignedState: 'Tamil Nadu', // Default for demo
      department: `${staffType} Department`,
      parentRHO: rhoId,
      employmentType: Math.random() > 0.8 ? 'Contract' : 'Permanent',
      joiningDate: new Date(2020 + Math.floor(Math.random() * 4), Math.floor(Math.random() * 12), Math.floor(Math.random() * 28) + 1),
      salary: {
        basic: staffType === 'Doctor' ? 50000 + Math.floor(Math.random() * 30000) : 25000 + Math.floor(Math.random() * 20000),
        allowances: 5000 + Math.floor(Math.random() * 10000)
      },
      isActive: Math.random() > 0.1, // 90% active
      performance: {
        rating: 2 + Math.random() * 3, // 2-5 star rating
        patientsHandled: Math.floor(Math.random() * 500) + 100
      }
    };
  });
};

module.exports = {
  DISTRICT_MAPPING,
  MOCK_RHO_DATA,
  generateMockStaffData,
  
  // Helper functions
  getDistrictsByState: (state) => {
    return DISTRICT_MAPPING[state]?.districts || [];
  },
  
  getRegionsByState: (state) => {
    return DISTRICT_MAPPING[state]?.regions || {};
  },
  
  getRegionByDistrict: (state, district) => {
    const regions = DISTRICT_MAPPING[state]?.regions || {};
    for (const [regionName, districts] of Object.entries(regions)) {
      if (districts.includes(district)) {
        return regionName;
      }
    }
    return 'Unknown Region';
  },
  
  getMockRHOsByState: (state) => {
    return MOCK_RHO_DATA[state] || [];
  },
  
  generateDistrictCode: (district) => {
    return district.substring(0, 3).toUpperCase();
  },
  
  generateRegionCode: (state, region) => {
    const stateCode = state.split(' ').map(word => word[0]).join('').toUpperCase();
    const regionCode = region.split(' ').map(word => word[0]).join('').toUpperCase();
    return `${stateCode}-${regionCode}`;
  }
};