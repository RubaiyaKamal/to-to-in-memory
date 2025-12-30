#!/usr/bin/env node
/**
 * Skills Library MCP Server
 * Provides efficient access to development skills and workflows
 * Optimized for token usage and clean output
 */

const fs = require('fs').promises;
const path = require('path');

const SKILLS_PATH = process.env.SKILLS_PATH || __dirname;

// MCP Server Protocol Implementation
class SkillsM CPServer {
  constructor() {
    this.skills = new Map();
    this.workflows = new Map();
    this.cache = new Map();
  }

  async initialize() {
    await this.loadSkills();
    await this.loadWorkflows();
    console.error('[Skills MCP] Initialized with', this.skills.size, 'skills and', this.workflows.size, 'workflows');
  }

  async loadSkills() {
    const skillsDir = path.join(SKILLS_PATH, 'skills');
    try {
      const files = await fs.readdir(skillsDir);
      for (const file of files.filter(f => f.endsWith('.md'))) {
        const content = await fs.readFile(path.join(skillsDir, file), 'utf-8');
        const skillName = file.replace('.md', '');
        this.skills.set(skillName, {
          name: skillName,
          content,
          path: path.join('skills', file)
        });
      }
    } catch (error) {
      console.error('[Skills MCP] Error loading skills:', error.message);
    }
  }

  async loadWorkflows() {
    const workflowsDir = path.join(SKILLS_PATH, 'workflows');
    try {
      const files = await fs.readdir(workflowsDir);
      for (const file of files.filter(f => f.endsWith('.md'))) {
        const content = await fs.readFile(path.join(workflowsDir, file), 'utf-8');
        const workflowName = file.replace('.md', '');
        this.workflows.set(workflowName, {
          name: workflowName,
          content,
          path: path.join('workflows', file)
        });
      }
    } catch (error) {
      console.error('[Skills MCP] Error loading workflows:', error.message);
    }
  }

  async handleRequest(request) {
    const { method, params } = request;

    switch (method) {
      case 'initialize':
        return {
          protocolVersion: '0.1.0',
          capabilities: {
            resources: {}
          },
          serverInfo: {
            name: 'skills-server',
            version: '1.0.0'
          }
        };

      case 'resources/list':
        return {
          resources: [
            ...Array.from(this.skills.values()).map(s => ({
              uri: `skill:///${s.name}`,
              name: s.name.replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase()),
              mimeType: 'text/markdown',
              description: `Development skill: ${s.name}`
            })),
            ...Array.from(this.workflows.values()).map(w => ({
              uri: `workflow:///${w.name}`,
              name: w.name.replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase()),
              mimeType: 'text/markdown',
              description: `Workflow guide: ${w.name}`
            }))
          ]
        };

      case 'resources/read':
        const uri = params?.uri;
        if (!uri) throw new Error('URI required');

        if (uri.startsWith('skill:///')) {
          const skillName = uri.replace('skill:///', '');
          const skill = this.skills.get(skillName);
          if (!skill) throw new Error(`Skill not found: ${skillName}`);
          
          return {
            contents: [{
              uri,
              mimeType: 'text/markdown',
              text: skill.content
            }]
          };
        }

        if (uri.startsWith('workflow:///')) {
          const workflowName = uri.replace('workflow:///', '');
          const workflow = this.workflows.get(workflowName);
          if (!workflow) throw new Error(`Workflow not found: ${workflowName}`);
          
          return {
            contents: [{
              uri,
              mimeType: 'text/markdown',
              text: workflow.content
            }]
          };
        }

        throw new Error('Invalid URI scheme');

      default:
        throw new Error(`Unknown method: ${method}`);
    }
  }

  async start() {
    await this.initialize();

    // Read from stdin
    let buffer = '';
    process.stdin.on('data', async (chunk) => {
      buffer += chunk.toString();
      const lines = buffer.split('\n');
      buffer = lines.pop() || '';

      for (const line of lines) {
        if (!line.trim()) continue;
        
        try {
          const request = JSON.parse(line);
          const response = await this.handleRequest(request);
          
          console.log(JSON.stringify({
            jsonrpc: '2.0',
            id: request.id,
            result: response
          }));
        } catch (error) {
          console.log(JSON.stringify({
            jsonrpc: '2.0',
            id: null,
            error: {
              code: -32000,
              message: error.message
            }
          }));
        }
      }
    });

    process.stdin.on('end', () => {
      process.exit(0);
    });
  }
}

// Start server
const server = new SkillsMCPServer();
server.start().catch(error => {
  console.error('[Skills MCP] Fatal error:', error);
  process.exit(1);
});
