# Multi-Machine Docker Setup

This guide explains how to set up Telegram MCP server on one machine and access it from multiple machines on the same network.

## 🔒 Security Notice

**By default, this server runs in secure localhost-only mode.** The multi-machine setup requires explicit configuration to expose network access. Always consider firewall rules and network security when exposing services.

## 🚀 Quick Start

### Server Machine Setup

1. **Clone and prepare the repository:**
   ```bash
   git clone https://github.com/jason1365/telegram-mcp
   cd telegram-mcp
   ```

2. **Configure environment for TCP mode:**
   ```bash
   cp .env.example .env
   # Edit .env with your Telegram credentials (see Session String Generation below)
   ```

3. **Generate Telegram Session String (Required):**

   ```bash
   # Using the included generator
   python session_string_generator.py
   
   # OR using Docker (no local dependencies needed):
   docker run -it --rm -v $(pwd):/app -w /app python:3.13-alpine sh -c "pip install telethon python-dotenv && python session_string_generator.py"
   ```

   **What you'll need:**
   - Your `TELEGRAM_API_ID` and `TELEGRAM_API_HASH` from https://my.telegram.org/apps
   - Your phone number (with country code, e.g., +1234567890)
   - The verification code sent to your Telegram app

4. **For network access, set these in your .env:**
   ```env
   MCP_SERVER_MODE=tcp
   MCP_SERVER_HOST=0.0.0.0
   MCP_SERVER_PORT=8765
   ```

4. **Start the server with proxy support:**
   
   ⚠️ **Important**: Use `docker-compose.proxy.yml` for full client compatibility!
   
   ```bash
   # Run in foreground (logs visible)
   docker-compose -f docker-compose.proxy.yml up --build
   
   # OR run in background (detached)
   docker-compose -f docker-compose.proxy.yml up --build -d
   
   # Check if running
   docker-compose -f docker-compose.proxy.yml ps
   
   # Stop the server
   docker-compose -f docker-compose.proxy.yml down
   ```
   
   This starts TWO containers:
   - `telegram-mcp-main`: Main server on port 8765 (Streamable HTTP)
   - `telegram-mcp-proxy`: Client proxy on port 8766 (TCP bridge)

### Client Machine Setup

**No Docker required on client machine!** The server runs both the main service and a proxy for client compatibility.

#### Simple Node.js Connection (Recommended)

Configure Claude Desktop to connect to the proxy server on port 8766:

**For Claude Desktop** (`claude_desktop_config.json`):
```json
{
  "mcpServers": {
    "telegram": {
      "command": "node",
      "args": ["-e", "const net = require('net'); const client = net.createConnection(8766, '192.168.1.100'); process.stdin.pipe(client); client.pipe(process.stdout);"],
      "env": {}
    }
  }
}
```

**For Cursor** (`mcp.json`):
```json
{
  "mcpServers": {
    "telegram": {
      "command": "node",
      "args": ["-e", "const net = require('net'); const client = net.createConnection(8766, '192.168.1.100'); process.stdin.pipe(client); client.pipe(process.stdout);"]
    }
  }
}
```

Replace `192.168.1.100` with your server machine's IP address.

**Why port 8766?** The server runs a proxy on port 8766 that translates between Claude Desktop's TCP connection and the main server's HTTP protocol, solving transport compatibility issues.

## 📋 Configuration Options

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MCP_SERVER_MODE` | `stdio` | Set to `tcp` for network access, `proxy` for proxy mode |
| `MCP_SERVER_HOST` | `127.0.0.1` | Bind address (use `0.0.0.0` for network access) |
| `MCP_SERVER_PORT` | `8765` | TCP port for network mode |
| `PROXY_TARGET_HOST` | `127.0.0.1` | Target server host (for proxy mode) |
| `PROXY_TARGET_PORT` | `8765` | Target server port (for proxy mode) |

### Docker Compose Files

- `docker-compose.yml` - Original secure setup (localhost only)  
- `docker-compose.tcp.yml` - Network-accessible setup with port exposure
- `docker-compose.proxy.yml` - **Recommended**: Dual setup with main server + client proxy

## 🛡️ Security Considerations

1. **Firewall**: Configure firewall rules to restrict access to trusted networks
2. **Network**: Use on trusted networks only
3. **Authentication**: The MCP protocol itself doesn't include authentication
4. **Monitoring**: Monitor network connections and server logs

## 🔧 Troubleshooting

### Connection Issues
- Verify servers are running: `docker ps`
- Check main server logs: `docker logs telegram-mcp-main`
- Check proxy server logs: `docker logs telegram-mcp-proxy`
- Test main server: `telnet <server-ip> 8765`
- Test proxy server: `telnet <server-ip> 8766`
- Verify firewall allows ports 8765 and 8766

### Client Configuration
- Ensure correct server IP address in client config
- Restart client application after configuration changes
- Check client logs for connection errors

## 📝 Example Complete Setup

1. **Server (.env):**
   ```env
   TELEGRAM_API_ID=123456
   TELEGRAM_API_HASH=your_hash_here
   TELEGRAM_SESSION_STRING=your_session_string
   MCP_SERVER_MODE=tcp
   MCP_SERVER_HOST=0.0.0.0
   MCP_SERVER_PORT=8765
   ```

2. **Start server:**
   ```bash
   docker-compose -f docker-compose.tcp.yml up -d
   ```

3. **Client config (replace IP):**
   ```json
   {
     "mcpServers": {
       "telegram": {
         "command": "node",
         "args": ["-e", "const net = require('net'); const client = net.createConnection(8765, '192.168.1.100'); process.stdin.pipe(client); client.pipe(process.stdout);"]
       }
     }
   }
   ```

## 🔄 Switching Between Modes

To switch from network mode back to local mode:
1. Change `MCP_SERVER_MODE=stdio` in `.env`
2. Use original `docker-compose.yml`: `docker-compose up --build`
3. Update client configuration to use local setup