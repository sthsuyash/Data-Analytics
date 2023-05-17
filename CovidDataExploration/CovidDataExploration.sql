-- SELECT *
-- FROM CovidDataExploration..CovidDeaths
-- ORDER BY 3,4

-- SELECT *
-- FROM CovidDataExploration..CovidVaccinations
-- ORDER BY 3,4

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDataExploration..CovidDeaths
ORDER BY 1,2;