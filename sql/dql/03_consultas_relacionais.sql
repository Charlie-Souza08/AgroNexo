-- AgroNexo - Consultas relacionais (DQL)
-- Conteudos: INNER JOIN, LEFT JOIN, RIGHT JOIN, GROUP BY e HAVING.
-- Execute depois dos arquivos DDL e DML.

-- ============================================================================
-- 01. Custo de insumos por cultura
-- ============================================================================
SELECT
    c.id AS id_cultura,
    c.nome AS cultura,
    ROUND(SUM(ai.quantidade_aplicada * i.custo_unitario), 2) AS custo_total_insumos
FROM Cultura c
INNER JOIN AtividadeAgricola aa ON aa.idCultura = c.id
INNER JOIN AtividadeInsumo ai ON ai.idAtividade = aa.id
INNER JOIN Insumo i ON i.id = ai.idInsumo
GROUP BY c.id, c.nome
ORDER BY custo_total_insumos DESC;

-- ============================================================================
-- 02. Produtividade fisica por talhao (kg/ha)
-- LEFT JOIN inclui talhoes ainda sem colheita, exibidos com produtividade zero.
-- ============================================================================
SELECT
    t.id AS id_talhao,
    t.codigo AS talhao,
    t.area_ha,
    COALESCE(SUM(col.quantidade_kg), 0) AS quantidade_total_kg,
    ROUND(COALESCE(SUM(col.quantidade_kg), 0) / t.area_ha, 2)
        AS produtividade_kg_por_ha
FROM Talhao t
LEFT JOIN Colheita col ON col.idTalhao = t.id
GROUP BY t.id, t.codigo, t.area_ha
ORDER BY produtividade_kg_por_ha DESC;

-- ============================================================================
-- 03. Insumos nunca utilizados
-- RIGHT JOIN preserva todos os insumos, mesmo sem aplicacao correspondente.
-- ============================================================================
SELECT
    i.id AS id_insumo,
    i.nome AS insumo,
    ti.descricao AS tipo_insumo,
    i.unidade_medida
FROM AtividadeInsumo ai
RIGHT JOIN Insumo i ON i.id = ai.idInsumo
INNER JOIN TipoInsumo ti ON ti.id = i.idTipoInsumo
WHERE ai.id IS NULL
ORDER BY i.id;

-- ============================================================================
-- 04. Desempenho de maquinas com mais de 10 atividades
-- ============================================================================
SELECT
    m.id AS id_maquina,
    m.modelo,
    m.tipo,
    COUNT(aa.id) AS quantidade_atividades
FROM Maquina m
INNER JOIN AtividadeAgricola aa ON aa.idMaquina = m.id
GROUP BY m.id, m.modelo, m.tipo
HAVING COUNT(aa.id) > 10
ORDER BY quantidade_atividades DESC, m.id;

-- ============================================================================
-- 05. Receita bruta por propriedade
-- ============================================================================
SELECT
    p.id AS id_propriedade,
    p.nome AS propriedade,
    ROUND(COALESCE(SUM(col.valor_venda_total), 0), 2) AS receita_bruta_total
FROM Propriedade p
LEFT JOIN Talhao t ON t.idPropriedade = p.id
LEFT JOIN Colheita col ON col.idTalhao = t.id
GROUP BY p.id, p.nome
ORDER BY receita_bruta_total DESC;

-- ============================================================================
-- 06. Custo de insumos por talhao
-- ============================================================================
SELECT
    t.id AS id_talhao,
    t.codigo AS talhao,
    ROUND(SUM(ai.quantidade_aplicada * i.custo_unitario), 2) AS custo_total_insumos
FROM Talhao t
INNER JOIN AtividadeAgricola aa ON aa.idTalhao = t.id
INNER JOIN AtividadeInsumo ai ON ai.idAtividade = aa.id
INNER JOIN Insumo i ON i.id = ai.idInsumo
GROUP BY t.id, t.codigo
ORDER BY custo_total_insumos DESC;

-- ============================================================================
-- 07. Funcionarios com maior numero de operacoes
-- ============================================================================
SELECT
    f.id AS id_funcionario,
    f.nome AS funcionario,
    COUNT(aa.id) AS quantidade_operacoes
FROM Funcionario f
LEFT JOIN AtividadeAgricola aa ON aa.idFuncionario = f.id
GROUP BY f.id, f.nome
ORDER BY quantidade_operacoes DESC, f.nome;

-- ============================================================================
-- 08. Produtividade media por cultura
-- ============================================================================
SELECT
    c.id AS id_cultura,
    c.nome AS cultura,
    ROUND(AVG(col.quantidade_kg), 2) AS quantidade_media_kg
FROM Cultura c
INNER JOIN Colheita col ON col.idCultura = c.id
GROUP BY c.id, c.nome
ORDER BY quantidade_media_kg DESC;

