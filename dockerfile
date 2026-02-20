# Patient Service - Lambda Container Image
# Uses AWS Lambda Web Adapter for Express.js on Lambda

FROM public.ecr.aws/lambda/nodejs:20 AS base

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
