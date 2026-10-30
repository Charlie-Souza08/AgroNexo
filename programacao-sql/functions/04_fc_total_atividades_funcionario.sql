-- AgroNexo - Funcao: Total de Atividades por Funcionario
-- SGBD: PostgreSQL

CREATE OR REPLACE FUNCTION fc_total_atividades_funcionario(
    p_id_funcionario INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_atividades INT;
BEGIN
    SELECT COUNT(aa.id)
    INTO v_total_atividades
    FROM AtividadeAgricola aa
    WHERE aa.idFuncionario = p_id_funcionario;

    RETURN COALESCE(v_total_atividades, 0);
END;
$$;
