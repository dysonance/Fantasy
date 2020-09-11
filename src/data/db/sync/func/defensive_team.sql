CREATE OR REPLACE FUNCTION defensive_team (gsis_id gameid, drive_id Int)
    RETURNS Character Varying (
        3
)
    AS $$
    SELECT (
            CASE WHEN g.home_team = d.pos_team THEN
                g.away_team
            ELSE
                g.home_team
            END)::Character Varying(3)
    FROM drive d, game g
    WHERE d.gsis_id = g.gsis_id
        AND g.gsis_id = $1
        AND d.drive_id = $2
$$
LANGUAGE sql;
