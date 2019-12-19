---
title: Player Performance Prediction Ideas
author: Jacob T. Amos
toc: true
numbersections: true
listings: true
geometry: |
    margin=0.5in
header-includes: |
    \usepackage{bm}
    \usepackage{mathrsfs}
    \usepackage{amsfonts}
    \usepackage{amssymb}
    \usepackage{amsmath}
    \usepackage{mathalfa}
    \usepackage[utf8]{inputenc}
---

\newpage

# Introduction

## Motivation
We want to be able to predict the outcome of a player's performance in the future in as generalizable a manner as possible. Insofar as the most general ultimate solution to this performance prediction problem should be automatably with reasonably well-structured information for input, we should aim to rely solely on directly observable data produced as play occurs.

Given the finer details offered through data at a more granular level, we seek to infer more precise estimates/predictions of what the future outcome will be. This future "outcome" may be determined in any number of ways, often through the lens of some summary statistic computed based on aggregated game performance.

## Scoring
Take, for example, "fantasy points", commonly used in standard-scoring fantasy football leagues. This formula defines in precise terms a quantitative summary of the outcome of any given player's performance throughout a discrete game. Each of the following summary statistics measured over the course of a single game equates to one fantasy point. The player's total is summed throughout the game to get the player's total points for the outing.

| Context             | Event                             | Points Per Occurrence   |
| ------------------- | :-------------------------------: | ----------------------: |
| Rushing/Receiving   | Yard Gained                       | $\tfrac{1}{10}$         |
| Rushing/Receiving   | Touchdown Scored                  | 6                       |
| Rushing/Receiving   | Fumble Lost                       | -2                      |
| Passing             | Yard Gained                       | $\tfrac{1}{25}$         |
| Passing             | Touchdown Scored                  | 4                       |
| Passing             | Interception Thrown               | -2                      |
| Special Teams       | Extra Point Scored                | 1                       |
| Special Teams       | Field Goal Scored (0-39 Yards)    | 3                       |
| Special Teams       | Field Goal Scored (40-49 Yards)   | 4                       |
| Special Teams       | Field Goal Scored (50+ Yards)     | 5                       |
| Defense             | Turnover Won                      | 2                       |
| Defense             | Quarterback Sacked                | 1                       |
| Defense             | Safety Scored                     | 2                       |
| Defense             | Touchdown Scored                  | 6                       |
| Defense             | Kick Blocked                      | 2                       |

Table 1: Fantasy Football Standard Scoring Breakdown

## Objective
Given the above scoring breakdown, we can construct a mathematical formula for this statistic based on the various in-game component statistics that evolve in real-time during gameplay. These constituent metrics also provide a finer degree of detail that should prove useful for sharpening estimates of this outcome, provided that on the whole they permit a higher signal/noise ratio facilitating more accurate predictions.

Let us proceed using the following notation.

- Let $f$ denote the total fantasy points realized, with $f$ an estimate or prediction thereof. Further, let us denote the difference between predicted and observed $f$ as $\varepsilon$.
- Let $y$ denote yards gained generally, with passing yards $y^{p}$ and rushing or receiving yards $y^{r}$.
- Let $\tau$ denote touchdowns scored generally, with passing touchdowns $\tau^{p}$ and rushing or receiving touchdowns $\tau^{r}$.
- Let $\ell$ denote lost turnovers generally, with interceptions specified as $\ell^{I}$ and fumbles $\ell^{F}$ where distinction is appropriate.

Then we have the following mathematical relationship quantifying summative realized value for an offensive player.

$$
f := \left( 6\tau^{r} + 4\tau^{p} \right) + \left( \frac{y^{r}}{10} + \frac{y^{p}}{25} \right) - 2\ell
$$

To restrain the scope of the problem we seek to solve, we shall assume that our ultimate objective is to minimize $\mathbb{E}\left[ \varepsilon \right]$, that is, to predict the relevant future outcome as closely as possible.

---

\newpage

# Approach
Each particular position carries its own unique implications for how to predict a given summary statistic encapsulating outcome. To give the problem framing some structure, however, let there exist some unifying approach that applies across positions as a general model for how to estimate the expected outcome of a player given distributions around some randomness in underlying observable data.

Let us consider the standard formula for expected value as a motivating principle.

$$
\mathbb{E}\left[ X \right] := \int_{0}^{\infty}\left[ x \cdot p\left( x \right) dx \right]
$$

In our case, the random variable $X$ above would correspond to some statistic of interest summarizing player outcome. If the total fantasy points scored by some player in some game is this statistic, then we might interpret our sample space $X$ to be the space of all possible fantasy points scorable in a single game. One could imagine this space to have high density around the center and low density around its edges where the best and worst games are achieved.

We would be remiss, however, not to observe the following propositions.
1. Each point $x \in X$ is determined by numerous other observable random variables.
2. Given data recorded at sub-game frequency, we may sharpen our estimates of $\mathbb{E}\left[ X \right]$.

---

\newpage

# Appendix: Database Schema

## Overview

```
 Schema |    Name     | Type  | Owner
--------+-------------+-------+-------
 public | agg_play    | table | nfldb
 public | drive       | table | nfldb
 public | game        | table | nfldb
 public | meta        | table | nfldb
 public | play        | table | nfldb
 public | play_player | table | nfldb
 public | player      | table | nfldb
 public | team        | table | nfldb
```

## Static

### Players

