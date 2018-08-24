SELECT
	WRTE.*
-- 	WRTE."Points" :: NUMERIC / WRTE."Games" :: NUMERIC  AS "PPG",
-- 	WRTE."Points" :: NUMERIC / WRTE."Drives" :: NUMERIC AS "PPD",
-- 	WRTE."Points" :: NUMERIC / WRTE."Plays" :: NUMERIC  AS "PPP"
-- 	WRTE.AVG_"Points" :: NUMERIC / WRTE.STD_"Points" :: NUMERIC AS SHARPE_PTS,
-- 	WRTE.AVG_REC_YDS / WRTE.STD_REC_YDS                     AS SHARPE_REC_YDS,
-- 	WRTE.AVG_REC_TDS / WRTE.STD_REC_TDS                     AS SHARPE_REC_TDS,
-- 	WRTE.AVG_REC_2PT / WRTE.STD_REC_2PT                     AS SHARPE_REC_2PT,
-- 	WRTE.AVG_REC_REC / WRTE.STD_REC_REC                     AS SHARPE_REC_REC,
-- 	WRTE.AVG_REC_TAR / WRTE.STD_REC_TAR                     AS SHARPE_REC_TAR
FROM (
	     SELECT
		     PLAYER.FULL_NAME           AS "Name",
		     PLAYER.POSITION            AS "Pos",
		     PLAYER.TEAM                AS "Team",
		     PLAYER.YEARS_PRO           AS "Yrs",
		     count(DISTINCT PP.GSIS_ID) AS "Games",
		     (
			     SELECT count(DISTINCT PP.GSIS_ID :: TEXT || '-' || PP.DRIVE_ID :: TEXT)
		     )                          AS "Drives",
		     count(PP.PLAY_ID)          AS "Plays",
		     sum(PP.RECEIVING_YDS)      AS "Rec Yds",
		     sum(PP.RECEIVING_YAC_YDS)  AS "Yds After Catch",
		     sum(PP.RECEIVING_TDS)      AS "Rec TDs",
		     sum(PP.RECEIVING_REC)      AS "Receptions",
		     sum(PP.RECEIVING_TAR)      AS "Targets",
		     -- 		     avg(PP.RECEIVING_YDS)       AS AVG_REC_YDS,
		     -- 		     avg(PP.RECEIVING_TDS)       AS AVG_REC_TDS,
		     -- 		     avg(PP.RECEIVING_TWOPTM)    AS AVG_REC_2PT,
		     -- 		     avg(PP.RECEIVING_REC)       AS AVG_REC_REC,
		     -- 		     avg(PP.RECEIVING_TAR)       AS AVG_REC_TAR,
		     -- 		     stddev(PP.RECEIVING_YDS)    AS STD_REC_YDS,
		     -- 		     stddev(PP.RECEIVING_TDS)    AS STD_REC_TDS,
		     -- 		     stddev(PP.RECEIVING_TWOPTM) AS STD_REC_2PT,
		     -- 		     stddev(PP.RECEIVING_REC)    AS STD_REC_REC,
		     -- 		     stddev(PP.RECEIVING_TAR)    AS STD_REC_TAR,

		     -- "Points" CALCULATIONS --
		     sum(PP.PASSING_YDS) / 25 +
		     sum(PP.PASSING_TDS) * 4 -
		     sum(PP.PASSING_INT) * 2 +
		     sum(PP.PASSING_TWOPTM) * 2 +
		     sum(PP.RUSHING_YDS) / 10 +
		     sum(PP.RUSHING_TDS) * 6 +
		     sum(PP.RUSHING_TWOPTM) * 2 +
		     sum(PP.RECEIVING_YDS) / 10 +
		     sum(PP.RECEIVING_TDS) * 6 +
		     sum(PP.RECEIVING_TWOPTM) * 2 +
		     sum(PP.FUMBLES_REC_TDS) * 6 +
		     sum(PP.KICKRET_TDS) * 6 +
		     sum(PP.PUNTRET_TDS) * 6 -
		     sum(PP.FUMBLES_LOST) * 2   AS "Points"
	     -- 		     avg(PP.PASSING_YDS) / 25 +
	     -- 		     avg(PP.PASSING_TDS) * 4 -
	     -- 		     avg(PP.PASSING_INT) * 2 +
	     -- 		     avg(PP.PASSING_TWOPTM) * 2 +
	     -- 		     avg(PP.RUSHING_YDS) / 10 +
	     -- 		     avg(PP.RUSHING_TDS) * 6 +
	     -- 		     avg(PP.RUSHING_TWOPTM) * 2 +
	     -- 		     avg(PP.RECEIVING_YDS) / 10 +
	     -- 		     avg(PP.RECEIVING_TDS) * 6 +
	     -- 		     avg(PP.RECEIVING_TWOPTM) * 2 +
	     -- 		     avg(PP.FUMBLES_REC_TDS) * 6 +
	     -- 		     avg(PP.KICKRET_TDS) * 6 +
	     -- 		     avg(PP.PUNTRET_TDS) * 6 -
	     -- 		     avg(PP.FUMBLES_LOST) * 2    AS AVG_POINTS,
	     -- 		     stddev(PP.PASSING_YDS) / 25 +
	     -- 		     stddev(PP.PASSING_TDS) * 4 -
	     -- 		     stddev(PP.PASSING_INT) * 2 +
	     -- 		     stddev(PP.PASSING_TWOPTM) * 2 +
	     -- 		     stddev(PP.RUSHING_YDS) / 10 +
	     -- 		     stddev(PP.RUSHING_TDS) * 6 +
	     -- 		     stddev(PP.RUSHING_TWOPTM) * 2 +
	     -- 		     stddev(PP.RECEIVING_YDS) / 10 +
	     -- 		     stddev(PP.RECEIVING_TDS) * 6 +
	     -- 		     stddev(PP.RECEIVING_TWOPTM) * 2 +
	     -- 		     stddev(PP.FUMBLES_REC_TDS) * 6 +
	     -- 		     stddev(PP.KICKRET_TDS) * 6 +
	     -- 		     stddev(PP.PUNTRET_TDS) * 6 -
	     -- 		     stddev(PP.FUMBLES_LOST) * 2 AS STD_POINTS
	     FROM
		     PLAY_PLAYER PP
		     LEFT JOIN PLAYER
			     ON PLAYER.PLAYER_ID = PP.PLAYER_ID
		     LEFT JOIN GAME
			     ON GAME.GSIS_ID = PP.GSIS_ID
	     WHERE
		     (
			     PLAYER.POSITION = 'WR'
			     OR PLAYER.POSITION = 'TE'
		     )
		     AND GAME.SEASON_TYPE = 'Regular'
	     GROUP BY
		     PLAYER.FULL_NAME,
		     PLAYER.POSITION,
		     PLAYER.TEAM,
		     PLAYER.YEARS_PRO
     ) AS WRTE
-- WHERE
-- 	WRTE."Points" > 0
-- 	WRTE.STD_REC_2PT <> 0
-- 	AND WRTE.STD_REC_TDS <> 0
-- 	AND WRTE.STD_REC_YDS <> 0
ORDER BY
	"Points" DESC
