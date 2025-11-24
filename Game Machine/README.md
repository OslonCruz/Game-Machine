# 🚀 Game Machine

### Sistema de Gerenciamento de Desenvolvimento de Jogos

Este repositório contém o projeto de banco de dados para o sistema
**Game Machine**, criado para gerenciar o ciclo completo de
desenvolvimento e distribuição de jogos digitais.

------------------------------------------------------------------------

## 📄 Descrição do Projeto

O **Game Machine** é um banco de dados relacional projetado para atender
às necessidades de uma empresa de desenvolvimento de jogos digitais,
permitindo rastrear:

-   🎮 **Produtos (Jogos)**
-   🛠️ **Trabalhos (Projetos)** --- jogo base, DLCs, ports
-   👥 **Recursos Humanos** --- usuários, desenvolvedores e suas
    alocações
-   🧩 **Tecnologia** --- engines e suas versões
-   🌐 **Distribuição** --- publicação em múltiplas plataformas
-   🤝 **Parcerias** --- licenciamento para desenvolvedores externos

------------------------------------------------------------------------

## 🛠️ Estrutura e Tecnologia

### 1. 🧠 Modelo Entidade-Relacionamento (MER)

Principais componentes:

-   Entidades: Jogo, Projeto, Usuario, Engine, Plataforma
-   Relacionamentos N:N:
    -   `DesenvolvedorProjeto`
    -   `Publicacao`
    -   `UsoEngine`
-   Modelo final com **13 tabelas**

### 2. 📊 Modelo Relacional e Normalização

Totalmente normalizado até a **3FN**, com integridade referencial
garantida.

### 3. 🧩 Implementação SQL

-   **Arquivo principal:** `GameMachine.sql`
-   Inclui `CREATE TABLE`, `INSERT`, `UPDATE`, `DELETE` e `SELECT`.

------------------------------------------------------------------------

## 🚀 Como Utilizar

### Criar Estrutura

Execute todos os `CREATE TABLE` do arquivo principal.

### Popular Banco

Métodos:

-   Inserções manuais (`INSERT INTO`)
-   Importação em massa (`COPY` / `LOAD DATA`)

Limpeza completa:

``` sql
TRUNCATE TABLE Jogo, Projeto, Usuario, DesenvolvedorProjeto, Publicacao
RESTART IDENTITY CASCADE;
```

------------------------------------------------------------------------

## 🔍 Consultas de Demonstração

### Jogos publicados em mais de uma plataforma

``` sql
SELECT J.nome AS NomeDoJogo, COUNT(P.idPlataforma) AS TotalDePlataformas
FROM Jogo J
JOIN Publicacao P ON J.idJogo = P.idJogo
GROUP BY J.nome
HAVING COUNT(P.idPlataforma) > 1;
```

### Projetos usando apenas versões da Engine 'GameCore'

``` sql
SELECT P.nomeProjeto
FROM Projeto P
JOIN VersaoEngine VE ON P.idVersaoEngine = VE.idVersao
WHERE VE.idEngine IN (
    SELECT idEngine FROM Engine WHERE nomeEngine LIKE 'GameCore%'
);
```

### Auditoria de Licenças Ativas

``` sql
SELECT nomeEmpresa
FROM DesenvolvedorExterno DE
WHERE EXISTS (
    SELECT 1 
    FROM UsoEngine UE
    WHERE UE.idDevExt = DE.idDevExt AND UE.statusSuporte = 'Ativo'
);
```

------------------------------------------------------------------------

## 👥 Contato

**Desenvolvedores:** Nome dos Membros do Grupo\
**Disciplina:** Banco de Dados I --- EaD\
**Data:** Novembro/2025
