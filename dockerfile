# Patient Service - Multi-stage build
# - standalone: for CI health checks (plain Node.js, long-running server)
# - lambda: for AWS Lambda deployment (Lambda runtime + Web Adapter)

# Stage 1: Standalone image for health checks (docker run, CI)
FROM node:20-slim AS standalone
WORKDIR /var/task
COPY package*.json ./
RUN npm ci --omit=dev
COPY patient-service.js ./
ENV PORT=8080
EXPOSE 8080
CMD ["node", "patient-service.js"]

# Stage 2: Lambda deployment image
FROM public.ecr.aws/lambda/nodejs:20 AS lambda

# Install Lambda Web Adapter
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.8.4 /lambda-adapter /opt/extensions/lambda-adapter

WORKDIR /var/task

# Copy package files
COPY package*.json ./

# Install production dependencies
RUN npm ci --omit=dev

# Copy application code
COPY patient-service.js ./

# Lambda expects port 8080
ENV PORT=8080
ENV AWS_LWA_INVOKE_MODE=response

# Run the Express app (Lambda Web Adapter proxies requests to it)
CMD ["node", "patient-service.js"]
