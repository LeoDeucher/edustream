-- ========================================
-- DADOS DE EXEMPLO PARA EDUSTREAM
-- ========================================

USE edustream;

-- ========================================
-- INSERINDO CATEGORIAS
-- ========================================
INSERT INTO categoria (nomeCategoria, descricao) VALUES
('Programação', 'Cursos relacionados a desenvolvimento de software e programação'),
('Design', 'Cursos de design gráfico, UI/UX e design digital'),
('Marketing', 'Cursos de marketing digital, redes sociais e vendas'),
('Negócios', 'Cursos de empreendedorismo, gestão e administração'),
('Idiomas', 'Cursos de idiomas estrangeiros'),
('Tecnologia', 'Cursos de tecnologia, redes e infraestrutura');

-- ========================================
-- INSERINDO USUÁRIOS
-- ========================================
-- Senha padrão: 123456 (hash MD5: e10adc3949ba59abbe56e057f20f883e)
INSERT INTO usuario (nomeUsuario, email, senha, tipoUsuario) VALUES
('Administrador', 'admin@edustream.com', 'e10adc3949ba59abbe56e057f20f883e', 'admin'),
('João Silva', 'joao@email.com', 'e10adc3949ba59abbe56e057f20f883e', 'comum'),
('Maria Santos', 'maria@email.com', 'e10adc3949ba59abbe56e057f20f883e', 'comum'),
('Pedro Oliveira', 'pedro@email.com', 'e10adc3949ba59abbe56e057f20f883e', 'comum'),
('Ana Costa', 'ana@email.com', 'e10adc3949ba59abbe56e057f20f883e', 'comum'),
('Carlos Ferreira', 'carlos@email.com', 'e10adc3949ba59abbe56e057f20f883e', 'comum');

-- ========================================
-- INSERINDO CURSOS
-- ========================================
INSERT INTO curso (tituloCurso, descricao, resumo, idCategoria, dificuldade, valor, autor) VALUES
('HTML e CSS Básico', 'Aprenda os fundamentos do desenvolvimento web com HTML e CSS', 'Curso completo para iniciantes em desenvolvimento web', 1, 'iniciante', 99.90, 'Prof. João Developer'),
('JavaScript Avançado', 'Domine JavaScript moderno e suas principais funcionalidades', 'Curso avançado de JavaScript ES6+', 1, 'avancado', 199.90, 'Prof. Maria JS'),
('Design UI/UX', 'Princípios de design de interface e experiência do usuário', 'Aprenda a criar interfaces incríveis', 2, 'intermediario', 149.90, 'Prof. Ana Designer'),
('Marketing Digital', 'Estratégias completas de marketing digital', 'Do básico ao avançado em marketing online', 3, 'iniciante', 129.90, 'Prof. Carlos Marketing'),
('Python para Iniciantes', 'Programação em Python do zero', 'Aprenda Python de forma prática e objetiva', 1, 'iniciante', 119.90, 'Prof. Pedro Python'),
('Photoshop Avançado', 'Técnicas avançadas de edição de imagens', 'Domine o Photoshop como um profissional', 2, 'avancado', 179.90, 'Prof. Design Master');

-- ========================================
-- INSERINDO MÓDULOS
-- ========================================
INSERT INTO modulo (idCurso, tituloModulo, descricao, ordem) VALUES
-- Módulos do curso HTML e CSS Básico (idCurso = 1)
(1, 'Introdução ao HTML', 'Fundamentos da linguagem HTML', 1),
(1, 'Estilização com CSS', 'Aprenda a estilizar páginas web', 2),
(1, 'Layout Responsivo', 'Criando layouts que se adaptam a diferentes telas', 3),

-- Módulos do curso JavaScript Avançado (idCurso = 2)
(2, 'ES6+ Features', 'Novas funcionalidades do JavaScript moderno', 1),
(2, 'Programação Assíncrona', 'Promises, async/await e fetch API', 2),
(2, 'Frameworks e Bibliotecas', 'Introdução ao React e Vue.js', 3),

-- Módulos do curso Design UI/UX (idCurso = 3)
(3, 'Princípios de Design', 'Fundamentos do design visual', 1),
(3, 'Prototipagem', 'Criando protótipos funcionais', 2),
(3, 'Testes de Usabilidade', 'Validando suas interfaces', 3);

