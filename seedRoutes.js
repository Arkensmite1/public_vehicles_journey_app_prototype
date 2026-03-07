const mongoose = require('mongoose');
const Route = require('./models/Route');
require('dotenv').config();

mongoose.connect(process.env.MONGO_URI).then(async () => {
  await Route.insertMany([
    { from: "Delhi", to: "Agra", busId: "BUS101", departure: "10:00", arrival: "12:30", fare: 200 },
    { from: "Delhi", to: "Agra", busId: "BUS102", departure: "14:00", arrival: "16:30", fare: 220 },
    { from: "Agra", to: "Delhi", busId: "BUS201", departure: "09:00", arrival: "11:30", fare: 210 }
  ]);
  console.log("Routes seeded");
  process.exit();
});
