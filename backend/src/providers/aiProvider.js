function chat(message) {
  const lower = message.toLowerCase();
  if (lower.includes('plan') || lower.includes('ghante') || lower.includes('hour')) {
    return {
      reply: 'Based on your available time, I suggest prioritizing personal coding and high-priority college tasks. Review the suggestions below and confirm before applying.',
      suggestions: [
        { title: 'Personal Coding', durationMinutes: 90, priority: 'high' },
        { title: 'College Assignment', durationMinutes: 60, priority: 'medium' }
      ]
    };
  }
  if (lower.includes('break') || lower.includes('task')) {
    return {
      reply: 'Here is a suggested breakdown. You can add these as subtasks.',
      suggestions: null
    };
  }
  return {
    reply: `I received: "${message}". Add GEMINI_API_KEY or OPENAI_API_KEY to .env for full AI responses. Your schedule is safe.`,
    suggestions: null
  };
}

function planDay(hoursAvailable) {
  const total = Math.round(hoursAvailable * 60);
  return {
    suggestions: [
      { title: 'Personal Coding', durationMinutes: Math.min(Math.round(total * 0.6), 180), priority: 'high' },
      { title: 'College Work', durationMinutes: Math.min(Math.round(total * 0.3), 90), priority: 'medium' },
      { title: 'Review & Planning', durationMinutes: Math.min(Math.round(total * 0.1), 30), priority: 'low' }
    ]
  };
}

function breakdown(task) {
  return [
    `Research and scope: ${task}`,
    'Design the approach',
    'Implement core functionality',
    'Write tests',
    'Review and ship'
  ];
}

module.exports = { chat, planDay, breakdown };
