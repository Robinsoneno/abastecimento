# ============================================
# STAGE 1: Compilar o módulo nativo
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

# Cria o diretório de custom nodes e copia os arquivos
# O n8n v2.x lê de /home/node/.n8n/custom
RUN mkdir -p /home/node/.n8n/custom/@jazario
COPY --from=builder /tmp/build/node_modules/@jazario/n8n-nodes-bailey /home/node/.n8n/custom/@jazario/n8n-nodes-bailey

# Ajusta permissões
RUN chown -R node:node /home/node/.n8n

ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

# NÃO sobrescreva ENTRYPOINT ou CMD
USER node
