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

# Cria diretório temporário para os custom nodes
RUN mkdir -p /opt/custom-nodes/@jazario

# Copia o node compilado
COPY --from=builder /tmp/build/node_modules/@jazario /opt/custom-nodes/@jazario

# Ajusta permissões
RUN chown -R node:node /opt/custom-nodes

# Habilita pacotes da comunidade
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

# Volta para o usuário node
USER node

# NÃO sobrescreva o ENTRYPOINT ou CMD
# O n8n já tem seu próprio entrypoint configurado
