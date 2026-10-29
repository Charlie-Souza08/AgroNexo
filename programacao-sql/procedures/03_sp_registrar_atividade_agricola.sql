-- AgroNexo - Procedure: Registro de Atividade Agricola
-- SGBD: PostgreSQL

CREATE OR REPLACE PROCEDURE sp_registrar_atividade_agricola(
    p_id INT,
    p_data_operacao DATE,
    p_id_talhao INT,
    p_id_cultura INT,
    p_id_funcionario INT,
    p_id_maquina INT,
    p_id_tipo_operacao INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO AtividadeAgricola (
        id,
        data_operacao,
        idTalhao,
        idCultura,
        idFuncionario,
        idMaquina,
        idTipoOperacao
    ) VALUES (
        p_id,
        p_data_operacao,
        p_id_talhao,
        p_id_cultura,
        p_id_funcionario,
        p_id_maquina,
        p_id_tipo_operacao
    );
END;
$$;
