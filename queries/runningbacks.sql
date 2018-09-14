with rb_plays as (
    select
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
        sum(rb.runyds) as runyds,
        sum(rb.runyds)::float/(case when sum(rb.rushes)=0 then 1 else sum(rb.rushes) end) as ypc,
        sum(rb.targets) as targets,
        sum(rb.receptions) as catches,
        sum(rb.recyds) as recyds,
        sum(rb.receptions)::float/(case when sum(rb.targets)=0 then 1 else sum(rb.targets) end) as rpt,
        sum(rb.recyds)::float/(case when sum(rb.receptions)=0 then 1 else sum(rb.receptions) end) as ypr
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
where
    rb.week = 1
    and rb.year = 2018
order by
    rb.year desc,
    rb.carries desc,
    rb.targets desc,
    rb.week desc,
    rb.team
limit 50
