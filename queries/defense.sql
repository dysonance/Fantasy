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
        g.away_team
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
        ag.rushing_tds rush_touchdowns,
        ag.defense_int,
        ag.defense_sk
    from
        drive_team dt,
        agg_play ag
    where
        dt.gsis_id = ag.gsis_id
        and dt.drive_id = ag.drive_id
),

passavg as (
    select
        year,
        week,
        avg(pass_yards) as avg_yds
    from
        team_plays
    where
        passes != 0
    group by
        year,
        week
),

rushavg as (
    select
        year,
        week,
        avg(rush_yards) as avg_yds
    from
        team_plays
    where
        rushes != 0
    group by
        year,
        week
),

passing as (
    select
        tp.year,
        tp.week,
        tp.team,
        count(tp.play_count) as plays,
        sum(tp.defense_sk)::float / count(tp.play_count) as spp,
        sum(tp.defense_int)::float / count(tp.play_count) as ipp,
        avg(tp.pass_yards) as team_avg,
        stddev(tp.pass_yards) as team_dev,
        avg(pa.avg_yds) as league_avg
    from
        team_plays tp
        left join passavg pa on tp.year=pa.year and tp.week=pa.week
    where
        (tp.passes != 0 or tp.defense_sk != 0)
        and tp.year = pa.year
        and tp.week = pa.week
    group by
        tp.year,
        tp.week,
        tp.team
),

rushing as (
    select
        tp.year,
        tp.week,
        tp.team,
        count(tp.play_count) as plays,
        avg(tp.rush_yards) as team_avg,
        stddev(tp.rush_yards) as team_dev,
        avg(ra.avg_yds) as league_avg
    from
        team_plays tp
        left join rushavg ra on tp.year=ra.year and tp.week=ra.week
    where
        rushes != 0
    group by
        tp.year,
        tp.week,
        tp.team
),

defense as (
    select
        p.year,
        p.week,
        p.team,
        p.plays as npp,
        p.spp,
        p.ipp,
        p.team_avg as pyta,
        p.team_dev as pytd,
        p.league_avg as pyla,
        (sqrt(p.plays) * (p.team_avg - p.league_avg) / p.team_dev) as pt,
        r.plays as nrp,
        r.team_avg as ryta,
        r.team_dev as rytd,
        r.league_avg as ryla,
        (sqrt(r.plays) * (r.team_avg - r.league_avg) / r.team_dev) as rt
    from
        passing p,
        rushing r
    where
        p.year = r.year
        and p.week = r.week
        and p.team = r.team
)

select
    d.year,
    d.week,
    d.team,
    d.npp,
    d.spp,
    d.ipp,
    d.pt,
    d.nrp,
    d.rt
from
    defense d
order by
    year desc,
    week desc,
    team
