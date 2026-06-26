FROM n8nio/n8n:latest

# 1. Muda para root para instalar pacotes do sistema e npm
USER root

# 2. Instala Python e ferramentas de compilação C++ (necessário para o node-gyp)
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 3. Instala o nó comunitário do Baileys
RUN npm install -g @jazario/n8n-nodes-bailey

# 4. (Opcional) Remove as ferramentas de compilação para economizar espaço em disco
# RUN apt-get purge -y --auto-remove python3 make g++ gcc

# 5. Volta para o usuário 'node' por segurança
USER node

# 6. Habilita pacotes comunitários
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true
