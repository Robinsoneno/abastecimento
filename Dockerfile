# ============================================
# STAGE 1: Compilar o módulo nativo (Node 22 necessário para isolated-vm)
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

# Copia o node compilado para o diretório temporário
COPY --from=builder /tmp/build/node_modules/@jazario /opt/custom-nodes/@jazario

# Cria script de inicialização que copia os nodes para o volume
RUN echo '#!/bin/sh' > /entrypoint-custom.sh && \
    echo 'if [ -d "/opt/custom-nodes/@jazario" ] && [ ! -d "/home/node/.n8n/nodes/@jazario" ]; then' >> /entrypoint-custom.sh && \
    echo '  mkdir -p /home/node/.n8n/nodes' >> /entrypoint-custom.sh && \
    echo '  cp -r /opt/custom-nodes/@jazario /home/node/.n8n/nodes/' >> /entrypoint-custom.sh && \
    echo '  chown -R node:node /home/node/.n8n/nodes' >> /entrypoint-custom.sh && \
    echo 'fi' >> /entrypoint-custom.sh && \
    echo 'exec "$@"' >> /entrypoint-custom.sh && \
    chmod +x /entrypoint-custom.sh

# Ajusta permissões
RUN chown -R node:node /opt/custom-nodes

ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

# Usa o script customizado como entrypoint
ENTRYPOINT ["/entrypoint-custom.sh"]
CMD ["n8n", "start"]

USER node
