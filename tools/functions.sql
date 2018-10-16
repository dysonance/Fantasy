drop function if exists offense_team;
create function offense_team (gsis_id gameid, drive_id int)
    returns character varying (3)
as $$
select
    (
        case when g.home_team = d.pos_team then
            g.home_team
        else
            g.away_team
        end)::character varying (3)
from
    drive d,
    game g
where
    d.gsis_id = g.gsis_id
    and g.gsis_id = $1
    and d.drive_id = $2
$$
language sql;

drop function if exists defense_team;
create function defense_team (gsis_id gameid, drive_id int)
    returns character varying (3)
as $$
select
    (
        case when g.home_team = d.pos_team then
            g.away_team
        else
            g.home_team
        end)::character varying (3)
from
    drive d,
    game g
where
    d.gsis_id = g.gsis_id
    and g.gsis_id = $1
    and d.drive_id = $2
$$
language sql;

drop function if exists is_offensive_position;
create function is_offensive_position (pos player_pos)
    returns boolean
as $$
select
    case when (pos = 'QB'
            or pos = 'RB'
            or pos = 'WR'
            or pos = 'TE') then
        true
    else
        false
    end
$$ language sql;
