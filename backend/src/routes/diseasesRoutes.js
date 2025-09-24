const express = require('express');
const router = express.Router();
const diseasesList = require('../data/diseases');

// Get all diseases - for initial load and full list
router.get('/', (req, res) => {
  try {
    console.log('📋 Fetching diseases list...');
    res.status(200).json({
      success: true,
      data: diseasesList,
      count: diseasesList.length
    });
  } catch (error) {
    console.error('❌ Error fetching diseases:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch diseases list'
    });
  }
});

// Search diseases - dynamic search functionality
router.get('/search', (req, res) => {
  try {
    const { query } = req.query;
    
    if (!query || query.trim().length === 0) {
      return res.status(200).json({
        success: true,
        data: diseasesList,
        count: diseasesList.length
      });
    }

    console.log(`🔍 Searching diseases for query: "${query}"`);
    
    // Case-insensitive search that matches anywhere in the disease name
    const searchResults = diseasesList.filter(disease => 
      disease.toLowerCase().includes(query.toLowerCase().trim())
    );

    console.log(`✅ Found ${searchResults.length} matching diseases`);

    res.status(200).json({
      success: true,
      data: searchResults,
      count: searchResults.length,
      query: query
    });
  } catch (error) {
    console.error('❌ Error searching diseases:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to search diseases'
    });
  }
});

module.exports = router;