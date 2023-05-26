SELECT * 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
Order By 3,4

SELECT * 
FROM PortfolioProject.dbo.CovidVaccinations
WHERE continent IS NOT NULL
Order BY 3,4

--Select the data that we will be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--looking at Total Cases vs Total Deaths
ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths DECIMAL 

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases DECIMAL 
--Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases) * 100, 2) AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY 1,2

--Looking at Total cases vs Population 
-- Percentage of population that has gotten covid
SELECT location, date, population, total_cases, ROUND((total_cases/population) * 100, 2) AS TotalCasesPerPopulationPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Philippines' AND continent IS NOT NULL
ORDER BY 1,2

--Looking at Countries with Highest Infection rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, ROUND(MAX((total_cases/population)) * 100, 2) AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population 
ORDER BY 4 DESC

--Looking at Countries with highest Death Count Per Population
SELECT location, population, MAX(CAST(total_deaths AS INT)) AS HighesCovidDeathCount, ROUND(MAX((total_deaths/population)) * 100, 2) AS PercentPopulationDeath
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

--Looking at Continents with highest Death Count 
--Shows different values depending on what data column and approach is chosen
SELECT location, population, MAX(CAST(total_deaths AS INT)) AS HighestCovidDeathCount, ROUND(MAX((total_deaths/population)) * 100, 2) AS PercentPopulationDeath
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY location, population
ORDER BY 4 DESC

SELECT continent, MAX(population), MAX(CAST(total_deaths AS INT)) AS HighestCovidDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

SELECT MAX(population)
FROM CovidDeaths
WHERE continent = 'South America' AND continent IS NOT NULL

--Looking at the Global numbers
SELECT date, NewTotalCases, NewTotalDeaths, ROUND((NewTotalDeaths / NULLIF(NewTotalCases, 0)) * 100, 2) AS DeathPercentage
FROM (
    SELECT date, SUM(new_cases) AS NewTotalCases, SUM(new_deaths) AS NewTotalDeaths
    FROM PortfolioProject.dbo.CovidDeaths
    WHERE continent IS NOT NULL
    GROUP BY date
) AS subquery
ORDER BY date, NewTotalCases;

SELECT NewTotalCases, NewTotalDeaths, ROUND((NewTotalDeaths / NewTotalCases) * 100, 2) AS DeathPercentage
FROM (
    SELECT SUM(new_cases) AS NewTotalCases, SUM(new_deaths) AS NewTotalDeaths
    FROM PortfolioProject.dbo.CovidDeaths
    WHERE continent IS NOT NULL
) AS subquery

--Looking at Total Population vs Vaccinations
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(CONVERT(float, vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths death
JOIN PortfolioProject.dbo.CovidVaccinations vaccine
ON death.location = vaccine.location AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3

--Making use of CTE in order to use one of tables created above
WITH PopulationVSVaccination (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
( 
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(CONVERT(float, vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths death
JOIN PortfolioProject.dbo.CovidVaccinations vaccine
ON death.location = vaccine.location AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated / population) * 100
FROM PopulationVSVaccination

--Through Temp table
--DROP TABLE IF EXISTS #PERCENTPOPULATIONVACCINATED; --incase the temp table needs update or revisions
CREATE TABLE #PERCENTPOPULATIONVACCINATED
(
continent NVARCHAR (255),
location NVARCHAR (255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)
INSERT INTO #PERCENTPOPULATIONVACCINATED
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(CONVERT(float, vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths death
JOIN PortfolioProject.dbo.CovidVaccinations vaccine
ON death.location = vaccine.location AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
SELECT *, (RollingPeopleVaccinated / population) * 100 
FROM #PERCENTPOPULATIONVACCINATED 

--Create view to store data for later visualizations
CREATE VIEW PERCENTPOPULATIONVACCINATED AS
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(CONVERT(float, vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths death
JOIN PortfolioProject.dbo.CovidVaccinations vaccine
ON death.location = vaccine.location AND death.date = vaccine.date
WHERE death.continent IS NOT NULL

--Looking at the View table created for further analysis
SELECT * 
FROM PERCENTPOPULATIONVACCINATED