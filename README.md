# 🤖 Secretária Eletrônica IA

[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![N8N](https://img.shields.io/badge/n8n-FF6D5B?style=for-the-badge&logo=n8n&logoColor=white)](https://n8n.io/)
[![WhatsApp](https://img.shields.io/badge/WhatsApp-25D366?style=for-the-badge&logo=whatsapp&logoColor=white)](https://evolution-api.com/)
[![Chatwoot](https://img.shields.io/badge/Chatwoot-1f93ff?style=for-the-badge&logo=chatwoot&logoColor=white)](https://www.chatwoot.com/)

Este projeto é uma **Secretária Eletrônica Automatizada com Inteligência Artificial**. Ele integra ferramentas poderosas para criar um fluxo de atendimento inteligente e fluido via WhatsApp, permitindo que IAs (LLMs) processem mensagens e automatizem tarefas complexas.

## 🛠️ Tecnologias e Estrutura

O ecossistema é composto por três pilares principais:

*   **[Evolution API](https://evolution-api.com/):** Atua como o gateway para o WhatsApp, gerenciando a conexão e as mensagens.
*   **[Chatwoot](https://www.chatwoot.com/):** Serve como a ponte de atendimento humano e interface de visualização das conversas.
*   **[n8n](https://n8n.io/):** O "cérebro" da operação, onde os fluxos de automação e a lógica da IA (LLM) são configurados.

### Componentes de Infraestrutura:
*   **PostgreSQL (com pgvector):** Banco de dados principal, preparado para busca vetorial (essencial para memória de longo prazo da IA).
*   **Redis:** Cache e gerenciamento de filas para alta performance.

## 📁 Estrutura de Arquivos

*   `compose.yml`: Configuração completa do Docker Compose para todos os serviços.
*   `init-db.sh`: Script de inicialização que cria os bancos de dados necessários automaticamente.
*   `makefile`: Atalhos para facilitar a gestão dos containers.
*   `.env.example`: Modelo de variáveis de ambiente.
*   `guides/`: Contém guias detalhados para a configuração das plataformas via interface web.

## 📖 Guias de Configuração

Após subir os containers, você precisará configurar cada serviço em seu respectivo painel web. Consulte os arquivos na pasta `guides/` para o passo a passo:

1.  **[n8n-guide.md](./guides/n8n-guide.md):** Como importar workflows e configurar credenciais de IA.
2.  **[chatwoot-guide.md](./guides/chatwoot-guide.md):** Configuração de inboxes e agentes.
3.  **[evolution-guide.md](./guides/evolution-guide.md):** Criação de instâncias e conexão com o WhatsApp.

## 🚀 Como Começar

### Pré-requisitos
*   Docker e Docker Compose instalados.
*   `make` (opcional, mas recomendado).

### Instalação

1.  **Clone o repositório e acesse a pasta:**
    ```bash
    git clone <url-do-repositorio>
    cd ai-secretary
    ```

2.  **Configure as variáveis de ambiente:**
    ```bash
    cp .env.example .env
    ```
    *Edite o arquivo `.env` e preencha as chaves de API e senhas necessárias.*

3.  **Inicie o projeto:**
    ```bash
    make up
    ```
    *Isso irá subir todos os containers e executar as migrações de banco de dados automaticamente.*

## 🕹️ Comandos Disponíveis

| Comando        | Descrição                                      |
|----------------|------------------------------------------------|
| `make up`      | Inicia os containers em modo background        |
| `make down`    | Para e remove os containers                    |
| `make logs`    | Exibe os logs dos containers em tempo real     |
| `make restart` | Reinicia todos os serviços                     |
| `make clean`   | Para os containers e apaga todos os volumes    |

## ⚙️ Informações Adicionais

### Portas Padrão
*   **Chatwoot:** `3000`
*   **Evolution API:** `8080` (configurável no `.env`)
*   **n8n:** `5678` (configurável no `.env`)

### Configuração de IA
Para utilizar as funcionalidades de IA no n8n, você precisará configurar as chaves de API (OpenAI, Anthropic, ou Google Gemini) diretamente no arquivo `.env` ou dentro da interface do n8n.

### Banco de Dados
O script `init-db.sh` cria automaticamente quatro bases de dados distintas no Postgres:
1. `chatwoot_db`
2. `evolution_db`
3. `n8n_db`
4. `main_db` (Postgres default)

---
*Desenvolvido para automação inteligente de processos e atendimento.*
