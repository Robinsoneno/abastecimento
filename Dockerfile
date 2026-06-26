FROM n8nio/n8n:latest

# 1. Muda para o usuário root temporariamente para instalar pacotes globais
USER root

# Instala o nó comunitário do Baileys
RUN npm install -g @jazario/n8n-nodes-bailey

# 2. Volta para o usuário 'node' por segurança (padrão da imagem)
USER node

# 3. Habilita pacotes comunitários via variável de ambiente
# Isso substitui a necessidade do seu entrypoint.sh customizado
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

# O CMD padrão da imagem n8nio/n8n já inicia o n8n corretamente.
# Não sobrescreva o ENTRYPOINT ou CMD.
