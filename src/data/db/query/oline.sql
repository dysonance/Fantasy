select
    g.season_year as yr,
    g.week as wk,
    g.gsis_id as gid,
    p.drive_id as did,
    p.play_id as pid,
    p.time,
    p.down,
    offense_team(p.gsis_id, p.drive_id) as off,
    defense_team(p.gsis_id, p.drive_id) as def,
    p.yardline as fldpos,
    p.yards_to_go as togo,
    ap.rushing_att as run,
    ap.rushing_yds as run_yds,
    ap.passing_att as pass,
    ap.passing_yds as pass_yds,
    ap.passing_sk_yds as pass_sk_yds
from
    play p,
    agg_play ap,
    game g
where
    p.down is not null
    and (g.season_type = 'Regular' or g.season_type = 'Postseason')
    and ap.gsis_id = p.gsis_id
    and ap.drive_id = p.drive_id
    and ap.play_id = p.play_id
    and p.gsis_id = g.gsis_id
order by
    g.gsis_id,
    p.drive_id,
    p.play_id,
    p.down
