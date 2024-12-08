select *
from PortfolioProject..CovidDeaths
order by 3,4;

select *
from PortfolioProject..Covidvaccinations
order by 3,4

--total cases and deaths vs population


select location, date, total_cases,new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- looking at total cases vs total death


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPrecentage
from PortfolioProject..CovidDeaths
where location like '%egypt%'
order by 1,2

-- looking at total cases vs population

select location, date, population, total_cases, (total_cases/population)*100 as CasesPrecentage
from PortfolioProject..CovidDeaths
where location = 'egypt'
order by 1,2

-- looking at countries with the highest infiction rate compared to population

select location, population, max(total_cases) as TotalCasesCount, 
   max((total_cases/population))*100 as PopulationInfictedRate
from PortfolioProject..CovidDeaths
group by location, population
order by PopulationInfictedRate desc


-- showing highest deaths count

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- this one is countries with the highest death precentage

select location, population, max(cast(total_deaths as int)) as TotalDeathsCount,
   max((total_deaths/population))*100 as PopulationDeathRate
FROM PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PopulationDeathRate desc

-- NOW, WE'RE BREAKING THINGS DOWN BY CONTINET

-- showing continets with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
-- cases and deaths everyday globaly

select date, sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths ,
  sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathsPrecentage
from PortfolioProject..CovidDeaths
--where location like '%egypt%'
where continent is not null
group by date
order by 1,2

--total cases - deaths 2020/2021

select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths ,
  sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathsPrecentage
from PortfolioProject..CovidDeaths
--where location like '%egypt%'
where continent is not null
--group by date
order by 1,2


-- this one is total population vs vaccinations

with VacivsPopulation (continet, location, date, population, new_vaccinations, RollingVaccinations)
as
(
select dea.continent , dea.location , dea.date, dea.population, vaci.new_vaccinations,
sum(convert(bigint,vaci.new_vaccinations)) over(partition by dea.location order by dea.location,
 dea.date) as RollingVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vaci
 on dea.date = vaci.date
  and dea.location = vaci.location
  where dea.continent is not null
  --order by
)

select * , (RollingVaccinations/population)*100 as precentage
from VacivsPopulation

-- temp table
drop table if exists #PrecentPopulationVaccination
create table #PrecentPopulationVaccination
  (
 continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinated numeric,
  rollingvaccinations numeric
  )

insert into #PrecentPopulationVaccination
select dea.continent , dea.location , dea.date, dea.population, vaci.new_vaccinations,
sum(convert(bigint,vaci.new_vaccinations)) over(partition by dea.location order by dea.location,
 dea.date) as RollingVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vaci
 on dea.date = vaci.date
  and dea.location = vaci.location
  --where dea.continent is not null
  --order by

  select * , (RollingVaccinations/population)*100
from #PrecentPopulationVaccination

 
 --creating view to store data for visualization

 create view PopulationVaccinationPrecent as
 select dea.continent , dea.location , dea.date, dea.population, vaci.new_vaccinations,
sum(convert(bigint,vaci.new_vaccinations)) over(partition by dea.location order by dea.location,
 dea.date) as RollingVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vaci
 on dea.date = vaci.date
  and dea.location = vaci.location
  where dea.continent is not null
  --order by

  select *
  from PopulationVaccinationPrecent



