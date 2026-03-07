const mongoose = require('mongoose');

const RouteSchema = new mongoose.Schema({
  from: String,
  to: String,
  busId: String,
  departure: String,
  arrival: String,
  fare: Number,
});

module.exports = mongoose.model('Route', RouteSchema);