```
                          Table "public.player"
     Column     |          Type          | Collation | Nullable | Default
----------------+------------------------+-----------+----------+---------
 player_id      | character varying(10)  |           | not null |
 gsis_name      | character varying(75)  |           |          |
 full_name      | character varying(100) |           |          |
 first_name     | character varying(100) |           |          |
 last_name      | character varying(100) |           |          |
 team           | character varying(3)   |           | not null |
 position       | player_pos             |           | not null |
 profile_id     | integer                |           |          |
 profile_url    | character varying(255) |           |          |
 uniform_number | usmallint              |           |          |
 birthdate      | character varying(75)  |           |          |
 college        | character varying(255) |           |          |
 height         | usmallint              |           |          |
 weight         | usmallint              |           |          |
 years_pro      | usmallint              |           |          |
 status         | player_status          |           | not null |
Indexes:
    "player_pkey" PRIMARY KEY, btree (player_id)
    "player_in_full_name" btree (full_name)
    "player_in_gsis_name" btree (gsis_name)
    "player_in_position" btree ("position")
    "player_in_team" btree (team)
Check constraints:
    "player_player_id_check" CHECK (char_length(player_id::text) = 10)
Foreign-key constraints:
    "player_team_fkey" FOREIGN KEY (team) REFERENCES team(team_id) ON UPDATE CASCADE ON DELETE RESTRICT
Referenced by:
    TABLE "play_player" CONSTRAINT "play_player_player_id_fkey" FOREIGN KEY (player_id) REFERENCES player(player_id) ON DELETE RESTRICT
```

### Teams

```
                       Table "public.team"
 Column  |         Type          | Collation | Nullable | Default
---------+-----------------------+-----------+----------+---------
 team_id | character varying(3)  |           | not null |
 city    | character varying(50) |           | not null |
 name    | character varying(50) |           | not null |
Indexes:
    "team_pkey" PRIMARY KEY, btree (team_id)
Referenced by:
    TABLE "drive" CONSTRAINT "drive_pos_team_fkey" FOREIGN KEY (pos_team) REFERENCES team(team_id) ON UPDATE CASCADE ON DELETE RESTRICT
    TABLE "game" CONSTRAINT "game_away_team_fkey" FOREIGN KEY (away_team) REFERENCES team(team_id) ON UPDATE CASCADE ON DELETE RESTRICT
    TABLE "game" CONSTRAINT "game_home_team_fkey" FOREIGN KEY (home_team) REFERENCES team(team_id) ON UPDATE CASCADE ON DELETE RESTRICT
    TABLE "play_player" CONSTRAINT "play_player_team_fkey" FOREIGN KEY (team) REFERENCES team(team_id) ON UPDATE CASCADE ON DELETE RESTRICT
    TABLE "play" CONSTRAINT "play_pos_team_fkey" FOREIGN KEY (pos_team) REFERENCES team(team_id) ON UPDATE CASCADE ON DELETE RESTRICT
    TABLE "player" CONSTRAINT "player_team_fkey" FOREIGN KEY (team) REFERENCES team(team_id) ON UPDATE CASCADE ON DELETE RESTRICT
```

### Metadata

```
                         Table "public.meta"
        Column        |     Type     | Collation | Nullable | Default
----------------------+--------------+-----------+----------+---------
 version              | smallint     |           |          |
 last_roster_download | utctime      |           | not null |
 season_type          | season_phase |           |          |
 season_year          | usmallint    |           |          |
 week                 | usmallint    |           |          |
Check constraints:
    "meta_season_year_check" CHECK (season_year::smallint >= 1960 AND season_year::smallint <= 2100)
    "meta_week_check" CHECK (week::smallint >= 0 AND week::smallint <= 25)
```

## Dynamic

### Aggregated Plays

