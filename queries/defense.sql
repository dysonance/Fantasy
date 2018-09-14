with drive_team as (
    select
        g.season_year as year,
        g.week,
        d.drive_id,
        d.gsis_id,
        d.play_count,
        case when g.home_team = d.pos_team then g.away_team else g.home_team end defense_team,
        case when g.home_team = d.pos_team then g.home_team else g.away_team end offense_team,
        g.home_team,
        g.away_team,
    from
        drive d,
        game g
    where
        d.gsis_id = g.gsis_id
        and g.season_type = 'Regular'
    order by
        year,
        week,
        drive_id
),
team_plays as (
    select
        dt.year,
        dt.week,
        dt.drive_id,
        dt.gsis_id,
        dt.defense_team team,
        dt.play_count,
        ag.play_id,
        ag.passing_att passes,
        ag.passing_cmp completions,
        ag.passing_yds pass_yards,
        ag.passing_tds pass_touchdowns,
        ag.rushing_att rushes,
        ag.rushing_yds rush_yards,
        ag.rushing_tds rush_touchdowns
    from
        drive_team dt,
        agg_play ag
    where
        dt.gsis_id = ag.gsis_id
        and dt.drive_id = ag.drive_id
)
select * from team_plays
