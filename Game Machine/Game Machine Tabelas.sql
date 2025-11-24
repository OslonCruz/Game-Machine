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