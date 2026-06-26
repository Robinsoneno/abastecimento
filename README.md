 Pré-requisitos
Hardware e Sistema
Docker e Docker Compose instalados

Mínimo 1GB de RAM disponível

10GB de espaço em disco

Software
Docker Engine 20.10+

Docker Compose 2.0+

Git (para clonar o repositório)

Contas
Número de WhatsApp válido para pareamento

Conexão com internet para download de imagens

🚀 Instalação e Configuração
1. Clone o Repositório
bash
git clone https://github.com/seu-usuario/abastecimento-bot.git
cd abastecimento-bot
2. Configure as Variáveis de Ambiente
Crie o arquivo .env:

bash
cp .env.example .env
Edite o .env com suas configurações:

env
# N8N
N8N_ENCRYPTION_KEY=8uJm7vYh2xNf4QsW9ZcR3tGp5LkD6aB0

# Postgres
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin123
POSTGRES_DB=abastecimento

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# API
API_PORT=8001
3. Inicie os Serviços
bash
docker-compose up -d
4. Verifique os Logs
bash
docker-compose logs -f n8n
5. Acesse o n8n
bash
http://localhost:5678
6. Importe o Workflow
No n8n, clique em "Workflows" → "Import"

Cole o JSON do workflow (disponível em /workflows/abastecimento.json)

Configure as credenciais:

PostgreSQL: Host postgres, Database abastecimento, User admin, Password admin123

Redis: Host redis, Port 6379

Baileys: Pasta de sessão /home/node/.n8n/sessions

7. Ative o Workflow
Clique em "Active" no workflow

O sistema gerará um código de pareamento de 8 dígitos

8. Conecte ao WhatsApp
No WhatsApp do celular:

Vá em "Configurações" → "Dispositivos Vinculados"

Clique em "Vincular um dispositivo"

Escolha "Vincular com número de telefone"

Digite o código de 8 dígitos

Pronto! O sistema está conectado.

📱 Comandos Disponíveis
Comando	Descrição	Exemplo
/abast	Inicia novo abastecimento	/abast
/status	Mostra estatísticas do sistema	/status
/ultimos	Mostra seus últimos abastecimentos	/ultimos
/ajuda	Lista todos os comandos disponíveis	/ajuda
🔄 Fluxo de Abastecimento
Passo a Passo
Iniciar Abastecimento

text
Motorista: /abast
Bot: "Informe a PLACA do veículo (ex: ABC1D23 ou ABC1234)"
Informar Placa

text
Motorista: ABC1D23
Bot: "Placa ABC1D23 registrada! Agora informe a KM ATUAL"
Informar KM

text
Motorista: 15234
Bot: "KM 15234 registrada! Agora informe a QUANTIDADE DE LITROS"
Informar Litros

text
Motorista: 45.5
Bot: "45.5 litros registrados! Agora envie a FOTO DO ODÔMETRO"
Enviar Foto do Odômetro

text
Motorista: 📸 (envia imagem)
Bot: "Foto do odômetro registrada! Agora envie a FOTO DO ABASTECIMENTO"
Enviar Foto do Abastecimento

text
Motorista: 📸 (envia imagem)
Bot: "✅ ABASTECIMENTO REGISTRADO COM SUCESSO!"
🌐 API REST
O sistema expõe uma API REST para consulta de dados (opcional, via código adicional).

Endpoints
Método	Endpoint	Descrição
GET	/api/abastecimentos	Lista todos os abastecimentos
GET	/api/abastecimentos/:id	Busca abastecimento por ID
GET	/api/abastecimentos/placa/:placa	Busca por placa
GET	/api/abastecimentos/usuario/:usuario	Busca por usuário
GET	/api/status	Estatísticas do sistema
GET	/api/media/:filename	Acessa as fotos salvas
Exemplos
bash
# Listar todos
curl http://localhost:8001/api/abastecimentos

# Buscar por placa
curl http://localhost:8001/api/abastecimentos/placa/ABC1D23

