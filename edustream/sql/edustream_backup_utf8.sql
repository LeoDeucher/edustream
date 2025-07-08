-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geraÃ§Ã£o: 05/07/2025 Ã s 23:49
-- VersÃ£o do servidor: 10.4.32-MariaDB
-- VersÃ£o do PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `edustream_backup`
--

DELIMITER $$
--
-- Procedimentos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_matricular_usuario` (IN `p_idUsuario` INT, IN `p_idCurso` INT)   BEGIN
    
    IF NOT EXISTS (
        SELECT 1 FROM matricula 
        WHERE idUsuario = p_idUsuario AND idCurso = p_idCurso
    ) THEN
        
        INSERT INTO matricula (idUsuario, idCurso, dataMatricula)
        VALUES (p_idUsuario, p_idCurso, CURDATE());
    ELSE
        
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usu rio j  est  matriculado neste curso.';
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `aula`
--
-- Erro ao ler a estrutura para a tabela edustream_backup.aula: #1932 - Table &#039;edustream_backup.aula&#039; doesn&#039;t exist in engine
-- Erro ao ler dados para tabela edustream_backup.aula: #1064 - VocÃª tem um erro de sintaxe no seu SQL prÃ³ximo a &#039;FROM `edustream_backup`.`aula`&#039; na linha 1

-- --------------------------------------------------------

--
-- Estrutura para tabela `certificado`
--
-- Erro ao ler a estrutura para a tabela edustream_backup.certificado: #1932 - Table &#039;edustream_backup.certificado&#039; doesn&#039;t exist in engine
-- Erro ao ler dados para tabela edustream_backup.certificado: #1064 - VocÃª tem um erro de sintaxe no seu SQL prÃ³ximo a &#039;FROM `edustream_backup`.`certificado`&#039; na linha 1

--
-- Acionadores `certificado`
--
DELIMITER $$
CREATE TRIGGER `trg_before_insert_certificado` BEFORE INSERT ON `certificado` FOR EACH ROW BEGIN
    IF NEW.dataEmissao IS NULL THEN
        SET NEW.dataEmissao = CURDATE();
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `curso`
--
-- Erro ao ler a estrutura para a tabela edustream_backup.curso: #1932 - Table &#039;edustream_backup.curso&#039; doesn&#039;t exist in engine
-- Erro ao ler dados para tabela edustream_backup.curso: #1064 - VocÃª tem um erro de sintaxe no seu SQL prÃ³ximo a &#039;FROM `edustream_backup`.`curso`&#039; na linha 1

-- --------------------------------------------------------

--
-- Estrutura para tabela `matricula`
--
-- Erro ao ler a estrutura para a tabela edustream_backup.matricula: #1932 - Table &#039;edustream_backup.matricula&#039; doesn&#039;t exist in engine
-- Erro ao ler dados para tabela edustream_backup.matricula: #1064 - VocÃª tem um erro de sintaxe no seu SQL prÃ³ximo a &#039;FROM `edustream_backup`.`matricula`&#039; na linha 1

-- --------------------------------------------------------

--
-- Estrutura para tabela `progresso`
--
-- Erro ao ler a estrutura para a tabela edustream_backup.progresso: #1932 - Table &#039;edustream_backup.progresso&#039; doesn&#039;t exist in engine
-- Erro ao ler dados para tabela edustream_backup.progresso: #1064 - VocÃª tem um erro de sintaxe no seu SQL prÃ³ximo a &#039;FROM `edustream_backup`.`progresso`&#039; na linha 1

-- --------------------------------------------------------

--
-- Estrutura para tabela `usuario`
--
-- Erro ao ler a estrutura para a tabela edustream_backup.usuario: #1932 - Table &#039;edustream_backup.usuario&#039; doesn&#039;t exist in engine
-- Erro ao ler dados para tabela edustream_backup.usuario: #1064 - VocÃª tem um erro de sintaxe no seu SQL prÃ³ximo a &#039;FROM `edustream_backup`.`usuario`&#039; na linha 1

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `vw_certificados_emitidos`
-- (Veja abaixo para a visÃ£o atual)
--
CREATE TABLE `vw_certificados_emitidos` (
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `vw_progresso_usuario`
-- (Veja abaixo para a visÃ£o atual)
--
CREATE TABLE `vw_progresso_usuario` (
);

-- --------------------------------------------------------

--
-- Estrutura para view `vw_certificados_emitidos`
--
DROP TABLE IF EXISTS `vw_certificados_emitidos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_certificados_emitidos`  AS SELECT `u`.`nomeUsuario` AS `nomeUsuario`, `c`.`tituloCurso` AS `tituloCurso`, `cert`.`dataEmissao` AS `dataEmissao` FROM ((`edustream`.`certificado` `cert` join `edustream`.`usuario` `u` on(`cert`.`idUsuario` = `u`.`idUsuario`)) join `edustream`.`curso` `c` on(`cert`.`idCurso` = `c`.`idCurso`)) ;

-- --------------------------------------------------------

--
-- Estrutura para view `vw_progresso_usuario`
--
DROP TABLE IF EXISTS `vw_progresso_usuario`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_progresso_usuario`  AS SELECT `u`.`nomeUsuario` AS `nomeUsuario`, `c`.`tituloCurso` AS `tituloCurso`, `a`.`tituloAula` AS `tituloAula`, `p`.`dataVisualizacao` AS `dataVisualizacao` FROM (((`edustream`.`progresso` `p` join `edustream`.`usuario` `u` on(`p`.`idUsuario` = `u`.`idUsuario`)) join `edustream`.`aula` `a` on(`p`.`idAula` = `a`.`idAula`)) join `edustream`.`curso` `c` on(`a`.`idCurso` = `c`.`idCurso`)) ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
