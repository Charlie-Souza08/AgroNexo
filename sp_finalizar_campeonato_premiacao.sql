DELIMITER $$

CREATE PROCEDURE sp_finalizar_campeonato_premiacao(
    IN p_id_campeonato INT
)
BEGIN
    DECLARE v_status VARCHAR(30);
    DECLARE v_premio DECIMAL(12,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT status, premio_total
    INTO v_status, v_premio
    FROM campeonatos
    WHERE id_campeonato = p_id_campeonato
    FOR UPDATE;

    IF v_status <> 'em_andamento' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Campeonato nao esta em andamento';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM partidas
        WHERE id_campeonato = p_id_campeonato
          AND status <> 'finalizada'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Existem partidas ainda nao finalizadas';
    END IF;

    UPDATE inscricoes i
    JOIN (
        SELECT
            c.id_equipe,
            ROW_NUMBER() OVER (
                ORDER BY c.pontos DESC,
                         c.vitorias DESC,
                         c.id_equipe ASC
            ) AS colocacao_final
        FROM classificacao c
        WHERE c.id_campeonato = p_id_campeonato
    ) r ON r.id_equipe = i.id_equipe
    SET i.colocacao = r.colocacao_final
    WHERE i.id_campeonato = p_id_campeonato;

    UPDATE inscricoes
    SET premio = CASE colocacao
        WHEN 1 THEN ROUND(v_premio * 0.50, 2)
        WHEN 2 THEN ROUND(v_premio * 0.30, 2)
        WHEN 3 THEN
            v_premio
            - ROUND(v_premio * 0.50, 2)
            - ROUND(v_premio * 0.30, 2)
        ELSE 0
    END
    WHERE id_campeonato = p_id_campeonato;

    UPDATE campeonatos
    SET status = 'encerrado',
        data_fim = CURDATE()
    WHERE id_campeonato = p_id_campeonato;

    COMMIT;
END$$

DELIMITER ;