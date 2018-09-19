with rb_plays as (
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
    rb.*
from
    rb_stats rb
order by
    rb.year desc,
    rb.week desc,
    rb.carries desc,
    rb.targets desc,
    rb.team
--  limit 50
