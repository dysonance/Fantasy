with play_stats as (
    select
        g.gsis_id,
        g.week,
        g.season_year as year,
        case when g.home_team = d.pos_team then g.away_team else g.home_team end defense_team,
        case when g.home_team = d.pos_team then g.home_team else g.away_team end offense_team,
        sum(case when ag.passing_att>0 or ag.rushing_att>0 then 1 else 0 end) as plays,
        sum(case when ag.passing_att>0 then 1 else 0 end) as passes,
        sum(case when ag.rushing_att>0 then 1 else 0 end) as rushes
    from
        game g,
        drive d,
        agg_play ag
    where
        g.gsis_id = d.gsis_id
        and g.gsis_id = ag.gsis_id
        and d.drive_id = ag.drive_id
        and g.season_type = 'Regular'
    group by
        g.gsis_id,
        g.season_year,
        g.week,
        offense_team,
        defense_team
    order by
        year desc,
        week desc,
        offense_team
),

rb_plays as (
    select
        g.gsis_id,
        g.season_year as year,
        g.week,
        pp.drive_id,
        pp.play_id,
        p.full_name as name,
        pp.team,
        pp.receiving_tar as targets,
        pp.receiving_rec as receptions,
        pp.receiving_yds as recyds,
        pp.rushing_att as rushes,
        pp.rushing_yds as runyds
    from
        play_player pp,
        player p,
        game g
    where
        pp.player_id = p.player_id
        and pp.gsis_id = g.gsis_id
        and p.position = 'RB'
        and p.team != 'UNK'
        and p.status = 'Active'
        and g.season_type = 'Regular'
),

rb_stats as (
    select
        rb.year,
        rb.week,
        rb.team,
        rb.name,
        sum(rb.rushes) as carries,
        sum(rb.targets) as targets,
        sum(rb.receptions) as catches,
        sum(rb.runyds) as runyds,
        sum(rb.recyds) as recyds,
        round(sum(rb.runyds)::numeric/(case when sum(rb.rushes)=0 then 1 else sum(rb.rushes) end), 2) as ypc,
        round(sum(rb.receptions)::numeric/(case when sum(rb.targets)=0 then 1 else sum(rb.targets) end), 2) as rpt,
        round(sum(rb.recyds)::numeric/(case when sum(rb.receptions)=0 then 1 else sum(rb.receptions) end), 2) as ypr
    from
        rb_plays rb
    group by
        rb.year,
        rb.week,
        rb.team,
        rb.name
)

select
    rb.*,
    round((rb.carries)::numeric / ps.rushes, 2) as cpr,
    round((rb.targets)::numeric / ps.passes, 2) as tpp
from
    rb_stats rb,
    play_stats ps
where
    ps.year = rb.year
    and ps.week = rb.week
    and ps.offense_team = rb.team
order by
    rb.year desc,
    rb.week desc,
    rb.carries desc,
    rb.targets desc,
    rb.team