-- ========================================
-- INSERINDO AULAS
-- ========================================
INSERT INTO aula (idModulo, idCurso, tituloAula, descricao, duracao, ordem) VALUES
-- Aulas do módulo 1 (Introdução ao HTML)
(1, 1, 'O que é HTML?', 'Conceitos básicos sobre HTML', 15, 1),
(1, 1, 'Estrutura de um documento HTML', 'Tags básicas e estrutura', 20, 2),
(1, 1, 'Tags de texto e formatação', 'Formatando texto com HTML', 25, 3),
(1, 1, 'Links e imagens', 'Inserindo links e imagens', 18, 4),

-- Aulas do módulo 2 (Estilização com CSS)
(2, 1, 'Introdução ao CSS', 'O que é CSS e como usar', 12, 1),
(2, 1, 'Seletores CSS', 'Diferentes tipos de seletores', 22, 2),
(2, 1, 'Propriedades de texto e cor', 'Estilizando textos', 16, 3),
(2, 1, 'Box Model', 'Entendendo o modelo de caixa', 28, 4),

-- Aulas do módulo 3 (Layout Responsivo)
(3, 1, 'Media Queries', 'Criando layouts responsivos', 30, 1),
(3, 1, 'Flexbox', 'Layout flexível com CSS', 35, 2),
(3, 1, 'CSS Grid', 'Sistema de grid moderno', 40, 3);

-- ========================================
-- INSERINDO MATRÍCULAS
-- ========================================
INSERT INTO matricula (idUsuario, idCurso, progressoGeral) VALUES
(2, 1, 45.50), -- João no curso de HTML/CSS
(2, 2, 12.30), -- João no curso de JavaScript
(3, 1, 78.90), -- Maria no curso de HTML/CSS
(3, 3, 23.40), -- Maria no curso de Design
(4, 4, 67.80), -- Pedro no curso de Marketing
(5, 1, 100.00), -- Ana completou HTML/CSS
(5, 5, 34.50), -- Ana no curso de Python
(6, 6, 89.20); -- Carlos no curso de Photoshop

-- ========================================
-- INSERINDO PROGRESSO
-- ========================================
INSERT INTO progresso (idUsuario, idAula, idCurso, concluida, tempoAssistido) VALUES
-- Progresso do João (idUsuario = 2)
(2, 1, 1, TRUE, 900),  -- Aula 1 concluída
(2, 2, 1, TRUE, 1200), -- Aula 2 concluída
(2, 3, 1, FALSE, 800), -- Aula 3 em andamento

-- Progresso da Maria (idUsuario = 3)
(3, 1, 1, TRUE, 900),
(3, 2, 1, TRUE, 1200),
(3, 3, 1, TRUE, 1500),
(3, 4, 1, TRUE, 1080),
(3, 5, 1, TRUE, 720),

-- Progresso da Ana (idUsuario = 5) - Curso completo
(5, 1, 1, TRUE, 900),
(5, 2, 1, TRUE, 1200),
(5, 3, 1, TRUE, 1500),
(5, 4, 1, TRUE, 1080),
(5, 5, 1, TRUE, 720),
(5, 6, 1, TRUE, 1320),
(5, 7, 1, TRUE, 960),
(5, 8, 1, TRUE, 1680),
(5, 9, 1, TRUE, 1800),
(5, 10, 1, TRUE, 2100),
(5, 11, 1, TRUE, 2400);

-- ========================================
-- INSERINDO CERTIFICADOS
-- ========================================
INSERT INTO certificado (idUsuario, idCurso, codigoCertificado) VALUES
(5, 1, 'CERT-5-1-1720224000'); -- Ana completou o curso de HTML/CSS

-- ========================================
-- INSERINDO PAGAMENTOS
-- ========================================
INSERT INTO pagamento (idUsuario, idCurso, valor, metodoPagamento, status) VALUES
(2, 1, 99.90, 'cartao', 'aprovado'),
(2, 2, 199.90, 'pix', 'aprovado'),
(3, 1, 99.90, 'cartao', 'aprovado'),
(3, 3, 149.90, 'boleto', 'pendente'),
(4, 4, 129.90, 'pix', 'aprovado'),
(5, 1, 99.90, 'cartao', 'aprovado'),
(5, 5, 119.90, 'cartao', 'aprovado'),
(6, 6, 179.90, 'cartao', 'aprovado');

