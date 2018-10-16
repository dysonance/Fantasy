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
