-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 08-Jul-2025 às 03:42
-- Versão do servidor: 10.4.24-MariaDB
-- versão do PHP: 7.4.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `edustream`
--

DELIMITER $$
--
-- Procedimentos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_atualizar_progresso` (IN `p_idUsuario` INT, IN `p_idAula` INT, IN `p_tempoAssistido` INT, IN `p_concluida` BOOLEAN)   BEGIN
    DECLARE v_idCurso INT;
    DECLARE v_totalAulas INT;
    DECLARE v_aulasConcluidasUsuario INT;
    DECLARE v_novoProgresso DECIMAL(5,2);
    
    -- Busca o curso da aula
    SELECT idCurso INTO v_idCurso FROM aula WHERE idAula = p_idAula;
    
    -- Atualiza ou insere progresso da aula
    INSERT INTO progresso (idUsuario, idAula, idCurso, tempoAssistido, concluida)
    VALUES (p_idUsuario, p_idAula, v_idCurso, p_tempoAssistido, p_concluida)
    ON DUPLICATE KEY UPDATE
        tempoAssistido = p_tempoAssistido,
        concluida = p_concluida,
        dataVisualizacao = NOW();
    
    -- Calcula novo progresso geral
    SELECT COUNT(*) INTO v_totalAulas FROM aula WHERE idCurso = v_idCurso AND ativo = TRUE;
    
    SELECT COUNT(*) INTO v_aulasConcluidasUsuario 
    FROM progresso 
    WHERE idUsuario = p_idUsuario AND idCurso = v_idCurso AND concluida = TRUE;
    
    SET v_novoProgresso = (v_aulasConcluidasUsuario / v_totalAulas) * 100;
    
    -- Atualiza progresso na matrícula
    UPDATE matricula 
    SET progressoGeral = v_novoProgresso,
        dataUltimoacesso = NOW()
    WHERE idUsuario = p_idUsuario AND idCurso = v_idCurso;
    
    -- Se completou 100%, gera certificado
    IF v_novoProgresso >= 100 THEN
        CALL sp_gerar_certificado(p_idUsuario, v_idCurso);
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_gerar_certificado` (IN `p_idUsuario` INT, IN `p_idCurso` INT)   BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_codigo VARCHAR(50);
    
    -- Verifica se já existe certificado
    SELECT COUNT(*) INTO v_count
    FROM certificado 
    WHERE idUsuario = p_idUsuario AND idCurso = p_idCurso;
    
    IF v_count = 0 THEN
        -- Gera código único
        SET v_codigo = CONCAT('CERT-', p_idUsuario, '-', p_idCurso, '-', UNIX_TIMESTAMP());
        
        INSERT INTO certificado (idUsuario, idCurso, codigoCertificado)
        VALUES (p_idUsuario, p_idCurso, v_codigo);
        
        -- Atualiza status da matrícula
        UPDATE matricula 
        SET status = 'concluida'
        WHERE idUsuario = p_idUsuario AND idCurso = p_idCurso;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_matricular_usuario` (IN `p_idUsuario` INT, IN `p_idCurso` INT)   BEGIN
    DECLARE v_count INT DEFAULT 0;
    
    -- Verifica se já existe matrícula
    SELECT COUNT(*) INTO v_count
    FROM matricula 
    WHERE idUsuario = p_idUsuario AND idCurso = p_idCurso;
    
    IF v_count = 0 THEN
        INSERT INTO matricula (idUsuario, idCurso, dataMatricula)
        VALUES (p_idUsuario, p_idCurso, NOW());
        
        SELECT 'Matrícula realizada com sucesso!' as mensagem;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuário já está matriculado neste curso.';
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `aula`
--

CREATE TABLE `aula` (
  `idAula` int(11) NOT NULL,
  `idModulo` int(11) NOT NULL,
  `idCurso` int(11) NOT NULL,
  `tituloAula` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `conteudo` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `videoUrl` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duracao` int(11) DEFAULT 0,
  `ordem` int(11) NOT NULL,
  `ativo` tinyint(1) DEFAULT 1,
  `dataCriacao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `aula`
--

INSERT INTO `aula` (`idAula`, `idModulo`, `idCurso`, `tituloAula`, `descricao`, `conteudo`, `videoUrl`, `duracao`, `ordem`, `ativo`, `dataCriacao`) VALUES
(1, 1, 1, 'O que é HTML?', 'Conceitos básicos sobre HTML', NULL, NULL, 15, 1, 1, '2025-07-06 02:34:55'),
(2, 1, 1, 'Estrutura de um documento HTML', 'Tags básicas e estrutura', NULL, NULL, 20, 2, 1, '2025-07-06 02:34:55'),
(3, 1, 1, 'Tags de texto e formatação', 'Formatando texto com HTML', NULL, NULL, 25, 3, 1, '2025-07-06 02:34:55'),
(4, 1, 1, 'Links e imagens', 'Inserindo links e imagens', NULL, NULL, 18, 4, 1, '2025-07-06 02:34:55'),
(5, 2, 1, 'Introdução ao CSS', 'O que é CSS e como usar', NULL, NULL, 12, 1, 1, '2025-07-06 02:34:55'),
(6, 2, 1, 'Seletores CSS', 'Diferentes tipos de seletores', NULL, NULL, 22, 2, 1, '2025-07-06 02:34:55'),
(7, 2, 1, 'Propriedades de texto e cor', 'Estilizando textos', NULL, NULL, 16, 3, 1, '2025-07-06 02:34:55'),
(8, 2, 1, 'Box Model', 'Entendendo o modelo de caixa', NULL, NULL, 28, 4, 1, '2025-07-06 02:34:55'),
(9, 3, 1, 'Media Queries', 'Criando layouts responsivos', NULL, NULL, 30, 1, 1, '2025-07-06 02:34:55'),
(10, 3, 1, 'Flexbox', 'Layout flexível com CSS', NULL, NULL, 35, 2, 1, '2025-07-06 02:34:55'),
(11, 3, 1, 'CSS Grid', 'Sistema de grid moderno', NULL, NULL, 40, 3, 1, '2025-07-06 02:34:55');

--
-- Acionadores `aula`
--
DELIMITER $$
CREATE TRIGGER `trg_after_insert_aula` AFTER INSERT ON `aula` FOR EACH ROW BEGIN
    UPDATE curso 
    SET totalAulas = (
        SELECT COUNT(*) FROM aula WHERE idCurso = NEW.idCurso AND ativo = TRUE
    ),
    totalModulos = (
        SELECT COUNT(DISTINCT idModulo) FROM aula WHERE idCurso = NEW.idCurso AND ativo = TRUE
    ),
    duracaoTotal = (
        SELECT COALESCE(SUM(duracao), 0) FROM aula WHERE idCurso = NEW.idCurso AND ativo = TRUE
    )
    WHERE idCurso = NEW.idCurso;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `categoria`
--

CREATE TABLE `categoria` (
  `idCategoria` int(11) NOT NULL,
  `nomeCategoria` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ativo` tinyint(1) DEFAULT 1,
  `dataCriacao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `categoria`
--

INSERT INTO `categoria` (`idCategoria`, `nomeCategoria`, `descricao`, `ativo`, `dataCriacao`) VALUES
(1, 'Programação', 'Cursos relacionados a desenvolvimento de software e programação', 1, '2025-07-06 02:34:55'),
(2, 'Design', 'Cursos de design gráfico, UI/UX e design digital', 1, '2025-07-06 02:34:55'),
(3, 'Marketing', 'Cursos de marketing digital, redes sociais e vendas', 1, '2025-07-06 02:34:55'),
(4, 'Negócios', 'Cursos de empreendedorismo, gestão e administração', 1, '2025-07-06 02:34:55'),
(5, 'Idiomas', 'Cursos de idiomas estrangeiros', 1, '2025-07-06 02:34:55'),
(6, 'Tecnologia', 'Cursos de tecnologia, redes e infraestrutura', 1, '2025-07-06 02:34:55');

-- --------------------------------------------------------

--
-- Estrutura da tabela `certificado`
--

CREATE TABLE `certificado` (
  `idCertificado` int(11) NOT NULL,
  `idUsuario` int(11) NOT NULL,
  `idCurso` int(11) NOT NULL,
  `dataEmissao` timestamp NOT NULL DEFAULT current_timestamp(),
  `codigoCertificado` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ativo` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `certificado`
