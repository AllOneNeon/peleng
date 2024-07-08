SELECT
    c.Coach AS Coach,
    SUM(CASE WHEN p.Place = 1 THEN 3
             WHEN p.Place = 2 THEN 2
             WHEN p.Place = 3 THEN 1
        ELSE 0 END) AS RatingSum
FROM SwimCompetitions2021 AS c
JOIN SwimResults AS p ON c.CompetitionID = p.CompetitionID
GROUP BY c.Coach
ORDER BY RatingSum DESC
LIMIT 10;
