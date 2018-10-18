with team_plays as (
    select
        g.gsis_id,
        ag.drive_id,
        ag.play_id,
        g.season_year as year,
        g.week,
        offense_team(ag.gsis_id, ag.drive_id) as offense,
        defense_team(ag.gsis_id, ag.drive_id) as defense,
        (ag.passing_att > 0 or ag.passing_sk_yds < 0)::integer as pass_play,
        (ag.rushing_att > 0)::integer as run_play
    from
        agg_play ag,
        game g
    where
        g.season_type = 'Regular'
        and ag.gsis_id = g.gsis_id
        and (ag.passing_att > 0 or ag.passing_sk_yds < 0 or ag.rushing_att > 0)
    order by
        g.season_year desc,
        g.week desc,
        offense,
        ag.drive_id,
        ag.play_id
)

select
    tp.year,
    tp.week,
    tp.offense,
    tp.defense,
    count(tp.play_id) as n_plays,
    sum(tp.pass_play) as n_pass,
    sum(tp.run_play) as n_run,
    sum(tp.pass_play)/count(tp.play_id)::float as pct_pass,
    sum(tp.run_play)/count(tp.play_id)::float as pct_run
from
    team_plays tp
group by
    tp.year,
    tp.week,
    tp.offense,
    tp.defense
order by
    tp.year desc,
    tp.week desc,
    tp.offense
