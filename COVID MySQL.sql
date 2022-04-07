SELECT *
FROM portfolioproject.deaths
WHERE continent IS NOT NULL 
ORDER BY location, date;

-- Total Cases vs. Total Deaths
SELECT date, location, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRatePercent
FROM portfolioproject.deaths
WHERE location like 'canada' AND
	continent IS NOT NULL
ORDER BY location, date;

-- Total Cases vs. Population
-- % population infected
SELECT date, location, total_cases, population, (total_cases/population)*100 AS InfectionRatePercent
FROM portfolioproject.deaths
-- WHERE location like 'canada' AND
	-- continent IS NOT NULL
ORDER BY location, date;

-- Countries with Highest Infection Rate vs. Population
SELECT location, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS InfectionRatePerPop
FROM portfolioproject.deaths
WHERE continent IS NOT NULL
GROUP BY continent, population
ORDER BY InfectionRatePerPop DESC;

-- Showing Countries w/ Highest Death Count Per Pop
SELECT 
	location,
    MAX(cast(total_deaths as UNSIGNED)) AS TotalDeathCount
FROM portfolioproject.deaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount desc;

-- Breakdown by Continent
SELECT 
	continent,
    MAX(cast(total_deaths as UNSIGNED)) AS TotalDeathCount
FROM portfolioproject.deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- Global Total Numbers
SELECT 
	date, 
    SUM(new_cases) AS TotalCases,
    SUM(cast(new_deaths as UNSIGNED)) AS TotalDeaths,
    SUM(cast(new_deaths as UNSIGNED))/SUM(new_cases)*100 AS DeathPercentage
FROM portfolioproject.deaths
-- WHERE location like 'canada' AND
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, TotalCases;

-- Global Cases Cumulative
SELECT 
	date, 
    SUM(new_cases) AS TotalCases,
    SUM(cast(new_deaths as UNSIGNED)) AS TotalDeaths,
    SUM(cast(new_deaths as UNSIGNED))/SUM(new_cases)*100 AS DeathPercentage
FROM portfolioproject.deaths
-- WHERE location like 'canada' AND
WHERE continent IS NOT NULL
ORDER BY date, TotalCases;


-- Total Population vs. Vaccinations


-- Joining Tables
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, SUM(cast(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS RollingTotalVaccinations
    -- (RollingTotalVaccinations/population)*100
FROM portfolioproject.deaths dea
JOIN portfolioproject.vaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
	AND dea.location NOT LIKE '%income%'
	-- AND dea.location LIKE 'canada'
ORDER BY 2,3;


-- Use CTE to execute (RollingTotalVaccinations/population)*100, a column we just created

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingTotalVaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, SUM(cast(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS RollingTotalVaccinations
    -- (RollingTotalVaccinations/population)*100
FROM portfolioproject.deaths dea
JOIN portfolioproject.vaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
	AND dea.location NOT LIKE '%income%'
	-- AND dea.location LIKE 'canada'
-- ORDER BY 2,3
)

SELECT *, (RollingTotalVaccinations/Population)*100 AS PercentRollingTotal
FROM PopvsVac;

-- Temp Table
-- DROP TABLE IF EXISTS PercentPopulationVaccinated
REPAIR TABLE PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated (
	Continent character varying(255),
	Location character varying(255),
	Date datetime,
	Population numeric,
	new_vaccinations numeric,
	RollingTotalVaccinations numeric
);
INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, SUM(cast(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS RollingTotalVaccinations
    -- (RollingTotalVaccinations/population)*100
FROM portfolioproject.deaths dea
JOIN portfolioproject.vaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
	-- AND dea.location NOT LIKE '%income%'
	-- AND dea.location LIKE 'canada'
	ORDER BY 2,3
    
SELECT * (RollingTotalVaccinations/Population)*100 
FROM PercentPopulationVaccinated;

-- Creating View to Store Data for Late

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, SUM(cast(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS RollingTotalVaccinations
    -- (RollingTotalVaccinations/population)*100
FROM portfolioproject.deaths dea
JOIN portfolioproject.vaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
	-- AND dea.location NOT LIKE '%income%'
	-- AND dea.location LIKE 'canada'
-- ORDER BY 2,3