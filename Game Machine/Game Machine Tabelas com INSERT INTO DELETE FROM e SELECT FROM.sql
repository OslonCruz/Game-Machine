-- 1. CRIAÇÃO DAS TABELAS SEM CHAVES ESTRANGEIRAS (FK)

-- Tabela 1: JOGO
-- Armazena o produto final da empresa.
CREATE TABLE Jogo (
    idJogo      SERIAL PRIMARY KEY,      -- Chave Primária, auto-incrementável
    nome        VARCHAR(100) NOT NULL,   -- Nome do jogo (Obrigatório)
    descricao   TEXT,                    -- Descrição detalhada do jogo
    dataCriacao DATE DEFAULT CURRENT_DATE
);

-- Tabela 2: ENGINE
-- Lista as tecnologias bases de desenvolvimento (ex: Unity, Unreal, GameCore).
CREATE TABLE Engine (
    idEngine    SERIAL PRIMARY KEY,
    nomeEngine  VARCHAR(50) NOT NULL UNIQUE
);

-- Tabela 3: PLATAFORMA
-- Lista os canais de distribuição dos jogos (ex: Steam, PS5, Android).
CREATE TABLE Plataforma (
    idPlataforma    SERIAL PRIMARY KEY,
    nomePlataforma  VARCHAR(50) NOT NULL UNIQUE
);

-- Tabela 4: FUNCAO_USUARIO
-- Classifica os perfis dos desenvolvedores (ex: Programador, Designer, Artista).
CREATE TABLE FuncaoUsuario (
    idFuncao    SERIAL PRIMARY KEY,
    nomeFuncao  VARCHAR(50) NOT NULL UNIQUE
);

-- Tabela 5: BIBLIOTECA (Assets)
-- Repositório de assets reutilizáveis (imagens, áudios, scripts, modelos 3D).
CREATE TABLE Biblioteca (
    idAsset         SERIAL PRIMARY KEY,
    tipoAsset       VARCHAR(50) NOT NULL, -- Ex: 'Imagem', 'Áudio', 'Modelo 3D'
    descricaoAsset  VARCHAR(255),
    caminhoArquivo  VARCHAR(255) NOT NULL UNIQUE
);

-- Tabela 6: DESENVOLVEDOR_EXTERNO
-- Parceiros ou estúdios que licenciam a Engine proprietária.
CREATE TABLE DesenvolvedorExterno (
    idDevExt    SERIAL PRIMARY KEY,
    nomeEmpresa VARCHAR(100) NOT NULL,
    contato     VARCHAR(100),
    cnpj        VARCHAR(18) UNIQUE
);

-- 2. CRIAÇÃO DAS TABELAS COM DEPENDÊNCIAS DE FK SIMPLES

-- Tabela 7: VERSAO_ENGINE
-- Lista as versões específicas de uma Engine, dependendo da Tabela Engine.
CREATE TABLE VersaoEngine (
    idVersao      SERIAL PRIMARY KEY,
    idEngine      INTEGER NOT NULL,                    
    numeroVersao  VARCHAR(20) NOT NULL,
    dataRelease   DATE,
    
    FOREIGN KEY (idEngine) REFERENCES Engine(idEngine) 
        ON DELETE RESTRICT ON UPDATE CASCADE 
);

