-- COVID-19 Data Exploration Project

-- 1. View full data (Deaths & Vaccinations)
SELECT * FROM [Portfolio project]..CovidDeaths$ ORDER BY 3, 4;
--SELECT * FROM [Portfolio project]..CovidVaccination$ ORDER BY 3, 4;

-- 2. Select data to explore
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM [Portfolio project]..CovidDeaths$ 
ORDER BY location, date;

-- 3. Total Cases vs Total Deaths (% death rate)
SELECT location, date, total_cases, total_deaths,
  CASE WHEN total_cases > 0 THEN (total_deaths/total_cases)*100 ELSE NULL END AS Death_percentage
FROM [Portfolio project]..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY location, date;

-- 4. Death % in the India
SELECT location, date, total_cases, total_deaths,
  CASE WHEN total_cases > 0 THEN (total_deaths/total_cases)*100 ELSE NULL END AS Death_percentage
FROM [Portfolio project]..CovidDeaths$
WHERE location = 'India'
ORDER BY location, date;

-- 5. Total Cases vs Population (% infected)
SELECT location, date, total_cases, population,
  CASE WHEN population > 0 THEN (total_cases/population)*100 ELSE NULL END AS Cases_percentage
FROM [Portfolio project]..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY location, date;

-- 6. Total Deaths by Region (excluding continents)
SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio project]..CovidDeaths$
WHERE continent IS NULL
  AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- 7. Countries with highest infection %
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,
  MAX(total_cases/population)*100 AS PercentageOfPopulationInfected
FROM [Portfolio project]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentageOfPopulationInfected DESC;

-- 8. Peak infection date per country
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount,
  MAX(total_cases/population)*100 AS PercentageOfPopulationInfected
FROM [Portfolio project]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY PercentageOfPopulationInfected DESC;

-- 9. Countries with highest death count vs population
SELECT location, population, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount,
  MAX(total_deaths/population)*100 AS PercentageOfPopulationDead
FROM [Portfolio project]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentageOfPopulationDead DESC;

-- 10. Countries with highest total death count
SELECT location, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM [Portfolio project]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC;

-- 11. Continents with highest death count
SELECT continent, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM [Portfolio project]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

-- 12. Global aggregates
SELECT SUM(new_cases) AS total_cases, 
       SUM(CAST(new_deaths AS INT)) AS total_deaths,
       CASE WHEN SUM(new_cases) > 0 THEN SUM(CAST(new_deaths AS INT))*100.0/SUM(new_cases) ELSE NULL END AS Death_percentage
FROM [Portfolio project]..CovidDeaths$
WHERE continent IS NOT NULL;

-- 13. Join Deaths and Vaccination datasets
-- Step 1: Switch to the correct database
USE [Portfolio project];
GO

-- Step 2: Query using fully qualified names with proper brackets
SELECT * 
FROM [Portfolio project].[dbo].[CovidDeaths$] AS dea
JOIN [Portfolio project].[dbo].[CovidVaccinations$] AS vac
  ON dea.location = vac.location 
  AND dea.date = vac.date;
-- 14. Total vaccinations by location
-- Total vaccinations by location using window function
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(TRY_CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS Total_Vaccinations
FROM [Portfolio project].[dbo].[CovidDeaths$] AS dea
JOIN [Portfolio project].[dbo].[CovidVaccinations$] AS vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

-- 15. Rolling people vaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(TRY_CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM [Portfolio project].[dbo].[CovidDeaths$] dea
JOIN [Portfolio project].[dbo].[CovidVaccinations$] vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

-- 16. CTE for rolling vaccination %
 WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
  SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(TRY_CAST(vac.new_vaccinations AS INT)) OVER (
      PARTITION BY dea.location 
      ORDER BY dea.date
    ) AS RollingPeopleVaccinated
  FROM [Portfolio project].[dbo].[CovidDeaths$] AS dea
  JOIN [Portfolio project].[dbo].[CovidVaccinations$] AS vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
)

SELECT 
  Continent, 
  Location, 
  Date, 
  Population, 
  New_Vaccinations, 
  RollingPeopleVaccinated,
  (CAST(RollingPeopleVaccinated AS FLOAT) / NULLIF(Population, 0)) * 100 AS RollingVaccinatedPercentage
FROM PopVsVac;

-- 17. Temp table for vaccination %
-- Drop the table if it exists
DROP TABLE IF EXISTS #PercentagePopulationVaccinated;

-- Create the table to store data
CREATE TABLE #PercentagePopulationVaccinated (
  Continent NVARCHAR(255),
  Location NVARCHAR(255),
  Date DATETIME,
  Population NUMERIC,
  New_Vaccinations NUMERIC,
  RollingPeopleVaccinated NUMERIC
);

-- Insert data into the table
INSERT INTO #PercentagePopulationVaccinated
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations,
  SUM(TRY_CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM [Portfolio project].[dbo].[CovidDeaths$] dea
JOIN [Portfolio project].[dbo].[CovidVaccinations$] vac
  ON dea.location = vac.location 
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Select from the temporary table with Rolling Vaccinated Percentage calculation
SELECT 
  Continent, 
  Location, 
  Date, 
  Population, 
  New_Vaccinations, 
  RollingPeopleVaccinated,
  (CAST(RollingPeopleVaccinated AS FLOAT) / NULLIF(Population, 0)) * 100 AS RollingVaccinatedPercentage
FROM #PercentagePopulationVaccinated;

-- 18. Create a view for visualization
-- Creating a view to calculate Rolling People Vaccinated
-- Creating the view with proper table name referencing

CREATE VIEW PercentagePopulationVaccinated AS
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations,
  SUM(TRY_CAST(vac.new_vaccinations AS INT)) OVER (
    PARTITION BY dea.location 
    ORDER BY dea.date
  ) AS RollingPeopleVaccinated
FROM [dbo].[CovidDeaths$] dea
JOIN [dbo].[CovidVaccinations$] vac
  ON dea.location = vac.location 
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


-- Query the created view
SELECT * FROM PercentagePopulationVaccinated;
