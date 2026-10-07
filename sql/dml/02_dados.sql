-- AgroNexo - Carga deterministica de dados (DML)
-- Execute depois de sql/ddl/01_estrutura.sql.

BEGIN;

INSERT INTO CargoFuncionario (id, descricao) VALUES
    (1, 'Operador de Maquinas'),
    (2, 'Engenheiro Agronomo'),
    (3, 'Trabalhador Rural');

INSERT INTO TipoInsumo (id, descricao) VALUES
    (1, 'Fertilizante'),
    (2, 'Defensivo Quimico'),
    (3, 'Semente');

INSERT INTO TipoOperacao (id, descricao) VALUES
    (1, 'Preparo de Solo'),
    (2, 'Plantio'),
    (3, 'Pulverizacao'),
    (4, 'Adubacao'),
    (5, 'Colheita');

-- 30 propriedades com areas suficientes para seus talhoes.
INSERT INTO Propriedade (id, nome, municipio, area_total_ha)
SELECT
    gs,
    'Fazenda AgroNexo ' || LPAD(gs::text, 2, '0'),
    'Municipio ' || (((gs - 1) % 5) + 1),
    (500 + gs * 20)::numeric(10, 2)
FROM generate_series(1, 30) AS gs;

-- 30 culturas catalogadas.
INSERT INTO Cultura (id, nome, ciclo_dias)
SELECT
    gs,
    'Cultura ' || LPAD(gs::text, 2, '0'),
    (75 + ((gs - 1) % 8) * 15)
FROM generate_series(1, 30) AS gs;

-- 30 talhoes, um por propriedade nesta massa de demonstracao.
INSERT INTO Talhao (id, codigo, area_ha, idPropriedade)
SELECT
    gs,
    'TAL-' || LPAD(gs::text, 3, '0'),
    (20 + ((gs * 7) % 50))::numeric(8, 2),
    gs
FROM generate_series(1, 30) AS gs;

INSERT INTO Funcionario (id, nome, cpf, idCargo)
SELECT
    gs,
    'Funcionario Campo ' || LPAD(gs::text, 2, '0'),
    LPAD(gs::text, 11, '0'),
    ((gs - 1) % 3) + 1
FROM generate_series(1, 30) AS gs;

INSERT INTO Maquina (id, modelo, tipo, ano_fabricacao)
SELECT
    gs,
    'Maquina Modelo ' || LPAD(gs::text, 2, '0'),
    CASE ((gs - 1) % 3)
        WHEN 0 THEN 'Trator'
        WHEN 1 THEN 'Pulverizador'
        ELSE 'Colheitadeira'
    END,
    2000 + ((gs - 1) % 25)
FROM generate_series(1, 30) AS gs;

-- Os insumos 26 a 30 ficam sem uso propositalmente.
INSERT INTO Insumo (id, nome, unidade_medida, custo_unitario, idTipoInsumo)
SELECT
    gs,
    'Insumo Agricola ' || LPAD(gs::text, 2, '0'),
    CASE ((gs - 1) % 3)
        WHEN 1 THEN 'L'
        ELSE 'KG'
    END,
    (20 + gs * 4.35)::numeric(10, 2),
    ((gs - 1) % 3) + 1
FROM generate_series(1, 30) AS gs;

-- 180 atividades. As maquinas 1 a 5 superam dez operacoes;
-- algumas atividades sao manuais e as maquinas 15 a 30 nao sao utilizadas.
INSERT INTO AtividadeAgricola (
    id,
    data_operacao,
    idTalhao,
    idCultura,
    idFuncionario,
    idMaquina,
    idTipoOperacao
)
SELECT
    gs,
    CURRENT_DATE - ((gs - 1) % 90),
    ((gs - 1) % 25) + 1,
    ((gs - 1) % 10) + 1,
    ((gs - 1) % 15) + 1,
    CASE
        WHEN gs % 12 = 0 THEN NULL
        WHEN gs <= 45 THEN 1
        WHEN gs <= 80 THEN 2
        WHEN gs <= 105 THEN 3
        WHEN gs <= 120 THEN 4
        WHEN gs <= 135 THEN 5
        ELSE 6 + ((gs - 136) % 9)
    END,
    ((gs - 1) % 5) + 1
FROM generate_series(1, 180) AS gs;

-- 300 aplicacoes distribuidas entre 180 atividades e 25 insumos.
INSERT INTO AtividadeInsumo (
    id,
    idAtividade,
    idInsumo,
    quantidade_aplicada
)
SELECT
    gs,
    ((gs - 1) % 180) + 1,
    ((gs - 1) % 25) + 1,
    (5 + ((gs * 7) % 40))::numeric(10, 2)
FROM generate_series(1, 300) AS gs;

-- 60 colheitas em apenas 20 talhoes. Os talhoes 21 a 30 ficam sem colheita.
INSERT INTO Colheita (
    id,
    data_colheita,
    quantidade_kg,
    valor_venda_total,
    idTalhao,
    idCultura
)
SELECT
    gs,
    CURRENT_DATE - (30 + gs),
    (10000 + gs * 525)::numeric(12, 2),
    ((10000 + gs * 525) * (2.20 + ((gs - 1) % 5) * 0.15))::numeric(12, 2),
    ((gs - 1) % 20) + 1,
    ((((gs - 1) % 20) + 5 * ((gs - 1) / 20)) % 10) + 1
FROM generate_series(1, 60) AS gs;

COMMIT;
