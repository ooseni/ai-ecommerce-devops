const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();

// Liveness: the process is up and answering. It never checks MongoDB, so a
// database outage doesn't make kubernetes restart every API container.
router.get('/live', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// Readiness: 200 only while MongoDB is connected, 503 otherwise, so traffic
// and smoke tests wait until the API can really serve data.
router.get('/', (req, res) => {
  const connected = mongoose.connection.readyState === 1;
  res.status(connected ? 200 : 503).json({
    status: connected ? 'ok' : 'unavailable',
    db: connected ? 'connected' : 'disconnected',
    uptime: Math.round(process.uptime())
  });
});

module.exports = router;
