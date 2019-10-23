SELECT
	PLAYER.FULL_NAME         AS "Name",
	PLAYER.POSITION          AS "Pos",
	PP.TEAM                  AS "Team",
	GAME.SEASON_YEAR         AS "Year",
	GAME.WEEK                AS "Week",
	GAME.GAMEKEY             AS "Game",
	PLAY.DRIVE_ID            AS "Drive",
	PLAY.PLAY_ID             AS "Play",
	PLAY.DOWN                AS "Down",
	PLAY.POS_TEAM            AS "Offense",
	GAME.HOME_TEAM           AS "Home",
	GAME.AWAY_TEAM           AS "Away",
	PLAY.YARDS_TO_GO         AS "Yds To First",
	PLAY.TIME                AS "Time",
	PLAY.YARDLINE            AS "Yardline",
	PP.PASSING_ATT           AS "Pass Att",
	PP.PASSING_CMP           AS "Pass Cmp",
	PP.PASSING_TDS           AS "Pass TD",
	PP.PASSING_YDS           AS "Pass Yds",
	PP.PASSING_CMP_AIR_YDS   AS "Cmp Air Yds",
	PP.PASSING_INCMP_AIR_YDS AS "Incmp Air Yds",
	PP.PASSING_INT           AS "Interception",
	PP.RUSHING_ATT           AS "Rush Att",
	PP.RUSHING_YDS           AS "Rush Yds",
	PP.RUSHING_TDS           AS "Rush TD",
	PP.RECEIVING_TAR         AS "Targeted",
	PP.RECEIVING_REC         AS "Reception",
	PP.RECEIVING_YDS         AS "Rec Yds",
	PP.RECEIVING_YAC_YDS     AS "Rec YAC",
	PP.RECEIVING_TDS         AS "Rec TD",

	PP.PASSING_YDS / 25 +
	PP.PASSING_TDS * 4 -
	PP.PASSING_INT * 2 +
	PP.PASSING_TWOPTM * 2 +
	PP.RUSHING_YDS / 10 +
	PP.RUSHING_TDS * 6 +
	PP.RUSHING_TWOPTM * 2 +
	PP.RECEIVING_YDS / 10 +
	PP.RECEIVING_TDS * 6 +
	PP.RECEIVING_TWOPTM * 2 +
	PP.FUMBLES_REC_TDS * 6 +
	PP.KICKRET_TDS * 6 +
	PP.PUNTRET_TDS * 6 -
	PP.FUMBLES_LOST * 2      AS "Points"
FROM PLAY_PLAYER PP
	LEFT JOIN PLAYER
		ON PLAYER.PLAYER_ID = PP.PLAYER_ID
	LEFT JOIN PLAY
		ON PLAY.GSIS_ID = PP.GSIS_ID AND PLAY.DRIVE_ID = PP.DRIVE_ID AND PLAY.PLAY_ID = PP.PLAY_ID
	LEFT JOIN GAME
		ON PLAY.GSIS_ID = GAME.GSIS_ID
WHERE
	-- 	PLAYER.POSITION = 'QB' AND
	GAME.SEASON_TYPE = 'Regular'
ORDER BY "Name", "Year", "Week", "Drive", "Down"