-- Tabela 8: USUARIO (Desenvolvedores Internos)
-- Lista os desenvolvedores internos, dependendo da Tabela FuncaoUsuario.
CREATE TABLE Usuario (
    idUsuario         SERIAL PRIMARY KEY,
    idFuncaoUsuario   INTEGER NOT NULL,               
    nome              VARCHAR(100) NOT NULL,
    email             VARCHAR(100) NOT NULL UNIQUE,
    dataContratacao   DATE DEFAULT CURRENT_DATE,
    
    FOREIGN KEY (idFuncaoUsuario) REFERENCES FuncaoUsuario(idFuncao) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Tabela 9: PROJETO
-- Representa a unidade de trabalho, dependendo de Jogo e VersaoEngine.
CREATE TABLE Projeto (
    idProjeto         SERIAL PRIMARY KEY,
    idJogo            INTEGER NOT NULL,
    idVersaoEngine    INTEGER NOT NULL,
    nomeProjeto       VARCHAR(100) NOT NULL,
    dataInicio        DATE NOT NULL,
    dataPrevTermino   DATE,
    status            VARCHAR(50) NOT NULL, -- Ex: 'Em Andamento', 'Concluído', 'Arquivado'
    
    FOREIGN KEY (idJogo) REFERENCES Jogo(idJogo) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (idVersaoEngine) REFERENCES VersaoEngine(idVersao) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 3. CRIAÇÃO DAS TABELAS ASSOCIATIVAS (Relacionamentos N:N)

-- Tabela 10: DESENVOLVEDOR_PROJETO
-- Associa N Usuários a N Projetos, registrando a participação e o progresso.
CREATE TABLE DesenvolvedorProjeto (
    idUsuario       INTEGER NOT NULL,
    idProjeto       INTEGER NOT NULL,
    progresso       NUMERIC(5,2) DEFAULT 0 CHECK (progresso >= 0 AND progresso <= 100), -- Percentual
    dataAlocacao    DATE DEFAULT CURRENT_DATE,
    
    PRIMARY KEY (idUsuario, idProjeto),
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (idProjeto) REFERENCES Projeto(idProjeto) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Tabela 11: PUBLICACAO
-- Associa N Jogos a N Plataformas, registrando a data de lançamento específica.
CREATE TABLE Publicacao (
    idJogo          INTEGER NOT NULL,
    idPlataforma    INTEGER NOT NULL,
    dataLancamento  DATE NOT NULL,
    urlStore        VARCHAR(255),
    
    PRIMARY KEY (idJogo, idPlataforma),
    FOREIGN KEY (idJogo) REFERENCES Jogo(idJogo) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (idPlataforma) REFERENCES Plataforma(idPlataforma) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Tabela 12: PROJETO_ASSET
-- Associa N Projetos a N Assets da Biblioteca, registrando a quantidade usada.
CREATE TABLE ProjetoAsset (
    idProjeto   INTEGER NOT NULL,
    idAsset     INTEGER NOT NULL,
    qtdUsada    INTEGER DEFAULT 1,
    
    PRIMARY KEY (idProjeto, idAsset),
    FOREIGN KEY (idProjeto) REFERENCES Projeto(idProjeto) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (idAsset) REFERENCES Biblioteca(idAsset) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Tabela 13: USO_ENGINE
-- Associa N Versões da Engine a N Desenvolvedores Externos, para controle de licença.
CREATE TABLE UsoEngine (
    idVersao            INTEGER NOT NULL,
    idDevExt            INTEGER NOT NULL,
    dataInicio          DATE NOT NULL,
    statusSuporte       VARCHAR(50) NOT NULL, -- Ex: 'Ativo', 'Expirado', 'Pendente'
    licencaValidaAte    DATE,
    
    PRIMARY KEY (idVersao, idDevExt),
    FOREIGN KEY (idVersao) REFERENCES VersaoEngine(idVersao) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (idDevExt) REFERENCES DesenvolvedorExterno(idDevExt) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Foi utilizada uma IA para geração de dados e organização dos comandos "INSERT INTO", segue abaixo...

-- [i. INSERT] 1. Insere funções de usuário
INSERT INTO FuncaoUsuario (nomeFuncao) 
VALUES ('Programador Sênior'), 
       ('Artista 2D/3D'), 
       ('Game Designer'), 
       ('Gerente de Projeto');

-- [i. INSERT] 2. Insere Engines
INSERT INTO Engine (nomeEngine) 
VALUES ('GameCore v1.0'), 
       ('Unity 2024 LTS');

-- [i. INSERT] 3. Insere Plataformas
INSERT INTO Plataforma (nomePlataforma) 
VALUES ('Steam PC'), 
       ('PlayStation 5'), 
       ('Mobile Android');

-- [i. INSERT] 4. Insere Jogos
INSERT INTO Jogo (nome, descricao) 
VALUES ('Chronos Rift', 'RPG de ação e ficção científica.'), 
       ('Dino Dash Racing', 'Jogo de corrida casual para mobile.');

-- [i. INSERT] 5. Insere Assets na Biblioteca
INSERT INTO Biblioteca (tipoAsset, descricaoAsset, caminhoArquivo) 
VALUES ('Modelo 3D', 'Personagem principal, herói.', '/assets/models/hero.fbx'),
       ('Áudio', 'Música tema da fase 1.', '/assets/audio/theme1.mp3');

-- [i. INSERT] 6. Insere Desenvolvedor Externo (Parceiro)
INSERT INTO DesenvolvedorExterno (nomeEmpresa, contato) 
VALUES ('Aero Studios', 'contato@aero.com.br');

-- [i. INSERT] 7. Insere Versões de Engine (FK para Engine)
-- Usa idEngine = 1 (GameCore v1.0) e idEngine = 2 (Unity 2024 LTS)
INSERT INTO VersaoEngine (idEngine, numeroVersao, dataRelease) 
VALUES (1, '1.0.12', '2025-05-01'),
       (2, '2024.1.5f1', '2025-07-20');

-- [i. INSERT] 8. Insere Usuários (FK para FuncaoUsuario)
-- Usa idFuncaoUsuario = 1 (Programador) e idFuncaoUsuario = 4 (Gerente)
INSERT INTO Usuario (idFuncaoUsuario, nome, email, dataContratacao) 
VALUES (1, 'Alan Smith', 'alan@game.com', '2024-01-15'),
       (4, 'Danielly Reis', 'dani@game.com', '2023-05-20');

-- [i. INSERT] 9. Insere Projetos (FK para Jogo e VersaoEngine)
-- Usa idJogo = 1 ('Chronos Rift') e idVersaoEngine = 1 (GameCore 1.0.12)
INSERT INTO Projeto (idJogo, idVersaoEngine, nomeProjeto, dataInicio, dataPrevTermino, status) 
VALUES (1, 1, 'CR - Módulo de Combate', '2025-08-01', '2026-03-30', 'Em Andamento'),
       (2, 2, 'DD - UI/UX Mobile', '2025-09-10', '2025-12-15', 'Em Andamento');

-- [i. INSERT] 10. Associa Desenvolvedores a Projetos (FK para Usuario e Projeto)
-- Associa Alan Smith (idUsuario=1) ao Projeto CR - Módulo de Combate (idProjeto=1)
INSERT INTO DesenvolvedorProjeto (idUsuario, idProjeto, progresso) 
VALUES (1, 1, 65.50);

-- [i. INSERT] 11. Registra a Publicação do Jogo (FK para Jogo e Plataforma)
-- Publica 'Chronos Rift' (idJogo=1) na 'Steam PC' (idPlataforma=1)
INSERT INTO Publicacao (idJogo, idPlataforma, dataLancamento) 
VALUES (1, 1, '2026-04-10');

-- [i. INSERT] 12. Associa Assets a Projetos (FK para Projeto e Biblioteca)
-- Projeto 'CR - Módulo de Combate' (idProjeto=1) usa Asset 'Modelo 3D' (idAsset=1)
INSERT INTO ProjetoAsset (idProjeto, idAsset, qtdUsada) 
VALUES (1, 1, 4);

-- [i. INSERT] 13. Registra o Uso da Engine por Parceiro (FK para VersaoEngine e DevExt)
-- Aero Studios (idDevExt=1) usa Versão 1.0.12 (idVersao=1)
INSERT INTO UsoEngine (idVersao, idDevExt, dataInicio, statusSuporte, licencaValidaAte) 
VALUES (1, 1, '2025-10-01', 'Ativo', '2026-10-01');

-- Para facilitar a inserção de dados, solicitei à IA para gerar os dados a partir de um arquivo csv.
-- Vamos precisar apagar os dados para inserir os dados a partir do CSV devido aos cadastros de itens SERIAL.

-- Antes para atender o topico da tarefa ii. Remover dados das tabelas; vou remover um dos dados.
-- Remove um projeto específico que foi cancelado antes do início.

DELETE FROM Projeto
-- Condição: Apaga o projeto com ID 2 (CR - Expansão I: O Despertar) e status 'Em Planejamento'
WHERE idProjeto = 2 AND status = 'Em Planejamento';

-- Agora vamos seguir com a limpeza de dados de todas as tabelas...
-- TRUNCATE TABLE: Comando mais rápido para remover todos os dados e resetar contadores.
-- CASCADE: Remove os dados das tabelas que fazem referência a estas.
-- RESTART IDENTITY: Reseta o contador SERIAL das chaves primárias para 1.
TRUNCATE TABLE 
    Jogo, Engine, Plataforma, FuncaoUsuario, Biblioteca, DesenvolvedorExterno,
    VersaoEngine, Usuario, Projeto, 
    DesenvolvedorProjeto, Publicacao, ProjetoAsset, UsoEngine
RESTART IDENTITY CASCADE;

-- Apaga os dados das tabelas associativas e de relacionamento (devem ser apagadas primeiro devido às FKs)
TRUNCATE TABLE DesenvolvedorProjeto RESTART IDENTITY;
TRUNCATE TABLE Publicacao RESTART IDENTITY;
TRUNCATE TABLE ProjetoAsset RESTART IDENTITY;
TRUNCATE TABLE UsoEngine RESTART IDENTITY;

-- Apaga os dados das tabelas com dependências de FK simples
TRUNCATE TABLE Projeto RESTART IDENTITY;
TRUNCATE TABLE Usuario RESTART IDENTITY;
TRUNCATE TABLE VersaoEngine RESTART IDENTITY;

-- Apaga os dados das tabelas mestras (sem FKs de entrada)
TRUNCATE TABLE Jogo RESTART IDENTITY;
TRUNCATE TABLE Engine RESTART IDENTITY;
TRUNCATE TABLE Plataforma RESTART IDENTITY;
TRUNCATE TABLE FuncaoUsuario RESTART IDENTITY;
TRUNCATE TABLE Biblioteca RESTART IDENTITY;
TRUNCATE TABLE DesenvolvedorExterno RESTART IDENTITY;

SELECT COUNT(*) FROM jogo;
SELECT COUNT(*) FROM Engine;
SELECT COUNT(*) FROM Plataforma;
SELECT COUNT(*) FROM FuncaoUsuario;
SELECT COUNT(*) FROM Biblioteca;
SELECT COUNT(*) FROM DesenvolvedorExterno;
-- Tabelas com FKs Simples
SELECT COUNT(*) FROM VersaoEngine;
SELECT COUNT(*) FROM Usuario;
SELECT COUNT(*) FROM Projeto;
-- Tabelas Associativas (N:N)
SELECT COUNT(*) FROM DesenvolvedorProjeto;
SELECT COUNT(*) FROM Publicacao;
SELECT COUNT(*) FROM ProjetoAsset;
SELECT COUNT(*) FROM UsoEngine;

SELECT * FROM Jogo;


-- #### APRESENTAR 10 CONSULTAS DIFERENTES ####
-- 01. Consulta (LIKE): Lista todos os jogos cujo nome começa com 'C'.	
SELECT nome, descricao FROM Jogo WHERE nome LIKE 'C%';

-- 02. Consulta (AND / ORDER BY): Lista programadores (idFuncaoUsuario = 1, 2 ou 3) contratados após 2024, ordenados do mais novo ao mais antigo na empresa.
SELECT nome, dataContratacao, idFuncaoUsuario 
FROM Usuario
WHERE idFuncaoUsuario IN (1, 2, 3) AND dataContratacao > '2024-01-01'
ORDER BY dataContratacao DESC;

-- 03. Consulta (OR): Lista os projetos que estão 'Em Andamento' OU 'Em Planejamento'.
SELECT idProjeto, nomeProjeto, status
FROM Projeto
WHERE status = 'Em Andamento' OR status = 'Em Planejamento';

-- 04. Consulta (Operador Aritmético): Calcula a duração (em dias) de projetos CONCLUÍDOS.
SELECT nomeProjeto, (dataPrevTermino - dataInicio) AS duracao_em_dias
FROM Projeto
WHERE status = 'Concluído';

-- 05. Consulta (NOT IN): Lista os Desenvolvedores Externos que NÃO estão nas empresas com ID 1, 2 ou 3.
SELECT nomeEmpresa, contato
FROM DesenvolvedorExterno
WHERE idDevExt NOT IN (1, 2, 3);

-- 06. Consulta (JOIN / GROUP BY): Conta quantos desenvolvedores estão alocados em cada projeto.
SELECT P.nomeProjeto, COUNT(DP.idUsuario) AS total_desenvolvedores
FROM Projeto P
JOIN DesenvolvedorProjeto DP ON P.idProjeto = DP.idProjeto
GROUP BY P.nomeProjeto
ORDER BY total_desenvolvedores DESC;

-- 07. Consulta (JOIN / GROUP BY / HAVING): Lista os Jogos que foram publicados em mais de uma plataforma.
SELECT J.nome AS NomeDoJogo, COUNT(P.idPlataforma) AS TotalDePlataformas
FROM Jogo J
JOIN Publicacao P ON J.idJogo = P.idJogo
GROUP BY J.nome
HAVING COUNT(P.idPlataforma) > 1;

-- 08. Consulta (JOIN / IN): Lista o nome do projeto e a Engine que usam versões da 'GameCore'.
SELECT P.nomeProjeto, E.nomeEngine || ' (' || VE.numeroVersao || ')' AS EngineUtilizada
FROM Projeto P
JOIN VersaoEngine VE ON P.idVersaoEngine = VE.idVersao
JOIN Engine E ON VE.idEngine = E.idEngine
WHERE E.nomeEngine IN ('GameCore v1.0', 'GameCore v1.1');

-- 09. Consulta (EXISTS): Lista os nomes dos Desenvolvedores Externos que possuem pelo menos uma licença de Engine com status de Suporte ATIVO.
SELECT nomeEmpresa
FROM DesenvolvedorExterno DE
WHERE EXISTS (
    SELECT 1 
    FROM UsoEngine UE
    WHERE UE.idDevExt = DE.idDevExt AND UE.statusSuporte = 'Ativo'
);

-- 10. Consulta (Múltiplos JOIN): Lista o Nome do Jogo, Nome do Projeto e o Desenvolvedor alocado, para rastreamento completo.
SELECT J.nome AS Jogo, P.nomeProjeto AS Projeto, U.nome AS Desenvolvedor, DP.progresso
FROM Jogo J
JOIN Projeto P ON J.idJogo = P.idJogo
JOIN DesenvolvedorProjeto DP ON P.idProjeto = DP.idProjeto
JOIN Usuario U ON DP.idUsuario = U.idUsuario
ORDER BY J.nome, P.nomeProjeto;