FROM node:26-alpine
RUN apk add --no-cache iproute2 su-exec iptables
WORKDIR /app

COPY package.json ./
COPY server.js ./
COPY database.js ./
COPY index.html ./
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && chown -R node:node /app

EXPOSE 9000
CMD ["/entrypoint.sh"]