-- Create the Database
CREATE DATABASE CovidDataExploration;

-- Then, data is imported from the excel file to the db to tables CovidDeaths and CovidVaccinations

USE CovidDataExploration;

-- Select all data for checking purpose
SELECT *
FROM CovidDataExploration..CovidDeaths
ORDER BY 3,4
---

SELECT *
FROM CovidDataExploration..CovidVaccinations
ORDER BY 3,4
---

-- Select data that is going to be used
SELECT 
    Location, 
    Date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    Population
FROM CovidDataExploration..CovidDeaths
ORDER BY 1,2;
---

-- Looking at Total Cases vs Total Deaths

-- 'CAST' type conversion is added to ensure that both total_deaths and total_cases are treated as decimal numbers before division operation 
-- as there may arise erros otherwise.

-- Shows how much likely you are to die if you get covid in your country
SELECT 
    Location, 
    Date, 
    total_cases, 
    total_deaths, 
    (CAST(total_deaths AS decimal) / CAST(total_cases AS decimal)) * 100 AS DeathPercentage
FROM CovidDataExploration..CovidDeaths
ORDER BY 1,2;

SELECT 
    Location, 
    Date, 
    total_cases, 
    total_deaths, 
    (CAST(total_deaths AS decimal) / CAST(total_cases AS decimal)) * 100 AS DeathPercentage
FROM CovidDataExploration..CovidDeaths
WHERE location = 'Nepal'
ORDER BY 1,2;
---

-- Looking at Total Cases vs Population

-- Shows the Covid affected population percentage 
SELECT 
    Location, 
    Date, 
    Population, 
    total_cases,
    (CAST(total_cases AS decimal) / CAST(population AS decimal)) * 100 as AffectedPercentage
FROM CovidDataExploration..CovidDeaths
WHERE location = 'Nepal'
ORDER BY 1,2;
---

-- Looking at countries with Highest Infection Rate compared to Population
SELECT 
    Location,
    Population, 
    MAX(CAST(total_cases AS decimal)) as HighestInfectionCount,
    MAX(CAST(total_cases AS decimal) / population) * 100 as AffectedPercentage
FROM CovidDataExploration..CovidDeaths
GROUP BY Location, Population
ORDER BY AffectedPercentage DESC;
---

-- Checking the data
SELECT * 
FROM CovidDataExploration..CovidDeaths 
WHERE iso_code='AFG' 
ORDER BY CAST(total_cases AS decimal) DESC;
---

-- Showing countries with Highest Death Count per population
SELECT 
    Location,
    MAX(CAST(total_deaths AS bigint)) AS TotalDeaths
FROM CovidDataExploration..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeaths DESC;
---

-- Showing continents with highest death count per population
SELECT 
    Location, 
    MAX(CAST(total_deaths AS decimal)) AS TotalDeaths
FROM CovidDataExploration..CovidDeaths
WHERE continent IS NULL
AND Location NOT IN (
	SELECT Location
	FROM CovidDataExploration..CovidDeaths 
	WHERE 
        Location = 'World' 
	    OR Location Like '%income'
	    OR Location Like '%Union'
)
GROUP BY Location
ORDER BY TotalDeaths DESC;
---

-- Showing countries in specific continent with Highest Death Count per population
SELECT 
    Location,
    MAX(CAST(total_deaths AS bigint)) AS TotalDeaths
FROM CovidDataExploration..CovidDeaths
WHERE continent = 'Asia'
GROUP BY location
ORDER BY TotalDeaths DESC;
---

-- Global Numbers
SELECT
    CAST(date as Date) AS Date, -- Cast date to only display date and not times
	SUM(new_cases) AS DailyNewCases,
	SUM(CAST(new_deaths AS decimal)) AS DailyNewDeaths,
    CASE WHEN SUM(new_cases) <> 0
		THEN SUM(CAST(new_deaths AS decimal)) / SUM(new_cases) * 100
		ELSE 0
	END AS DeathPercentage
FROM CovidDataExploration..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;
---

