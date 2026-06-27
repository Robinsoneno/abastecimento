FROM n8nio/n8n:1.123.16

USER root

# Instala Python e ferramentas de build
RUN apk add --no-cache python3 make g++ gcc git

# Instala o node Bailey
RUN cd /home/node/.n8n && \
    npm install @jazario/n8n-nodes-bailey --save && \
    chown -R node:node /home/node/.n8n

USER node
