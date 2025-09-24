/// Comprehensive Indian States, Districts, and Sub-districts data
/// with RHO assignment mapping for DHRMS hospital registration system
library;

class DistrictData {
  final String name;
  final String code;
  final List<String> subDistricts;
  final List<String> rhoAssignments; // RHO IDs assigned to this district
  final bool isDenselyPopulated; // For districts with multiple RHOs
  final Map<String, String>? areaWiseRhoMapping; // For dense districts with area-specific RHOs

  const DistrictData({
    required this.name,
    required this.code,
    required this.subDistricts,
    this.rhoAssignments = const [],
    this.isDenselyPopulated = false,
    this.areaWiseRhoMapping,
  });

  bool get hasMultipleRHOs => isDenselyPopulated && (areaWiseRhoMapping?.isNotEmpty ?? false);
}

class StateData {
  final String name;
  final String code;
  final List<DistrictData> districts;

  const StateData({
    required this.name,
    required this.code,
    required this.districts,
  });
}

class IndianStatesDistrictsData {
  static const List<StateData> states = [
    StateData(
      name: 'Maharashtra',
      code: 'MH',
      districts: [
        DistrictData(
          name: 'Mumbai',
          code: 'MUM',
          subDistricts: [
            'Mumbai City',
            'Mumbai Suburban',
            'Andheri',
            'Bandra',
            'Borivali',
            'Dadar',
            'Ghatkopar',
            'Goregaon',
            'Jogeshwari',
            'Kandivali',
            'Kurla',
            'Malad',
            'Mulund',
            'Powai',
            'Santa Cruz',
            'Vile Parle',
            'Worli'
          ],
          isDenselyPopulated: true,
          rhoAssignments: ['RHO_MUM_001', 'RHO_MUM_002', 'RHO_MUM_003', 'RHO_MUM_004'],
        ),
        DistrictData(
          name: 'Pune',
          code: 'PUN',
          subDistricts: [
            'Pune City',
            'Pimpri-Chinchwad',
            'Maval',
            'Mulshi',
            'Velhe',
            'Bhor',
            'Purandar',
            'Baramati',
            'Indapur',
            'Khed',
            'Shirur',
            'Ambegaon',
            'Junnar',
            'Haveli'
          ],
          isDenselyPopulated: true,
          rhoAssignments: ['RHO_PUN_001', 'RHO_PUN_002', 'RHO_PUN_003'],
        ),
        DistrictData(
          name: 'Thane',
          code: 'THA',
          subDistricts: [
            'Thane',
            'Kalyan',
            'Dombivli',
            'Ulhasnagar',
            'Ambarnath',
            'Badlapur',
            'Bhiwandi',
            'Shahapur',
            'Murbad',
            'Vikramgad'
          ],
          isDenselyPopulated: true,
          rhoAssignments: ['RHO_THA_001', 'RHO_THA_002'],
        ),
        DistrictData(
          name: 'Nashik',
          code: 'NAS',
          subDistricts: [
            'Nashik',
            'Malegaon',
            'Sinnar',
            'Niphad',
            'Dindori',
            'Peint',
            'Trimbakeshwar',
            'Kalwan',
            'Deola',
            'Baglan',
            'Chandwad',
            'Nandgaon',
            'Yeola',
            'Surgana',
            'Igatpuri'
          ],
          rhoAssignments: ['RHO_NAS_001'],
        ),
        DistrictData(
          name: 'Nagpur',
          code: 'NAG',
          subDistricts: [
            'Nagpur',
            'Kamptee',
            'Hingna',
            'Katol',
            'Narkhed',
            'Savner',
            'Parseoni',
            'Ramtek',
            'Kuhi',
            'Umred',
            'Bhiwapur',
            'Mouda'
          ],
          rhoAssignments: ['RHO_NAG_001'],
        ),
        DistrictData(
          name: 'Aurangabad',
          code: 'AUR',
          subDistricts: [
            'Aurangabad',
            'Kannad',
            'Soegaon',
            'Sillod',
            'Phulambri',
            'Khultabad',
            'Vaijapur',
            'Gangapur',
            'Paithan'
          ],
          rhoAssignments: ['RHO_AUR_001'],
        ),
        DistrictData(
          name: 'Solapur',
          code: 'SOL',
          subDistricts: [
            'Solapur',
            'Pandharpur',
            'Malshiras',
            'Barshi',
            'Karmala',
            'Madha',
            'Sangole',
            'Mangalvedhe',
            'Mohol',
            'Akkalkot',
            'South Solapur'
          ],
          rhoAssignments: ['RHO_SOL_001'],
        ),
        DistrictData(
          name: 'Kolhapur',
          code: 'KOL',
          subDistricts: [
            'Kolhapur',
            'Panhala',
            'Shahuwadi',
            'Shirol',
            'Karvir',
            'Bavda',
            'Radhanagari',
            'Kagal',
            'Bhudargad',
            'Ajra',
            'Chandgad',
            'Gadhinglaj'
          ],
          rhoAssignments: ['RHO_KOL_001'],
        ),
        DistrictData(
          name: 'Satara',
          code: 'SAT',
          subDistricts: [
            'Satara',
            'Karad',
            'Koregaon',
            'Wai',
            'Mahabaleshwar',
            'Phaltan',
            'Man',
            'Khatav',
            'Jaoli',
            'Patan',
            'Khandala'
          ],
          rhoAssignments: ['RHO_SAT_001'],
        ),
        DistrictData(
          name: 'Sangli',
          code: 'SAN',
          subDistricts: [
            'Sangli',
            'Miraj',
            'Kupwad',
            'Palus',
            'Khanapur',
            'Atpadi',
            'Tasgaon',
            'Kavathemahankal',
            'Shirala',
            'Walwa'
          ],
          rhoAssignments: ['RHO_SAN_001'],
        ),
      ],
    ),
    StateData(
      name: 'Tamil Nadu',
      code: 'TN',
      districts: [
        DistrictData(
          name: 'Ariyalur',
          code: 'ARY',
          subDistricts: [
            'Ariyalur',
            'Andimadam',
            'Sendurai',
            'Udayarpalayam'
          ],
          rhoAssignments: ['RHO_ARY_001'],
        ),
        DistrictData(
          name: 'Chengalpattu',
          code: 'CGP',
          subDistricts: [
            'Chengalpattu',
            'Thirukkalukundram',
            'Thirupporur',
            'Cheyyur',
            'Madhurantakam',
            'Tambaram',
            'Pallavaram',
            'Vandalur'
          ],
          rhoAssignments: ['RHO_CGP_001'],
        ),
        DistrictData(
          name: 'Chennai',
          code: 'CHE',
          subDistricts: [
            'Ambattur',
            'Aminjikarai',
            'Ayanavaram',
            'Egmore',
            'Maduravoyal',
            'Mambalam',
            'Madhavaram',
            'Perambur',
            'Purasawalkam',
            'Tiruvottiyur',
            'Tondiarpet',
            'Alandur',
            'Guindy',
            'Mylapore',
            'Sholinganallur',
            'Velachery',
            'Kolathur'
          ],
          isDenselyPopulated: true,
          rhoAssignments: ['RHO_CHE_001', 'RHO_CHE_002', 'RHO_CHE_003'],
        ),
        DistrictData(
          name: 'Coimbatore',
          code: 'COI',
          subDistricts: [
            'Annur',
            'Coimbatore North',
            'Coimbatore South',
            'Madukarai',
            'Mettupalayam',
            'Perur',
            'Pollachi',
            'Sulur',
            'Valparai',
            'Anaimalai',
            'Kinathukadavu'
          ],
          rhoAssignments: ['RHO_COI_001'],
        ),
        DistrictData(
          name: 'Cuddalore',
          code: 'CUD',
          subDistricts: [
            'Bhuvanagiri',
            'Chidambaram',
            'Kattumannarkoil',
            'Kurinjipadi',
            'Panruti',
            'Srimushnam',
            'Thittakudi',
            'Veppur',
            'Vriddhachalam',
            'Cuddalore'
          ],
          rhoAssignments: ['RHO_CUD_001'],
        ),
        DistrictData(
          name: 'Dharmapuri',
          code: 'DHA',
          subDistricts: [
            'Dharmapuri',
            'Karimangalam',
            'Nallampalli',
            'Palacode',
            'Pappireddipatti',
            'Harur',
            'Pennagaram'
          ],
          rhoAssignments: ['RHO_DHA_001'],
        ),
        DistrictData(
          name: 'Dindigul',
          code: 'DIN',
          subDistricts: [
            'Athoor',
            'Dindigul East',
            'Dindigul West',
            'Natham',
            'Nilakottai',
            'Kodaikanal',
            'Oddanchatram',
            'Palani',
            'Vedasandur'
          ],
          rhoAssignments: ['RHO_DIN_001'],
        ),
        DistrictData(
          name: 'Erode',
          code: 'ERO',
          subDistricts: [
            'Erode',
            'Kodumudi',
            'Modakkurichi',
            'Perundurai',
            'Anthiyur',
            'Bhavani',
            'Gobichettipalayam',
            'Nambiyur',
            'Sathyamangalam',
            'Thalavadi'
          ],
          rhoAssignments: ['RHO_ERO_001'],
        ),
        DistrictData(
          name: 'Kallakurichi',
          code: 'KAL',
          subDistricts: [
            'Chinnasalem',
            'Kallakurichi',
            'Kalvarayan Hills',
            'Sankarapuram',
            'Tirukoilur',
            'Ulundurpet'
          ],
          rhoAssignments: ['RHO_KAL_001'],
        ),
        DistrictData(
          name: 'Kancheepuram',
          code: 'KAN',
          subDistricts: [
            'Kancheepuram',
            'Uthiramerur',
            'Sriperumbudur',
            'Walajabad',
            'Kundrathur'
          ],
          rhoAssignments: ['RHO_KAN_001'],
        ),
        DistrictData(
          name: 'Kanyakumari',
          code: 'KNK',
          subDistricts: [
            'Agastheeswaram',
            'Kalkulam',
            'Killiyoor',
            'Thovalai',
            'Thiruvattar',
            'Vilavancode'
          ],
          rhoAssignments: ['RHO_KNK_001'],
        ),
        DistrictData(
          name: 'Karur',
          code: 'KAR',
          subDistricts: [
            'Karur',
            'Aravakurichi',
            'Kadavur',
            'Krishnarayapuram',
            'Kulithalai',
            'Manmangalam',
            'Pugalur'
          ],
          rhoAssignments: ['RHO_KAR_001'],
        ),
        DistrictData(
          name: 'Krishnagiri',
          code: 'KRI',
          subDistricts: [
            'Anchetty',
            'Denkanikottai',
            'Hosur',
            'Shoolagiri',
            'Bargur',
            'Krishnagiri',
            'Pochampalli',
            'Uthangarai'
          ],
          rhoAssignments: ['RHO_KRI_001'],
        ),
        DistrictData(
          name: 'Madurai',
          code: 'MAD',
          subDistricts: [
            'Madurai North',
            'Madurai South',
            'Madurai East',
            'Madurai West',
            'Vadipatti',
            'Melur',
            'Peraiyur',
            'Thirumangalam',
            'Thiruparankundram',
            'Usilampatti'
          ],
          rhoAssignments: ['RHO_MAD_001'],
        ),
        DistrictData(
          name: 'Mayiladuthurai',
          code: 'MAY',
          subDistricts: [
            'Mayiladuthurai',
            'Sirkazhi',
            'Tharangambadi',
            'Kuthalam'
          ],
          rhoAssignments: ['RHO_MAY_001'],
        ),
        DistrictData(
          name: 'Nagapattinam',
          code: 'NAG',
          subDistricts: [
            'Nagapattinam',
            'Kilvelur',
            'Thirukkuvalai',
            'Vedaranyam'
          ],
          rhoAssignments: ['RHO_NAG_001'],
        ),
        DistrictData(
          name: 'Namakkal',
          code: 'NAM',
          subDistricts: [
            'Namakkal',
            'Kumarapalayam',
            'Mohanur',
            'Paramathi-Velur',
            'Rasipuram',
            'Senthamangalam'
          ],
          rhoAssignments: ['RHO_NAM_001'],
        ),
        DistrictData(
          name: 'The Nilgiris',
          code: 'NIL',
          subDistricts: [
            'Udagamandalam',
            'Coonoor',
            'Gudalur',
            'Kundah',
            'Kothagiri',
            'Pandalur'
          ],
          rhoAssignments: ['RHO_NIL_001'],
        ),
        DistrictData(
          name: 'Perambalur',
          code: 'PER',
          subDistricts: [
            'Perambalur',
            'Alathur',
            'Kunnam',
            'Veppanthattai'
          ],
          rhoAssignments: ['RHO_PER_001'],
        ),
        DistrictData(
          name: 'Pudukkottai',
          code: 'PUD',
          subDistricts: [
            'Alangudi',
            'Aranthangi',
            'Avudaiyarkoil',
            'Gandarvakottai',
            'Iluppur',
            'Karambakudi',
            'Kulathur',
            'Manamelkudi',
            'Ponnamaravathi',
            'Thirumayam',
            'Viralimalai'
          ],
          rhoAssignments: ['RHO_PUD_001'],
        ),
        DistrictData(
          name: 'Ramanathapuram',
          code: 'RAM',
          subDistricts: [
            'Ramanathapuram',
            'Paramakudi',
            'Kadaladi',
            'Kamuthi',
            'Mudukulathur',
            'Rameswaram',
            'Rajasingamangalam',
            'Tiruvadanai'
          ],
          rhoAssignments: ['RHO_RAM_001'],
        ),
        DistrictData(
          name: 'Salem',
          code: 'SAL',
          subDistricts: [
            'Salem',
            'Attur',
            'Edappadi',
            'Gangavalli',
            'Kadaiyampatti',
            'Mettur',
            'Omalur',
            'Pethanayakanpalayam',
            'Salem South',
            'Salem West',
            'Sankari',
            'Vazhapadi',
            'Yercaud'
          ],
          rhoAssignments: ['RHO_SAL_001'],
        ),
        DistrictData(
          name: 'Sivaganga',
          code: 'SIV',
          subDistricts: [
            'Sivaganga',
            'Devakottai',
            'Ilaiyangudi',
            'Kalaiyarkovil',
            'Karaikudi',
            'Manamadurai',
            'Singampunari',
            'Thirupuvanam'
          ],
          rhoAssignments: ['RHO_SIV_001'],
        ),
        DistrictData(
          name: 'Thanjavur',
          code: 'THA',
          subDistricts: [
            'Thanjavur',
            'Kumbakonam',
            'Orathanadu',
            'Papanasam',
            'Pattukkottai',
            'Peravurani',
            'Thiruvaiyaru',
            'Thiruvidaimarudur',
            'Boothalur'
          ],
          rhoAssignments: ['RHO_THA_001'],
        ),
        DistrictData(
          name: 'Theni',
          code: 'THE',
          subDistricts: [
            'Theni',
            'Andipatti',
            'Bodinayakanur',
            'Periyakulam',
            'Uthamapalayam'
          ],
          rhoAssignments: ['RHO_THE_001'],
        ),
        DistrictData(
          name: 'Thiruvallur',
          code: 'THI',
          subDistricts: [
            'Avadi',
            'Gummidipoondi',
            'Pallipattu',
            'Ponneri',
            'Poonamallee',
            'R.K. Pet',
            'Tiruttani',
            'Uthukottai',
            'Thiruvallur'
          ],
          rhoAssignments: ['RHO_THI_001'],
        ),
        DistrictData(
          name: 'Tiruvannamalai',
          code: 'TIR',
          subDistricts: [
            'Tiruvannamalai',
            'Arni',
            'Chengam',
            'Chetpet',
            'Cheyyar',
            'Jamunamarathur',
            'Kalasapakkam',
            'Kilpennathur',
            'Polur',
            'Thandramet',
            'Vandavasi',
            'Vembakkam'
          ],
          rhoAssignments: ['RHO_TIR_001'],
        ),
        DistrictData(
          name: 'Tiruvarur',
          code: 'TIV',
          subDistricts: [
            'Thiruvarur',
            'Kodavasal',
            'Koothanallur',
            'Mannargudi',
            'Nannilam',
            'Needamangalam',
            'Thiruthuraipoondi',
            'Valangaiman'
          ],
          rhoAssignments: ['RHO_TIV_001'],
        ),
        DistrictData(
          name: 'Thoothukudi',
          code: 'THO',
          subDistricts: [
            'Thoothukudi',
            'Ottapidaram',
            'Kovilpatti',
            'Srivaikundam',
            'Tiruchendur',
            'Vilathikulam',
            'Kayathar',
            'Eral',
            'Ettayapuram'
          ],
          rhoAssignments: ['RHO_THO_001'],
        ),
        DistrictData(
          name: 'Tiruchirapalli',
          code: 'TRC',
          subDistricts: [
            'Tiruchirappalli East',
            'Tiruchirappalli West',
            'Lalgudi',
            'Manachanallur',
            'Manapparai',
            'Marungapuri',
            'Musiri',
            'Srirangam',
            'Thottiam',
            'Thuraiyur'
          ],
          rhoAssignments: ['RHO_TRC_001'],
        ),
        DistrictData(
          name: 'Tiruppur',
          code: 'TIP',
          subDistricts: [
            'Tiruppur North',
            'Tiruppur South',
            'Avinashi',
            'Dharapuram',
            'Kangeyam',
            'Madathukulam',
            'Oothukuli',
            'Palladam'
          ],
          rhoAssignments: ['RHO_TIP_001'],
        ),
        DistrictData(
          name: 'Tenkasi',
          code: 'TEN',
          subDistricts: [
            'Tenkasi',
            'Alangulam',
            'Kadayanallur',
            'Sankarankovil',
            'Shenkottai',
            'Sivagiri',
            'Thiruvengadam',
            'Veerakeralampudur'
          ],
          rhoAssignments: ['RHO_TEN_001'],
        ),
        DistrictData(
          name: 'Tirupathur',
          code: 'TPR',
          subDistricts: [
            'Tirupathur',
            'Vaniyambadi',
            'Natrampalli',
            'Ambur'
          ],
          rhoAssignments: ['RHO_TPR_001'],
        ),
        DistrictData(
          name: 'Virudhunagar',
          code: 'VIR',
          subDistricts: [
            'Virudhunagar',
            'Aruppukottai',
            'Kariapatti',
            'Rajapalayam',
            'Sathur',
            'Sivakasi',
            'Srivilliputhur',
            'Tiruchuli',
            'Vembakottai',
            'Watrap'
          ],
          rhoAssignments: ['RHO_VIR_001'],
        ),
      ],
    ),
    StateData(
      name: 'Karnataka',
      code: 'KA',
      districts: [
        DistrictData(
          name: 'Bengaluru Urban',
          code: 'BLR',
          subDistricts: [
            'Bengaluru North',
            'Bengaluru South',
            'Bengaluru East',
            'Anekal',
            'Devanahalli'
          ],
          isDenselyPopulated: true,
          rhoAssignments: ['RHO_BLR_001', 'RHO_BLR_002'],
        ),
        DistrictData(
          name: 'Mysuru',
          code: 'MYS',
          subDistricts: [
            'Mysuru',
            'Krishnarajanagara',
            'Hunsur',
            'Piriyapatna',
            'Nanjangud',
            'T. Narasipur',
            'Saragur'
          ],
          rhoAssignments: ['RHO_MYS_001'],
        ),
      ],
    ),
    StateData(
      name: 'Gujarat',
      code: 'GJ',
      districts: [
        DistrictData(
          name: 'Ahmedabad',
          code: 'AMD',
          subDistricts: [
            'Ahmedabad City',
            'Daskroi',
            'Detroj-Rampura',
            'Dholka',
            'Bavla',
            'Ranpur',
            'Viramgam',
            'Mandal',
            'Dhandhuka'
          ],
          isDenselyPopulated: true,
          rhoAssignments: ['RHO_AMD_001', 'RHO_AMD_002'],
        ),
        DistrictData(
          name: 'Surat',
          code: 'SUR',
          subDistricts: [
            'Surat City',
            'Chorasi',
            'Palsana',
            'Bardoli',
            'Mahuva',
            'Kamrej',
            'Olpad',
            'Mangrol',
            'Umarpada'
          ],
          rhoAssignments: ['RHO_SUR_001'],
        ),
      ],
    ),
    StateData(
      name: 'Rajasthan',
      code: 'RJ',
      districts: [
        DistrictData(
          name: 'Jaipur',
          code: 'JAI',
          subDistricts: [
            'Jaipur',
            'Amber',
            'Phagi',
            'Dudu',
            'Mauzamabad',
            'Shahpura',
            'Chomu',
            'Phulera',
            'Sanganer',
            'Bassi',
            'Chaksu',
            'Govindgarh',
            'Jamwa Ramgarh',
            'Jhotwara',
            'Kotputli',
            'Viratnagar'
          ],
          rhoAssignments: ['RHO_JAI_001'],
        ),
        DistrictData(
          name: 'Jodhpur',
          code: 'JOD',
          subDistricts: [
            'Jodhpur',
            'Bilara',
            'Bhopalgarh',
            'Falodi',
            'Luni',
            'Mandore',
            'Osian',
            'Phalodi',
            'Pipar',
            'Shergarh'
          ],
          rhoAssignments: ['RHO_JOD_001'],
        ),
      ],
    ),
    StateData(
      name: 'West Bengal',
      code: 'WB',
      districts: [
        DistrictData(
          name: 'Kolkata',
          code: 'KOL',
          subDistricts: [
            'Kolkata',
          ],
          isDenselyPopulated: true,
          rhoAssignments: ['RHO_KOL_001', 'RHO_KOL_002'],
        ),
        DistrictData(
          name: 'Howrah',
          code: 'HOW',
          subDistricts: [
            'Howrah',
            'Panchla',
            'Uluberia',
            'Shyampur',
            'Bagnan',
            'Amta',
            'Udaynarayanpur',
            'Jagatballavpur',
            'Domjur'
          ],
          rhoAssignments: ['RHO_HOW_001'],
        ),
      ],
    ),
    StateData(
      name: 'Kerala',
      code: 'KL',
      districts: [
        DistrictData(
          name: 'Thiruvananthapuram',
          code: 'TVM',
          subDistricts: [
            'Thiruvananthapuram',
            'Neyyattinkara',
            'Kattakkada',
            'Nedumangad',
            'Chirayinkeezhu (Attingal)',
            'Varkala'
          ],
          isDenselyPopulated: true,
          rhoAssignments: ['RHO_TVM_001', 'RHO_TVM_002'],
        ),
        DistrictData(
          name: 'Kollam',
          code: 'KLM',
          subDistricts: [
            'Kollam',
            'Kunnathoor',
            'Karunagappally',
            'Kottarakkara',
            'Punalur',
            'Pathanapuram'
          ],
          rhoAssignments: ['RHO_KLM_001'],
        ),
        DistrictData(
          name: 'Pathanamthitta',
          code: 'PTA',
          subDistricts: [
            'Adoor',
            'Konni',
            'Kozhencherry',
            'Ranni',
            'Mallappally',
            'Thiruvalla'
          ],
          rhoAssignments: ['RHO_PTA_001'],
        ),
        DistrictData(
          name: 'Alappuzha',
          code: 'ALP',
          subDistricts: [
            'Ambalappuzha',
            'Chengannur',
            'Kuttanad (Mankombu)',
            'Karthikappally',
            'Cherthala',
            'Mavelikkara'
          ],
          rhoAssignments: ['RHO_ALP_001'],
        ),
        DistrictData(
          name: 'Kottayam',
          code: 'KTM',
          subDistricts: [
            'Changanasserry',
            'Kottayam',
            'Vaikom',
            'Meenachil',
            'Kanjirappally'
          ],
          rhoAssignments: ['RHO_KTM_001'],
        ),
        DistrictData(
          name: 'Idukki',
          code: 'IDK',
          subDistricts: [
            'Peermade',
            'Udumbanchola',
            'Devikulam',
            'Thodupuzha',
            'Idukki'
          ],
          rhoAssignments: ['RHO_IDK_001'],
        ),
        DistrictData(
          name: 'Ernakulam',
          code: 'EKM',
          subDistricts: [
            'Paravur (North)',
            'Aluva',
            'Kochi/Ernakulam',
            'Muvattupuzha',
            'Kothamangalam',
            'Thrikkakara'
          ],
          isDenselyPopulated: true,
          rhoAssignments: ['RHO_EKM_001', 'RHO_EKM_002'],
        ),
        DistrictData(
          name: 'Thrissur',
          code: 'TSR',
          subDistricts: [
            'Thrissur',
            'Chavakkad',
            'Thalapilly (Kodungallur?)',
            'Talappilly',
            'Chalakudy'
          ],
          isDenselyPopulated: true,
          rhoAssignments: ['RHO_TSR_001', 'RHO_TSR_002'],
        ),
        DistrictData(
          name: 'Palakkad',
          code: 'PKD',
          subDistricts: [
            'Palakkad',
            'Ottapalam',
            'Alathur',
            'Chittur',
            'Pattambi',
            'Mannarkkad'
          ],
          rhoAssignments: ['RHO_PKD_001'],
        ),
        DistrictData(
          name: 'Malappuram',
          code: 'MPM',
          subDistricts: [
            'Malappuram',
            'Tirur',
            'Ponnani',
            'Perinthalmanna',
            'Nilambur',
            'Ernad'
          ],
          rhoAssignments: ['RHO_MPM_001'],
        ),
        DistrictData(
          name: 'Kozhikode',
          code: 'KZK',
          subDistricts: [
            'Kozhikode',
            'Vatakara',
            'Thamarassery',
            'Koyilandy'
          ],
          rhoAssignments: ['RHO_KZK_001'],
        ),
        DistrictData(
          name: 'Wayanad',
          code: 'WYD',
          subDistricts: [
            'Mananthavady',
            'Sulthan Bathery',
            'Vythiri'
          ],
          rhoAssignments: ['RHO_WYD_001'],
        ),
        DistrictData(
          name: 'Kannur',
          code: 'KNR',
          subDistricts: [
            'Kannur',
            'Thalassery',
            'Taliparamba',
            'Iritty'
          ],
          rhoAssignments: ['RHO_KNR_001'],
        ),
        DistrictData(
          name: 'Kasaragod',
          code: 'KSD',
          subDistricts: [
            'Kasaragod',
            'Hosdurg (Kanhangad)',
            'Manjeshwaram'
          ],
          rhoAssignments: ['RHO_KSD_001'],
        ),
      ],
    ),
    StateData(
      name: 'Andhra Pradesh',
      code: 'AP',
      districts: [
        DistrictData(
          name: 'Visakhapatnam',
          code: 'VSK',
          subDistricts: [
            'Visakhapatnam City',
            'Visakhapatnam Rural',
            'Anakapalli',
            'Narsipatnam'
          ],
          isDenselyPopulated: true,
          rhoAssignments: ['RHO_VSK_001', 'RHO_VSK_002'],
        ),
        DistrictData(
          name: 'Vijayawada',
          code: 'VJA',
          subDistricts: [
            'Vijayawada City',
            'Vijayawada Rural',
            'Machilipatnam',
            'Gudivada'
          ],
          isDenselyPopulated: true,
          rhoAssignments: ['RHO_VJA_001', 'RHO_VJA_002'],
        ),
        DistrictData(
          name: 'Guntur',
          code: 'GTR',
          subDistricts: [
            'Guntur City',
            'Guntur Rural',
            'Tenali',
            'Narasaraopet'
          ],
          rhoAssignments: ['RHO_GTR_001'],
        ),
        DistrictData(
          name: 'Chittoor',
          code: 'CTR',
          subDistricts: [
            'Chittoor',
            'Tirupati',
            'Madanapalle',
            'Srikalahasti'
          ],
          rhoAssignments: ['RHO_CTR_001'],
        ),
        DistrictData(
          name: 'Kurnool',
          code: 'KRN',
          subDistricts: [
            'Kurnool',
            'Nandyal',
            'Adoni',
            'Yemmiganur'
          ],
          rhoAssignments: ['RHO_KRN_001'],
        ),
        DistrictData(
          name: 'Anantapur',
          code: 'ATP',
          subDistricts: [
            'Anantapur',
            'Hindupur',
            'Guntakal',
            'Dharmavaram'
          ],
          rhoAssignments: ['RHO_ATP_001'],
        ),
        DistrictData(
          name: 'Nellore',
          code: 'NLR',
          subDistricts: [
            'Nellore City',
            'Nellore Rural',
            'Gudur',
            'Kavali'
          ],
          rhoAssignments: ['RHO_NLR_001'],
        ),
        DistrictData(
          name: 'Kadapa',
          code: 'KDP',
          subDistricts: [
            'Kadapa',
            'Proddatur',
            'Rajampet',
            'Jammalamadugu'
          ],
          rhoAssignments: ['RHO_KDP_001'],
        ),
      ],
    ),
  ];