-- Total cases, deaths and death percentage
SELECT 
    SUM(new_cases) AS TotalCases,
	SUM(CAST(new_deaths AS decimal)) AS TotalDeaths,
    SUM(CAST(new_deaths AS decimal)) / SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDataExploration..CovidDeaths
WHERE continent IS NOT NULL;
---

-- What is the total population of the world and the vaccinated population?

-- Join the tables
----SELECT
----	death.continent AS Continent,
----	death.location AS Country,
----	CAST(death.date AS date) AS Date,
----	death.population AS TotalPopulation,
----	vac.new_vaccinations AS NewVaccinationsPerDay,
----	SUM(CAST(vac.new_vaccinations AS decimal)) 
----		OVER (PARTITION BY death.location 
----			ORDER BY death.location, death.date) 
----		AS TotalVaccinatedPerCountry
----FROM CovidDataExploration..CovidDeaths death
----JOIN CovidDataExploration..CovidVaccinations vac
----	ON death.location = vac.location
----	AND death.date = vac.date
----WHERE death.continent IS NOT NULL
----ORDER BY 2, 3;
---

-- Use CTE
WITH PopVSVac (Continent, Country, Date, TotalPopulation, NewVaccinationsPerDay, TotalVaccinatedPerCountry)
AS
(
	SELECT
	death.continent AS Continent,
	death.location AS Country,
	CAST(death.date AS date) AS Date,
	death.population AS TotalPopulation,
	vac.new_vaccinations AS NewVaccinationsPerDay,
	SUM(CAST(vac.new_vaccinations AS decimal)) 
		OVER (PARTITION BY death.location 
			ORDER BY death.location, death.date) 
		AS TotalVaccinatedPerCountry
	FROM CovidDataExploration..CovidDeaths death
	JOIN CovidDataExploration..CovidVaccinations vac
		ON death.location = vac.location
		AND death.date = vac.date
	WHERE death.continent IS NOT NULL
)
SELECT * ,
	(TotalVaccinatedPerCountry / TotalPopulation) * 100 AS VaccinatedPercentage
FROM PopVSVac
ORDER BY 2,3;
---

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date date,
	TotalPopulation decimal,
	NewVaccinationsPerDay decimal,
	TotalVaccinatedPerCountry decimal
);

INSERT INTO #PercentPopulationVaccinated
SELECT
	death.continent AS Continent,
	death.location AS Country,
	CAST(death.date AS date) AS Date,
	death.population AS TotalPopulation,
	vac.new_vaccinations AS NewVaccinationsPerDay,
	SUM(CAST(vac.new_vaccinations AS decimal)) 
		OVER (PARTITION BY death.location 
			ORDER BY death.location, death.date) 
		AS TotalVaccinatedPerCountry
FROM CovidDataExploration..CovidDeaths death
JOIN CovidDataExploration..CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
--WHERE death.continent IS NOT NULL

SELECT * ,
	(TotalVaccinatedPerCountry / TotalPopulation) * 100 AS VaccinatedPercentage
FROM #PercentPopulationVaccinated
ORDER BY 2,3;
---

-- Creating Views to store data for later visualization

-- Drop the view if it already exists
IF OBJECT_ID('VaccinatedPopPercent', 'V') IS NOT NULL
    DROP VIEW VaccinatedPopPercent;
---

-- Creating the view
CREATE VIEW VaccinatedPopPercent AS
SELECT
    death.continent AS Continent,
    death.location AS Country,
    CAST(death.date AS date) AS Date,
    death.population AS TotalPopulation,
    vac.new_vaccinations AS NewVaccinationsPerDay,
    SUM(CAST(vac.new_vaccinations AS decimal)) 
        OVER (PARTITION BY death.location 
            ORDER BY death.location, death.date) 
        AS TotalVaccinatedPerCountry
FROM CovidDataExploration..CovidDeaths death
JOIN CovidDataExploration..CovidVaccinations vac
    ON death.location = vac.location
    AND death.date = vac.date
WHERE death.continent IS NOT NULL;
---
