const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Bus = require('../models/buses');

// Example: GET available buses
router.get('/search', auth, async (req, res) => {
  const { source, destination, date } = req.query;

  if (!source || !destination || !date) {
    return res.status(400).json({ message: 'Source, destination, and date are required.' });
  }

  try {
    const buses = await Bus.find({
      source,
      destination,
      date,
    });

    res.json({ buses });
  } catch (error) {
    console.error('Error fetching buses:', error);
    res.status(500).json({ message: 'Server error fetching buses.' });
  }
});

module.exports = router;