  /// Get list of all state names
  static List<String> get stateNames {
    return states.map((state) => state.name).toList()..sort();
  }

  /// Get districts for a specific state
  static List<DistrictData> getDistrictsForState(String stateName) {
    print('🔍 getDistrictsForState called with: "$stateName"');
    print('🔍 Available states: ${states.map((s) => s.name).toList()}');
    
    final state = states.firstWhere(
      (state) => state.name == stateName,
      orElse: () {
        print('❌ State "$stateName" not found, returning empty state');
        return const StateData(name: '', code: '', districts: []);
      },
    );
    
    print('🔍 Found state: "${state.name}" with ${state.districts.length} districts');
    return state.districts;
  }

  /// Get district names for a specific state
  static List<String> getDistrictNamesForState(String stateName) {
    print('🔍 getDistrictNamesForState called with: "$stateName"');
    final districts = getDistrictsForState(stateName);
    final districtNames = districts.map((district) => district.name).toList()..sort();
    print('🔍 Returning ${districtNames.length} district names: $districtNames');
    return districtNames;
  }

  /// Get sub-districts for a specific district
  static List<String> getSubDistrictsForDistrict(String stateName, String districtName) {
    final districts = getDistrictsForState(stateName);
    final district = districts.firstWhere(
      (district) => district.name == districtName,
      orElse: () => const DistrictData(name: '', code: '', subDistricts: []),
    );
    return List<String>.from(district.subDistricts)..sort();
  }

