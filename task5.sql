SELECT
    c.coach_id,
    c.first_name,
    c.last_name,
    AVG(r.result_value) AS average_result,
    CASE
        WHEN AVG(r.result_value) >= 60 THEN 'High Rank'
        WHEN AVG(r.result_value) >= 40 THEN 'Medium Rank'
        ELSE 'Low Rank'
    END AS coach_rank
INTO CoachRanks
FROM Coaches c
JOIN Swimmers s ON c.coach_id = s.coach_id
JOIN Results r ON s.swimmer_id = r.swimmer_id
GROUP BY c.coach_id, c.first_name, c.last_name;



USE SwimCompetitions2021;

SELECT
    SwimmerID,
    Surname,
    Name,
    SwimmedCompetition,
    CoachID,
    CoachFullName,
    RANK() OVER (PARTITION BY CoachID ORDER BY SwimmedCompetition DESC) AS CoachRank
FROM YourSwimResultsTable;
