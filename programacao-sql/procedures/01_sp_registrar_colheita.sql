-- AgroNexo - Procedure: Registro de Colheita
-- SGBD: PostgreSQL

CREATE OR REPLACE PROCEDURE sp_registrar_colheita(
    p_id INT,
    p_data_colheita DATE,
    p_quantidade_kg NUMERIC,
    p_valor_venda_total NUMERIC,
    p_id_talhao INT,
    p_id_cultura INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Colheita (
        id,
        data_colheita,
        quantidade_kg,
        valor_venda_total,
        idTalhao,
        idCultura
    ) VALUES (
        p_id,
        p_data_colheita,
        p_quantidade_kg,
        p_valor_venda_total,
        p_id_talhao,
        p_id_cultura
    );
END;
$$;
