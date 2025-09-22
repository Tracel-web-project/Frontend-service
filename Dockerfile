# ===== Stage 1: Build Stage =====
FROM node:18-alpine AS build_stage

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apk add --no-cache python3 make g++

# Copy package files
COPY package*.json ./

# Install exact dependencies
RUN npm ci

# Copy the rest of the source code
COPY . .

# Build React app
RUN npm run build

# ===== Stage 2: Runtime Stage =====
FROM nginx:alpine

# Remove default Nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy built React app from build stage
COPY --from=build_stage /app/build /usr/share/nginx/html

# Copy custom Nginx configuration (if you have one)
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port
EXPOSE 80

# Start Nginx
ENTRYPOINT ["nginx", "-g", "daemon off;"]
