-- AgroNexo - Procedure: Atualizacao de Quantidade de Colheita
-- SGBD: PostgreSQL

CREATE OR REPLACE PROCEDURE sp_atualizar_quantidade_colheita(
    p_id INT,
    p_nova_quantidade_kg NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Colheita
    SET quantidade_kg = p_nova_quantidade_kg
    WHERE id = p_id;
END;
$$;