```
                      Table "public.agg_play"
        Column         |   Type    | Collation | Nullable | Default
-----------------------+-----------+-----------+----------+---------
 gsis_id               | gameid    |           | not null |
 drive_id              | usmallint |           | not null |
 play_id               | usmallint |           | not null |
 defense_ast           | smallint  |           | not null | 0
 defense_ffum          | smallint  |           | not null | 0
 defense_fgblk         | smallint  |           | not null | 0
 defense_frec          | smallint  |           | not null | 0
 defense_frec_tds      | smallint  |           | not null | 0
 defense_frec_yds      | smallint  |           | not null | 0
 defense_int           | smallint  |           | not null | 0
 defense_int_tds       | smallint  |           | not null | 0
 defense_int_yds       | smallint  |           | not null | 0
 defense_misc_tds      | smallint  |           | not null | 0
 defense_misc_yds      | smallint  |           | not null | 0
 defense_pass_def      | smallint  |           | not null | 0
 defense_puntblk       | smallint  |           | not null | 0
 defense_qbhit         | smallint  |           | not null | 0
 defense_safe          | smallint  |           | not null | 0
 defense_sk            | real      |           | not null | 0.0
 defense_sk_yds        | smallint  |           | not null | 0
 defense_tkl           | smallint  |           | not null | 0
 defense_tkl_loss      | smallint  |           | not null | 0
 defense_tkl_loss_yds  | smallint  |           | not null | 0
 defense_tkl_primary   | smallint  |           | not null | 0
 defense_xpblk         | smallint  |           | not null | 0
 fumbles_forced        | smallint  |           | not null | 0
 fumbles_lost          | smallint  |           | not null | 0
 fumbles_notforced     | smallint  |           | not null | 0
 fumbles_oob           | smallint  |           | not null | 0
 fumbles_rec           | smallint  |           | not null | 0
 fumbles_rec_tds       | smallint  |           | not null | 0
 fumbles_rec_yds       | smallint  |           | not null | 0
 fumbles_tot           | smallint  |           | not null | 0
 kicking_all_yds       | smallint  |           | not null | 0
 kicking_downed        | smallint  |           | not null | 0
 kicking_fga           | smallint  |           | not null | 0
 kicking_fgb           | smallint  |           | not null | 0
 kicking_fgm           | smallint  |           | not null | 0
 kicking_fgm_yds       | smallint  |           | not null | 0
 kicking_fgmissed      | smallint  |           | not null | 0
 kicking_fgmissed_yds  | smallint  |           | not null | 0
 kicking_i20           | smallint  |           | not null | 0
 kicking_rec           | smallint  |           | not null | 0
 kicking_rec_tds       | smallint  |           | not null | 0
 kicking_tot           | smallint  |           | not null | 0
 kicking_touchback     | smallint  |           | not null | 0
 kicking_xpa           | smallint  |           | not null | 0
 kicking_xpb           | smallint  |           | not null | 0
 kicking_xpmade        | smallint  |           | not null | 0
 kicking_xpmissed      | smallint  |           | not null | 0
 kicking_yds           | smallint  |           | not null | 0
 kickret_fair          | smallint  |           | not null | 0
 kickret_oob           | smallint  |           | not null | 0
 kickret_ret           | smallint  |           | not null | 0
 kickret_tds           | smallint  |           | not null | 0
 kickret_touchback     | smallint  |           | not null | 0
 kickret_yds           | smallint  |           | not null | 0
 passing_att           | smallint  |           | not null | 0
 passing_cmp           | smallint  |           | not null | 0
 passing_cmp_air_yds   | smallint  |           | not null | 0
 passing_incmp         | smallint  |           | not null | 0
 passing_incmp_air_yds | smallint  |           | not null | 0
 passing_int           | smallint  |           | not null | 0
 passing_sk            | smallint  |           | not null | 0
 passing_sk_yds        | smallint  |           | not null | 0
 passing_tds           | smallint  |           | not null | 0
 passing_twopta        | smallint  |           | not null | 0
 passing_twoptm        | smallint  |           | not null | 0
 passing_twoptmissed   | smallint  |           | not null | 0
 passing_yds           | smallint  |           | not null | 0
 punting_blk           | smallint  |           | not null | 0
 punting_i20           | smallint  |           | not null | 0
 punting_tot           | smallint  |           | not null | 0
 punting_touchback     | smallint  |           | not null | 0
 punting_yds           | smallint  |           | not null | 0
 puntret_downed        | smallint  |           | not null | 0
 puntret_fair          | smallint  |           | not null | 0
 puntret_oob           | smallint  |           | not null | 0
 puntret_tds           | smallint  |           | not null | 0
 puntret_tot           | smallint  |           | not null | 0
 puntret_touchback     | smallint  |           | not null | 0
 puntret_yds           | smallint  |           | not null | 0
 receiving_rec         | smallint  |           | not null | 0
 receiving_tar         | smallint  |           | not null | 0
 receiving_tds         | smallint  |           | not null | 0
 receiving_twopta      | smallint  |           | not null | 0
 receiving_twoptm      | smallint  |           | not null | 0
 receiving_twoptmissed | smallint  |           | not null | 0
 receiving_yac_yds     | smallint  |           | not null | 0
 receiving_yds         | smallint  |           | not null | 0
 rushing_att           | smallint  |           | not null | 0
 rushing_loss          | smallint  |           | not null | 0
 rushing_loss_yds      | smallint  |           | not null | 0
 rushing_tds           | smallint  |           | not null | 0
 rushing_twopta        | smallint  |           | not null | 0
 rushing_twoptm        | smallint  |           | not null | 0
 rushing_twoptmissed   | smallint  |           | not null | 0
 rushing_yds           | smallint  |           | not null | 0
Indexes:
    "agg_play_pkey" PRIMARY KEY, btree (gsis_id, drive_id, play_id)
    "agg_play_in_defense_ast" btree (defense_ast)
    "agg_play_in_defense_ffum" btree (defense_ffum)
    "agg_play_in_defense_fgblk" btree (defense_fgblk)
    "agg_play_in_defense_frec" btree (defense_frec)
    "agg_play_in_defense_frec_tds" btree (defense_frec_tds)
    "agg_play_in_defense_frec_yds" btree (defense_frec_yds)
    "agg_play_in_defense_int" btree (defense_int)
    "agg_play_in_defense_int_tds" btree (defense_int_tds)
    "agg_play_in_defense_int_yds" btree (defense_int_yds)
    "agg_play_in_defense_misc_tds" btree (defense_misc_tds)
    "agg_play_in_defense_misc_yds" btree (defense_misc_yds)
    "agg_play_in_defense_pass_def" btree (defense_pass_def)
    "agg_play_in_defense_puntblk" btree (defense_puntblk)
    "agg_play_in_defense_qbhit" btree (defense_qbhit)
    "agg_play_in_defense_safe" btree (defense_safe)
    "agg_play_in_defense_sk" btree (defense_sk)
    "agg_play_in_defense_sk_yds" btree (defense_sk_yds)
    "agg_play_in_defense_tkl" btree (defense_tkl)
    "agg_play_in_defense_tkl_loss" btree (defense_tkl_loss)
    "agg_play_in_defense_tkl_loss_yds" btree (defense_tkl_loss_yds)
    "agg_play_in_defense_tkl_primary" btree (defense_tkl_primary)
    "agg_play_in_defense_xpblk" btree (defense_xpblk)
    "agg_play_in_fumbles_forced" btree (fumbles_forced)
    "agg_play_in_fumbles_lost" btree (fumbles_lost)
    "agg_play_in_fumbles_notforced" btree (fumbles_notforced)
    "agg_play_in_fumbles_oob" btree (fumbles_oob)
    "agg_play_in_fumbles_rec" btree (fumbles_rec)
    "agg_play_in_fumbles_rec_tds" btree (fumbles_rec_tds)
    "agg_play_in_fumbles_rec_yds" btree (fumbles_rec_yds)
    "agg_play_in_fumbles_tot" btree (fumbles_tot)
    "agg_play_in_gsis_drive_id" btree (gsis_id, drive_id)
    "agg_play_in_gsis_id" btree (gsis_id)
    "agg_play_in_kicking_all_yds" btree (kicking_all_yds)
    "agg_play_in_kicking_downed" btree (kicking_downed)
    "agg_play_in_kicking_fga" btree (kicking_fga)
    "agg_play_in_kicking_fgb" btree (kicking_fgb)
    "agg_play_in_kicking_fgm" btree (kicking_fgm)
    "agg_play_in_kicking_fgm_yds" btree (kicking_fgm_yds)
    "agg_play_in_kicking_fgmissed" btree (kicking_fgmissed)
    "agg_play_in_kicking_fgmissed_yds" btree (kicking_fgmissed_yds)
    "agg_play_in_kicking_i20" btree (kicking_i20)
    "agg_play_in_kicking_rec" btree (kicking_rec)
    "agg_play_in_kicking_rec_tds" btree (kicking_rec_tds)
    "agg_play_in_kicking_tot" btree (kicking_tot)
    "agg_play_in_kicking_touchback" btree (kicking_touchback)
    "agg_play_in_kicking_xpa" btree (kicking_xpa)
    "agg_play_in_kicking_xpb" btree (kicking_xpb)
    "agg_play_in_kicking_xpmade" btree (kicking_xpmade)
    "agg_play_in_kicking_xpmissed" btree (kicking_xpmissed)
    "agg_play_in_kicking_yds" btree (kicking_yds)
    "agg_play_in_kickret_fair" btree (kickret_fair)
    "agg_play_in_kickret_oob" btree (kickret_oob)
    "agg_play_in_kickret_ret" btree (kickret_ret)
    "agg_play_in_kickret_tds" btree (kickret_tds)
    "agg_play_in_kickret_touchback" btree (kickret_touchback)
    "agg_play_in_kickret_yds" btree (kickret_yds)
    "agg_play_in_passing_att" btree (passing_att)
    "agg_play_in_passing_cmp" btree (passing_cmp)
    "agg_play_in_passing_cmp_air_yds" btree (passing_cmp_air_yds)
    "agg_play_in_passing_incmp" btree (passing_incmp)
    "agg_play_in_passing_incmp_air_yds" btree (passing_incmp_air_yds)
    "agg_play_in_passing_int" btree (passing_int)
    "agg_play_in_passing_sk" btree (passing_sk)
    "agg_play_in_passing_sk_yds" btree (passing_sk_yds)
    "agg_play_in_passing_tds" btree (passing_tds)
    "agg_play_in_passing_twopta" btree (passing_twopta)
    "agg_play_in_passing_twoptm" btree (passing_twoptm)
    "agg_play_in_passing_twoptmissed" btree (passing_twoptmissed)
    "agg_play_in_passing_yds" btree (passing_yds)
    "agg_play_in_punting_blk" btree (punting_blk)
    "agg_play_in_punting_i20" btree (punting_i20)
    "agg_play_in_punting_tot" btree (punting_tot)
    "agg_play_in_punting_touchback" btree (punting_touchback)
    "agg_play_in_punting_yds" btree (punting_yds)
    "agg_play_in_puntret_downed" btree (puntret_downed)
    "agg_play_in_puntret_fair" btree (puntret_fair)
    "agg_play_in_puntret_oob" btree (puntret_oob)
    "agg_play_in_puntret_tds" btree (puntret_tds)
    "agg_play_in_puntret_tot" btree (puntret_tot)
    "agg_play_in_puntret_touchback" btree (puntret_touchback)
    "agg_play_in_puntret_yds" btree (puntret_yds)
    "agg_play_in_receiving_rec" btree (receiving_rec)
    "agg_play_in_receiving_tar" btree (receiving_tar)
    "agg_play_in_receiving_tds" btree (receiving_tds)
    "agg_play_in_receiving_twopta" btree (receiving_twopta)
    "agg_play_in_receiving_twoptm" btree (receiving_twoptm)
    "agg_play_in_receiving_twoptmissed" btree (receiving_twoptmissed)
    "agg_play_in_receiving_yac_yds" btree (receiving_yac_yds)
    "agg_play_in_receiving_yds" btree (receiving_yds)
    "agg_play_in_rushing_att" btree (rushing_att)
    "agg_play_in_rushing_loss" btree (rushing_loss)
    "agg_play_in_rushing_loss_yds" btree (rushing_loss_yds)
    "agg_play_in_rushing_tds" btree (rushing_tds)
    "agg_play_in_rushing_twopta" btree (rushing_twopta)
    "agg_play_in_rushing_twoptm" btree (rushing_twoptm)
    "agg_play_in_rushing_twoptmissed" btree (rushing_twoptmissed)
    "agg_play_in_rushing_yds" btree (rushing_yds)
Foreign-key constraints:
    "agg_play_gsis_id_fkey" FOREIGN KEY (gsis_id, drive_id, play_id) REFERENCES play(gsis_id, drive_id, play_id) ON DELETE CASCADE
    "agg_play_gsis_id_fkey1" FOREIGN KEY (gsis_id, drive_id) REFERENCES drive(gsis_id, drive_id) ON DELETE CASCADE
    "agg_play_gsis_id_fkey2" FOREIGN KEY (gsis_id) REFERENCES game(gsis_id) ON DELETE CASCADE
```

