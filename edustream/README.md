# 🎓 EduStream - Plataforma de Cursos Online

Sistema completo de gerenciamento de cursos online com área administrativa e interface para usuários.

## 📋 Estrutura do Projeto

```
site-cursos/
├── index.html              # Página de login
├── cadastro.html           # Página de cadastro
├── dashboard.html          # Dashboard principal do usuário
├── cursos.html             # Listagem completa de cursos
├── admin/                  # Área administrativa
│   ├── dashboard.html      # Dashboard do administrador
│   ├── usuarios.html       # Gerenciamento de usuários
│   ├── analytics.html      # Gráficos e relatórios
│   ├── curso-form.html     # Formulário de curso
│   └── configuracoes.html  # Configurações do sistema
├── css/                    # Arquivos de estilo
│   ├── reset.css          # Reset CSS
│   ├── variables.css      # Variáveis CSS
│   └── components.css     # Componentes reutilizáveis
├── sql/                    # Scripts do banco de dados
│   ├── edustream_complete.sql    # Estrutura completa
│   └── dados_exemplo.sql         # Dados de exemplo
└── README.md              # Este arquivo
```

## 🚀 Como Configurar no XAMPP

### 1. Configuração do Banco de Dados

1. **Inicie o XAMPP:**
   - Abra o painel de controle do XAMPP
   - Inicie os serviços **Apache** e **MySQL**

2. **Acesse o phpMyAdmin:**
   - Abra o navegador e vá para: `http://localhost/phpmyadmin`

3. **Crie o banco de dados:**
   ```sql
   CREATE DATABASE edustream CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

4. **Importe a estrutura:**
   - Selecione o banco `edustream`
   - Vá na aba **Importar**
   - Selecione o arquivo `sql/edustream_complete.sql`
   - Clique em **Executar**

5. **Importe os dados de exemplo (opcional):**
   - Selecione o arquivo `sql/dados_exemplo.sql`
   - Clique em **Executar**

### 2. Configuração dos Arquivos

1. **Copie os arquivos:**
   - Copie toda a pasta `site-cursos` para `C:\xampp\htdocs\`

2. **Acesse o site:**
   - Abra o navegador e vá para: `http://localhost/site-cursos`

## 🔐 Credenciais de Acesso

### Usuário Comum
- **Email:** usuario@email.com
- **Senha:** 123456

### Administrador
- **Email:** admin@edustream.com
- **Senha:** admin123

## 📱 Páginas Disponíveis

### 👤 Área do Usuário
- **Login** (`index.html`) - Autenticação de usuários
- **Cadastro** (`cadastro.html`) - Registro de novos usuários
- **Dashboard** (`dashboard.html`) - Página principal com cursos
- **Cursos** (`cursos.html`) - Listagem completa com filtros

### 👨‍💼 Área Administrativa
- **Dashboard Admin** (`admin/dashboard.html`) - Visão geral do sistema
- **Usuários** (`admin/usuarios.html`) - Gerenciamento de usuários
- **Analytics** (`admin/analytics.html`) - Gráficos e relatórios
- **Cursos** (`admin/curso-form.html`) - Cadastro/edição de cursos
- **Configurações** (`admin/configuracoes.html`) - Configurações do sistema

## 🎨 Recursos Visuais

### ✨ Melhorias Implementadas
- **Gradientes modernos** em botões e cards
- **Animações suaves** de hover e transição
- **Micro-interações** em elementos clicáveis
- **Sombras dinâmicas** para profundidade
- **Layout responsivo** para mobile
- **Ícones intuitivos** em toda interface
- **Paleta de cores harmoniosa**
- **Tipografia otimizada**

### 📊 Gráficos e Visualizações
- Gráficos interativos com **Chart.js**
- Dashboards com métricas em tempo real
- Filtros avançados de busca
- Paginação inteligente

## 🛠️ Tecnologias Utilizadas

- **HTML5** - Estrutura semântica
- **CSS3** - Estilização avançada com:
  - CSS Grid e Flexbox
  - Variáveis CSS customizadas
  - Animações e transições
  - Design responsivo
- **JavaScript** - Interatividade:
  - Manipulação do DOM
  - Validação de formulários
  - Filtros dinâmicos
  - Gráficos interativos
- **Chart.js** - Visualização de dados
- **MySQL** - Banco de dados relacional

## 📋 Funcionalidades

### 🔐 Sistema de Autenticação
- Login com validação
- Cadastro de usuários
- Diferentes níveis de acesso (usuário/admin)
- Validação de força de senha

### 👥 Gerenciamento de Usuários
- Listagem com busca e filtros
- Ações de ativação/desativação
- Visualização de estatísticas
- Controle de permissões

### 📚 Gerenciamento de Cursos
- Cadastro completo de cursos
- Upload de imagens
- Categorização e tags
- Controle de preços e descontos

### 📊 Analytics e Relatórios
- Gráficos de usuários ativos
- Receita mensal
- Cursos por categoria
- Insights automáticos

### 🎛️ Configurações Avançadas
- Métodos de pagamento
- Configurações de segurança
- Notificações personalizáveis
- Acessibilidade

## 🔧 Comandos SQL Importantes

### Verificar estrutura das tabelas:
```sql
SHOW TABLES;
DESCRIBE usuario;
DESCRIBE curso;
```

### Consultas úteis:
```sql
-- Ver todos os usuários
SELECT * FROM usuario;

-- Ver todos os cursos
SELECT * FROM curso;

-- Ver matrículas ativas
SELECT u.nome, c.titulo, m.data_matricula 
FROM matricula m 
JOIN usuario u ON m.usuario_id = u.id 
JOIN curso c ON m.curso_id = c.id;
```

### Backup do banco:
```bash
mysqldump -u root -p edustream > backup_edustream.sql
```

## 🐛 Solução de Problemas

### Erro de conexão com banco:
1. Verifique se o MySQL está rodando no XAMPP
2. Confirme as credenciais no arquivo de configuração
3. Teste a conexão via phpMyAdmin

### Páginas não carregam:
1. Verifique se o Apache está ativo
2. Confirme se os arquivos estão em `htdocs`
3. Teste com `http://localhost/site-cursos`

### Estilos não aplicam:
1. Verifique os caminhos dos arquivos CSS
2. Limpe o cache do navegador
3. Confirme se não há erros no console

## 📞 Suporte

Para dúvidas ou problemas:
1. Verifique este README primeiro
2. Consulte os comentários no código
3. Teste as funcionalidades passo a passo

## 🚀 Próximos Passos

Para expandir o sistema:
1. **Backend PHP** - Conectar com banco de dados
2. **Sistema de pagamento** - Integrar gateway
3. **Upload de vídeos** - Armazenamento de aulas
4. **Certificados** - Geração automática
5. **Mobile App** - Versão para dispositivos móveis

---

**Desenvolvido com ❤️ para EduStream**

