-- AgroNexo - Funcao: Quantidade Colhida por Cultura
-- SGBD: PostgreSQL

CREATE OR REPLACE FUNCTION fc_quantidade_colhida_cultura(
    p_id_cultura INT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_colhido NUMERIC;
BEGIN
    SELECT COALESCE(SUM(col.quantidade_kg), 0)
    INTO v_total_colhido
    FROM Colheita col
    WHERE col.idCultura = p_id_cultura;

    RETURN ROUND(v_total_colhido, 2);
END;
$$;
