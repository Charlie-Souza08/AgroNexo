-- ============================================================================
-- 1. Alocação de Trabalho de Campo
-- Finalidade: Rastrear a execução operacional das tarefas agrícolas, identificando
-- o colaborador responsável, a máquina utilizada, o talhão e a cultura atendida.
-- ============================================================================
SELECT 
    aa.id AS id_atividade,
    aa.data_operacao,
    top.descricao AS tipo_operacao,
    f.nome AS funcionario_responsavel,
    m.modelo AS maquina_utilizada,
    m.tipo AS tipo_maquina,
    t.codigo AS codigo_talhao,
    c.nome AS cultura
FROM AtividadeAgricola aa
INNER JOIN TipoOperacao top ON aa.idTipoOperacao = top.id
INNER JOIN Funcionario f ON aa.idFuncionario = f.id
INNER JOIN Maquina m ON aa.idMaquina = m.id
INNER JOIN Talhao t ON aa.idTalhao = t.id
INNER JOIN Cultura c ON aa.idCultura = c.id
ORDER BY aa.data_operacao DESC;

-- ============================================================================
-- 2. Custo Financeiro por Aplicação
-- Finalidade: Mensurar o custo financeiro direto dos insumos aplicados em cada
-- operação e talhão, subsidiando o controle orçamentário dos custos de produção.
-- ============================================================================
SELECT 
    t.codigo AS codigo_talhao,
    aa.data_operacao,
    i.nome AS insumo,
    i.unidade_medida,
    ai.quantidade_aplicada,
    i.custo_unitario,
    ROUND((ai.quantidade_aplicada * i.custo_unitario), 2) AS custo_total_aplicacao
FROM AtividadeInsumo ai
INNER JOIN AtividadeAgricola aa ON ai.idAtividade = aa.id
INNER JOIN Talhao t ON aa.idTalhao = t.id
INNER JOIN Insumo i ON ai.idInsumo = i.id
ORDER BY custo_total_aplicacao DESC;

-- ============================================================================
-- 3. Desempenho e Produtividade da Colheita
-- Finalidade: Analisar o rendimento físico e financeiro da colheita por talhão,
-- calculando a produtividade por hectare e o faturamento bruto gerado.
-- ============================================================================
SELECT 
    p.nome AS propriedade,
    t.codigo AS codigo_talhao,
    t.area_ha AS area_talhao_ha,
    c.nome AS cultura,
    col.data_colheita,
    col.quantidade_kg AS total_colhido_kg,
    col.valor_venda_total AS faturamento_bruto,
    ROUND((col.quantidade_kg / t.area_ha), 2) AS produtividade_kg_por_ha,
    ROUND((col.valor_venda_total / t.area_ha), 2) AS receita_bruta_por_ha
FROM Colheita col
INNER JOIN Talhao t ON col.idTalhao = t.id
INNER JOIN Propriedade p ON t.idPropriedade = p.id
INNER JOIN Cultura c ON col.idCultura = c.id
ORDER BY col.data_colheita DESC;

-- ============================================================================
-- 4. Uso de Insumos por Categoria
-- Finalidade: Consolidar o volume total de insumos aplicados e o montante financeiro
-- consumido por categoria de produto, apoiando o gerenciamento e ressuprimento de estoque.
-- ============================================================================
SELECT 
    ti.descricao AS categoria_insumo,
    i.unidade_medida,
    COUNT(ai.id) AS quantidade_aplicacoes,
    SUM(ai.quantidade_aplicada) AS total_quantidade_aplicada,
    ROUND(SUM(ai.quantidade_aplicada * i.custo_unitario), 2) AS custo_acumulado
FROM AtividadeInsumo ai
INNER JOIN Insumo i ON ai.idInsumo = i.id
INNER JOIN TipoInsumo ti ON i.idTipoInsumo = ti.id
GROUP BY ti.descricao, i.unidade_medida
ORDER BY custo_acumulado DESC;

-- ============================================================================
-- 5. Escala Operacional de Máquinas
-- Finalidade: Avaliar a demanda e o nível de utilização da frota de maquinários
-- agrícolas, totalizando as operações realizadas por equipamento.
-- ============================================================================
SELECT 
    m.id AS id_maquina,
    m.modelo,
    m.tipo,
    m.ano_fabricacao,
    COUNT(aa.id) AS total_operacoes_realizadas
FROM Maquina m
INNER JOIN AtividadeAgricola aa ON m.id = aa.idMaquina
GROUP BY m.id, m.modelo, m.tipo, m.ano_fabricacao
ORDER BY total_operacoes_realizadas DESC;
