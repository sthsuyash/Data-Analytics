-- For tableau

-- 1. Get the total cases, deaths and the death percentage
-- CTE
WITH CaseDeaths(TotalCases, TotalDeaths)
AS(
	SELECT
		SUM(new_cases) AS TotalCases,
		SUM(CAST(new_deaths AS decimal)) AS TotalDeaths
	FROM CovidDataExploration..CovidDeaths
	WHERE continent IS NOT NULL
)

SELECT *,
	(TotalDeaths / TotalCases) * 100 AS DeathPercentage
FROM CaseDeaths
ORDER BY 1, 2;

-- Checking the data query is right or NOT
--SELECT 
--	SUM(new_cases) AS total_cases, 
--	SUM(CAST(new_deaths AS decimal)) AS total_deaths, 
--	SUM(CAST(new_deaths AS decimal)) / SUM(New_cases) * 100 AS DeathPercentage
--FROM CovidDataExploration..CovidDeaths
--WHERE location = 'World'
--ORDER BY 1, 2;

-- 2.
-- We take these out as they are not inluded in the above queries and want to stay consistent
SELECT 
	location, 
	SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM CovidDataExploration..CovidDeaths
WHERE continent IS NULL
	AND location NOT IN ('World', 'European Union')
	AND location NOT LIKE '%income'
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- 3. We get the Percentage of Population Infected with the count of Highest Infection
SELECT 
	Location, 
	Population, 
	MAX(total_cases) AS HighestInfectionCount,  
	MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM CovidDataExploration..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;


-- 4. similar to above with date
SELECT 
	location, 
	Population,
	CAST(date AS date) as Date,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/Population)) * 100 AS PercentPopulationInfected
FROM CovidDataExploration..CovidDeaths
GROUP BY location, Population, Date
ORDER BY PercentPopulationInfected DESC;
