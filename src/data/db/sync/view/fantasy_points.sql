DROP MATERIALIZED VIEW IF EXISTS fantasy_points;
CREATE MATERIALIZED VIEW fantasy_points AS
    (
    WITH
        fantasy_scoring AS (
            SELECT
                pp.gsis_id,
                pp.player_id,
                (
                        floor((sum(pp.passing_yds)::Float / 25)::Numeric) +
                        sum(pp.passing_tds) * 4 +
                        sum(pp.passing_int) * -2 +
                        sum(pp.passing_twoptm) * 2 +
                        floor((sum(pp.rushing_yds)::Float / 10)::Numeric) +
                        sum(pp.rushing_tds) * 6 +
                        sum(pp.rushing_twoptm) * 2 +
                        floor((sum(pp.receiving_yds)::Float / 10)::Numeric) +
                        sum(pp.receiving_tds) * 6 +
                        sum(pp.receiving_twoptm) * 2 +
                        sum(pp.puntret_tds) * 6 +
                        sum(pp.kickret_tds) * 6 +
                        sum(pp.fumbles_lost) * -2
                    ) AS points
            FROM
                play_player pp,
                player p
            WHERE
                pp.player_id = p.player_id AND
                is_offensive_position(p.position)
            GROUP BY
                pp.gsis_id,
                pp.player_id
        )
    SELECT
        p.full_name AS name,
        p.position,
        p.team,
        g.season_year AS year,
        g.week,
        fs.gsis_id,
        fs.points
    FROM
        player p,
        fantasy_scoring fs,
        game g
    WHERE
        p.player_id = fs.player_id AND
        g.season_type = 'Regular' AND
        g.gsis_id = fs.gsis_id
    ORDER BY
        points DESC
        );

ALTER MATERIALIZED VIEW fantasy_points OWNER TO nfldb;