--

INSERT INTO `certificado` (`idCertificado`, `idUsuario`, `idCurso`, `dataEmissao`, `codigoCertificado`, `ativo`) VALUES
(1, 5, 1, '2025-07-06 02:34:55', 'CERT-5-1-1720224000', 1);

--
-- Acionadores `certificado`
--
DELIMITER $$
CREATE TRIGGER `trg_before_insert_certificado` BEFORE INSERT ON `certificado` FOR EACH ROW BEGIN
    IF NEW.dataEmissao IS NULL THEN
        SET NEW.dataEmissao = NOW();
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `curso`
--

CREATE TABLE `curso` (
  `idCurso` int(11) NOT NULL,
  `tituloCurso` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resumo` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `idCategoria` int(11) DEFAULT NULL,
  `dificuldade` enum('iniciante','intermediario','avancado') COLLATE utf8mb4_unicode_ci DEFAULT 'iniciante',
  `valor` decimal(10,2) DEFAULT 0.00,
  `autor` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `imagemCapa` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ativo` tinyint(1) DEFAULT 1,
  `dataCriacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `dataAtualizacao` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `totalAulas` int(11) DEFAULT 0,
  `totalModulos` int(11) DEFAULT 0,
  `duracaoTotal` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `curso`
--

INSERT INTO `curso` (`idCurso`, `tituloCurso`, `descricao`, `resumo`, `idCategoria`, `dificuldade`, `valor`, `autor`, `imagemCapa`, `ativo`, `dataCriacao`, `dataAtualizacao`, `totalAulas`, `totalModulos`, `duracaoTotal`) VALUES
(1, 'HTML e CSS Básico', 'Aprenda os fundamentos do desenvolvimento web com HTML e CSS', 'Curso completo para iniciantes em desenvolvimento web', 1, 'iniciante', '99.90', 'Prof. João Developer', NULL, 1, '2025-07-06 02:34:55', '2025-07-06 02:34:55', 11, 3, 261),
(2, 'JavaScript Avançado', 'Domine JavaScript moderno e suas principais funcionalidades', 'Curso avançado de JavaScript ES6+', 1, 'avancado', '199.90', 'Prof. Maria JS', NULL, 1, '2025-07-06 02:34:55', '2025-07-06 02:34:55', 0, 0, 0),
(3, 'Design UI/UX', 'Princípios de design de interface e experiência do usuário', 'Aprenda a criar interfaces incríveis', 2, 'intermediario', '149.90', 'Prof. Ana Designer', NULL, 1, '2025-07-06 02:34:55', '2025-07-06 02:34:55', 0, 0, 0),
(4, 'Marketing Digital', 'Estratégias completas de marketing digital', 'Do básico ao avançado em marketing online', 3, 'iniciante', '129.90', 'Prof. Carlos Marketing', NULL, 1, '2025-07-06 02:34:55', '2025-07-06 02:34:55', 0, 0, 0),
(5, 'Python para Iniciantes', 'Programação em Python do zero', 'Aprenda Python de forma prática e objetiva', 1, 'iniciante', '119.90', 'Prof. Pedro Python', NULL, 1, '2025-07-06 02:34:55', '2025-07-06 02:34:55', 0, 0, 0),
(6, 'Photoshop Avançado', 'Técnicas avançadas de edição de imagens', 'Domine o Photoshop como um profissional', 2, 'avancado', '179.90', 'Prof. Design Master', NULL, 1, '2025-07-06 02:34:55', '2025-07-06 02:34:55', 0, 0, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `matricula`
--

CREATE TABLE `matricula` (
  `idMatricula` int(11) NOT NULL,
  `idUsuario` int(11) NOT NULL,
  `idCurso` int(11) NOT NULL,
  `dataMatricula` timestamp NOT NULL DEFAULT current_timestamp(),
  `dataUltimoacesso` timestamp NULL DEFAULT NULL,
  `status` enum('ativa','concluida','cancelada') COLLATE utf8mb4_unicode_ci DEFAULT 'ativa',
  `progressoGeral` decimal(5,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `matricula`
--

INSERT INTO `matricula` (`idMatricula`, `idUsuario`, `idCurso`, `dataMatricula`, `dataUltimoacesso`, `status`, `progressoGeral`) VALUES
(1, 2, 1, '2025-07-06 02:34:55', NULL, 'ativa', '45.50'),
(2, 2, 2, '2025-07-06 02:34:55', NULL, 'ativa', '12.30'),
(3, 3, 1, '2025-07-06 02:34:55', NULL, 'ativa', '78.90'),
(4, 3, 3, '2025-07-06 02:34:55', NULL, 'ativa', '23.40'),
(5, 4, 4, '2025-07-06 02:34:55', NULL, 'ativa', '67.80'),
(6, 5, 1, '2025-07-06 02:34:55', NULL, 'ativa', '100.00'),
(7, 5, 5, '2025-07-06 02:34:55', NULL, 'ativa', '34.50'),
(8, 6, 6, '2025-07-06 02:34:55', NULL, 'ativa', '89.20');

-- --------------------------------------------------------

--
-- Estrutura da tabela `modulo`
--

CREATE TABLE `modulo` (
  `idModulo` int(11) NOT NULL,
  `idCurso` int(11) NOT NULL,
  `tituloModulo` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ordem` int(11) NOT NULL,
  `ativo` tinyint(1) DEFAULT 1,
  `dataCriacao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `modulo`
--

INSERT INTO `modulo` (`idModulo`, `idCurso`, `tituloModulo`, `descricao`, `ordem`, `ativo`, `dataCriacao`) VALUES
(1, 1, 'Introdução ao HTML', 'Fundamentos da linguagem HTML', 1, 1, '2025-07-06 02:34:55'),
(2, 1, 'Estilização com CSS', 'Aprenda a estilizar páginas web', 2, 1, '2025-07-06 02:34:55'),
(3, 1, 'Layout Responsivo', 'Criando layouts que se adaptam a diferentes telas', 3, 1, '2025-07-06 02:34:55'),
(4, 2, 'ES6+ Features', 'Novas funcionalidades do JavaScript moderno', 1, 1, '2025-07-06 02:34:55'),
(5, 2, 'Programação Assíncrona', 'Promises, async/await e fetch API', 2, 1, '2025-07-06 02:34:55'),
(6, 2, 'Frameworks e Bibliotecas', 'Introdução ao React e Vue.js', 3, 1, '2025-07-06 02:34:55'),
(7, 3, 'Princípios de Design', 'Fundamentos do design visual', 1, 1, '2025-07-06 02:34:55'),
(8, 3, 'Prototipagem', 'Criando protótipos funcionais', 2, 1, '2025-07-06 02:34:55'),
(9, 3, 'Testes de Usabilidade', 'Validando suas interfaces', 3, 1, '2025-07-06 02:34:55');

-- --------------------------------------------------------

--
-- Estrutura da tabela `pagamento`
--

CREATE TABLE `pagamento` (
  `idPagamento` int(11) NOT NULL,
  `idUsuario` int(11) NOT NULL,
  `idCurso` int(11) NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  `metodoPagamento` enum('cartao','pix','boleto') COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pendente','aprovado','rejeitado','cancelado') COLLATE utf8mb4_unicode_ci DEFAULT 'pendente',
  `dataPagamento` timestamp NOT NULL DEFAULT current_timestamp(),
  `dataVencimento` timestamp NULL DEFAULT NULL,
  `transacaoId` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `pagamento`
--

INSERT INTO `pagamento` (`idPagamento`, `idUsuario`, `idCurso`, `valor`, `metodoPagamento`, `status`, `dataPagamento`, `dataVencimento`, `transacaoId`) VALUES
(1, 2, 1, '99.90', 'cartao', 'aprovado', '2025-07-06 02:34:55', NULL, NULL),
(2, 2, 2, '199.90', 'pix', 'aprovado', '2025-07-06 02:34:55', NULL, NULL),
(3, 3, 1, '99.90', 'cartao', 'aprovado', '2025-07-06 02:34:55', NULL, NULL),
(4, 3, 3, '149.90', 'boleto', 'pendente', '2025-07-06 02:34:55', NULL, NULL),
(5, 4, 4, '129.90', 'pix', 'aprovado', '2025-07-06 02:34:55', NULL, NULL),
(6, 5, 1, '99.90', 'cartao', 'aprovado', '2025-07-06 02:34:55', NULL, NULL),
(7, 5, 5, '119.90', 'cartao', 'aprovado', '2025-07-06 02:34:55', NULL, NULL),
(8, 6, 6, '179.90', 'cartao', 'aprovado', '2025-07-06 02:34:55', NULL, NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `progresso`
--

CREATE TABLE `progresso` (
  `idProgresso` int(11) NOT NULL,
  `idUsuario` int(11) NOT NULL,
  `idAula` int(11) NOT NULL,
  `idCurso` int(11) NOT NULL,
  `dataVisualizacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `concluida` tinyint(1) DEFAULT 0,
  `tempoAssistido` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `progresso`
--

INSERT INTO `progresso` (`idProgresso`, `idUsuario`, `idAula`, `idCurso`, `dataVisualizacao`, `concluida`, `tempoAssistido`) VALUES
(1, 2, 1, 1, '2025-07-06 02:34:55', 1, 900),
(2, 2, 2, 1, '2025-07-06 02:34:55', 1, 1200),
(3, 2, 3, 1, '2025-07-06 02:34:55', 0, 800),
(4, 3, 1, 1, '2025-07-06 02:34:55', 1, 900),
(5, 3, 2, 1, '2025-07-06 02:34:55', 1, 1200),
(6, 3, 3, 1, '2025-07-06 02:34:55', 1, 1500),
(7, 3, 4, 1, '2025-07-06 02:34:55', 1, 1080),
(8, 3, 5, 1, '2025-07-06 02:34:55', 1, 720),
(9, 5, 1, 1, '2025-07-06 02:34:55', 1, 900),
(10, 5, 2, 1, '2025-07-06 02:34:55', 1, 1200),
(11, 5, 3, 1, '2025-07-06 02:34:55', 1, 1500),
(12, 5, 4, 1, '2025-07-06 02:34:55', 1, 1080),
(13, 5, 5, 1, '2025-07-06 02:34:55', 1, 720),
(14, 5, 6, 1, '2025-07-06 02:34:55', 1, 1320),
(15, 5, 7, 1, '2025-07-06 02:34:55', 1, 960),
(16, 5, 8, 1, '2025-07-06 02:34:55', 1, 1680),
(17, 5, 9, 1, '2025-07-06 02:34:55', 1, 1800),
(18, 5, 10, 1, '2025-07-06 02:34:55', 1, 2100),
(19, 5, 11, 1, '2025-07-06 02:34:55', 1, 2400);

-- --------------------------------------------------------

--
-- Estrutura da tabela `usuario`
--

CREATE TABLE `usuario` (
  `idUsuario` int(11) NOT NULL,
  `nomeUsuario` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `senha` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipoUsuario` enum('comum','admin') COLLATE utf8mb4_unicode_ci DEFAULT 'comum',
  `dataCadastro` timestamp NOT NULL DEFAULT current_timestamp(),
  `dataUltimoLogin` timestamp NULL DEFAULT NULL,
  `ativo` tinyint(1) DEFAULT 1,
  `fotoPerfil` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `usuario`
--

INSERT INTO `usuario` (`idUsuario`, `nomeUsuario`, `email`, `senha`, `tipoUsuario`, `dataCadastro`, `dataUltimoLogin`, `ativo`, `fotoPerfil`) VALUES
(1, 'Administrador', 'admin@edustream.com', 'e10adc3949ba59abbe56e057f20f883e', 'admin', '2025-07-06 02:34:55', NULL, 1, NULL),
(2, 'João Silva', 'joao@email.com', 'e10adc3949ba59abbe56e057f20f883e', 'comum', '2025-07-06 02:34:55', NULL, 1, NULL),
(3, 'Maria Santos', 'maria@email.com', 'e10adc3949ba59abbe56e057f20f883e', 'comum', '2025-07-06 02:34:55', NULL, 1, NULL),
(4, 'Pedro Oliveira', 'pedro@email.com', 'e10adc3949ba59abbe56e057f20f883e', 'comum', '2025-07-06 02:34:55', NULL, 1, NULL),
(5, 'Ana Costa', 'ana@email.com', 'e10adc3949ba59abbe56e057f20f883e', 'comum', '2025-07-06 02:34:55', NULL, 1, NULL),
(6, 'Carlos Ferreira', 'carlos@email.com', 'e10adc3949ba59abbe56e057f20f883e', 'comum', '2025-07-06 02:34:55', NULL, 1, NULL);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `vw_certificados_emitidos`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `vw_certificados_emitidos` (
`nomeUsuario` varchar(100)
,`email` varchar(150)
,`tituloCurso` varchar(200)
,`dataEmissao` timestamp
,`codigoCertificado` varchar(50)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `vw_estatisticas_cursos`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `vw_estatisticas_cursos` (
`idCurso` int(11)
,`tituloCurso` varchar(200)
,`nomeCategoria` varchar(100)
,`totalMatriculas` bigint(21)
,`totalCertificados` bigint(21)
,`progressoMedio` decimal(9,6)
,`valor` decimal(10,2)
,`dataCriacao` timestamp
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `vw_progresso_usuario`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `vw_progresso_usuario` (
`nomeUsuario` varchar(100)
,`email` varchar(150)
,`tituloCurso` varchar(200)
,`tituloAula` varchar(200)
,`dataVisualizacao` timestamp
,`concluida` tinyint(1)
,`tempoAssistido` int(11)
);

-- --------------------------------------------------------

--
-- Estrutura para vista `vw_certificados_emitidos`
--
DROP TABLE IF EXISTS `vw_certificados_emitidos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_certificados_emitidos`  AS SELECT `u`.`nomeUsuario` AS `nomeUsuario`, `u`.`email` AS `email`, `c`.`tituloCurso` AS `tituloCurso`, `cert`.`dataEmissao` AS `dataEmissao`, `cert`.`codigoCertificado` AS `codigoCertificado` FROM ((`certificado` `cert` join `usuario` `u` on(`cert`.`idUsuario` = `u`.`idUsuario`)) join `curso` `c` on(`cert`.`idCurso` = `c`.`idCurso`)) WHERE `cert`.`ativo` = 11  ;

-- --------------------------------------------------------

--
-- Estrutura para vista `vw_estatisticas_cursos`
--
DROP TABLE IF EXISTS `vw_estatisticas_cursos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_estatisticas_cursos`  AS SELECT `c`.`idCurso` AS `idCurso`, `c`.`tituloCurso` AS `tituloCurso`, `cat`.`nomeCategoria` AS `nomeCategoria`, count(distinct `m`.`idUsuario`) AS `totalMatriculas`, count(distinct `cert`.`idCertificado`) AS `totalCertificados`, avg(`m`.`progressoGeral`) AS `progressoMedio`, `c`.`valor` AS `valor`, `c`.`dataCriacao` AS `dataCriacao` FROM (((`curso` `c` left join `categoria` `cat` on(`c`.`idCategoria` = `cat`.`idCategoria`)) left join `matricula` `m` on(`c`.`idCurso` = `m`.`idCurso` and `m`.`status` = 'ativa')) left join `certificado` `cert` on(`c`.`idCurso` = `cert`.`idCurso` and `cert`.`ativo` = 1)) WHERE `c`.`ativo` = 1 GROUP BY `c`.`idCurso``idCurso`  ;

-- --------------------------------------------------------

--
-- Estrutura para vista `vw_progresso_usuario`
--
DROP TABLE IF EXISTS `vw_progresso_usuario`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_progresso_usuario`  AS SELECT `u`.`nomeUsuario` AS `nomeUsuario`, `u`.`email` AS `email`, `c`.`tituloCurso` AS `tituloCurso`, `a`.`tituloAula` AS `tituloAula`, `p`.`dataVisualizacao` AS `dataVisualizacao`, `p`.`concluida` AS `concluida`, `p`.`tempoAssistido` AS `tempoAssistido` FROM (((`progresso` `p` join `usuario` `u` on(`p`.`idUsuario` = `u`.`idUsuario`)) join `aula` `a` on(`p`.`idAula` = `a`.`idAula`)) join `curso` `c` on(`a`.`idCurso` = `c`.`idCurso`))  ;

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `aula`
--
ALTER TABLE `aula`
  ADD PRIMARY KEY (`idAula`),
  ADD KEY `idx_modulo` (`idModulo`),
  ADD KEY `idx_curso` (`idCurso`),
  ADD KEY `idx_ordem` (`ordem`);

--
-- Índices para tabela `categoria`
--
ALTER TABLE `categoria`
  ADD PRIMARY KEY (`idCategoria`),
  ADD UNIQUE KEY `nomeCategoria` (`nomeCategoria`);

--
-- Índices para tabela `certificado`
--
ALTER TABLE `certificado`
  ADD PRIMARY KEY (`idCertificado`),
  ADD UNIQUE KEY `codigoCertificado` (`codigoCertificado`),
  ADD UNIQUE KEY `unique_certificado` (`idUsuario`,`idCurso`),
  ADD KEY `idx_usuario` (`idUsuario`),
  ADD KEY `idx_curso` (`idCurso`),
  ADD KEY `idx_codigo` (`codigoCertificado`);

--
-- Índices para tabela `curso`
--
ALTER TABLE `curso`
  ADD PRIMARY KEY (`idCurso`),
  ADD KEY `idx_categoria` (`idCategoria`),
  ADD KEY `idx_dificuldade` (`dificuldade`),
  ADD KEY `idx_ativo` (`ativo`);

--
-- Índices para tabela `matricula`
--
ALTER TABLE `matricula`
  ADD PRIMARY KEY (`idMatricula`),
  ADD UNIQUE KEY `unique_matricula` (`idUsuario`,`idCurso`),
  ADD KEY `idx_usuario` (`idUsuario`),
  ADD KEY `idx_curso` (`idCurso`),
  ADD KEY `idx_status` (`status`);

--
-- Índices para tabela `modulo`
--
ALTER TABLE `modulo`
  ADD PRIMARY KEY (`idModulo`),
  ADD KEY `idx_curso` (`idCurso`),
  ADD KEY `idx_ordem` (`ordem`);

--
-- Índices para tabela `pagamento`
--
ALTER TABLE `pagamento`
  ADD PRIMARY KEY (`idPagamento`),
  ADD KEY `idx_usuario` (`idUsuario`),
  ADD KEY `idx_curso` (`idCurso`),
  ADD KEY `idx_status` (`status`);

--
-- Índices para tabela `progresso`
--
ALTER TABLE `progresso`
  ADD PRIMARY KEY (`idProgresso`),
  ADD UNIQUE KEY `unique_progresso` (`idUsuario`,`idAula`),
  ADD KEY `idx_usuario` (`idUsuario`),
  ADD KEY `idx_aula` (`idAula`),
  ADD KEY `idx_curso` (`idCurso`);

--
-- Índices para tabela `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`idUsuario`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_tipo` (`tipoUsuario`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `aula`
--
ALTER TABLE `aula`
  MODIFY `idAula` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de tabela `categoria`
--
ALTER TABLE `categoria`
  MODIFY `idCategoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de tabela `certificado`
--
ALTER TABLE `certificado`
  MODIFY `idCertificado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `curso`
--
ALTER TABLE `curso`
  MODIFY `idCurso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de tabela `matricula`
--
ALTER TABLE `matricula`
  MODIFY `idMatricula` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de tabela `modulo`
--
ALTER TABLE `modulo`
  MODIFY `idModulo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de tabela `pagamento`
--
ALTER TABLE `pagamento`
  MODIFY `idPagamento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de tabela `progresso`
--
ALTER TABLE `progresso`
  MODIFY `idProgresso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT de tabela `usuario`
--
ALTER TABLE `usuario`
  MODIFY `idUsuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `aula`
--
ALTER TABLE `aula`
  ADD CONSTRAINT `aula_ibfk_1` FOREIGN KEY (`idModulo`) REFERENCES `modulo` (`idModulo`) ON DELETE CASCADE,
  ADD CONSTRAINT `aula_ibfk_2` FOREIGN KEY (`idCurso`) REFERENCES `curso` (`idCurso`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `certificado`
--
ALTER TABLE `certificado`
  ADD CONSTRAINT `certificado_ibfk_1` FOREIGN KEY (`idUsuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE CASCADE,
  ADD CONSTRAINT `certificado_ibfk_2` FOREIGN KEY (`idCurso`) REFERENCES `curso` (`idCurso`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `curso`
--
ALTER TABLE `curso`
  ADD CONSTRAINT `curso_ibfk_1` FOREIGN KEY (`idCategoria`) REFERENCES `categoria` (`idCategoria`);

--
-- Limitadores para a tabela `matricula`
--
ALTER TABLE `matricula`
  ADD CONSTRAINT `matricula_ibfk_1` FOREIGN KEY (`idUsuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE CASCADE,
  ADD CONSTRAINT `matricula_ibfk_2` FOREIGN KEY (`idCurso`) REFERENCES `curso` (`idCurso`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `modulo`
--
ALTER TABLE `modulo`
  ADD CONSTRAINT `modulo_ibfk_1` FOREIGN KEY (`idCurso`) REFERENCES `curso` (`idCurso`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `pagamento`
--
ALTER TABLE `pagamento`
  ADD CONSTRAINT `pagamento_ibfk_1` FOREIGN KEY (`idUsuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE CASCADE,
  ADD CONSTRAINT `pagamento_ibfk_2` FOREIGN KEY (`idCurso`) REFERENCES `curso` (`idCurso`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `progresso`
--
ALTER TABLE `progresso`
  ADD CONSTRAINT `progresso_ibfk_1` FOREIGN KEY (`idUsuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE CASCADE,
  ADD CONSTRAINT `progresso_ibfk_2` FOREIGN KEY (`idAula`) REFERENCES `aula` (`idAula`) ON DELETE CASCADE,
  ADD CONSTRAINT `progresso_ibfk_3` FOREIGN KEY (`idCurso`) REFERENCES `curso` (`idCurso`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
