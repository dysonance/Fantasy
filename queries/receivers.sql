with wr_plays as (
    select
        pp.gsis_id,
        pp.drive_id,
        pp.play_id,
        g.season_year as year,
        g.week,
        play.down,
        play.yardline,
        play.yards_to_go as togo,
        p.full_name as name,
        pp.team,
        pp.receiving_tar as targets,
        pp.receiving_rec as catches,
        pp.receiving_yds as yds,
        pp.receiving_yac_yds as yac
    from
        play_player pp,
        player p,
        game g,
        play
    where
        p.position = 'WR'
        and pp.gsis_id = play.gsis_id
        and pp.drive_id = play.drive_id
        and pp.play_id = play.play_id
        and pp.gsis_id = g.gsis_id
        and pp.player_id = p.player_id
        and (g.season_type = 'Regular'
            or g.season_type = 'Postseason')
    order by
        g.season_year desc,
        g.week desc,
        targets desc,
        catches desc,
        yds desc,
        yac desc
)

select * from wr_plays;

--  select
--      wrp.year,
--      wrp.week,
--      wrp.name,
--      wrp.team,
--      sum(wrp.targets) as targets,
--      sum(wrp.catches) as catches,
--      round((sum(wrp.catches)::float / sum(wrp.targets + 1e-16))::numeric, 2) as catchrate,
--      sum(wrp.yds) as yds,
--      sum(wrp.yac) as yac
--  from
--      wr_plays wrp
--  group by
--      wrp.year,
--      wrp.week,
--      wrp.name,
--      wrp.team,
--  order by
--      wrp.year desc,
--      wrp.week desc,
--      targets desc,
--      catchrate desc
