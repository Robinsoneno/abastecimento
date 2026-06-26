# ============================================
# STAGE 1: Compilar o módulo nativo
# ============================================
FROM node:22-alpine AS builder

RUN apk add --no-cache python3 make g++ gcc git
RUN npm install -g @jazario/n8n-nodes-bailey

# ============================================
# STAGE 2: Imagem final do n8n
# ============================================
FROM n8nio/n8n:latest

USER root

# Copia o pacote compilado do builder
COPY --from=builder /usr/local/lib/node_modules/@jazario /usr/local/lib/node_modules/@jazario

# Configura variáveis de ambiente para o n8n reconhecer o node
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true
ENV NODE_PATH=/usr/local/lib/node_modules

USER node
