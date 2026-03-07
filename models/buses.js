const mongoose = require('mongoose');

const busSchema = new mongoose.Schema({
  name: String,
  source: String,
  destination: String,
  date: String,
  departureTime: String,
  arrivalTime: String,
  seatsAvailable: Number,
  price: Number,
});

module.exports = mongoose.model('Bus', busSchema);
