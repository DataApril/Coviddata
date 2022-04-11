SELECT *
FROM CovidDeath
ORDER BY 3,4


--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

--SELECT Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeath
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeath
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
FROM CovidDeath
--WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection RAte compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidPercentage
FROM CovidDeath
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY CovidPercentage Desc

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeath
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount Desc

-- Let's break things down by continent 



-- Showing continents with the highest death count population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeath
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount Desc


-- Global Numbers

SELECT SUM(New_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/
SUM(New_cases)*100 as DeathPercentage
FROM CovidDeath
--WHERE location like '%states%'
where continent is not null
--Group by date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated
FROM CovidDeath dea 
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
ORDER BY 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated
FROM CovidDeath dea 
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--Order by 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 




SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated
FROM CovidDeath dea 
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
--where dea.continent is not null
--Order by 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated 

-- Creatomg View to store data for later visualizations

Create View PercentPopulationVaccinated  as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated
FROM CovidDeath dea 
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--Order by 2,3


SELECT *
FROM PercentPopulationVaccinated