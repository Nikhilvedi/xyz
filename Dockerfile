FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies for build)
RUN npm ci

# Copy source code
COPY . .

# Build CSS
RUN npm run build

# Remove dev dependencies for smaller image
RUN npm prune --production

# Expose the port Cloud Run will use
EXPOSE 8080

# Set environment variable for Cloud Run
ENV PORT=8080

# Start the application
CMD ["npm", "start"]