-- ============================================================================
-- 09. Talhoes sem colheita
-- ============================================================================
SELECT
    t.id AS id_talhao,
    t.codigo AS talhao,
    p.nome AS propriedade
FROM Talhao t
INNER JOIN Propriedade p ON p.id = t.idPropriedade
LEFT JOIN Colheita col ON col.idTalhao = t.id
WHERE col.id IS NULL
ORDER BY t.codigo;

-- ============================================================================
-- 10. Consumo de sementes por hectare para cada talhao com aplicacao
-- ============================================================================
SELECT
    t.id AS id_talhao,
    t.codigo AS talhao,
    t.area_ha,
    SUM(ai.quantidade_aplicada) AS total_sementes_kg,
    ROUND(SUM(ai.quantidade_aplicada) / t.area_ha, 2) AS sementes_kg_por_ha
FROM Talhao t
INNER JOIN AtividadeAgricola aa ON aa.idTalhao = t.id
INNER JOIN AtividadeInsumo ai ON ai.idAtividade = aa.id
INNER JOIN Insumo i ON i.id = ai.idInsumo
INNER JOIN TipoInsumo ti ON ti.id = i.idTipoInsumo
WHERE ti.descricao = 'Semente'
  AND i.unidade_medida = 'KG'
GROUP BY t.id, t.codigo, t.area_ha
ORDER BY sementes_kg_por_ha DESC;

-- ============================================================================
-- 11. Gasto com defensivos por propriedade
-- ============================================================================
SELECT
    p.id AS id_propriedade,
    p.nome AS propriedade,
    ROUND(SUM(ai.quantidade_aplicada * i.custo_unitario), 2)
        AS gasto_total_defensivos
FROM Propriedade p
INNER JOIN Talhao t ON t.idPropriedade = p.id
INNER JOIN AtividadeAgricola aa ON aa.idTalhao = t.id
INNER JOIN AtividadeInsumo ai ON ai.idAtividade = aa.id
INNER JOIN Insumo i ON i.id = ai.idInsumo
INNER JOIN TipoInsumo ti ON ti.id = i.idTipoInsumo
WHERE ti.descricao = 'Defensivo Quimico'
GROUP BY p.id, p.nome
ORDER BY gasto_total_defensivos DESC;

-- ============================================================================
-- 12. Rentabilidade estimada por cultura
-- Os totais sao calculados separadamente para evitar multiplicacao de linhas.
-- ============================================================================
WITH receita_por_cultura AS (
    SELECT
        col.idCultura,
        SUM(col.valor_venda_total) AS receita_total
    FROM Colheita col
    GROUP BY col.idCultura
),
custo_por_cultura AS (
    SELECT
        aa.idCultura,
        SUM(ai.quantidade_aplicada * i.custo_unitario) AS custo_total
    FROM AtividadeAgricola aa
    INNER JOIN AtividadeInsumo ai ON ai.idAtividade = aa.id
    INNER JOIN Insumo i ON i.id = ai.idInsumo
    GROUP BY aa.idCultura
)
SELECT
    c.id AS id_cultura,
    c.nome AS cultura,
    ROUND(COALESCE(r.receita_total, 0), 2) AS receita_total,
    ROUND(COALESCE(ci.custo_total, 0), 2) AS custo_total_insumos,
    ROUND(COALESCE(r.receita_total, 0) - COALESCE(ci.custo_total, 0), 2)
        AS rentabilidade_estimada
FROM Cultura c
LEFT JOIN receita_por_cultura r ON r.idCultura = c.id
LEFT JOIN custo_por_cultura ci ON ci.idCultura = c.id
ORDER BY rentabilidade_estimada DESC;

-- ============================================================================
-- 13. Maquinas sem atividade nos ultimos 30 dias
-- Inclui maquinas nunca utilizadas e maquinas utilizadas somente antes do periodo.
-- ============================================================================
SELECT
    m.id AS id_maquina,
    m.modelo,
    m.tipo,
    MAX(aa.data_operacao) AS ultima_atividade
FROM Maquina m
LEFT JOIN AtividadeAgricola aa ON aa.idMaquina = m.id
GROUP BY m.id, m.modelo, m.tipo
HAVING MAX(aa.data_operacao) IS NULL
    OR MAX(aa.data_operacao) < CURRENT_DATE - 30
ORDER BY ultima_atividade NULLS FIRST, m.id;

-- ============================================================================
-- 14. Quantidade de insumos por tipo de operacao
-- A unidade integra o agrupamento para nao somar litros e quilogramas.
-- ============================================================================
SELECT
    top.id AS id_tipo_operacao,
    top.descricao AS tipo_operacao,
    i.unidade_medida,
    ROUND(SUM(ai.quantidade_aplicada), 2) AS quantidade_total_aplicada
