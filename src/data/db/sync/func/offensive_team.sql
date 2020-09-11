CREATE OR REPLACE FUNCTION offensive_team (gsis_id Gameid, drive_id Int)
    RETURNS Varchar (
        3
)
    AS $$
    SELECT (
            CASE WHEN g.home_team = d.pos_team THEN
                g.home_team
            ELSE
                g.away_team
            END)::Varchar(3)
    FROM drive d, game g
    WHERE d.gsis_id = g.gsis_id
        AND g.gsis_id = $1
        AND d.drive_id = $2
$$
LANGUAGE sql;
