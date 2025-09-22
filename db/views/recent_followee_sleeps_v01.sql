SELECT
    (md5(CONCAT(f.follower_id::text, '-', us.id::text))::uuid) AS id,
    f.follower_id,
    us.id AS sleep_id,
    us.user_id,
    us.duration
FROM
    follows f
    JOIN users u ON f.followed_id = u.id
    JOIN user_sleeps us ON us.user_id = u.id
WHERE
    us.end_time IS NOT NULL
    AND us.start_time >= NOW() - interval '14 days'
ORDER BY
    us.duration DESC;
