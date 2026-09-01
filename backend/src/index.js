require('dotenv').config();
const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');

const newsRoutes = require('./routes/news');
const aiRoutes = require('./routes/ai');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use(rateLimit({ windowMs: 60 * 1000, max: 60 }));

app.get('/api/v1/health', (_req, res) => {
  res.json({ status: 'ok', service: 'AI LifeOS API', version: '1.0.0' });
});

app.use('/api/v1/news', newsRoutes);
app.use('/api/v1/ai', aiRoutes);

app.use((_req, res) => res.status(404).json({ error: 'Not found' }));

app.listen(PORT, () => {
  console.log(`AI LifeOS API running on http://localhost:${PORT}/api/v1`);
});
