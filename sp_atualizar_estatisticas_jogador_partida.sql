DELIMITER $$

CREATE PROCEDURE sp_atualizar_estatisticas_jogador_partida(
    IN p_id_partida INT,
    IN p_id_jogador INT,
    IN p_eliminacoes INT,
    IN p_mortes INT,
    IN p_assistencias INT,
    IN p_dano DECIMAL(12,2)
)
BEGIN
    DECLARE v_campeonato INT;
    DECLARE v_equipe_a INT;
    DECLARE v_equipe_b INT;
    DECLARE v_status VARCHAR(20);
    DECLARE v_vinculo INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT id_campeonato, id_equipe_a,
           id_equipe_b, status
    INTO v_campeonato, v_equipe_a,
         v_equipe_b, v_status
    FROM partidas
    WHERE id_partida = p_id_partida
    FOR UPDATE;

    IF v_status NOT IN ('em_andamento', 'finalizada') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Partida nao iniciada';
    END IF;

    IF p_eliminacoes < 0
       OR p_mortes < 0
       OR p_assistencias < 0
       OR p_dano < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estatisticas nao podem ser negativas';
    END IF;

    SELECT COUNT(*)
    INTO v_vinculo
    FROM contratos c
    WHERE c.id_jogador = p_id_jogador
      AND c.ativo = TRUE
      AND c.data_inicio <= CURDATE()
      AND (c.data_fim IS NULL OR c.data_fim >= CURDATE())
      AND c.id_equipe IN (v_equipe_a, v_equipe_b);

    IF v_vinculo = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Jogador nao possui vinculo ativo com as equipes da partida';
    END IF;

    INSERT INTO estatisticas_jogador (
        id_partida,
        id_jogador,
        eliminacoes,
        mortes,
        assistencias,
        dano
    )
    VALUES (
        p_id_partida,
        p_id_jogador,
        p_eliminacoes,
        p_mortes,
        p_assistencias,
        p_dano
    )
    ON DUPLICATE KEY UPDATE
        eliminacoes = p_eliminacoes,
        mortes = p_mortes,
        assistencias = p_assistencias,
        dano = p_dano;

    INSERT INTO estatisticas_jogador_campeonato (
        id_jogador,
        id_campeonato
    )
    VALUES (
        p_id_jogador,
        v_campeonato
    )
    ON DUPLICATE KEY UPDATE
        id_jogador = p_id_jogador;

    UPDATE estatisticas_jogador_campeonato
    SET
        eliminacoes = (
            SELECT COALESCE(SUM(e.eliminacoes), 0)
            FROM estatisticas_jogador e
            JOIN partidas p
                ON p.id_partida = e.id_partida
            WHERE e.id_jogador = p_id_jogador
              AND p.id_campeonato = v_campeonato
        ),
        mortes = (
            SELECT COALESCE(SUM(e.mortes), 0)
            FROM estatisticas_jogador e
            JOIN partidas p
                ON p.id_partida = e.id_partida
            WHERE e.id_jogador = p_id_jogador
              AND p.id_campeonato = v_campeonato
        ),
        assistencias = (
            SELECT COALESCE(SUM(e.assistencias), 0)
            FROM estatisticas_jogador e
            JOIN partidas p
                ON p.id_partida = e.id_partida
            WHERE e.id_jogador = p_id_jogador
              AND p.id_campeonato = v_campeonato
        ),
        dano = (
            SELECT COALESCE(SUM(e.dano), 0)
            FROM estatisticas_jogador e
            JOIN partidas p
                ON p.id_partida = e.id_partida
            WHERE e.id_jogador = p_id_jogador
              AND p.id_campeonato = v_campeonato
        )
    WHERE id_jogador = p_id_jogador
      AND id_campeonato = v_campeonato;

    COMMIT;
END$$

DELIMITER ;