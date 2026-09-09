-- ============================================
-- DROP TABLES (FILHAS → PAIS)
-- ============================================

DROP TABLE IF EXISTS Colheita;
DROP TABLE IF EXISTS AtividadeInsumo;
DROP TABLE IF EXISTS AtividadeAgricola;
DROP TABLE IF EXISTS Insumo;
DROP TABLE IF EXISTS Maquina;
DROP TABLE IF EXISTS Funcionario;
DROP TABLE IF EXISTS Talhao;
DROP TABLE IF EXISTS Cultura;
DROP TABLE IF EXISTS Propriedade;
DROP TABLE IF EXISTS TipoOperacao;
DROP TABLE IF EXISTS TipoInsumo;
DROP TABLE IF EXISTS CargoFuncionario;

-- ============================================
-- CREATE TABLES (PAIS → FILHAS)
-- ============================================

CREATE TABLE CargoFuncionario (
    id SERIAL PRIMARY KEY,
    descricao VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE TipoInsumo (
    id SERIAL PRIMARY KEY,
    descricao VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE TipoOperacao (
    id SERIAL PRIMARY KEY,
    descricao VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Propriedade (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    municipio VARCHAR(80) NOT NULL,
    area_total_ha NUMERIC(10,2) NOT NULL CHECK (area_total_ha > 0)
);

CREATE TABLE Cultura (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(60) NOT NULL,
    ciclo_dias INT NOT NULL CHECK (ciclo_dias > 0)
);

CREATE TABLE Talhao (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL,
    area_ha NUMERIC(8,2) NOT NULL CHECK (area_ha > 0),
    idPropriedade INT NOT NULL,
    CONSTRAINT fk_talhao_propriedade
        FOREIGN KEY (idPropriedade)
        REFERENCES Propriedade(id)
        ON DELETE RESTRICT
);

CREATE TABLE Funcionario (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    idCargo INT NOT NULL,
    CONSTRAINT fk_funcionario_cargo
        FOREIGN KEY (idCargo)
        REFERENCES CargoFuncionario(id)
        ON DELETE RESTRICT
);

CREATE TABLE Maquina (
    id SERIAL PRIMARY KEY,
    modelo VARCHAR(80) NOT NULL,
    tipo VARCHAR(40) NOT NULL,
    ano_fabricacao INT NOT NULL CHECK (ano_fabricacao >= 1970)
);

CREATE TABLE Insumo (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    unidade_medida VARCHAR(10) NOT NULL,
    custo_unitario NUMERIC(10,2) NOT NULL CHECK (custo_unitario >= 0),
    idTipoInsumo INT NOT NULL,
    CONSTRAINT fk_insumo_tipo
        FOREIGN KEY (idTipoInsumo)
        REFERENCES TipoInsumo(id)
        ON DELETE RESTRICT
);

CREATE TABLE AtividadeAgricola (
    id SERIAL PRIMARY KEY,
    data_operacao DATE NOT NULL,
    idTalhao INT NOT NULL,
    idCultura INT NOT NULL,
    idFuncionario INT NOT NULL,
    idMaquina INT,
    idTipoOperacao INT NOT NULL,
    CONSTRAINT fk_atividade_talhao
        FOREIGN KEY (idTalhao)
        REFERENCES Talhao(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_atividade_cultura
        FOREIGN KEY (idCultura)
        REFERENCES Cultura(id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_atividade_funcionario
        FOREIGN KEY (idFuncionario)
        REFERENCES Funcionario(id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_atividade_maquina
        FOREIGN KEY (idMaquina)
        REFERENCES Maquina(id)
        ON DELETE SET NULL,
    CONSTRAINT fk_atividade_operacao
        FOREIGN KEY (idTipoOperacao)
        REFERENCES TipoOperacao(id)
        ON DELETE RESTRICT
);

CREATE TABLE AtividadeInsumo (
    id SERIAL PRIMARY KEY,
    idAtividade INT NOT NULL,
    idInsumo INT NOT NULL,
    quantidade_aplicada NUMERIC(10,2) NOT NULL CHECK (quantidade_aplicada > 0),
    CONSTRAINT fk_item_atividade
        FOREIGN KEY (idAtividade)
        REFERENCES AtividadeAgricola(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_item_insumo
        FOREIGN KEY (idInsumo)
        REFERENCES Insumo(id)
        ON DELETE RESTRICT
);

CREATE TABLE Colheita (
    id SERIAL PRIMARY KEY,
    data_colheita DATE NOT NULL,
    quantidade_kg NUMERIC(12,2) NOT NULL CHECK (quantidade_kg > 0),
    valor_venda_total NUMERIC(12,2) NOT NULL CHECK (valor_venda_total >= 0),
    idTalhao INT NOT NULL,
    idCultura INT NOT NULL,
    CONSTRAINT fk_colheita_talhao
        FOREIGN KEY (idTalhao)
        REFERENCES Talhao(id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_colheita_cultura
        FOREIGN KEY (idCultura)
        REFERENCES Cultura(id)
        ON DELETE RESTRICT
);

-- ============================================
-- INSERTS TABELAS AUXILIARES
-- ============================================

INSERT INTO CargoFuncionario (descricao) VALUES
('Operador de Maquinas'),
('Engenheiro Agronomo'),
('Trabalhador Rural');

INSERT INTO TipoInsumo (descricao) VALUES
('Fertilizante'),
('Defensivo Quimico'),
('Semente');

INSERT INTO TipoOperacao (descricao) VALUES
('Preparo de Solo'),
('Plantio'),
('Pulverizacao');

-- ============================================
-- INSERTS TABELAS CORE
-- ============================================

-- 30 Propriedades
INSERT INTO Propriedade (nome, municipio, area_total_ha)
SELECT 
    'Fazenda Santa ' || gs,
    'Municipio ' || ((gs % 5) + 1),
    (random() * 800 + 100)::numeric(10,2)
FROM generate_series(1, 30) AS gs;

-- 30 Culturas
INSERT INTO Cultura (nome, ciclo_dias)
SELECT 
    'Cultura Variedade ' || gs,
    (random() * 90 + 60)::int
FROM generate_series(1, 30) AS gs;

-- 30 Talhoes
INSERT INTO Talhao (codigo, area_ha, idPropriedade)
SELECT 
    'TAL-' || LPAD(gs::text, 3, '0'),
    (random() * 50 + 10)::numeric(8,2),
    (gs % 30) + 1
FROM generate_series(1, 30) AS gs;

-- 30 Funcionarios
INSERT INTO Funcionario (nome, cpf, idCargo)
SELECT 
    'Funcionario Campo ' || gs,
    LPAD(gs::text, 11, '0'),
    (gs % 3) + 1
FROM generate_series(1, 30) AS gs;

-- 30 Maquinas
INSERT INTO Maquina (modelo, tipo, ano_fabricacao)
SELECT 
    'Trator Modelo ' || gs,
    'Equipamento Agricola',
    (2000 + (gs % 24))::int
FROM generate_series(1, 30) AS gs;

-- 30 Insumos
INSERT INTO Insumo (nome, unidade_medida, custo_unitario, idTipoInsumo)
SELECT 
    'Insumo Agricola ' || gs,
    CASE WHEN (gs % 2 = 0) THEN 'KG' ELSE 'L' END,
    (random() * 150 + 20)::numeric(10,2),
    (gs % 3) + 1
FROM generate_series(1, 30) AS gs;

-- 30 Atividades Agricolas
INSERT INTO AtividadeAgricola (data_operacao, idTalhao, idCultura, idFuncionario, idMaquina, idTipoOperacao)
SELECT 
    CURRENT_DATE - (gs || ' days')::interval,
    (gs % 30) + 1,
    (gs % 30) + 1,
    (gs % 30) + 1,
    (gs % 30) + 1,
    (gs % 3) + 1
FROM generate_series(1, 30) AS gs;

-- 30 Relacionamentos Atividade / Insumo
INSERT INTO AtividadeInsumo (idAtividade, idInsumo, quantidade_aplicada)
SELECT 
    gs,
    (gs % 30) + 1,
    (random() * 40 + 5)::numeric(10,2)
FROM generate_series(1, 30) AS gs;

-- 30 Colheitas
INSERT INTO Colheita (data_colheita, quantidade_kg, valor_venda_total, idTalhao, idCultura)
SELECT 
    CURRENT_DATE - ((gs * 2) || ' days')::interval,
    (random() * 50000 + 10000)::numeric(12,2),
    (random() * 120000 + 30000)::numeric(12,2),
    (gs % 30) + 1,
    (gs % 30) + 1
FROM generate_series(1, 30) AS gs;
