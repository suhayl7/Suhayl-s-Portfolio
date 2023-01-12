select *
from PortfolioProject..CovidDeaths2022$
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVacs2022$
--order by 3,4

-- select the data that will be used in project

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths2022$
order by 1,2


-- looking at the Total cases vs Total deaths
-- This shows the likelihood of dying if you were to get covid per country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercent
from PortfolioProject..CovidDeaths2022$
where location like '%kingdom%'
and continent is not null
order by 1,2


-- Total cases vs population
-- Shows what percent of the population contactacted covid

select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths2022$
--where location like '%kingdom%'
order by 1,2


-- Looking at countires with Highest Infection Rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases)/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths2022$
--where location like '%kingdom%'
Group by location, population
order by PercentPopulationInfected desc


-- Showing countries with the highest Death count per population

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths2022$
where continent is not null
--where location like '%kingdom%'
Group by location
order by TotalDeathCount desc


-- Breaking things down by continent 


-- Showing the continents with the highest death counts
select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths2022$
where continent is not null
--where location like '%kingdom%'
Group by continent 
order by TotalDeathCount desc



-- Global numbers 

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercent
from PortfolioProject..CovidDeaths2022$
--where location like '%kingdom%'
where continent is not null
--group by date
order by 1,2

-- Looking at Total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order 
by dea.location, dea.date) as RollingPeopleVaccinated
,
from PortfolioProject..CovidDeaths2022$ dea
join PortfolioProject..CovidVacs2022$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use CTE

with PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order 
by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths2022$ dea
join PortfolioProject..CovidVacs2022$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



-- Temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated

(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT into #PercentPopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths2022$ dea
join PortfolioProject..CovidVacs2022$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating view to store data later for visualisations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths2022$ dea
join PortfolioProject..CovidVacs2022$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3