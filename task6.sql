CREATE PROCEDURE FindWinnersByCompetitionOrYear
    @CompetitionName NVARCHAR(100) = NULL,
    @YearComp INT = NULL
AS
BEGIN
    SELECT FullName, LastName, CompetitionName, YearComp, PlaceComp 
    FROM SwimCompetitions2021 
    WHERE (CompetitionName = @CompetitionName OR @CompetitionName IS NULL)
      AND (YearComp = @YearComp OR @YearComp IS NULL)
      AND PlaceComp IN (1, 2, 3)
END;
