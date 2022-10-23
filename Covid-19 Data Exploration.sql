SELECT *
FROM Portfolio..CovidDeaths
WHERE continent is NOT NULL 
ORDER BY 3,4

----Selecting Data to be used 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio..CovidDeaths
WHERE continent is NOT NULL 
ORDER BY 1,2

--Total Cases vs Total Deaths 
--Shows likelihood of dying if contracted in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as PercentageDeath 
FROM Portfolio..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent is NOT NULL 
ORDER BY 1,2



---Total Cases Vs Population 
-- shows the percentage of population that contracted covid-19

SELECT location, date, population, total_cases, (total_cases/population) * 100 as PercentageInfectedPopulation 
FROM Portfolio..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent is NOT NULL 
ORDER BY 1,2


-- Countries with the Highest Infection Rate 

SELECT location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases/population)) * 100 as PercentageInfectedPopulation
FROM Portfolio..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent is NOT NULL 
GROUP BY location, population
ORDER BY PercentageInfectedPopulation DESC


-- Countries with the Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM Portfolio..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent is NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC


---CONTINENT

-- Continent with the Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM Portfolio..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent is NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(CAST(New_deaths as int)) as total_deaths, SUM(CAST(New_deaths as int))/SUM(new_cases) * 100 as PercentageDeath 
FROM Portfolio..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2




-- Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
, dea.Date) as RollingVaccinatedPopulation
--, (RollingVaccinatedPopulation/population) *100
FROM Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is NOT NULL
ORDER BY 2,3


--CTE

With PopvsVac (continent, location, date, population, new_vaccination, RollingVaccinatedPopulation)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
, dea.Date) as RollingVaccinatedPopulation
--, (RollingVaccinatedPopulation/population) *100
FROM Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingVaccinatedPopulation/population) *100 as  PercentageVaccinatedPopulation
FROM PopvsVac


---TEMP TABLE

DROP Table if  exists #PercentageVaccinatedPopulation
Create Table #PercentageVaccinatedPopulation
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccination numeric, 
RollingVaccinatedPopulation numeric
)

INSERT INTO #PercentageVaccinatedPopulation
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
, dea.Date) as RollingVaccinatedPopulation
--, (RollingVaccinatedPopulation/population) *100
FROM Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *, (RollingVaccinatedPopulation/population) *100 as  PercentageVaccinatedPopulation
FROM #PercentageVaccinatedPopulation




--Creating views for data visualization 

Create View PercentageVaccinatedPopulation as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
, dea.Date) as RollingVaccinatedPopulation
--, (RollingVaccinatedPopulation/population) *100
FROM Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

Select *
From PercentageVaccinatedPopulation



------------------------------------------------------------------------------------------------------------------------------------

-------------------Data For Visualization

--------1.

SELECT SUM(new_cases) as total_cases, SUM(CAST(New_deaths as int)) as total_deaths, SUM(CAST(New_deaths as int))/SUM(new_cases) * 100 as PercentageDeath 
FROM Portfolio..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2


--------2.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
--Where location = Nigeria'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income' )
Group by location
order by TotalDeathCount desc


-- 3.

SELECT location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases/population)) * 100 as PercentageInfectedPopulation
FROM Portfolio..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent is NOT NULL 
GROUP BY location, population
ORDER BY PercentageInfectedPopulation DESC


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentageInfectedPopulation
From Portfolio..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentageInfectedPopulation desc
vb 

