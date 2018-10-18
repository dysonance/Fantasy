drop materialized view if exists fantasy_points;
create materialized view fantasy_points as (
    with fantasy_scoring as (
        select
            pp.gsis_id,
            pp.player_id,
            (
                floor((sum(pp.passing_yds)::float / 25)::numeric) +
                sum(pp.passing_tds) * 4 +
                sum(pp.passing_int) * -2 +
                sum(pp.passing_twoptm) * 2 +
                floor((sum(pp.rushing_yds)::float / 10)::numeric) +
                sum(pp.rushing_tds) * 6 +
                sum(pp.rushing_twoptm) * 2 +
                floor((sum(pp.receiving_yds)::float / 10)::numeric) +
                sum(pp.receiving_tds) * 6 +
                sum(pp.receiving_twoptm) * 2 +
                sum(pp.puntret_tds) * 6 +
                sum(pp.kickret_tds) * 6 +
                sum(pp.fumbles_lost) * -2
            ) as points
        from
            play_player pp,
            player p
        where
            pp.player_id = p.player_id
            and is_offensive_position(p.position)
        group by
            pp.gsis_id,
            pp.player_id
    )
    select
        p.full_name,
        p.position,
        p.team,
        g.season_year,
        g.week,
        fs.gsis_id,
        fs.points
    from
        player p,
        fantasy_scoring fs,
        game g
    where
        p.player_id = fs.player_id
        and g.season_type = 'Regular'
        and g.gsis_id = fs.gsis_id
    order by
        points desc
);

drop materialized view if exists team_balance;
create materialized view team_balance as (
    with team_plays as (
        select
            g.gsis_id,
            ag.drive_id,
            ag.play_id,
            g.season_year as year,
            g.week,
            offense_team(ag.gsis_id, ag.drive_id) as offense,
            defense_team(ag.gsis_id, ag.drive_id) as defense,
            (ag.passing_att > 0 or ag.passing_sk_yds < 0)::integer as pass_play,
            (ag.rushing_att > 0)::integer as run_play
        from
            agg_play ag,
            game g
        where
            g.season_type = 'Regular'
            and ag.gsis_id = g.gsis_id
            and (ag.passing_att > 0 or ag.passing_sk_yds < 0 or ag.rushing_att > 0)
        order by
            g.season_year desc,
            g.week desc,
            offense,
            ag.drive_id,
            ag.play_id
    )
    select
        tp.year,
        tp.week,
        tp.offense,
        tp.defense,
        count(tp.play_id) as n_plays,
        sum(tp.pass_play) as n_pass,
        sum(tp.run_play) as n_run,
        sum(tp.pass_play)/count(tp.play_id)::float as pct_pass,
        sum(tp.run_play)/count(tp.play_id)::float as pct_run
    from
        team_plays tp
    group by
        tp.year,
        tp.week,
        tp.offense,
        tp.defense
    order by
        tp.year desc,
        tp.week desc,
        tp.offense
);

alter materialized view fantasy_points owner to nfldb;
alter materialized view team_balance owner to nfldb;
