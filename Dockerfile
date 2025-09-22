# ===== Stage 1: Build stage =====
FROM node:20-alpine AS build_stage

WORKDIR /app

# Copy package.json and lock file first for better caching
COPY package*.json ./

# Install exact deps based on package-lock.json
RUN npm install

# Copy rest of the source code
COPY . .

# Build React app
RUN npm run build

# ===== Stage 2: Runtime stage =====
FROM nginx:alpine

WORKDIR /usr/share/nginx/html

# Remove default nginx assets
RUN rm -rf ./*

# Copy built React app from build stage
COPY --from=build_stage /app/build .

# Copy custom nginx config (make sure nginx.conf exists in repo root)
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

