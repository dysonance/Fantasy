CREATE OR REPLACE FUNCTION is_offensive_position (pos player_pos)
    RETURNS Boolean
    AS $$
    SELECT CASE WHEN (pos = 'QB'
            OR pos = 'RB'
            OR pos = 'WR'
            OR pos = 'TE') THEN
            TRUE
        ELSE
            FALSE
        END
$$
LANGUAGE sql;
