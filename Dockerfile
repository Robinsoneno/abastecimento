# ============================================
# STAGE 1: Compilar o módulo nativo (Node 22 necessário)
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

# Copia o node compilado do stage anterior
COPY --from=builder /tmp/build/node_modules/@jazario /opt/custom-nodes/@jazario

# Ajusta permissões
RUN chown -R node:node /opt/custom-nodes

# Cria script de inicialização que copia os nodes para o volume
RUN echo '#!/bin/sh' > /docker-entrypoint-init.sh && \
    echo '# Copia custom nodes se não existirem no volume' >> /docker-entrypoint-init.sh && \
    echo 'if [ -d "/opt/custom-nodes/@jazario" ] && [ ! -d "/home/node/.n8n/nodes/@jazario" ]; then' >> /docker-entrypoint-init.sh && \
    echo '  mkdir -p /home/node/.n8n/nodes' >> /docker-entrypoint-init.sh && \
    echo '  cp -r /opt/custom-nodes/@jazario /home/node/.n8n/nodes/' >> /docker-entrypoint-init.sh && \
    echo '  chown -R node:node /home/node/.n8n/nodes' >> /docker-entrypoint-init.sh && \
    echo 'fi' >> /docker-entrypoint-init.sh && \
    echo '# Executa o entrypoint original do n8n' >> /docker-entrypoint-init.sh && \
    echo 'exec /docker-entrypoint.sh "$@"' >> /docker-entrypoint-init.sh && \
    chmod +x /docker-entrypoint-init.sh

ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

# Usa o script customizado como entrypoint
ENTRYPOINT ["/docker-entrypoint-init.sh"]
CMD ["n8n", "start"]

USER node
