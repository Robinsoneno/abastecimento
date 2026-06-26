# ============================================
# STAGE 1: Compilar o módulo nativo
# ============================================
FROM node:22-alpine AS builder

# Instala ferramentas de compilação
RUN apk add --no-cache python3 make g++ gcc git

# Instala o pacote do Baileys globalmente
RUN npm install -g @jazario/n8n-nodes-bailey

# ============================================
# STAGE 2: Imagem final do n8n
# ============================================
FROM n8nio/n8n:latest

# Muda para root temporariamente
USER root

# Copia o módulo compilado do stage anterior
COPY --from=builder /usr/local/lib/node_modules/@jazario /usr/local/lib/node_modules/@jazario

# Volta para o usuário node
USER node

# Habilita pacotes comunitários
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true
