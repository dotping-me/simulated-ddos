FROM node:26-alpine
WORKDIR /app

COPY package.json ./
COPY server.js ./
COPY database.js ./
COPY index.html ./

RUN chown -R node:node /app

USER node
EXPOSE 9000

CMD ["node", "server.js"]