# ============================================
# STAGE 1: Compilar o módulo nativo
# ============================================
FROM node:22-alpine AS builder

RUN apk add --no-cache python3 make g++ gcc git
WORKDIR /tmp/bailey
RUN npm init -y
RUN npm install @jazario/n8n-nodes-bailey

# ============================================
# STAGE 2: Imagem final do n8n
# ============================================
FROM n8nio/n8n:latest

USER root

# Copia o node compilado para o diretório de custom nodes do n8n
COPY --from=builder /tmp/bailey/node_modules/@jazario /usr/local/lib/node_modules/@jazario

# Cria link simbólico no diretório do n8n
RUN mkdir -p /usr/local/lib/node_modules/n8n/node_modules
RUN ln -s /usr/local/lib/node_modules/@jazario /usr/local/lib/node_modules/n8n/node_modules/@jazario || true

# Configura variáveis de ambiente
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true
ENV NODE_PATH=/usr/local/lib/node_modules:/usr/local/lib/node_modules/n8n/node_modules

# Volta para node
USER node
