
Select *
From PortfolioProject..CovidDeaths
Order by 3,4

-- check  table where continent is not NULL
Select *
From PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
Order by 3,4

Select *
From PortfolioProject..CovidVaccinations
Order by 3,4

--Data to work with
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths

--Compare Total_Cases with Total_Deaths
SELECT location, date, population, total_cases, total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL

--TABLEAU TABLE 4 #4 IN ALEX SAMPLE
--Compare percentage of total_cases with population
SELECT location, population, date , MAX(total_cases) AS Highest_total_cases_Ct, MAX((total_cases/population))*100 AS Percentage_Population_Infected
FROM PortfolioProject..CovidDeaths
--WHERE continent is NOT NULL
GROUP BY location, population, date
ORDER BY Percentage_Population_Infected desc

--TABLEAU TABLE 3, #3 IN ALEX SAMPLE
--Compare countries with total cases count per population
SELECT location, population, MAX(total_cases) AS Highest_Cases_Ct, MAX(total_cases/population)*100  AS Highest_Total_Case_Percentage
FROM PortfolioProject..CovidDeaths
--WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY Highest_Total_Case_Percentage desc

--Compare countries with highest death count
SELECT location, MAX(total_deaths) AS Total_Deaths_Ct
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY Total_Deaths_Ct desc

--Compare countries with highest death count
--convert datatype of total deaths to int
SELECT location, MAX(CAST(total_deaths AS int)) AS Total_Deaths_Ct
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY Total_Deaths_Ct desc

--Compare continents and other groups with highest death count
SELECT location, MAX(CAST(total_deaths AS int)) AS Total_Deaths_Ct
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL --considering  by continents and others groups like EU
GROUP BY location
ORDER BY Total_Deaths_Ct desc

--TABLEAU TABLE 2, #2 ON ALEX SAMPLE
--Compare continents with the highest death count not considering other groups like EU
SELECT location, MAX(CAST(total_deaths AS int)) AS Total_Deaths_Ct
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY Total_Deaths_Ct desc

--Compare continents with highest death count ....
SELECT continent, MAX(CAST(total_deaths AS int)) AS Total_Deaths_Ct
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL --considering by continents only
GROUP BY continent
ORDER BY Total_Deaths_Ct desc

--Compare by continents number of NEW cases and deaths with the highest death count
SELECT location, MAX(CAST(new_deaths AS int)) AS Total_Deaths_Ct
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL --considering by continents only
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY Total_Deaths_Ct desc

--Global number of cases and deaths
SELECT date, total_cases, total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1, 2


--Global number of NEW cases and deaths per day
SELECT date, SUM(new_cases) AS G_Total_Cases, SUM(CAST(new_deaths AS int)) AS G_Total_Deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as G_Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY date 
ORDER BY 1, 2

--TABLEAU TABLE 1, TABLE 1 FROM ALEX SAMPLE
--Global number of NEW cases and deaths ...THIS WILL BE VIEWED
SELECT SUM(new_cases) AS Global_Total_Cases, SUM(CAST(new_deaths AS int)) AS Global_Total_Deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as Global_Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1, 2

--Join the two tables on location and dates
SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--Compare Total Population vs Vacccinations
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--Adding all vaccinations as received daily
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations 
	 ,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
	dea.date) AS Cum_Vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


--To know the cummulative number of vaccinations per location
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations 
	 ,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
	dea.date) AS Cum_Vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--To know the cummulative number of vaccinations per location
--USING CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Cum_Vaccinations) --no of columns here must be same with no of columns in the select below
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	 ,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
	dea.date) AS Cum_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * , (Cum_Vaccinations/population)*100 AS Percentage_Cum_Vac
FROM PopvsVac



--CREATING A TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Cum_Vaccinations numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	 ,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
	dea.date) AS Cum_Vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT * , (Cum_Vaccinations/Population)*100 AS Percentage_Cum_Vac
FROM #PercentPopulationVaccinated

--Create a View to find PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	 ,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
	dea.date) AS Cum_Vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT * 
FROM PercentPopulationVaccinated