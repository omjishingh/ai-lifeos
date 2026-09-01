const express = require('express');
const { chat, planDay, breakdown } = require('../providers/aiProvider');

const router = express.Router();

router.post('/chat', (req, res) => {
  const { message } = req.body || {};
  if (!message) return res.status(400).json({ error: 'message required' });
  res.json(chat(message));
});

router.post('/plan', (req, res) => {
  const hours = req.body?.hoursAvailable ?? 2;
  res.json(planDay(hours));
});

router.post('/breakdown', (req, res) => {
  const task = req.body?.task;
  if (!task) return res.status(400).json({ error: 'task required' });
  res.json({ steps: breakdown(task) });
});

module.exports = router;
