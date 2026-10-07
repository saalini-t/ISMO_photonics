FROM node:20-alpine

WORKDIR /app

# Install openssl and dependencies
RUN apk add --no-cache openssl

COPY package*.json ./
RUN npm install

# Copy Prisma schema and generate client
COPY prisma ./prisma/
RUN npx prisma generate

# Copy source code
COPY . .

EXPOSE 3000

CMD ["node", "src/server.js"]
