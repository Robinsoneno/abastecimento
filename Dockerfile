FROM n8nio/n8n:latest

# Instala o node Baileys
RUN npm install -g @jazario/n8n-nodes-bailey

# Copia o script de inicialização
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
