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

# Copia o node compilado DIRETAMENTE para o diretório de custom nodes
# O n8n v2.x carrega nodes de /usr/local/lib/node_modules automaticamente
COPY --from=builder /tmp/build/node_modules/@jazario /usr/local/lib/node_modules/@jazario

# Ajusta permissões
RUN chown -R node:node /usr/local/lib/node_modules/@jazario

# Habilita pacotes da comunidade
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

USER node

# NÃO sobrescreva ENTRYPOINT ou CMD - use o padrão do n8n
