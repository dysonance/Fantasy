with players as (
    select
        player_id,
        full_name,
        team,
        position,
        years_pro
    from
        player
    where
        team != 'UNK'
        and position = 'QB'
        and status = 'Active'
),
game_meta as (
    select
        gsis_id,
        home_team,
        away_team,
        day_of_week,
        week,
        season_year
    from
        game
    where
        season_type = 'Regular'
),
game_stats as (
    select
        pp.player_id,
        pp.gsis_id,
        count(distinct drive_id) n_drives,
        count(distinct play_id) n_plays,
        sum(passing_att) passes,
        sum(rushing_att) rushes,
        sum(receiving_tar) targets,
        sum(passing_cmp) completions,
        sum(receiving_rec) receptions,
        sum(passing_yds) yds_passing,
        sum(rushing_yds) yds_rushing,
        sum(receiving_yds) yds_receiving,
        sum(passing_tds) tds_passing,
        sum(rushing_tds) tds_rushing,
        sum(receiving_tds) tds_receiving
    from
        play_player pp,
        game_meta gm
    where
        pp.gsis_id = gm.gsis_id
    group by
        pp.player_id,
        pp.gsis_id
),
qb_stats as (
    select
        p.full_name,
        count(distinct gs.gsis_id) games,
        sum(gs.n_drives) drives,
        sum(gs.n_plays) plays,
        sum(gs.passes) passes,
        sum(gs.completions) completions,
        sum(gs.yds_passing) yards,
        sum(gs.tds_passing) touchdowns
    from
        players p,
        game_stats gs
    where
        p.player_id = gs.player_id
    group by
        p.full_name
    order by
        touchdowns desc,
        yards desc
)
select
    qb.*
from
    qb_stats qb
