# ============================================
# STAGE 1: Compilar e baixar tudo
# ============================================
FROM node:22-alpine AS builder

RUN apk add --no-cache python3 make g++ gcc git
WORKDIR /tmp/build
RUN npm init -y
# Instala o pacote e todas as dependências dele
RUN npm install @jazario/n8n-nodes-bailey

# ============================================
# STAGE 2: Imagem final do n8n
# ============================================
FROM n8nio/n8n:latest

USER root

# 1. Copia o node customizado para a pasta correta do n8n v2
RUN mkdir -p /home/node/.n8n/custom/@jazario
COPY --from=builder /tmp/build/node_modules/@jazario/n8n-nodes-bailey /home/node/.n8n/custom/@jazario/n8n-nodes-bailey

# 2. CRÍTICO: Copia as dependências (node_modules) para o diretório global do Node
# Isso garante que o '@whiskeysockets/baileys' seja encontrado pelo loader isolado
COPY --from=builder /tmp/build/node_modules /usr/local/lib/node_modules

# 3. Ajusta permissões para o usuário node
RUN chown -R node:node /home/node/.n8n /usr/local/lib/node_modules

# Habilita pacotes da comunidade
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

USER node
