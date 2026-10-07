-- AgroNexo - Definicao da estrutura do banco de dados (DDL)
-- SGBD: PostgreSQL

BEGIN;

-- As tabelas sao removidas na ordem inversa das dependencias.
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

CREATE TABLE CargoFuncionario (
    id INT PRIMARY KEY,
    descricao VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE TipoInsumo (
    id INT PRIMARY KEY,
    descricao VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE TipoOperacao (
    id INT PRIMARY KEY,
    descricao VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Propriedade (
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    municipio VARCHAR(80) NOT NULL,
    area_total_ha NUMERIC(10, 2) NOT NULL CHECK (area_total_ha > 0)
);

CREATE TABLE Cultura (
    id INT PRIMARY KEY,
    nome VARCHAR(60) NOT NULL UNIQUE,
    ciclo_dias INT NOT NULL CHECK (ciclo_dias > 0)
);

CREATE TABLE Talhao (
    id INT PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    area_ha NUMERIC(8, 2) NOT NULL CHECK (area_ha > 0),
    idPropriedade INT NOT NULL,
    CONSTRAINT fk_talhao_propriedade
        FOREIGN KEY (idPropriedade)
        REFERENCES Propriedade(id)
        ON DELETE RESTRICT
);

CREATE TABLE Funcionario (
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    idCargo INT NOT NULL,
    CONSTRAINT fk_funcionario_cargo
        FOREIGN KEY (idCargo)
        REFERENCES CargoFuncionario(id)
        ON DELETE RESTRICT
);

CREATE TABLE Maquina (
    id INT PRIMARY KEY,
    modelo VARCHAR(80) NOT NULL,
    tipo VARCHAR(40) NOT NULL,
    ano_fabricacao INT NOT NULL CHECK (ano_fabricacao >= 1970)
);

CREATE TABLE Insumo (
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    unidade_medida VARCHAR(10) NOT NULL
        CHECK (unidade_medida IN ('KG', 'L', 'SC')),
    custo_unitario NUMERIC(10, 2) NOT NULL CHECK (custo_unitario >= 0),
    idTipoInsumo INT NOT NULL,
    CONSTRAINT fk_insumo_tipo
        FOREIGN KEY (idTipoInsumo)
        REFERENCES TipoInsumo(id)
        ON DELETE RESTRICT
);

CREATE TABLE AtividadeAgricola (
    id INT PRIMARY KEY,
    data_operacao DATE NOT NULL,
    idTalhao INT NOT NULL,
    idCultura INT NOT NULL,
    idFuncionario INT NOT NULL,
    idMaquina INT,
    idTipoOperacao INT NOT NULL,
    CONSTRAINT fk_atividade_talhao
        FOREIGN KEY (idTalhao)
        REFERENCES Talhao(id)
        ON DELETE RESTRICT,
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
    id INT PRIMARY KEY,
    idAtividade INT NOT NULL,
    idInsumo INT NOT NULL,
    quantidade_aplicada NUMERIC(10, 2) NOT NULL
        CHECK (quantidade_aplicada > 0),
    CONSTRAINT uq_atividade_insumo UNIQUE (idAtividade, idInsumo),
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
    id INT PRIMARY KEY,
    data_colheita DATE NOT NULL,
    quantidade_kg NUMERIC(12, 2) NOT NULL CHECK (quantidade_kg > 0),
    valor_venda_total NUMERIC(12, 2) NOT NULL CHECK (valor_venda_total >= 0),
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

-- Indices das chaves estrangeiras mais usadas nas consultas relacionais.
CREATE INDEX idx_talhao_propriedade ON Talhao (idPropriedade);
CREATE INDEX idx_funcionario_cargo ON Funcionario (idCargo);
CREATE INDEX idx_insumo_tipo ON Insumo (idTipoInsumo);
CREATE INDEX idx_atividade_talhao ON AtividadeAgricola (idTalhao);
CREATE INDEX idx_atividade_cultura ON AtividadeAgricola (idCultura);
CREATE INDEX idx_atividade_funcionario ON AtividadeAgricola (idFuncionario);
CREATE INDEX idx_atividade_maquina ON AtividadeAgricola (idMaquina);
CREATE INDEX idx_atividade_tipo ON AtividadeAgricola (idTipoOperacao);
CREATE INDEX idx_atividade_data ON AtividadeAgricola (data_operacao);
CREATE INDEX idx_atividade_insumo_insumo ON AtividadeInsumo (idInsumo);
CREATE INDEX idx_colheita_talhao ON Colheita (idTalhao);
CREATE INDEX idx_colheita_cultura ON Colheita (idCultura);

COMMIT;
