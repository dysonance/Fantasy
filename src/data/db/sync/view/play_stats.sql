DROP MATERIALIZED VIEW IF EXISTS play_stats;

CREATE MATERIALIZED VIEW play_stats AS
    (
    SELECT
        -- identifiers
        player.full_name AS name,
        player.position AS pos,
        play_player.team AS tm,
        game.season_year AS yr,
        game.season_type AS st,
        game.week AS wk,
        play.drive_id AS drive,
        play.play_id AS play,

        -- context
        play.down AS down,
        play.yards_to_go AS togo,
        time_elapsed(play.time) AS time,
        (play.yardline).pos + 50 AS fldpos,
        drive.pos_team AS offense,
        (CASE
             WHEN drive.pos_team = game.home_team
                 THEN game.away_team
                 ELSE game.home_team
         END) AS defense,
        game.home_team,
        game.away_team,

        -- passing
        play_player.passing_att AS pass,
        play_player.passing_cmp AS comp,
        play_player.passing_yds AS pass_yds,
        (CASE
             WHEN play_player.passing_cmp > 0
                 THEN play_player.passing_cmp_air_yds
                 ELSE play_player.passing_incmp_air_yds
         END) AS air_yds,
        play_player.passing_tds AS pass_td,
        play_player.passing_int AS interception,

        -- rushing
        play_player.rushing_att AS run,
        play_player.rushing_yds AS run_yds,
        play_player.rushing_tds AS run_td,

        -- receiving
        play_player.receiving_tar AS tgt,
        play_player.receiving_rec AS rec,
        play_player.receiving_yds AS rec_yds,
        play_player.receiving_yac_yds AS rec_yac,
        play_player.receiving_tds AS rec_td,

        -- defense TODO

        -- fantasy
        (
                (play_player.passing_yds)::Float / 25 +
                (play_player.passing_tds) * 4 +
                (play_player.passing_int) * -2 +
                (play_player.passing_twoptm) * 2 +
                (play_player.rushing_yds)::Float / 10 +
                (play_player.rushing_tds) * 6 +
                (play_player.rushing_twoptm) * 2 +
                (play_player.receiving_yds)::Float / 10 +
                (play_player.receiving_rec)::Float / 2 +
                (play_player.receiving_tds) * 6 +
                (play_player.receiving_twoptm) * 2 +
                (play_player.puntret_tds) * 6 +
                (play_player.kickret_tds) * 6 +
                (play_player.fumbles_lost) * -2
            ) AS pts

    FROM
        play_player
        LEFT JOIN player
                  ON player.player_id = play_player.player_id
        LEFT JOIN play
                  ON play.gsis_id = play_player.gsis_id AND play.drive_id = play_player.drive_id AND
                     play.play_id = play_player.play_id
        LEFT JOIN game
                  ON play.gsis_id = game.gsis_id
        LEFT JOIN drive ON play.gsis_id = drive.gsis_id AND play.drive_id = drive.drive_id
    WHERE
        game.season_type != 'Preseason' AND
        (
                play_player.passing_att > 0
                OR play_player.rushing_att > 0
                OR play_player.receiving_tar > 0
            )
    ORDER BY
        yr,
        st,
        wk,
        name,
        drive,
        down
        );

ALTER MATERIALIZED VIEW play_stats OWNER TO nfldb;
