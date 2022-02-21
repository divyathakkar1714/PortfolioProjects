select *
from PortfolioProject..CovidDeaths

--select the data that would be used to execute 

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--shows the likelihood of getting covid in a specific country

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where location like '%canada%'
and continent is not null
order by 1,2

--looking at the total cases vs population
-- shows the percentage of population that got covid in a specific country

select location,date,population,total_cases, (total_cases/population)*100 as population_percentage_infected
from PortfolioProject..CovidDeaths
where location like '%canada%'
and continent is not null
order by 1,2

--looking at counties with the highest infection rate compared to population

select location,population,MAX(total_cases) as higest_infect_count, MAX((total_cases/population))*100 as population_percentage_infected
from PortfolioProject..CovidDeaths
--where location like '%canada%'
where continent is not null
group by location,population
order by population_percentage_infected desc

--showing countries with the highest death counts per population

select location, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
--where location like '%canada%'
where continent is not null
group by location
order by total_death_count desc

--showing data by CONTINENTS
--showing continents with highest death counts per population

--select location, MAX(cast(total_deaths as int)) as total_death_count
--from PortfolioProject..CovidDeaths
----where location like '%canada%'
--where continent is null
--group by location
--order by total_death_count desc

select continent, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
--where location like '%canada%'
where continent is not null
group by continent
order by total_death_count desc

--global numbers
--by date
select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percent
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2
--total number of cases vs total deaths globally
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percent
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--joining the two tables of deaths and vaccinations
--looking at total population vs vaccinations
--by CTE add a new column and use it as it
With PopvsVac(continent,location,date,population,new_vaccinations,rolling_people_vac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location, dea.date) as rolling_people_vac
--,(rolling_people_vac/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select * ,(rolling_people_vac/population)*100
from PopvsVac

--by temp table
drop table if exists #per_pop_vac
create table #per_pop_vac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vac numeric,
rolling_people_vac numeric
)
Insert into #per_pop_vac
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location, dea.date) as rolling_people_vac
--,(rolling_people_vac/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select * ,(rolling_people_vac/population)*100
from #per_pop_vac

--create a view
create view percent_population_vac as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location, dea.date) as rolling_people_vac
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from percent_population_vac