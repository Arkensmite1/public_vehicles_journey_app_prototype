const express = require('express');
const router = express.Router();
const Ticket = require('../models/Ticket');
const verifyToken = require('../middleware/auth');

router.post('/book', verifyToken, async (req, res) => {
  const { busId, from, to, fare, departure, arrival } = req.body;
  const ticket = new Ticket({ userId: req.userId, busId, from, to, fare, departure, arrival });
  await ticket.save();
  res.status(201).json({ message: "Ticket booked", ticket });
});

router.get('/my', verifyToken, async (req, res) => {
  const tickets = await Ticket.find({ userId: req.userId });
  res.json(tickets);
});

module.exports = router;
