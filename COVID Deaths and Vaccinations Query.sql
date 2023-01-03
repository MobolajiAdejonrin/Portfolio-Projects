SELECT *
FROM [Project Portfolio]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM [Project Portfolio]..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Project Portfolio]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at Total cases vs Total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM [Project Portfolio]..CovidDeaths
WHERE location like '%nigeria%'
ORDER BY 1,2

--Total cases vs Population
--Showing percentage of population with COVID 
SELECT location, date, total_cases, population, (total_cases/population)*100 AS deathpercentage
FROM [Project Portfolio]..CovidDeaths
WHERE location like '%nigeria%'
AND continent is not null
ORDER BY 1,2

--Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS 
PerecntPopulationInfected
FROM [Project Portfolio]..CovidDeaths
GROUP BY location, population
ORDER BY PerecntPopulationInfected desc

--Countries with lowest infection rate
SELECT location, population, MIN(total_cases) AS LowestInfectionCount, MIN((total_cases/population))*100 AS 
PerecntPopulationInfected
FROM [Project Portfolio]..CovidDeaths
GROUP BY location, population
ORDER BY PerecntPopulationInfected

--Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Project Portfolio]..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Continent with Highest Death Count per Population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Project Portfolio]..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS NewCasesCount, SUM(cast(new_deaths as int)) AS NewDeathCount, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS
DeathPercentage
FROM [Project Portfolio]..CovidDeaths
--WHERE location like '%nigeria%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total Global Numbers of New Cases and New Deaths
SELECT SUM(new_cases) AS NewCasesCount, SUM(cast(new_deaths as int)) AS NewDeathCount, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS
DeathPercentage
FROM [Project Portfolio]..CovidDeaths
--WHERE location like '%nigeria%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--COVID VACCINATIONS
SELECT *
FROM [Project Portfolio]..CovidVaccinations
WHERE Continent is not null
ORDER BY 1,2

--Joining Covid Death and Covid Vaccinations table
SELECT *
FROM [Project Portfolio]..CovidDeaths dea
JOIN [Project Portfolio]..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

--Total Populations vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location) AS RollingPeopleVaccinated
FROM [Project Portfolio]..CovidDeaths dea
JOIN [Project Portfolio]..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE
With PopvsVac(Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location) AS RollingPeopleVaccinated
FROM [Project Portfolio]..CovidDeaths dea
JOIN [Project Portfolio]..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location) AS RollingPeopleVaccinated
FROM [Project Portfolio]..CovidDeaths dea
JOIN [Project Portfolio]..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated