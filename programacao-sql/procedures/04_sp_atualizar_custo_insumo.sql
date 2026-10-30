-- AgroNexo - Procedure: Atualizacao de Custo de Insumo
-- SGBD: PostgreSQL

CREATE OR REPLACE PROCEDURE sp_atualizar_custo_insumo(
    p_id INT,
    p_novo_custo_unitario NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Insumo
    SET custo_unitario = p_novo_custo_unitario
    WHERE id = p_id;
END;
$$;
