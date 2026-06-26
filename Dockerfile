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

# Copia o node compilado para o diretório CORRETO de custom nodes
# O n8n carrega nodes de /home/node/.n8n/custom/
RUN mkdir -p /opt/custom-nodes/@jazario
COPY --from=builder /tmp/build/node_modules/@jazario /opt/custom-nodes/@jazario
RUN chown -R node:node /opt/custom-nodes

# Cria script de inicialização que copia os nodes para o volume
RUN echo '#!/bin/sh' > /docker-entrypoint-init.sh && \
    echo '# Copia custom nodes para o diretório correto' >> /docker-entrypoint-init.sh && \
    echo 'mkdir -p /home/node/.n8n/custom' >> /docker-entrypoint-init.sh && \
    echo 'if [ ! -d "/home/node/.n8n/custom/@jazario" ]; then' >> /docker-entrypoint-init.sh && \
    echo '  cp -r /opt/custom-nodes/@jazario /home/node/.n8n/custom/' >> /docker-entrypoint-init.sh && \
    echo '  chown -R node:node /home/node/.n8n/custom' >> /docker-entrypoint-init.sh && \
    echo 'fi' >> /docker-entrypoint-init.sh && \
    echo '# Executa o entrypoint original do n8n' >> /docker-entrypoint-init.sh && \
    echo 'exec /docker-entrypoint.sh "$@"' >> /docker-entrypoint-init.sh && \
    chmod +x /docker-entrypoint-init.sh

ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

ENTRYPOINT ["/docker-entrypoint-init.sh"]
CMD ["n8n", "start"]

USER node
