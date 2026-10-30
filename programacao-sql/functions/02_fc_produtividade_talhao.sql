-- AgroNexo - Funcao: Produtividade de Talhao
-- SGBD: PostgreSQL

CREATE OR REPLACE FUNCTION fc_produtividade_talhao(
    p_id_talhao INT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_area_ha NUMERIC;
    v_total_colhido NUMERIC;
BEGIN
    SELECT area_ha
    INTO v_area_ha
    FROM Talhao
    WHERE id = p_id_talhao;

    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    SELECT COALESCE(SUM(quantidade_kg), 0)
    INTO v_total_colhido
    FROM Colheita
    WHERE idTalhao = p_id_talhao;

    IF v_total_colhido = 0 THEN
        RETURN 0;
    END IF;

    RETURN ROUND(v_total_colhido / v_area_ha, 2);
END;
$$;