FROM TipoOperacao top
INNER JOIN AtividadeAgricola aa ON aa.idTipoOperacao = top.id
INNER JOIN AtividadeInsumo ai ON ai.idAtividade = aa.id
INNER JOIN Insumo i ON i.id = ai.idInsumo
GROUP BY top.id, top.descricao, i.unidade_medida
ORDER BY top.id, i.unidade_medida;

-- ============================================================================
-- 15. Area plantada por cultura
-- Cada combinacao talhao/cultura e contabilizada uma unica vez.
-- ============================================================================
WITH cultivo_por_talhao AS (
    SELECT DISTINCT
        aa.idTalhao,
        aa.idCultura
    FROM AtividadeAgricola aa
)
SELECT
    c.id AS id_cultura,
    c.nome AS cultura,
    ROUND(SUM(t.area_ha), 2) AS area_total_plantada_ha
FROM cultivo_por_talhao ct
INNER JOIN Cultura c ON c.id = ct.idCultura
INNER JOIN Talhao t ON t.id = ct.idTalhao
GROUP BY c.id, c.nome
ORDER BY area_total_plantada_ha DESC;

-- ============================================================================
-- 16. Custo medio de aplicacao por tipo de insumo
-- ============================================================================
SELECT
    ti.id AS id_tipo_insumo,
    ti.descricao AS tipo_insumo,
    ROUND(AVG(ai.quantidade_aplicada * i.custo_unitario), 2)
        AS custo_medio_aplicacao
FROM TipoInsumo ti
INNER JOIN Insumo i ON i.idTipoInsumo = ti.id
INNER JOIN AtividadeInsumo ai ON ai.idInsumo = i.id
GROUP BY ti.id, ti.descricao
ORDER BY custo_medio_aplicacao DESC;

-- ============================================================================
-- 17. Cinco insumos com maior gasto total
-- ============================================================================
SELECT
    i.id AS id_insumo,
    i.nome AS insumo,
    i.unidade_medida,
    ROUND(SUM(ai.quantidade_aplicada * i.custo_unitario), 2) AS gasto_total
FROM Insumo i
INNER JOIN AtividadeInsumo ai ON ai.idInsumo = i.id
GROUP BY i.id, i.nome, i.unidade_medida
ORDER BY gasto_total DESC
LIMIT 5;

-- ============================================================================
-- 18. Talhoes com historico de multiplas culturas
-- ============================================================================
SELECT
    t.id AS id_talhao,
    t.codigo AS talhao,
    COUNT(DISTINCT aa.idCultura) AS quantidade_culturas
FROM Talhao t
INNER JOIN AtividadeAgricola aa ON aa.idTalhao = t.id
GROUP BY t.id, t.codigo
HAVING COUNT(DISTINCT aa.idCultura) > 1
ORDER BY quantidade_culturas DESC, t.codigo;

-- ============================================================================
-- 19. Produtividade financeira por talhao (receita/ha)
-- ============================================================================
SELECT
    t.id AS id_talhao,
    t.codigo AS talhao,
    t.area_ha,
    ROUND(COALESCE(SUM(col.valor_venda_total), 0), 2) AS receita_total,
    ROUND(COALESCE(SUM(col.valor_venda_total), 0) / t.area_ha, 2)
        AS receita_por_ha
FROM Talhao t
LEFT JOIN Colheita col ON col.idTalhao = t.id
GROUP BY t.id, t.codigo, t.area_ha
ORDER BY receita_por_ha DESC;

-- ============================================================================
-- 20. Relatorio de rastreabilidade das atividades
-- LEFT JOIN em Maquina preserva as operacoes manuais.
-- ============================================================================
SELECT
    aa.id AS id_atividade,
    aa.data_operacao,
    p.nome AS propriedade,
    t.codigo AS talhao,
    c.nome AS cultura,
    top.descricao AS tipo_operacao,
    f.nome AS funcionario_responsavel,
    COALESCE(m.modelo, 'Operacao manual') AS maquina,
    i.nome AS insumo,
    ti.descricao AS tipo_insumo,
    ai.quantidade_aplicada,
    i.unidade_medida,
    ROUND(ai.quantidade_aplicada * i.custo_unitario, 2) AS custo_aplicacao
FROM AtividadeAgricola aa
INNER JOIN Talhao t ON t.id = aa.idTalhao
INNER JOIN Propriedade p ON p.id = t.idPropriedade
INNER JOIN Cultura c ON c.id = aa.idCultura
INNER JOIN TipoOperacao top ON top.id = aa.idTipoOperacao
INNER JOIN Funcionario f ON f.id = aa.idFuncionario
LEFT JOIN Maquina m ON m.id = aa.idMaquina
INNER JOIN AtividadeInsumo ai ON ai.idAtividade = aa.id
INNER JOIN Insumo i ON i.id = ai.idInsumo
INNER JOIN TipoInsumo ti ON ti.id = i.idTipoInsumo
ORDER BY aa.data_operacao DESC, aa.id, i.nome;
