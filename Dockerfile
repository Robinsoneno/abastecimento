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

# Copia o node compilado para diretório temporário
RUN mkdir -p /opt/custom-nodes/@jazario
COPY --from=builder /tmp/build/node_modules/@jazario /opt/custom-nodes/@jazario
RUN chown -R node:node /opt/custom-nodes

# Cria script de inicialização no diretório do n8n
RUN echo '#!/bin/sh' > /home/node/.n8n/init-custom-nodes.sh && \
    echo '# Copia custom nodes se não existirem' >> /home/node/.n8n/init-custom-nodes.sh && \
    echo 'mkdir -p /home/node/.n8n/custom' >> /home/node/.n8n/init-custom-nodes.sh && \
    echo 'if [ ! -d "/home/node/.n8n/custom/@jazario" ]; then' >> /home/node/.n8n/init-custom-nodes.sh && \
    echo '  cp -r /opt/custom-nodes/@jazario /home/node/.n8n/custom/' >> /home/node/.n8n/init-custom-nodes.sh && \
    echo '  chown -R node:node /home/node/.n8n/custom' >> /home/node/.n8n/init-custom-nodes.sh && \
    echo 'fi' >> /home/node/.n8n/init-custom-nodes.sh && \
    chmod +x /home/node/.n8n/init-custom-nodes.sh && \
    chown node:node /home/node/.n8n/init-custom-nodes.sh

ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

# NÃO sobrescreva ENTRYPOINT - use o padrão do n8n
USER node
