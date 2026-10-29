-- AgroNexo - Procedure: Registro de Aplicacao de Insumo
-- SGBD: PostgreSQL

CREATE OR REPLACE PROCEDURE sp_registrar_aplicacao_insumo(
    p_id INT,
    p_id_atividade INT,
    p_id_insumo INT,
    p_quantidade_aplicada NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO AtividadeInsumo (
        id,
        idAtividade,
        idInsumo,
        quantidade_aplicada
    ) VALUES (
        p_id,
        p_id_atividade,
        p_id_insumo,
        p_quantidade_aplicada
    );
END;
$$;