# Status do sistema
curl http://localhost:8001/api/status
📊 Estrutura do Banco de Dados
Tabela abastecimentos
Coluna	Tipo	Descrição
id	UUID	Chave primária (auto gerada)
usuario_id	VARCHAR(50)	ID do WhatsApp do usuário
usuario_nome	VARCHAR(100)	Nome do usuário
placa	VARCHAR(8)	Placa do veículo
km	INTEGER	KM atual
litros	DECIMAL(10,2)	Quantidade de litros
foto_odometro	TEXT	Caminho da foto do odômetro
foto_abastecimento	TEXT	Caminho da foto do abastecimento
latitude	DECIMAL(10,8)	Localização (opcional)
longitude	DECIMAL(11,8)	Localização (opcional)
observacao	TEXT	Observações (opcional)
status	VARCHAR(20)	Status do abastecimento
criado_em	TIMESTAMP	Data de criação
atualizado_em	TIMESTAMP	Última atualização
Índices
idx_abastecimentos_usuario_id

idx_abastecimentos_placa

idx_abastecimentos_criado_em

Views
vw_resumo_abastecimentos - Resumo por placa

Funções
registrar_abastecimento() - Insere abastecimento e atualiza usuário

Redis Keys
Key	TTL	Descrição
flow:{userId}	15 min	Estado do fluxo do usuário
rate:{userId}	60s	Rate limit
user:{userId}	1h	Cache de dados do usuário
lock:{resource}	10s	Lock para operações concorrentes
🧹 Manutenção
Logs
bash
# Ver logs do n8n
docker-compose logs -f n8n

# Ver logs do PostgreSQL
docker-compose logs -f postgres

# Ver logs do Redis
docker-compose logs -f redis
Backup do Banco
bash
# Backup completo
docker-compose exec postgres pg_dump -U admin abastecimento > backup.sql

# Restaurar
docker-compose exec -T postgres psql -U admin abastecimento < backup.sql
Backup das Sessões
bash
# Backup das sessões do WhatsApp
tar -czf sessions-backup.tar.gz sessions/
Limpeza de Dados Antigos
sql
-- Deleta abastecimentos com mais de 1 ano
DELETE FROM abastecimentos 
WHERE criado_em < NOW() - INTERVAL '1 year';
Reiniciar Sessão
bash
# Remove sessão e reinicia
docker-compose down
rm -rf sessions/
docker-compose up -d
🐛 Solução de Problemas
Erro: "Failed to connect to WhatsApp"
Solução:

Verifique se o código de pareamento está correto

Remova a pasta sessions/ e reconecte

Verifique se o número está ativo no WhatsApp

Erro: "Redis connection refused"
Solução:

bash
docker-compose restart redis
Erro: "PostgreSQL connection failed"
Solução:

bash
docker-compose logs postgres
docker-compose restart postgres
Erro: "Rate limit exceeded"
Solução:
O sistema tem rate limit de 5 mensagens por minuto. Aguarde 60 segundos.

Workflow não responde
Solução:

Verifique se o workflow está ativo

Verifique os logs do n8n

Reinicie o workflow

Navegador não exibe QR Code
Solução:
O sistema usa pareamento (código de 8 dígitos), não QR Code. Siga as instruções do terminal.

🔒 Segurança
Recomendações
Altere as senhas padrão no .env

Use HTTPS em produção

Faça backup regular do banco de dados

Monitore logs para atividades suspeitas

Mantenha o sistema atualizado

Criptografia
n8n usa N8N_ENCRYPTION_KEY para dados sensíveis

Credenciais do WhatsApp salvas localmente na pasta sessions

Recomendado usar volumes criptografados para sessions/

🤝 Contribuição
Fork o projeto

Crie sua branch (git checkout -b feature/AmazingFeature)

Commit suas mudanças (git commit -m 'Add some AmazingFeature')

Push para a branch (git push origin feature/AmazingFeature)

Abra um Pull Request

📄 Licença
Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.

📞 Suporte
Documentação: n8n.io/docs

Baileys: github.com/WhiskeySockets/Baileys

Issues: Abra um issue no repositório

⚡ Quick Start
bash
# Clone
git clone https://github.com/seu-usuario/abastecimento-bot.git
cd abastecimento-bot

# Configure
cp .env.example .env
# Edite .env com suas configurações

# Inicie
docker-compose up -d

# Acesse
http://localhost:5678

# Importe o workflow e conecte o WhatsApp
# Código de pareamento aparecerá nos logs
docker-compose logs -f n8n
