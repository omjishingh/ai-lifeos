const express = require('express');
const { getTodayNews } = require('../providers/newsProvider');

const router = express.Router();

router.get('/today', (_req, res) => {
  const briefing = getTodayNews();
  res.json(briefing);
});

router.get('/:id', (req, res) => {
  const briefing = getTodayNews();
  const item = briefing.items.find((i) => i.id === req.params.id);
  if (!item) return res.status(404).json({ error: 'Article not found' });
  res.json(item);
});

module.exports = router;
