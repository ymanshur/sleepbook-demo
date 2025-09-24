SELECT
    (md5(CONCAT(f.follower_id::text, '-', us.id::text))::uuid) AS id,
    f.follower_id,
    us.id AS sleep_id,
    us.user_id,
    us.start_time,
    us.end_time,
    us.duration
FROM
    follows f
    JOIN user_sleeps us ON us.user_id = f.followed_id
WHERE
    us.end_time IS NOT NULL
    AND us.start_time >= DATE_TRUNC('week', NOW() - INTERVAL '1 week')
ORDER BY
    us.duration DESC;
