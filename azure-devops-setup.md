# 🚀 Configuração do Azure DevOps

Este guia explica como configurar e usar o Azure DevOps para o projeto DevOps.

## 📋 Pré-requisitos

- Conta no Azure DevOps
- Acesso ao Azure (para deploy)
- Repositório configurado no Azure DevOps

## 🔧 Configuração Inicial

### 1. Criar Projeto no Azure DevOps

1. Acesse [dev.azure.com](https://dev.azure.com)
2. Clique em "New Project"
3. Configure:
   - **Project name:** `devops-project`
   - **Description:** Projeto de demonstração DevOps
   - **Visibility:** Private ou Public
   - **Version control:** Git
   - **Work item process:** Agile

### 2. Configurar Repositório

```bash
# Clone o repositório
git clone https://dev.azure.com/your-org/devops-project/_git/devops-project

# Adicione os arquivos
git add .
git commit -m "Initial commit - DevOps project setup"
git push origin main
```

### 3. Configurar Pipeline

1. No Azure DevOps, vá para **Pipelines**
2. Clique em **New Pipeline**
3. Selecione **Azure Repos Git**
4. Selecione seu repositório
5. Escolha **Existing Azure Pipelines YAML file**
6. Selecione `azure-pipelines-simple.yml`

## 🔄 Pipeline Stages

### Build Stage
- Instala Node.js 18.x
- Instala dependências (`npm ci`)
- Executa build (`npm run build`)
- Cria pacote de deploy
- Publica artefatos

### Test Stage
- Baixa artefatos do build
- Executa testes unitários
- Executa testes E2E
- Publica resultados

### Security Stage
- Executa `npm audit`
- Análise de segurança
- Verificação de vulnerabilidades

### Deploy Stage
- Deploy para Azure Web App
- Configura variáveis de ambiente
- Health check pós-deploy

### Monitor Stage
- Verifica saúde da aplicação
- Coleta métricas
- Gera relatórios

### Notify Stage
- Envia notificações
- Slack, Teams, Email

## ⚙️ Configurações de Variáveis

### Pipeline Variables
Configure estas variáveis no pipeline:

```yaml
variables:
  webAppName: 'devops-project'
  resourceGroupName: 'devops-rg'
  environmentName: 'production'
  nodeVersion: '18.x'
```

### Library Variables
Configure variáveis sensíveis na Library:

- `AzureSubscription` - Service Connection do Azure
- `SlackWebhook` - Webhook do Slack
- `EmailPassword` - Senha do email
- `SonarQubeToken` - Token do SonarQube

## 🔐 Service Connections

### Azure Service Connection
1. Vá para **Project Settings** > **Service Connections**
2. Clique em **New Service Connection**
3. Selecione **Azure Resource Manager**
4. Configure com sua conta Azure

### SonarQube Service Connection
1. Crie nova Service Connection
2. Selecione **SonarQube**
3. Configure URL e token

## 🌍 Environments

### Production Environment
1. Vá para **Environments**
2. Clique em **New Environment**
3. Nome: `production`
4. Configure approvers se necessário

### Staging Environment
1. Crie ambiente `staging`
2. Configure para branch `develop`

## 📊 Dashboards

### Build Dashboard
- Status dos builds
- Tempo de execução
- Taxa de sucesso
- Últimos deploys

### Monitoring Dashboard
- Métricas de aplicação
- Alertas ativos
- Logs em tempo real
- Performance

## 🔍 Work Items

### Tipos de Work Items
- **Epic** - Funcionalidades grandes
- **Feature** - Funcionalidades específicas
- **User Story** - Requisitos do usuário
- **Task** - Tarefas técnicas
- **Bug** - Correções
- **Issue** - Problemas

### Exemplo de User Story
```
Title: Implementar monitoramento em tempo real
Description: Adicionar métricas em tempo real no dashboard
Acceptance Criteria:
- Dashboard mostra métricas atualizadas
- Alertas são exibidos em tempo real
- Logs são atualizados automaticamente
```

## 🧪 Testes

### Testes Unitários
```bash
npm test
```

### Testes E2E
```bash
npm run test:e2e
```

### Testes de Performance
```bash
npm run test:perf
```

## 📈 Métricas e KPIs

### Build Metrics
- **Build Success Rate:** > 95%
- **Build Duration:** < 10 minutes
- **Test Coverage:** > 80%
- **Security Score:** > 90%

### Deploy Metrics
- **Deploy Success Rate:** > 98%
- **Deploy Duration:** < 5 minutes
- **Rollback Time:** < 2 minutes
- **Uptime:** > 99.9%

## 🚨 Alertas e Notificações

### Alertas Automáticos
- Build falhou
- Deploy falhou
- Testes falharam
- Security scan falhou
- Performance degradada

### Notificações
- **Slack:** Canal #devops
- **Teams:** Canal DevOps
- **Email:** devops@company.com
- **SMS:** Para alertas críticos

## 🔄 Branch Policies

### Main Branch
- Requer Pull Request
- Requer aprovação
- Requer build bem-sucedido
- Requer testes passando

### Develop Branch
- Requer Pull Request
- Requer build bem-sucedido
- Auto-merge habilitado

## 📋 Checklist de Configuração

### ✅ Repositório
- [ ] Repositório criado
- [ ] Arquivos commitados
- [ ] Branch policies configuradas
- [ ] Webhooks configurados

### ✅ Pipeline
- [ ] Pipeline criado
- [ ] Stages configuradas
- [ ] Variables definidas
- [ ] Service connections configuradas

### ✅ Environments
- [ ] Production environment criado
- [ ] Staging environment criado
- [ ] Approvers configurados
- [ ] Deploy policies definidas

### ✅ Monitoring
- [ ] Dashboards criados
- [ ] Alertas configurados
- [ ] Métricas definidas
- [ ] Logs centralizados

### ✅ Notifications
- [ ] Slack webhook configurado
- [ ] Teams webhook configurado
- [ ] Email notifications configuradas
- [ ] SMS alerts configurados

## 🛠️ Troubleshooting

### Problemas Comuns

#### Build Falha
```bash
# Verificar logs
az pipelines runs show --id <build-id>

# Re-executar build
az pipelines runs rerun --id <build-id>
```

#### Deploy Falha
```bash
# Verificar status do Web App
az webapp show --name devops-project --resource-group devops-rg

# Verificar logs
az webapp log tail --name devops-project --resource-group devops-rg
```

#### Pipeline Lento
- Verificar cache de dependências
- Otimizar Docker images
- Usar agentes self-hosted
- Paralelizar stages

## 📚 Recursos Adicionais

- [Azure DevOps Documentation](https://docs.microsoft.com/azure/devops/)
- [YAML Schema Reference](https://docs.microsoft.com/azure/devops/pipelines/yaml-schema/)
- [Task Reference](https://docs.microsoft.com/azure/devops/pipelines/tasks/)
- [Best Practices](https://docs.microsoft.com/azure/devops/pipelines/policies/)

## 🤝 Suporte

- **Azure DevOps Support:** [support.microsoft.com](https://support.microsoft.com)
- **Community:** [Stack Overflow](https://stackoverflow.com/questions/tagged/azure-devops)
- **Documentation:** [docs.microsoft.com/azure/devops](https://docs.microsoft.com/azure/devops)

---

**Configurado com ❤️ para DevOps** 