FROM n8nio/n8n:latest

USER root

# Apenas habilita pacotes da comunidade
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

USER node
