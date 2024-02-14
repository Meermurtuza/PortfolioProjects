select *
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject.dbo.CovidVacinations
--order by 3,4

--select data that i am going to be using

select  location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1,2

--looking at total cases vs total deaths

select  location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as deathper
from PortfolioProject.dbo.CovidDeaths
where location like '%india%'
order by 1,2


alter table PortfolioProject.dbo.CovidDeaths
alter column total_cases float

--looking at total cases vs population
select  location, date, total_cases,  population, (total_cases/population)*100 as PercentOfPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location like '%india%'
order by 1,2

--looking at country with higest infection rate compared to population

select  location, population, max(total_cases) as HigestInfectionCount, max (total_cases/population) as PercentOfPopulationInfected
from PortfolioProject.dbo.CovidDeaths
group by location , population
order by PercentOfPopulationInfected desc

-- showing countries with higest death count  per population

select  location,  max(cast(total_deaths as int)) as totalDeathCount 
from PortfolioProject.dbo.CovidDeaths
--where location like '%india%'
where continent is not null
group by location 
order by totalDeathCount desc

-- lets break things by continent

select  location,  max(cast(total_deaths as int)) as totalDeathCount 
from PortfolioProject.dbo.CovidDeaths
--where location like '%india%'
where continent is null
group by location 
order by totalDeathCount desc

--showing the continent with higest death count per population

select  location,  max(cast(total_deaths as int)) as totalDeathCount 
from PortfolioProject.dbo.CovidDeaths
--where location like '%india%'
where continent is null
group by location 
order by totalDeathCount desc


-- global numbers

select   date, sum(new_cases), sum(new_deaths), sum(new_deaths )/sum(new_cases )*100 as deathper
from PortfolioProject.dbo.CovidDeaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2

alter table PortfolioProject.dbo.CovidDeaths
alter column new_deaths float

--covidvacinations

--looking at total population vs vacination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingPeoplevacination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

alter table PortfolioProject.dbo.CovidVacinations
alter column new_vaccinations float


--use cte

with PopvsVac (continent, location, date, population, New_vaccinations,rollingPeoplevacination)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeoplevacination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
)

--temp table

drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeoplevacination numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingPeoplevacination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
select *,(rollingPeoplevacination/population)*100
from #PercentPopulationVaccinated

--creating view

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingPeoplevacination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*  
from PercentPopulationVaccinated