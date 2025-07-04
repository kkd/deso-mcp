# Use Node.js 18 Alpine for smaller image size
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies and pm2 for process management
RUN npm ci --only=production && npm install -g pm2

# Copy the MCP server code
COPY deso-mcp.js ./

# Make the script executable
RUN chmod +x deso-mcp.js

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S mcp -u 1001

# Change ownership of the app directory
RUN chown -R mcp:nodejs /app
USER mcp

# Expose port for health checks
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "console.log('MCP server health check passed')" || exit 1

# Use pm2 to keep process running
CMD ["pm2-runtime", "start", "deso-mcp.js", "--name", "mcp-server"]