with wr_plays as (
    select
        pp.play_id,
        g.season_year as yr,
        g.week as wk,
        p.full_name as name,
        pp.team,
        p.status,
        sum(pp.receiving_tar) as targets,
        sum(pp.receiving_rec) as catches,
        sum(pp.receiving_yds) as yds,
        sum(pp.receiving_yac_yds) as yac
    from
        play_player pp,
        player p,
        game g
    where
        p.position = 'WR'
        and pp.gsis_id = g.gsis_id
        and pp.player_id = p.player_id
        and (g.season_type = 'Regular'
            or g.season_type = 'Postseason')
    group by
        pp.play_id,
        g.season_year,
        g.week,
        p.full_name,
        pp.team,
        p.status
    order by
        g.season_year desc,
        g.week desc,
        targets desc,
        catches desc,
        yds desc,
        yac desc
)

select
    wrp.yr,
    wrp.wk,
    wrp.name,
    wrp.team,
    wrp.status,
    sum(wrp.targets) as targets,
    sum(wrp.catches) as catches,
    round((sum(wrp.catches)::float / (case when sum(wrp.targets) = 0 then 1.0 else sum(wrp.targets) end))::numeric, 2) as catchrate,
    sum(wrp.yds) as yds,
    sum(wrp.yac) as yac
from
    wr_plays wrp
group by
    wrp.yr,
    wrp.wk,
    wrp.name,
    wrp.team,
    wrp.status
order by
    wrp.yr desc,
    wrp.wk desc,
    targets desc,
    catchrate desc

--  limit 50
