-- ========================================
-- EDUSTREAM - Sistema de Cursos Online
-- Estrutura Completa do Banco de Dados
-- ========================================

-- Criação do banco de dados
CREATE DATABASE IF NOT EXISTS edustream CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE edustream;

-- ========================================
-- TABELA: usuario
-- ========================================
CREATE TABLE usuario (
    idUsuario INT AUTO_INCREMENT PRIMARY KEY,
    nomeUsuario VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    tipoUsuario ENUM('comum', 'admin') DEFAULT 'comum',
    dataCadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dataUltimoLogin TIMESTAMP NULL,
    ativo BOOLEAN DEFAULT TRUE,
    fotoPerfil VARCHAR(255) NULL,
    INDEX idx_email (email),
    INDEX idx_tipo (tipoUsuario)
);

-- ========================================
-- TABELA: categoria
-- ========================================
CREATE TABLE categoria (
    idCategoria INT AUTO_INCREMENT PRIMARY KEY,
    nomeCategoria VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- TABELA: curso
-- ========================================
CREATE TABLE curso (
    idCurso INT AUTO_INCREMENT PRIMARY KEY,
    tituloCurso VARCHAR(200) NOT NULL,
    descricao TEXT,
    resumo TEXT,
    idCategoria INT,
    dificuldade ENUM('iniciante', 'intermediario', 'avancado') DEFAULT 'iniciante',
    valor DECIMAL(10,2) DEFAULT 0.00,
    autor VARCHAR(100),
    imagemCapa VARCHAR(255),
    ativo BOOLEAN DEFAULT TRUE,
    dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dataAtualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    totalAulas INT DEFAULT 0,
    totalModulos INT DEFAULT 0,
    duracaoTotal INT DEFAULT 0, -- em minutos
    FOREIGN KEY (idCategoria) REFERENCES categoria(idCategoria),
    INDEX idx_categoria (idCategoria),
    INDEX idx_dificuldade (dificuldade),
    INDEX idx_ativo (ativo)
);

-- ========================================
-- TABELA: modulo
-- ========================================
CREATE TABLE modulo (
    idModulo INT AUTO_INCREMENT PRIMARY KEY,
    idCurso INT NOT NULL,
    tituloModulo VARCHAR(200) NOT NULL,
    descricao TEXT,
    ordem INT NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (idCurso) REFERENCES curso(idCurso) ON DELETE CASCADE,
    INDEX idx_curso (idCurso),
    INDEX idx_ordem (ordem)
);

-- ========================================
-- TABELA: aula
-- ========================================
CREATE TABLE aula (
    idAula INT AUTO_INCREMENT PRIMARY KEY,
    idModulo INT NOT NULL,
    idCurso INT NOT NULL,
    tituloAula VARCHAR(200) NOT NULL,
    descricao TEXT,
    conteudo LONGTEXT,
    videoUrl VARCHAR(500),
    duracao INT DEFAULT 0, -- em minutos
    ordem INT NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (idModulo) REFERENCES modulo(idModulo) ON DELETE CASCADE,
    FOREIGN KEY (idCurso) REFERENCES curso(idCurso) ON DELETE CASCADE,
    INDEX idx_modulo (idModulo),
    INDEX idx_curso (idCurso),
    INDEX idx_ordem (ordem)
);

-- ========================================
-- TABELA: matricula
-- ========================================
CREATE TABLE matricula (
    idMatricula INT AUTO_INCREMENT PRIMARY KEY,
    idUsuario INT NOT NULL,
    idCurso INT NOT NULL,
    dataMatricula TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dataUltimoacesso TIMESTAMP NULL,
    status ENUM('ativa', 'concluida', 'cancelada') DEFAULT 'ativa',
    progressoGeral DECIMAL(5,2) DEFAULT 0.00, -- percentual de 0 a 100
    FOREIGN KEY (idUsuario) REFERENCES usuario(idUsuario) ON DELETE CASCADE,
    FOREIGN KEY (idCurso) REFERENCES curso(idCurso) ON DELETE CASCADE,
    UNIQUE KEY unique_matricula (idUsuario, idCurso),
    INDEX idx_usuario (idUsuario),
    INDEX idx_curso (idCurso),
    INDEX idx_status (status)
);

-- ========================================
-- TABELA: progresso
-- ========================================
CREATE TABLE progresso (
    idProgresso INT AUTO_INCREMENT PRIMARY KEY,
    idUsuario INT NOT NULL,
    idAula INT NOT NULL,
    idCurso INT NOT NULL,
    dataVisualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    concluida BOOLEAN DEFAULT FALSE,
    tempoAssistido INT DEFAULT 0, -- em segundos
    FOREIGN KEY (idUsuario) REFERENCES usuario(idUsuario) ON DELETE CASCADE,
    FOREIGN KEY (idAula) REFERENCES aula(idAula) ON DELETE CASCADE,
    FOREIGN KEY (idCurso) REFERENCES curso(idCurso) ON DELETE CASCADE,
    UNIQUE KEY unique_progresso (idUsuario, idAula),
    INDEX idx_usuario (idUsuario),
    INDEX idx_aula (idAula),
    INDEX idx_curso (idCurso)
);

-- ========================================
-- TABELA: certificado
-- ========================================
CREATE TABLE certificado (
    idCertificado INT AUTO_INCREMENT PRIMARY KEY,
    idUsuario INT NOT NULL,
    idCurso INT NOT NULL,
    dataEmissao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    codigoCertificado VARCHAR(50) UNIQUE NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (idUsuario) REFERENCES usuario(idUsuario) ON DELETE CASCADE,
    FOREIGN KEY (idCurso) REFERENCES curso(idCurso) ON DELETE CASCADE,
    UNIQUE KEY unique_certificado (idUsuario, idCurso),
    INDEX idx_usuario (idUsuario),
    INDEX idx_curso (idCurso),
    INDEX idx_codigo (codigoCertificado)
);

-- ========================================
-- TABELA: pagamento
-- ========================================
CREATE TABLE pagamento (
    idPagamento INT AUTO_INCREMENT PRIMARY KEY,
    idUsuario INT NOT NULL,
    idCurso INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    metodoPagamento ENUM('cartao', 'pix', 'boleto') NOT NULL,
    status ENUM('pendente', 'aprovado', 'rejeitado', 'cancelado') DEFAULT 'pendente',
    dataPagamento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dataVencimento TIMESTAMP NULL,
    transacaoId VARCHAR(100),
    FOREIGN KEY (idUsuario) REFERENCES usuario(idUsuario) ON DELETE CASCADE,
    FOREIGN KEY (idCurso) REFERENCES curso(idCurso) ON DELETE CASCADE,
    INDEX idx_usuario (idUsuario),
    INDEX idx_curso (idCurso),
    INDEX idx_status (status)
);

-- ========================================
-- VIEWS
-- ========================================

-- View para certificados emitidos
CREATE VIEW vw_certificados_emitidos AS
SELECT 
    u.nomeUsuario,
    u.email,
    c.tituloCurso,
    cert.dataEmissao,
    cert.codigoCertificado
FROM certificado cert
JOIN usuario u ON cert.idUsuario = u.idUsuario
JOIN curso c ON cert.idCurso = c.idCurso
WHERE cert.ativo = TRUE;

-- View para progresso do usuário
CREATE VIEW vw_progresso_usuario AS
SELECT 
    u.nomeUsuario,
    u.email,
    c.tituloCurso,
    a.tituloAula,
    p.dataVisualizacao,
    p.concluida,
    p.tempoAssistido
FROM progresso p
JOIN usuario u ON p.idUsuario = u.idUsuario
JOIN aula a ON p.idAula = a.idAula
JOIN curso c ON a.idCurso = c.idCurso;

-- View para estatísticas de cursos
CREATE VIEW vw_estatisticas_cursos AS
SELECT 
    c.idCurso,
    c.tituloCurso,
    cat.nomeCategoria,
    COUNT(DISTINCT m.idUsuario) as totalMatriculas,
    COUNT(DISTINCT cert.idCertificado) as totalCertificados,
    AVG(m.progressoGeral) as progressoMedio,
    c.valor,
    c.dataCriacao
FROM curso c
LEFT JOIN categoria cat ON c.idCategoria = cat.idCategoria
LEFT JOIN matricula m ON c.idCurso = m.idCurso AND m.status = 'ativa'
LEFT JOIN certificado cert ON c.idCurso = cert.idCurso AND cert.ativo = TRUE
WHERE c.ativo = TRUE
GROUP BY c.idCurso;

-- ========================================
-- STORED PROCEDURES
-- ========================================

-- Procedure para matricular usuário
DELIMITER $$
CREATE PROCEDURE sp_matricular_usuario(
    IN p_idUsuario INT,
    IN p_idCurso INT
)
BEGIN
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

-- Procedure para atualizar progresso
CREATE PROCEDURE sp_atualizar_progresso(
    IN p_idUsuario INT,
    IN p_idAula INT,
    IN p_tempoAssistido INT,
    IN p_concluida BOOLEAN
)
BEGIN
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

-- Procedure para gerar certificado
CREATE PROCEDURE sp_gerar_certificado(
    IN p_idUsuario INT,
    IN p_idCurso INT
)
BEGIN
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

DELIMITER ;

-- ========================================
-- TRIGGERS
-- ========================================

-- Trigger para atualizar contadores do curso
DELIMITER $$
CREATE TRIGGER trg_after_insert_aula
AFTER INSERT ON aula
FOR EACH ROW
BEGIN
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
END$$

-- Trigger para data de emissão do certificado
CREATE TRIGGER trg_before_insert_certificado
BEFORE INSERT ON certificado
FOR EACH ROW
BEGIN
    IF NEW.dataEmissao IS NULL THEN
        SET NEW.dataEmissao = NOW();
    END IF;
END$$

DELIMITER ;

