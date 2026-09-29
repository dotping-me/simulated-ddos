FROM node:26-alpine
WORKDIR /app

COPY package.json ./
COPY server.js ./

EXPOSE 8081
USER node

CMD ["node", "server.js"]