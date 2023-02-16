SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Looking at total deaths vs total cases

SELECT location,date,total_cases,total_deaths,ROUND((total_deaths/total_cases)*100,2)'deathpercentageofcases'
FROM CovidDeaths
WHERE location ='India' AND continent IS NOT NULL
ORDER BY 1,2;


--Looking at total Cases vs Population

SELECT location,date,population,total_cases,(total_cases/population)*100 'percentageOfPopulationinfection'
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Looking for countries with highest percentage of infection rate compared to population

SELECT location,population,MAX(total_cases)'highestcases',ROUND(MAX((total_cases/population)*100),2) 'percentageOfPopulationinfection'
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY percentageOfPopulationinfection DESC;

--Showing countries with highest death percentage
SELECT date,MAX(CAST(total_deaths AS INT))'HighestDeath' FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY HighestDeath DESC;


SELECT SUM(new_cases)'highest_new_cases',SUM(CAST(new_deaths AS INT))'totalDeaths',
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100'TotalDeathpercentage'
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Looking at total population vs vaccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) 'rollingtotal_vac'
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--USE CTE
WITH PopVsVac (continent,location,date,population,new_vaccinations,rollingtotal_vac)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) 'rollingtotal_vac'
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;
)
SELECT *,(rollingtotal_vac/population)*100 AS 'max_percent' FROM PopVsVac;


--Temp table
DROP TABLE if exists #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccination numeric,
rollingtotal_vac numeric
)
INSERT INTO #percentpopulationvaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) 'rollingtotal_vac'
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;
SELECT *,(rollingtotal_vac/population)*100 AS 'max_percent' FROM #percentpopulationvaccinated

--CREATING View for later visualization

CREATE VIEW percentpopulationvaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) 'rollingtotal_vac'
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL

