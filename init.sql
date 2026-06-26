-- Cria banco para o n8n (se não existir)
CREATE DATABASE n8n;

-- Conecta ao banco principal
\c abastecimento;

-- ============================================
-- TABELA DE ABASTECIMENTOS
-- ============================================
CREATE TABLE IF NOT EXISTS abastecimentos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id VARCHAR(50) NOT NULL,
    usuario_nome VARCHAR(100) NOT NULL,
    placa VARCHAR(8) NOT NULL,
    km INTEGER NOT NULL,
    litros DECIMAL(10,2) NOT NULL,
    foto_odometro TEXT,
    foto_abastecimento TEXT,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    observacao TEXT,
    status VARCHAR(20) DEFAULT 'concluido',
    criado_em TIMESTAMP DEFAULT NOW(),
    atualizado_em TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_abastecimentos_usuario_id ON abastecimentos(usuario_id);
CREATE INDEX IF NOT EXISTS idx_abastecimentos_placa ON abastecimentos(placa);
CREATE INDEX IF NOT EXISTS idx_abastecimentos_criado_em ON abastecimentos(criado_em);

-- ============================================
-- TABELA DE USUÁRIOS
-- ============================================
CREATE TABLE IF NOT EXISTS usuarios (
    id VARCHAR(50) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    ultimo_contato TIMESTAMP,
    criado_em TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_usuarios_ultimo_contato ON usuarios(ultimo_contato);

-- ============================================
-- TABELA DE SESSÕES DO WHATSAPP
-- ============================================
CREATE TABLE IF NOT EXISTS whatsapp_sessions (
    id VARCHAR(50) PRIMARY KEY,
    session_data JSONB NOT NULL,
    criado_em TIMESTAMP DEFAULT NOW(),
    atualizado_em TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- TRIGGER PARA ATUALIZAR atualizado_em
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_abastecimentos_updated_at 
    BEFORE UPDATE ON abastecimentos 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VIEW DE RESULTADOS
-- ============================================
CREATE OR REPLACE VIEW vw_resumo_abastecimentos AS
SELECT 
    placa,
    COUNT(*) as total_abastecimentos,
    SUM(litros) as total_litros,
    AVG(litros) as media_litros,
    MAX(km) as km_atual,
    MAX(criado_em) as ultimo_abastecimento
FROM abastecimentos
GROUP BY placa
ORDER BY total_abastecimentos DESC;

-- ============================================
-- FUNÇÃO PARA INSERIR ABASTECIMENTO
-- ============================================
CREATE OR REPLACE FUNCTION registrar_abastecimento(
    p_usuario_id VARCHAR,
    p_usuario_nome VARCHAR,
    p_placa VARCHAR,
    p_km INTEGER,
    p_litros DECIMAL,
    p_foto_odometro TEXT DEFAULT NULL,
    p_foto_abastecimento TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_id UUID;
BEGIN
    -- Insere o abastecimento
    INSERT INTO abastecimentos (
        usuario_id, usuario_nome, placa, km, litros, 
        foto_odometro, foto_abastecimento
    ) VALUES (
        p_usuario_id, p_usuario_nome, UPPER(p_placa), p_km, p_litros,
        p_foto_odometro, p_foto_abastecimento
    ) RETURNING id INTO v_id;

    -- Atualiza usuário
    INSERT INTO usuarios (id, nome, ultimo_contato)
    VALUES (p_usuario_id, p_usuario_nome, NOW())
    ON CONFLICT (id) 
    DO UPDATE SET 
        nome = EXCLUDED.nome,
        ultimo_contato = NOW();

    RETURN v_id;
END;
$$ LANGUAGE plpgsql;
