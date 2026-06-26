FROM node:22-alpine AS builder

RUN apk add --no-cache python3 make g++ gcc git
RUN npm install -g @jazario/n8n-nodes-bailey

FROM n8nio/n8n:latest

USER root

COPY --from=builder /usr/local/lib/node_modules/@jazario /usr/local/lib/node_modules/@jazario

# Instala como root no diretório do n8n
RUN cd /usr/local/lib/node_modules/n8n && \
    npm install @jazario/n8n-nodes-bailey --no-save --unsafe-perm

ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

USER node
