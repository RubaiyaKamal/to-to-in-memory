# AI Skills

## Overview
Guidelines for working with AI models, prompt engineering, and AI-powered features.

## Prompt Engineering

### Best Practices
1. **Be Clear and Specific** - Write unambiguous prompts
2. **Provide Context** - Include relevant background information
3. **Use Examples** - Show what you want with concrete examples
4. **Iterate** - Refine prompts based on results

### Effective Prompt Structure
```
Role: You are a [specific role]
Task: [Clear task description]
Context: [Relevant background]
Format: [Desired output format]
Constraints: [Any limitations]
```

## Claude API Integration

```javascript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

const message = await client.messages.create({
  model: 'claude-sonnet-4-20250514',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Your prompt here' }],
});

console.log(message.content);
```

## Context Management
- Keep conversation history organized
- Manage token limits (200K for Sonnet 4.5)
- Structure context for optimal results
- Use system prompts for consistency
- Leverage prompt caching for static content

## Token Optimization Strategies

### 1. Use MCP Servers
- Store frequently accessed content in MCP resources
- Automatic caching by Claude
- Reduces token usage significantly

### 2. Efficient Prompting
- Be concise but clear
- Remove redundant information
- Use references instead of repeating content

### 3. Leverage Caching
```javascript
// Use prompt caching for static content
const message = await client.messages.create({
  model: 'claude-sonnet-4-20250514',
  system: [
    {
      type: "text",
      text: "Long system prompt that doesn't change...",
      cache_control: { type: "ephemeral" }
    }
  ],
  messages: [...]
});
```

## Common Use Cases
1. Code generation and review
2. Documentation writing
3. Problem-solving assistance
4. Data analysis and visualization
5. Test case generation
6. API design and implementation
7. Debugging and troubleshooting

## Best Practices Checklist
- [ ] Clear, specific prompts
- [ ] Adequate context provided
- [ ] Examples included when relevant
- [ ] Iterative refinement
- [ ] Token usage optimized
- [ ] Responses validated
- [ ] Error handling implemented
