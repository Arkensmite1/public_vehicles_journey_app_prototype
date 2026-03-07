const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware/auth');
const Route = require('../models/Route');
const User = require('../models/User');

router.post('/search', verifyToken, async (req, res) => {
  const { from, to } = req.body;
  const routes = await Route.find({ from, to });

  // Add to search history
  await User.findByIdAndUpdate(req.userId, {
    $push: { searchHistory: { from, to } }
  });

  res.json(routes);
});

module.exports = router;
