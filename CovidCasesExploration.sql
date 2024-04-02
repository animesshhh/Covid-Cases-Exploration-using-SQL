--Selecting data that's going to be used

SELECT location, date, total_cases, new_cases, total_deaths, population_density
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2



--Total Cases vs Total Deaths
--Shows likelihood of dying if you get covid in India

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
WHERE location like 'India%'
ORDER BY 1, 2



--Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
WHERE location like 'India%'
ORDER BY 1, 2



--Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC



--Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC


--Highest Death Count by Continents

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC



--Showing continents with Highest Death Count per population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC



--Global Numbers(New Cases coming Everyday)

SELECT date, SUM(CAST(new_cases AS INT)) as TotalNewCases, SUM(CAST(new_deaths AS INT)) as TotalNewDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2 



--Exploring Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.Location ORDER BY dea.location,
dea.date) AS NewVaccinationsPerDay
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


--Using CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, NewVaccinationsPerDay)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.Location ORDER BY dea.location,
dea.date) AS NewVaccinationsPerDay
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (NewVaccinationsPerDay/Population)*100
FROM PopvsVac




--Using Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population float,
New_Vaccinations float,
NewVaccinationsPerDay float
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.Location ORDER BY dea.location,
dea.date) AS NewVaccinationsPerDay
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
ORDER BY 2, 3
SELECT *, (NewVaccinationsPerDay/Population)*100
FROM #PercentPopulationVaccinated



--Creating view for later data visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.Location ORDER BY dea.location,
dea.date) AS NewVaccinationsPerDay
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated