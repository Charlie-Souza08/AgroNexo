-- AgroNexo - Funcao: Custo Total de Atividade
-- SGBD: PostgreSQL

CREATE OR REPLACE FUNCTION fc_custo_total_atividade(
    p_id_atividade INT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_custo_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(ai.quantidade_aplicada * i.custo_unitario), 0)
    INTO v_custo_total
    FROM AtividadeInsumo ai
    INNER JOIN Insumo i ON i.id = ai.idInsumo
    WHERE ai.idAtividade = p_id_atividade;

    RETURN ROUND(v_custo_total, 2);
END;
$$;