### Drives

```
                         Table "public.drive"
    Column     |         Type         | Collation | Nullable | Default
---------------+----------------------+-----------+----------+---------
 gsis_id       | gameid               |           | not null |
 drive_id      | usmallint            |           | not null |
 start_field   | field_pos            |           |          |
 start_time    | game_time            |           | not null |
 end_field     | field_pos            |           |          |
 end_time      | game_time            |           | not null |
 pos_team      | character varying(3) |           | not null |
 pos_time      | pos_period           |           |          |
 first_downs   | usmallint            |           | not null |
 result        | text                 |           |          |
 penalty_yards | smallint             |           | not null |
 yards_gained  | smallint             |           | not null |
 play_count    | usmallint            |           | not null |
 time_inserted | utctime              |           | not null |
 time_updated  | utctime              |           | not null |
Indexes:
    "drive_pkey" PRIMARY KEY, btree (gsis_id, drive_id)
    "drive_in_drive_id" btree (drive_id)
    "drive_in_end_field" btree (((end_field).pos))
    "drive_in_end_time" btree (((end_time).phase), ((end_time).elapsed))
    "drive_in_first_downs" btree (first_downs DESC)
    "drive_in_gsis_id" btree (gsis_id)
    "drive_in_penalty_yards" btree (penalty_yards DESC)
    "drive_in_play_count" btree (play_count DESC)
    "drive_in_pos_team" btree (pos_team)
    "drive_in_pos_time" btree (((pos_time).elapsed) DESC)
    "drive_in_start_field" btree (((start_field).pos))
    "drive_in_start_time" btree (((start_time).phase), ((start_time).elapsed))
    "drive_in_yards_gained" btree (yards_gained DESC)
Foreign-key constraints:
    "drive_gsis_id_fkey" FOREIGN KEY (gsis_id) REFERENCES game(gsis_id) ON DELETE CASCADE
    "drive_pos_team_fkey" FOREIGN KEY (pos_team) REFERENCES team(team_id) ON UPDATE CASCADE ON DELETE RESTRICT
Referenced by:
    TABLE "agg_play" CONSTRAINT "agg_play_gsis_id_fkey1" FOREIGN KEY (gsis_id, drive_id) REFERENCES drive(gsis_id, drive_id) ON DELETE CASCADE
    TABLE "play" CONSTRAINT "play_gsis_id_fkey" FOREIGN KEY (gsis_id, drive_id) REFERENCES drive(gsis_id, drive_id) ON DELETE CASCADE
    TABLE "play_player" CONSTRAINT "play_player_gsis_id_fkey1" FOREIGN KEY (gsis_id, drive_id) REFERENCES drive(gsis_id, drive_id) ON DELETE CASCADE
```

