with te_plays as (
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
        p.position = 'TE'
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

select * from te_plays;

--  select
--      tep.year,
--      -- tep.week,
--      tep.name,
--      tep.team,
--      sum(tep.targets) as targets,
--      sum(tep.catches) as catches,
--      round((sum(tep.catches)::float / sum(tep.targets + 1e-16))::numeric, 2) as catchrate,
--      sum(tep.yds) as yds,
--      sum(tep.yac) as yac
--  from
--      te_plays tep
--  group by
--      tep.year,
--      --  tep.week,
--      tep.name,
--      tep.team
--  order by
--      tep.year desc,
--      -- tep.week desc,
--      targets desc,
--      catchrate desc