  /// Get RHO assignment for a specific location
  static String? getRHOForLocation({
    required String stateName,
    required String districtName,
    String? subDistrictName,
  }) {
    final districts = getDistrictsForState(stateName);
    final district = districts.firstWhere(
      (district) => district.name == districtName,
      orElse: () => const DistrictData(name: '', code: '', subDistricts: []),
    );

    if (district.name.isEmpty) return null;

    // If it's a densely populated district with area-wise mapping
    if (district.isDenselyPopulated && district.areaWiseRhoMapping != null) {
      // For dense districts with area-wise mapping, sub-district is required
      if (subDistrictName == null || subDistrictName.isEmpty) {
        return null; // No assignment until sub-district is selected
      }
      return district.areaWiseRhoMapping![subDistrictName];
    }

    // Otherwise, return the first RHO assigned to the district
    return district.rhoAssignments.isNotEmpty ? district.rhoAssignments.first : null;
  }

  /// Get all available RHOs for a district (for dense districts)
  static List<String> getAvailableRHOsForDistrict(String stateName, String districtName) {
    final districts = getDistrictsForState(stateName);
    final district = districts.firstWhere(
      (district) => district.name == districtName,
      orElse: () => const DistrictData(name: '', code: '', subDistricts: []),
    );

    if (district.name.isEmpty) return [];
    return district.rhoAssignments;
  }

