with game_team as (
    select
        g.gsis_id,
        g.week,
        g.season_year as year,
        case when g.home_team = d.pos_team then g.away_team else g.home_team end as defense_team,
        case when g.home_team = d.pos_team then g.home_team else g.away_team end as offense_team,
        case when g.home_team = d.pos_team then g.away_score-g.home_score else g.home_score-g.away_score end as defense_ptdiff,
        case when g.home_team = d.pos_team then g.home_score-g.away_score else g.away_score-g.home_score end as offense_ptdiff,
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
        defense_team,
        d.pos_team
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
        round(sum(rb.runyds)::numeric/(case when sum(rb.rushes)=0 then 1 else sum(rb.rushes) end), 2)::float as ypc,
        round(sum(rb.receptions)::numeric/(case when sum(rb.targets)=0 then 1 else sum(rb.targets) end), 2)::float as rpt,
        round(sum(rb.recyds)::numeric/(case when sum(rb.receptions)=0 then 1 else sum(rb.receptions) end), 2)::float as ypr
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
    round((rb.carries)::numeric / gt.rushes, 2)::float as cpr,
    round((rb.targets)::numeric / gt.passes, 2)::float as tpp,
    gt.offense_ptdiff as tsd
from
    rb_stats rb,
    game_team gt
where
    gt.year = rb.year
    and gt.week = rb.week
    and gt.offense_team = rb.team
    and rb.carries > 5
order by
    rb.year desc,
    rb.week desc,
    cpr desc,
    tpp desc,
    rb.team
--  limit 50