### Game Information

```
                          Table "public.game"
     Column     |         Type         | Collation | Nullable | Default
----------------+----------------------+-----------+----------+---------
 gsis_id        | gameid               |           | not null |
 gamekey        | character varying(5) |           |          |
 start_time     | utctime              |           | not null |
 week           | usmallint            |           | not null |
 day_of_week    | game_day             |           | not null |
 season_year    | usmallint            |           | not null |
 season_type    | season_phase         |           | not null |
 finished       | boolean              |           | not null |
 home_team      | character varying(3) |           | not null |
 home_score     | usmallint            |           | not null |
 home_score_q1  | usmallint            |           |          |
 home_score_q2  | usmallint            |           |          |
 home_score_q3  | usmallint            |           |          |
 home_score_q4  | usmallint            |           |          |
 home_score_q5  | usmallint            |           |          |
 home_turnovers | usmallint            |           | not null |
 away_team      | character varying(3) |           | not null |
 away_score     | usmallint            |           | not null |
 away_score_q1  | usmallint            |           |          |
 away_score_q2  | usmallint            |           |          |
 away_score_q3  | usmallint            |           |          |
 away_score_q4  | usmallint            |           |          |
 away_score_q5  | usmallint            |           |          |
 away_turnovers | usmallint            |           | not null |
 time_inserted  | utctime              |           | not null |
 time_updated   | utctime              |           | not null |
Indexes:
    "game_pkey" PRIMARY KEY, btree (gsis_id)
    "game_in_away_score" btree (away_score)
    "game_in_away_team" btree (away_team)
    "game_in_away_turnovers" btree (away_turnovers)
    "game_in_day_of_week" btree (day_of_week)
    "game_in_finished" btree (finished)
    "game_in_gamekey" btree (gamekey)
    "game_in_home_score" btree (home_score)
    "game_in_home_team" btree (home_team)
    "game_in_home_turnovers" btree (home_turnovers)
    "game_in_season_type" btree (season_type)
    "game_in_season_year" btree (season_year)
    "game_in_start_time" btree (start_time)
    "game_in_week" btree (week)
Check constraints:
    "game_season_year_check" CHECK (season_year::smallint >= 1960 AND season_year::smallint <= 2100)
    "game_week_check" CHECK (week::smallint >= 0 AND week::smallint <= 25)
Foreign-key constraints:
    "game_away_team_fkey" FOREIGN KEY (away_team) REFERENCES team(team_id) ON UPDATE CASCADE ON DELETE RESTRICT
    "game_home_team_fkey" FOREIGN KEY (home_team) REFERENCES team(team_id) ON UPDATE CASCADE ON DELETE RESTRICT
Referenced by:
    TABLE "agg_play" CONSTRAINT "agg_play_gsis_id_fkey2" FOREIGN KEY (gsis_id) REFERENCES game(gsis_id) ON DELETE CASCADE
    TABLE "drive" CONSTRAINT "drive_gsis_id_fkey" FOREIGN KEY (gsis_id) REFERENCES game(gsis_id) ON DELETE CASCADE
    TABLE "play" CONSTRAINT "play_gsis_id_fkey1" FOREIGN KEY (gsis_id) REFERENCES game(gsis_id) ON DELETE CASCADE
    TABLE "play_player" CONSTRAINT "play_player_gsis_id_fkey2" FOREIGN KEY (gsis_id) REFERENCES game(gsis_id) ON DELETE CASCADE
```

### Aggregated Plays

