const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware/auth');
const User = require('../models/User');

router.get('/me', verifyToken, async (req, res) => {
  const user = await User.findById(req.userId, 'username searchHistory');
  res.json(user);
});

module.exports = router;
