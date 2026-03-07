const mongoose = require('mongoose');

const TicketSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  busId: String,
  from: String,
  to: String,
  fare: Number,
  departure: String,
  arrival: String,
  bookedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Ticket', TicketSchema);
