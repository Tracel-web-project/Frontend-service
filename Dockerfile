# ===== Stage 1: Build stage =====
FROM node:18-alpine AS build_stage

WORKDIR /app

# Copy package.json and lock file
COPY package*.json ./

# Install dependencies (clean reproducible install)
RUN npm ci

# Copy rest of the project
COPY . .

# Build React app (requires devDependencies + REACT_APP_* vars)
RUN npm run build

# ===== Stage 2: Runtime stage =====
FROM nginx:alpine

WORKDIR /usr/share/nginx/html

# Clean default nginx assets
RUN rm -rf ./*

# Copy built React app
COPY --from=build_stage /app/build .

# Copy custom nginx config (must exist in repo)
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
