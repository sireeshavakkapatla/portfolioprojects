SELECT * FROM [portfolio project]..[covid deaths]
where continent is not null
ORDER BY 3,4
--SELECT * FROM [portfolio project]..[covid vaccinations] **
--ORDER BY 3,4

SELECT location,date,population,total_cases,total_deaths,new_cases
FROM [portfolio project]..[covid deaths]
ORDER BY 1,2

--looking at total caes vs total deaths
--shows likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
FROM [portfolio project]..[covid deaths]
WHERE location like '%India%'
ORDER BY 1,2

--looking at total cases vs population
--what percent of population got covid
SELECT location,date,total_cases,population,(total_cases/population)*100 as  percentpopulationinfected
FROM [portfolio project]..[covid deaths]
--WHERE location like '%India%'
ORDER BY 1,2 

--looking at the countries with highest infection rate compared to population
SELECT location,population,max(total_cases) as highestinfectioncount, max((total_cases/population)*100 )as  percentpopulationinfected
FROM [portfolio project]..[covid deaths]

GROUP BY location,population
ORDER BY percentpopulationinfected desc

--showing countries with highest death count per population
SELECT location,max(cast(total_deaths as int)) as Totaldeathcount
FROM [portfolio project]..[covid deaths]
where continent is not null
GROUP BY location
ORDER BY Totaldeathcount desc

--	LETS BREAK THINGS DOWN BY CONTINENT
--showing continents with highest death count per population
SELECT continent,max(cast(total_deaths as int)) as Totaldeathcount
FROM [portfolio project]..[covid deaths]
where continent is not null
GROUP BY continent
ORDER BY Totaldeathcount desc

--global numbers
SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage 
FROM [portfolio project]..[covid deaths]
--WHERE location like '%India%'
where continent is not null
--GROUP by date
ORDER BY 1,2

--looking at total population vs total vaccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location,dea.date) as Rollingdatavaccinated
FROM [portfolio project]..[covid deaths]dea
join [portfolio project]..[covid vaccinations]vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3

--use cte
with popvsvac (continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
FROM [portfolio project]..[covid deaths]dea
join [portfolio project]..[covid vaccinations]vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(Rollingpeoplevaccinated/population)*100 
FROM popvsvac

CREATE VIEW popvsvac as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
FROM [portfolio project]..[covid deaths]dea
join [portfolio project]..[covid vaccinations]vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3





--timetable
DROP TABLE if exists #Percentpopulationvaccinated
CREATE TABLE #Percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population INTEGER,
Rollingpeoplevaccinated INTEGER,
new_vaccinations INTEGER
)
INSERT INTO #Percentpopulationvaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
FROM [portfolio project]..[covid deaths]dea
join [portfolio project]..[covid vaccinations]vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3

SELECT *,(Rollingpeoplevaccinated/population)*100
FROM #Percentpopulationvaccinated
--creting view to store data for later visualizations

CREATE VIEW Percentpopulationvaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
FROM [portfolio project]..[covid deaths]dea
join [portfolio project]..[covid vaccinations]vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM Percentpopulationvaccinated