```
                            Table "public.play"
       Column       |         Type         | Collation | Nullable | Default
--------------------+----------------------+-----------+----------+---------
 gsis_id            | gameid               |           | not null |
 drive_id           | usmallint            |           | not null |
 play_id            | usmallint            |           | not null |
 time               | game_time            |           | not null |
 pos_team           | character varying(3) |           | not null |
 yardline           | field_pos            |           |          |
 down               | smallint             |           |          |
 yards_to_go        | smallint             |           |          |
 description        | text                 |           |          |
 note               | text                 |           |          |
 time_inserted      | utctime              |           | not null |
 time_updated       | utctime              |           | not null |
 first_down         | smallint             |           | not null | 0
 fourth_down_att    | smallint             |           | not null | 0
 fourth_down_conv   | smallint             |           | not null | 0
 fourth_down_failed | smallint             |           | not null | 0
 passing_first_down | smallint             |           | not null | 0
 penalty            | smallint             |           | not null | 0
 penalty_first_down | smallint             |           | not null | 0
 penalty_yds        | smallint             |           | not null | 0
 rushing_first_down | smallint             |           | not null | 0
 third_down_att     | smallint             |           | not null | 0
 third_down_conv    | smallint             |           | not null | 0
 third_down_failed  | smallint             |           | not null | 0
 timeout            | smallint             |           | not null | 0
 xp_aborted         | smallint             |           | not null | 0
Indexes:
    "play_pkey" PRIMARY KEY, btree (gsis_id, drive_id, play_id)
    "play_in_down" btree (down)
    "play_in_first_down" btree (first_down)
    "play_in_fourth_down_att" btree (fourth_down_att)
    "play_in_fourth_down_conv" btree (fourth_down_conv)
    "play_in_fourth_down_failed" btree (fourth_down_failed)
    "play_in_gsis_drive_id" btree (gsis_id, drive_id)
    "play_in_gsis_id" btree (gsis_id)
    "play_in_passing_first_down" btree (passing_first_down)
    "play_in_penalty" btree (penalty)
    "play_in_penalty_first_down" btree (penalty_first_down)
    "play_in_penalty_yds" btree (penalty_yds)
    "play_in_pos_team" btree (pos_team)
    "play_in_rushing_first_down" btree (rushing_first_down)
    "play_in_third_down_att" btree (third_down_att)
    "play_in_third_down_conv" btree (third_down_conv)
    "play_in_third_down_failed" btree (third_down_failed)
    "play_in_time" btree ((("time").phase), (("time").elapsed))
    "play_in_timeout" btree (timeout)
    "play_in_xp_aborted" btree (xp_aborted)
    "play_in_yardline" btree (((yardline).pos))
    "play_in_yards_to_go" btree (yards_to_go DESC)
Check constraints:
    "play_down_check" CHECK (down >= 1 AND down <= 4)
    "play_yards_to_go_check" CHECK (yards_to_go >= 0 AND yards_to_go <= 100)
Foreign-key constraints:
    "play_gsis_id_fkey" FOREIGN KEY (gsis_id, drive_id) REFERENCES drive(gsis_id, drive_id) ON DELETE CASCADE
    "play_gsis_id_fkey1" FOREIGN KEY (gsis_id) REFERENCES game(gsis_id) ON DELETE CASCADE
    "play_pos_team_fkey" FOREIGN KEY (pos_team) REFERENCES team(team_id) ON UPDATE CASCADE ON DELETE RESTRICT
Referenced by:
    TABLE "agg_play" CONSTRAINT "agg_play_gsis_id_fkey" FOREIGN KEY (gsis_id, drive_id, play_id) REFERENCES play(gsis_id, drive_id, play_id) ON DELETE CASCADE
    TABLE "play_player" CONSTRAINT "play_player_gsis_id_fkey" FOREIGN KEY (gsis_id, drive_id, play_id) REFERENCES play(gsis_id, drive_id, play_id) ON DELETE CASCADE
Triggers:
    agg_play_sync_insert AFTER INSERT ON play FOR EACH ROW EXECUTE PROCEDURE agg_play_insert()
```

### Player Performance

