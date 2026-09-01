const CATEGORIES = [
  'Major AI Company Update',
  'New AI Model',
  'AI Coding Tools',
  'AI Apps/Products',
  'Open-source AI',
  'Research',
  'AI Agents',
  'AI Business/Industry',
  'AI Policy/Safety',
  'Important AI Trend'
];

const SOURCES = [
  { name: 'TechCrunch AI', url: 'https://techcrunch.com/category/artificial-intelligence/' },
  { name: 'The Verge AI', url: 'https://www.theverge.com/ai-artificial-intelligence' },
  { name: 'MIT Technology Review', url: 'https://www.technologyreview.com/topic/artificial-intelligence/' },
  { name: 'ArXiv AI', url: 'https://arxiv.org/list/cs.AI/recent' },
  { name: 'Hugging Face Blog', url: 'https://huggingface.co/blog' }
];

function getTodayNews() {
  const today = new Date().toISOString().split('T')[0];
  const items = CATEGORIES.map((category, index) => {
    const source = SOURCES[index % SOURCES.length];
    return {
      id: `news-${today}-${index + 1}`,
      title: `${category}: Latest industry developments`,
      summary: `Today's briefing covers ${category.toLowerCase()}. Connect licensed news APIs for live content.`,
      whyItMatters: 'Staying current on AI helps you choose better tools and plan your projects.',
      sourceName: source.name,
      sourceUrl: source.url,
      publishedAt: new Date().toISOString(),
      category,
      imageUrl: null,
      tags: ['ai', 'daily-briefing'],
      sortOrder: index + 1
    };
  });

  return { date: today, count: items.length, items };
}

module.exports = { getTodayNews };
