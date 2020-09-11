DROP MATERIALIZED VIEW IF EXISTS team_balance;
CREATE MATERIALIZED VIEW team_balance AS
    (
    WITH
        team_plays AS (
            SELECT
                g.gsis_id,
                ag.drive_id,
                ag.play_id,
                g.season_year AS year,
                g.week,
                offensive_team(ag.gsis_id, ag.drive_id) AS offense,
                defensive_team(ag.gsis_id, ag.drive_id) AS defense,
                (ag.passing_att > 0 OR ag.passing_sk_yds < 0)::Integer AS pass_play,
                (ag.rushing_att > 0)::Integer AS run_play
            FROM
                agg_play ag,
                game g
            WHERE
                g.season_type = 'Regular' AND
                ag.gsis_id = g.gsis_id AND
                (ag.passing_att > 0 OR ag.passing_sk_yds < 0 OR ag.rushing_att > 0)
            ORDER BY
                g.season_year DESC,
                g.week DESC,
                offense,
                ag.drive_id,
                ag.play_id
        )
    SELECT
        tp.year,
        tp.week,
        tp.offense,
        tp.defense,
        count(tp.play_id) AS n_plays,
        sum(tp.pass_play) AS n_pass,
        sum(tp.run_play) AS n_run,
        sum(tp.pass_play) / count(tp.play_id)::Float AS pct_pass,
        sum(tp.run_play) / count(tp.play_id)::Float AS pct_run
    FROM
        team_plays tp
    GROUP BY
        tp.year,
        tp.week,
        tp.offense,
        tp.defense
    ORDER BY
        tp.year DESC,
        tp.week DESC,
        tp.offense
        );

ALTER MATERIALIZED VIEW team_balance OWNER TO nfldb;
