DROP MATERIALIZED VIEW IF EXISTS fantasy_points;

CREATE MATERIALIZED VIEW fantasy_points AS
    WITH
        fantasy_scoring AS (
            SELECT
                pp.gsis_id,
                pp.player_id,
                g.home_team,
                g.away_team,
                d.pos_team AS offense,
                (CASE
                     WHEN d.pos_team = g.home_team
                         THEN g.away_team
                         ELSE g.home_team
                 END) AS defense,
                (d.pos_team = g.home_team) AS is_home_game,
                (
                        (sum(pp.passing_yds)::Float / 25)::Float +
                        sum(pp.passing_tds) * 4 +
                        sum(pp.passing_int) * -2 +
                        sum(pp.passing_twoptm) * 2 +
                        (sum(pp.rushing_yds)::Float / 10)::Float +
                        sum(pp.rushing_tds) * 6 +
                        sum(pp.rushing_twoptm) * 2 +
                        (sum(pp.receiving_yds)::Float / 10)::Float +
                        (sum(pp.receiving_rec)::Float / 2)::Float +
                        sum(pp.receiving_tds) * 6 +
                        sum(pp.receiving_twoptm) * 2 +
                        sum(pp.puntret_tds) * 6 +
                        sum(pp.kickret_tds) * 6 +
                        sum(pp.fumbles_lost) * -2
                    ) AS points
            FROM
                play_player pp
                JOIN player p ON pp.player_id = p.player_id
                JOIN game g ON pp.gsis_id = g.gsis_id
                JOIN drive d ON pp.gsis_id = d.gsis_id AND pp.drive_id = d.drive_id
            WHERE
                pp.player_id = p.player_id AND
                is_offensive_position(p.position)
            GROUP BY
                pp.gsis_id,
                pp.player_id,
                g.home_team,
                g.away_team,
                d.pos_team
        )
    SELECT
        p.full_name AS name,
        p.position,
        g.season_year AS year,
        g.week,
        g.season_type,
        p.team AS current_team,
        fs.offense,
        fs.defense,
        fs.is_home_game,
        fs.points
    FROM
        player p,
        fantasy_scoring fs,
        game g
    WHERE
        p.player_id = fs.player_id AND
        g.season_type != 'Preseason' AND
        g.gsis_id = fs.gsis_id
    ORDER BY
        points DESC;

ALTER MATERIALIZED VIEW fantasy_points OWNER TO nfldb;
