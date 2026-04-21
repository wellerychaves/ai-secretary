#!/bin/bash
# =============================================================================
# Script de Inicialização do PostgreSQL
# Secretária Eletrônica IA - WhatsApp
# =============================================================================
#
# PROPÓSITO:
# Este script é executado AUTOMATICAMENTE na primeira vez que o container
# PostgreSQL é criado. Ele configura:
# 1. Bancos de dados separados para cada serviço (isolamento)
# 2. Usuários dedicados com permissões apropriadas
# 3. Extensões necessárias do PostgreSQL
#
# QUANDO EXECUTA:
# - Apenas na PRIMEIRA inicialização do volume postgres_data
# - Se o volume já existe, este script NÃO executa novamente
# - Para reexecutar, é necessário remover o volume: docker volume rm <volume_name>
#
# =============================================================================

set -e  # Interrompe execução se qualquer comando falhar

# Função auxiliar para logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "🚀 Iniciando configuração dos bancos de dados..."

# =============================================================================
# CHATWOOT - Plataforma de Atendimento
# =============================================================================
log "📱 Configurando banco do Chatwoot..."

# Criar usuário com privilégios de superuser (necessário para extensões)
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Criar usuário (se não existir)
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_user WHERE usename = '${CHATWOOT_POSTGRES_USER}') THEN
            CREATE USER ${CHATWOOT_POSTGRES_USER} WITH SUPERUSER PASSWORD '${CHATWOOT_POSTGRES_PASSWORD}';
            RAISE NOTICE 'Usuário ${CHATWOOT_POSTGRES_USER} criado com sucesso';
        ELSE
            RAISE NOTICE 'Usuário ${CHATWOOT_POSTGRES_USER} já existe';
        END IF;
    END
    \$\$;

    -- Criar banco de dados (se não existir)
    SELECT 'CREATE DATABASE ${CHATWOOT_POSTGRES_DB}'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${CHATWOOT_POSTGRES_DB}')\gexec

    -- Conceder privilégios
    GRANT ALL PRIVILEGES ON DATABASE ${CHATWOOT_POSTGRES_DB} TO ${CHATWOOT_POSTGRES_USER};
EOSQL

# Configurar extensões obrigatórias do Chatwoot
log "🔧 Instalando extensões do Chatwoot..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$CHATWOOT_POSTGRES_DB" <<-EOSQL
    -- pg_trgm: para busca de texto full-text e similaridade
    CREATE EXTENSION IF NOT EXISTS pg_trgm;

    -- pgcrypto: para funções de criptografia
    CREATE EXTENSION IF NOT EXISTS pgcrypto;

    -- Transferir ownership do schema public
    ALTER SCHEMA public OWNER TO ${CHATWOOT_POSTGRES_USER};

    -- Conceder uso do schema
    GRANT ALL ON SCHEMA public TO ${CHATWOOT_POSTGRES_USER};
EOSQL

log "✅ Chatwoot configurado"

# =============================================================================
# EVOLUTION API - Gateway WhatsApp
# =============================================================================
log "💬 Configurando banco do Evolution API..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Criar usuário (se não existir)
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_user WHERE usename = '${EVOLUTION_POSTGRES_USER}') THEN
            CREATE USER ${EVOLUTION_POSTGRES_USER} WITH PASSWORD '${EVOLUTION_POSTGRES_PASSWORD}';
            RAISE NOTICE 'Usuário ${EVOLUTION_POSTGRES_USER} criado com sucesso';
        ELSE
            RAISE NOTICE 'Usuário ${EVOLUTION_POSTGRES_USER} já existe';
        END IF;
    END
    \$\$;

    -- Criar banco de dados (se não existir)
    SELECT 'CREATE DATABASE ${EVOLUTION_POSTGRES_DB}'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${EVOLUTION_POSTGRES_DB}')\gexec

    -- Conceder privilégios
    GRANT ALL PRIVILEGES ON DATABASE ${EVOLUTION_POSTGRES_DB} TO ${EVOLUTION_POSTGRES_USER};
EOSQL

# Configurar ownership do schema
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$EVOLUTION_POSTGRES_DB" <<-EOSQL
    ALTER SCHEMA public OWNER TO ${EVOLUTION_POSTGRES_USER};
    GRANT ALL ON SCHEMA public TO ${EVOLUTION_POSTGRES_USER};
EOSQL

log "✅ Evolution API configurado"

# =============================================================================
# N8N - Automação e Workflows
# =============================================================================
log "⚙️  Configurando banco do N8N..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Criar usuário (se não existir)
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_user WHERE usename = '${N8N_POSTGRES_USER}') THEN
            CREATE USER ${N8N_POSTGRES_USER} WITH PASSWORD '${N8N_POSTGRES_PASSWORD}';
            RAISE NOTICE 'Usuário ${N8N_POSTGRES_USER} criado com sucesso';
        ELSE
            RAISE NOTICE 'Usuário ${N8N_POSTGRES_USER} já existe';
        END IF;
    END
    \$\$;

    -- Criar banco de dados (se não existir)
    SELECT 'CREATE DATABASE ${N8N_POSTGRES_DB}'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${N8N_POSTGRES_DB}')\gexec

    -- Conceder privilégios
    GRANT ALL PRIVILEGES ON DATABASE ${N8N_POSTGRES_DB} TO ${N8N_POSTGRES_USER};
EOSQL

# Configurar ownership do schema
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$N8N_POSTGRES_DB" <<-EOSQL
    ALTER SCHEMA public OWNER TO ${N8N_POSTGRES_USER};
    GRANT ALL ON SCHEMA public TO ${N8N_POSTGRES_USER};
EOSQL

log "✅ N8N configurado"

# =============================================================================
# RESUMO DA CONFIGURAÇÃO
# =============================================================================
log "📊 Listando bancos de dados criados..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    \l+ ${CHATWOOT_POSTGRES_DB}
    \l+ ${EVOLUTION_POSTGRES_DB}
    \l+ ${N8N_POSTGRES_DB}
EOSQL

log "🎉 Configuração concluída com sucesso!"
log "ℹ️  Para reexecutar este script, remova o volume: docker volume rm all-in-one_postgres_data"
