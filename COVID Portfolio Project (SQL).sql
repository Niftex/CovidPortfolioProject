
SELECT *
FROM covid_project.dbo.CovidDeaths$
Order by 3,4

SELECT *
FROM covid_project.dbo.CovidVaccinations$
Order BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM covid_project.dbo.CovidDeaths$ 
ORDER BY 1, 2;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM covid_project.dbo.CovidDeaths$ 
WHERE location like '%states%'
ORDER BY 1, 2;


-- Looking at Total Cases vs Population
-- Show what percentage of population go Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS Percent_Population_Infected
FROM covid_project.dbo.CovidDeaths$ 
--WHERE location like '%states%'
ORDER BY 1, 2;


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS Highest_Infection_Count, Max((total_cases/population))*100 AS Percent_Population_Infected
FROM covid_project.dbo.CovidDeaths$ 
--WHERE location like '%states%'
GROUP BY Location, population
ORDER BY Percent_Population_Infected;


-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths AS int)) AS Total_Death_Count
FROM covid_project.dbo.CovidDeaths$ 
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY Total_Death_Count desc;


-- Breaking things down by Continent
SELECT location, MAX(cast(total_deaths AS int)) AS Total_Death_Count
FROM covid_project.dbo.CovidDeaths$ 
--WHERE location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY Total_Death_Count desc;


-- Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths AS int)) AS Total_Death_Count
FROM covid_project.dbo.CovidDeaths$ 
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count desc;


-- Global Numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_cases)*100 AS Death_Percentage
FROM covid_project.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_cases)*100 AS Death_Percentage
FROM covid_project.dbo.CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;



-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM covid_project.dbo.CovidDeaths$ dea
JOIN covid_project.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;


--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM covid_project.dbo.CovidDeaths$ dea
JOIN covid_project.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (Rolling_People_Vaccinated/population)*100
FROM PopvsVac



-- Temp Table
DROP TABLE if exists #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM covid_project.dbo.CovidDeaths$ dea
JOIN covid_project.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (Rolling_People_Vaccinated/population)*100
FROM #Percent_Population_Vaccinated



-- Creating View to store data for later visualizations
CREATE VIEW Percent_Population_Vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM covid_project.dbo.CovidDeaths$ dea
JOIN covid_project.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM Percent_Population_Vaccinated