```
                           Table "public.play_player"
        Column         |         Type          | Collation | Nullable | Default
-----------------------+-----------------------+-----------+----------+---------
 gsis_id               | gameid                |           | not null |
 drive_id              | usmallint             |           | not null |
 play_id               | usmallint             |           | not null |
 player_id             | character varying(10) |           | not null |
 team                  | character varying(3)  |           | not null |
 defense_ast           | smallint              |           | not null | 0
 defense_ffum          | smallint              |           | not null | 0
 defense_fgblk         | smallint              |           | not null | 0
 defense_frec          | smallint              |           | not null | 0
 defense_frec_tds      | smallint              |           | not null | 0
 defense_frec_yds      | smallint              |           | not null | 0
 defense_int           | smallint              |           | not null | 0
 defense_int_tds       | smallint              |           | not null | 0
 defense_int_yds       | smallint              |           | not null | 0
 defense_misc_tds      | smallint              |           | not null | 0
 defense_misc_yds      | smallint              |           | not null | 0
 defense_pass_def      | smallint              |           | not null | 0
 defense_puntblk       | smallint              |           | not null | 0
 defense_qbhit         | smallint              |           | not null | 0
 defense_safe          | smallint              |           | not null | 0
 defense_sk            | real                  |           | not null | 0.0
 defense_sk_yds        | smallint              |           | not null | 0
 defense_tkl           | smallint              |           | not null | 0
 defense_tkl_loss      | smallint              |           | not null | 0
 defense_tkl_loss_yds  | smallint              |           | not null | 0
 defense_tkl_primary   | smallint              |           | not null | 0
 defense_xpblk         | smallint              |           | not null | 0
 fumbles_forced        | smallint              |           | not null | 0
 fumbles_lost          | smallint              |           | not null | 0
 fumbles_notforced     | smallint              |           | not null | 0
 fumbles_oob           | smallint              |           | not null | 0
 fumbles_rec           | smallint              |           | not null | 0
 fumbles_rec_tds       | smallint              |           | not null | 0
 fumbles_rec_yds       | smallint              |           | not null | 0
 fumbles_tot           | smallint              |           | not null | 0
 kicking_all_yds       | smallint              |           | not null | 0
 kicking_downed        | smallint              |           | not null | 0
 kicking_fga           | smallint              |           | not null | 0
 kicking_fgb           | smallint              |           | not null | 0
 kicking_fgm           | smallint              |           | not null | 0
 kicking_fgm_yds       | smallint              |           | not null | 0
 kicking_fgmissed      | smallint              |           | not null | 0
 kicking_fgmissed_yds  | smallint              |           | not null | 0
 kicking_i20           | smallint              |           | not null | 0
 kicking_rec           | smallint              |           | not null | 0
 kicking_rec_tds       | smallint              |           | not null | 0
 kicking_tot           | smallint              |           | not null | 0
 kicking_touchback     | smallint              |           | not null | 0
 kicking_xpa           | smallint              |           | not null | 0
 kicking_xpb           | smallint              |           | not null | 0
 kicking_xpmade        | smallint              |           | not null | 0
 kicking_xpmissed      | smallint              |           | not null | 0
 kicking_yds           | smallint              |           | not null | 0
 kickret_fair          | smallint              |           | not null | 0
 kickret_oob           | smallint              |           | not null | 0
 kickret_ret           | smallint              |           | not null | 0
 kickret_tds           | smallint              |           | not null | 0
 kickret_touchback     | smallint              |           | not null | 0
 kickret_yds           | smallint              |           | not null | 0
 passing_att           | smallint              |           | not null | 0
 passing_cmp           | smallint              |           | not null | 0
 passing_cmp_air_yds   | smallint              |           | not null | 0
 passing_incmp         | smallint              |           | not null | 0
 passing_incmp_air_yds | smallint              |           | not null | 0
 passing_int           | smallint              |           | not null | 0
 passing_sk            | smallint              |           | not null | 0
 passing_sk_yds        | smallint              |           | not null | 0
 passing_tds           | smallint              |           | not null | 0
 passing_twopta        | smallint              |           | not null | 0
 passing_twoptm        | smallint              |           | not null | 0
 passing_twoptmissed   | smallint              |           | not null | 0
 passing_yds           | smallint              |           | not null | 0
 punting_blk           | smallint              |           | not null | 0
 punting_i20           | smallint              |           | not null | 0
 punting_tot           | smallint              |           | not null | 0
 punting_touchback     | smallint              |           | not null | 0
 punting_yds           | smallint              |           | not null | 0
 puntret_downed        | smallint              |           | not null | 0
 puntret_fair          | smallint              |           | not null | 0
 puntret_oob           | smallint              |           | not null | 0
 puntret_tds           | smallint              |           | not null | 0
 puntret_tot           | smallint              |           | not null | 0
 puntret_touchback     | smallint              |           | not null | 0
 puntret_yds           | smallint              |           | not null | 0
 receiving_rec         | smallint              |           | not null | 0
 receiving_tar         | smallint              |           | not null | 0
 receiving_tds         | smallint              |           | not null | 0
 receiving_twopta      | smallint              |           | not null | 0
 receiving_twoptm      | smallint              |           | not null | 0
 receiving_twoptmissed | smallint              |           | not null | 0
 receiving_yac_yds     | smallint              |           | not null | 0
 receiving_yds         | smallint              |           | not null | 0
 rushing_att           | smallint              |           | not null | 0
 rushing_loss          | smallint              |           | not null | 0
 rushing_loss_yds      | smallint              |           | not null | 0
 rushing_tds           | smallint              |           | not null | 0
 rushing_twopta        | smallint              |           | not null | 0
 rushing_twoptm        | smallint              |           | not null | 0
 rushing_twoptmissed   | smallint              |           | not null | 0
 rushing_yds           | smallint              |           | not null | 0
Indexes:
    "play_player_pkey" PRIMARY KEY, btree (gsis_id, drive_id, play_id, player_id)
    "play_player_in_defense_ast" btree (defense_ast)
    "play_player_in_defense_ffum" btree (defense_ffum)
    "play_player_in_defense_fgblk" btree (defense_fgblk)
    "play_player_in_defense_frec" btree (defense_frec)
    "play_player_in_defense_frec_tds" btree (defense_frec_tds)
    "play_player_in_defense_frec_yds" btree (defense_frec_yds)
    "play_player_in_defense_int" btree (defense_int)
    "play_player_in_defense_int_tds" btree (defense_int_tds)
    "play_player_in_defense_int_yds" btree (defense_int_yds)
    "play_player_in_defense_misc_tds" btree (defense_misc_tds)
    "play_player_in_defense_misc_yds" btree (defense_misc_yds)
    "play_player_in_defense_pass_def" btree (defense_pass_def)
    "play_player_in_defense_puntblk" btree (defense_puntblk)
    "play_player_in_defense_qbhit" btree (defense_qbhit)
    "play_player_in_defense_safe" btree (defense_safe)
    "play_player_in_defense_sk" btree (defense_sk)
    "play_player_in_defense_sk_yds" btree (defense_sk_yds)
    "play_player_in_defense_tkl" btree (defense_tkl)
    "play_player_in_defense_tkl_loss" btree (defense_tkl_loss)
    "play_player_in_defense_tkl_loss_yds" btree (defense_tkl_loss_yds)
    "play_player_in_defense_tkl_primary" btree (defense_tkl_primary)
    "play_player_in_defense_xpblk" btree (defense_xpblk)
    "play_player_in_fumbles_forced" btree (fumbles_forced)
    "play_player_in_fumbles_lost" btree (fumbles_lost)
    "play_player_in_fumbles_notforced" btree (fumbles_notforced)
    "play_player_in_fumbles_oob" btree (fumbles_oob)
    "play_player_in_fumbles_rec" btree (fumbles_rec)
    "play_player_in_fumbles_rec_tds" btree (fumbles_rec_tds)
    "play_player_in_fumbles_rec_yds" btree (fumbles_rec_yds)
    "play_player_in_fumbles_tot" btree (fumbles_tot)
    "play_player_in_kicking_all_yds" btree (kicking_all_yds)
    "play_player_in_kicking_downed" btree (kicking_downed)
    "play_player_in_kicking_fga" btree (kicking_fga)
    "play_player_in_kicking_fgb" btree (kicking_fgb)
    "play_player_in_kicking_fgm" btree (kicking_fgm)
    "play_player_in_kicking_fgm_yds" btree (kicking_fgm_yds)
    "play_player_in_kicking_fgmissed" btree (kicking_fgmissed)
    "play_player_in_kicking_fgmissed_yds" btree (kicking_fgmissed_yds)
    "play_player_in_kicking_i20" btree (kicking_i20)
    "play_player_in_kicking_rec" btree (kicking_rec)
    "play_player_in_kicking_rec_tds" btree (kicking_rec_tds)
    "play_player_in_kicking_tot" btree (kicking_tot)
    "play_player_in_kicking_touchback" btree (kicking_touchback)
    "play_player_in_kicking_xpa" btree (kicking_xpa)
    "play_player_in_kicking_xpb" btree (kicking_xpb)
    "play_player_in_kicking_xpmade" btree (kicking_xpmade)
    "play_player_in_kicking_xpmissed" btree (kicking_xpmissed)
    "play_player_in_kicking_yds" btree (kicking_yds)
    "play_player_in_kickret_fair" btree (kickret_fair)
    "play_player_in_kickret_oob" btree (kickret_oob)
    "play_player_in_kickret_ret" btree (kickret_ret)
    "play_player_in_kickret_tds" btree (kickret_tds)
    "play_player_in_kickret_touchback" btree (kickret_touchback)
    "play_player_in_kickret_yds" btree (kickret_yds)
    "play_player_in_passing_att" btree (passing_att)
    "play_player_in_passing_cmp" btree (passing_cmp)
    "play_player_in_passing_cmp_air_yds" btree (passing_cmp_air_yds)
    "play_player_in_passing_incmp" btree (passing_incmp)
    "play_player_in_passing_incmp_air_yds" btree (passing_incmp_air_yds)
    "play_player_in_passing_int" btree (passing_int)
    "play_player_in_passing_sk" btree (passing_sk)
    "play_player_in_passing_sk_yds" btree (passing_sk_yds)
    "play_player_in_passing_tds" btree (passing_tds)
    "play_player_in_passing_twopta" btree (passing_twopta)
    "play_player_in_passing_twoptm" btree (passing_twoptm)
    "play_player_in_passing_twoptmissed" btree (passing_twoptmissed)
    "play_player_in_passing_yds" btree (passing_yds)
    "play_player_in_punting_blk" btree (punting_blk)
    "play_player_in_punting_i20" btree (punting_i20)
    "play_player_in_punting_tot" btree (punting_tot)
    "play_player_in_punting_touchback" btree (punting_touchback)
    "play_player_in_punting_yds" btree (punting_yds)
    "play_player_in_puntret_downed" btree (puntret_downed)
    "play_player_in_puntret_fair" btree (puntret_fair)
    "play_player_in_puntret_oob" btree (puntret_oob)
    "play_player_in_puntret_tds" btree (puntret_tds)
    "play_player_in_puntret_tot" btree (puntret_tot)
    "play_player_in_puntret_touchback" btree (puntret_touchback)
    "play_player_in_puntret_yds" btree (puntret_yds)
    "play_player_in_receiving_rec" btree (receiving_rec)
    "play_player_in_receiving_tar" btree (receiving_tar)
    "play_player_in_receiving_tds" btree (receiving_tds)
    "play_player_in_receiving_twopta" btree (receiving_twopta)
    "play_player_in_receiving_twoptm" btree (receiving_twoptm)
    "play_player_in_receiving_twoptmissed" btree (receiving_twoptmissed)
    "play_player_in_receiving_yac_yds" btree (receiving_yac_yds)
    "play_player_in_receiving_yds" btree (receiving_yds)
    "play_player_in_rushing_att" btree (rushing_att)
    "play_player_in_rushing_loss" btree (rushing_loss)
    "play_player_in_rushing_loss_yds" btree (rushing_loss_yds)
    "play_player_in_rushing_tds" btree (rushing_tds)
    "play_player_in_rushing_twopta" btree (rushing_twopta)
    "play_player_in_rushing_twoptm" btree (rushing_twoptm)
    "play_player_in_rushing_twoptmissed" btree (rushing_twoptmissed)
    "play_player_in_rushing_yds" btree (rushing_yds)
    "pp_in_gsis_drive_id" btree (gsis_id, drive_id)
    "pp_in_gsis_drive_play_id" btree (gsis_id, drive_id, play_id)
    "pp_in_gsis_id" btree (gsis_id)
    "pp_in_gsis_player_id" btree (gsis_id, player_id)
    "pp_in_player_id" btree (player_id)
    "pp_in_team" btree (team)
Foreign-key constraints:
    "play_player_gsis_id_fkey" FOREIGN KEY (gsis_id, drive_id, play_id) REFERENCES play(gsis_id, drive_id, play_id) ON DELETE CASCADE
    "play_player_gsis_id_fkey1" FOREIGN KEY (gsis_id, drive_id) REFERENCES drive(gsis_id, drive_id) ON DELETE CASCADE
    "play_player_gsis_id_fkey2" FOREIGN KEY (gsis_id) REFERENCES game(gsis_id) ON DELETE CASCADE
    "play_player_player_id_fkey" FOREIGN KEY (player_id) REFERENCES player(player_id) ON DELETE RESTRICT
    "play_player_team_fkey" FOREIGN KEY (team) REFERENCES team(team_id) ON UPDATE CASCADE ON DELETE RESTRICT
Triggers:
    agg_play_sync_update AFTER INSERT OR UPDATE ON play_player FOR EACH ROW EXECUTE PROCEDURE agg_play_update()
```