  /// Check if a district has multiple RHOs
  static bool isDistrictDenselyPopulated(String stateName, String districtName) {
    final districts = getDistrictsForState(stateName);
    final district = districts.firstWhere(
      (district) => district.name == districtName,
      orElse: () => const DistrictData(name: '', code: '', subDistricts: []),
    );

    return district.isDenselyPopulated;
  }

  /// Get district data for a specific district
  static DistrictData? getDistrictData(String stateName, String districtName) {
    final districts = getDistrictsForState(stateName);
    try {
      return districts.firstWhere((district) => district.name == districtName);
    } catch (e) {
      return null;
    }
  }

  /// Get state code for a state name
  static String? getStateCode(String stateName) {
    try {
      final state = states.firstWhere((state) => state.name == stateName);
      return state.code;
    } catch (e) {
      return null;
    }
  }

  /// Get district code for a district
  static String? getDistrictCode(String stateName, String districtName) {
    final district = getDistrictData(stateName, districtName);
    return district?.code;
  }

  /// Get formatted location string
  static String getFormattedLocation({
    required String stateName,
    required String districtName,
    String? subDistrictName,
  }) {
    if (subDistrictName != null && subDistrictName.isNotEmpty) {
      return '$subDistrictName, $districtName, $stateName';
    }
    return '$districtName, $stateName';
  }

  /// Search states by name (for autocomplete)
  static List<String> searchStates(String query) {
    if (query.isEmpty) return stateNames;
    
    return stateNames.where((state) => 
      state.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Search districts by name within a state (for autocomplete)
  static List<String> searchDistricts(String stateName, String query) {
    final districts = getDistrictNamesForState(stateName);
    if (query.isEmpty) return districts;
    
    return districts.where((district) => 
      district.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Search sub-districts by name within a district (for autocomplete)
  static List<String> searchSubDistricts(String stateName, String districtName, String query) {
    final subDistricts = getSubDistrictsForDistrict(stateName, districtName);
    if (query.isEmpty) return subDistricts;
    
    return subDistricts.where((subDistrict) => 
      subDistrict.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}