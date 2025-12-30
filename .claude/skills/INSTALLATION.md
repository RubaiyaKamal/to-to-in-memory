# Skills Library Installation Guide

## Quick Setup

### 1. Directory Structure
```
.claude/skills/
├── README.md (this file)
├── INSTALLATION.md
├── mcp-server.json (MCP configuration)
├── skills/ (11 skill files)
└── workflows/ (16 workflow files)
```

### 2. MCP Server Setup

Add to your Claude Desktop config (`~/Library/Application Support/Claude/claude_desktop_config.json` on Mac):

```json
{
  "mcpServers": {
    "skills-server": {
      "command": "node",
      "args": ["/path/to/to-do-in-memory/.claude/skills/mcp-server.js"],
      "env": {
        "SKILLS_PATH": "/path/to/to-do-in-memory/.claude/skills"
      }
    }
  }
}
```

### 3. Usage

**Via MCP (Recommended)**:
- Skills automatically available as MCP resources
- Optimized for token usage
- Cached responses

**Direct Access**:
- Browse markdown files in `skills/` and `workflows/`
- Use as reference documentation

## Benefits of MCP Integration

1. **Token Optimization**: Skills loaded on-demand, not in every prompt
2. **Clean Output**: Structured JSON responses
3. **Fast Access**: Cached skill content
4. **Cross-References**: Automatic linking between related skills

## Troubleshooting

**MCP Server not found?**
- Verify path in claude_desktop_config.json
- Restart Claude Desktop
- Check Node.js is installed

**Skills not loading?**
- Verify SKILLS_PATH environment variable
- Check file permissions
- Review Claude Desktop logs

## Manual Installation

If MCP is unavailable, skills work as standalone markdown files.

---

**Note**: MCP Server integration requires Claude Desktop. CLI users can access files directly.
