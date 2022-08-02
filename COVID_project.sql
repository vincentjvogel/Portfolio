-- Create the database --
USE master
GO
IF NOT EXISTS (
 SELECT name
 FROM sys.databases
 WHERE name = N'COVID_project'
)
 CREATE DATABASE [COVID_project];
GO
IF SERVERPROPERTY('ProductVersion') > '12'
 ALTER DATABASE [COVID_project] SET QUERY_STORE=ON;
GO




-- Look at the two databases --
select * 
from COVID_project..COVID_deaths
order by 3,4

select * 
from COVID_project..COVID_vaccinations
order by 3,4






-- Select data that we are going to use --
select location, date, total_cases, new_cases, total_deaths, population
from COVID_deaths
where continent is not NULL
order by 1,2






-- Looking at total cases vs total deaths --
select location, date, total_cases, total_deaths, (total_deaths*1.0/total_cases)*100 as death_rate_percentage
from COVID_deaths
where continent is not NULL
order by 1,2
-- total_deaths is type int but we need float so we must multiply it by 1.0 --






-- Look at a specific country --
select location, date, total_cases, total_deaths, (total_deaths*1.0/total_cases)*100 as death_rate_percentage
from COVID_deaths
where location like '%states%' 
and continent is not NULL
order by 1,2







-- Look at total cases vs population --
-- Shows the percentage of the population that got covid --
select location, date, total_cases, population, (total_cases*1.0/population)*100 as infected_population_percentage
from COVID_deaths
where continent is not NULL
--where location like '%states%'
order by 1,2








-- Look at countries with highest infection rate compared to population --
select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases*1.0/population))*100 as infected_population_percentage
from COVID_deaths
where continent is not NULL
group by location, population
order by infected_population_percentage desc







-- Show the countries with the highest death count per population --
select location, MAX(total_deaths) as total_death_count
from COVID_deaths
where location not like '%income%' and continent is not NULL
group by location
order by total_death_count desc








-- Show the continents with the highest death count per population --
select location, MAX(total_deaths) as total_death_count
from COVID_deaths
where location not like '%income%' and continent is NULL
group by location
order by total_death_count desc







-- Look at global numbers --
select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths*1.0)/SUM(new_cases)*100 as death_percentage
from COVID_deaths
where location not like '%income%'
and continent is not NULL
--group by date
order by 1, 2







-- Join the two tables --
-- Want to look at the total people vaccinated vs the population --
-- Use CTE --
with PopvsVac (location, date, population, new_vaccinations, total_vaccinations_accumulated)
as (

select death.location, death.date, death.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) OVER (partition by death.location order by death.location, death.date) as total_vaccinations_accumulated
from COVID_deaths death
join COVID_vaccinations vac
    on death.location = vac.location
    and death.date = vac.date
where death.continent is not NULL
--order by 1,2
)

select *, (total_vaccinations_accumulated*1.0/population)*100 as percentage_of_population_vaccinated
from PopvsVac
order by 1, 2








-- Temp table --
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
total_vaccinations_accumulated NUMERIC
)

insert into #PercentPopulationVaccinated
select death.location, death.date, death.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) OVER (partition by death.location order by death.location, death.date) as total_vaccinations_accumulated
from COVID_deaths death
join COVID_vaccinations vac
    on death.location = vac.location
    and death.date = vac.date
where death.continent is not NULL
--order by 1,2

select *, (total_vaccinations_accumulated*1.0/population)*100
from #PercentPopulationVaccinated







-- Create view to store for later visualizations --
create view PercentPopulationVaccinated AS
select death.location, death.date, death.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) OVER (partition by death.location order by death.location, death.date) as total_vaccinations_accumulated
from COVID_deaths death
join COVID_vaccinations vac
    on death.location = vac.location
    and death.date = vac.date
where death.continent is not NULL
--order by 1,2

select *
from PercentPopulationVaccinated