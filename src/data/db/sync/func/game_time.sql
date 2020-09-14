CREATE OR REPLACE FUNCTION time_elapsed (t Game_Time)
    RETURNS Int
AS
$$
SELECT
    (CASE
         WHEN t.phase = 'Q1'
             THEN t.elapsed
         WHEN t.phase = 'Q2'
             THEN t.elapsed + (1 * 15 * 60)
         WHEN t.phase = 'Q3'
             THEN t.elapsed + (2 * 15 * 60)
         WHEN t.phase = 'Q4'
             THEN t.elapsed + (3 * 15 * 60)
         WHEN t.phase = 'OT'
             THEN t.elapsed + (4 * 15 * 60)
         WHEN t.phase = 'OT2'
             THEN t.elapsed + (5 * 15 * 60)
             ELSE NULL
     END)
$$
    LANGUAGE sql;
