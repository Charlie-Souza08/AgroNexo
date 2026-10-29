-- AgroNexo - Funcao: Receita Total da Propriedade
-- SGBD: PostgreSQL

CREATE OR REPLACE FUNCTION fc_receita_total_propriedade(
    p_id_propriedade INT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_receita_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(col.valor_venda_total), 0)
    INTO v_receita_total
    FROM Propriedade p
    INNER JOIN Talhao t ON t.idPropriedade = p.id
    INNER JOIN Colheita col ON col.idTalhao = t.id
    WHERE p.id = p_id_propriedade;

    RETURN ROUND(v_receita_total, 2);
END;
$$;
