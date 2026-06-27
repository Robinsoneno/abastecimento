# ============================================
# STAGE 1: Compilar e baixar TUDO
# ============================================
FROM node:22-alpine AS builder

RUN apk add --no-cache python3 make g++ gcc git
WORKDIR /tmp/build
RUN npm init -y
RUN npm install @jazario/n8n-nodes-bailey

# ============================================
# STAGE 2: Imagem final do n8n
# ============================================
FROM n8nio/n8n:latest

USER root

# 1. Copia o plugin para o diretório correto do n8n v2
RUN mkdir -p /home/node/.n8n/custom/@jazario
COPY --from=builder /tmp/build/node_modules/@jazario/n8n-nodes-bailey /home/node/.n8n/custom/@jazario/n8n-nodes-bailey

# 2. Copia TODAS as dependências para o diretório global do Node
COPY --from=builder /tmp/build/node_modules /usr/local/lib/node_modules

# 3. Cria diretório de sessões com permissões corretas
RUN mkdir -p /home/node/.n8n/sessions && \
    chown -R node:node /home/node/.n8n/sessions

# 4. Ajusta permissões gerais
RUN chown -R node:node /home/node/.n8n /usr/local/lib/node_modules

ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

USER node
