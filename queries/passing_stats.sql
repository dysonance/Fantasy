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
game_stats as (
    select
        player_id,
        gsis_id,
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
        play_player
    group by
        player_id,
        gsis_id
)
select
    p.full_name,
    p.team,
    p.position,
    sum(gs.n_plays) n_plays,
    sum(gs.yds_passing) / sum(gs.n_plays) pass_yds_per_play
from
    players p,
    game_stats gs
where
    p.player_id = gs.player_id
group by
    p.full_name,
    p.team,
    p.position
order by
    pass_yds_per_play desc
