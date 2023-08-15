Select *
From PortfolioProject1 .. CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From PortfolioProject1 .. CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths$
order by 1,2

-- total cases vs total deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths$
WHERE location like '%states%'
order by 1,2

-- total cases vs population

Select Location, date, total_cases, population, (total_cases/population)*100 as CasesPerCapita
FROM PortfolioProject1..CovidDeaths$
WHERE location like '%states%'
order by 1,2

-- countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CasesPerCapita
FROM PortfolioProject1..CovidDeaths$
Group by location, population
order by CasesPerCapita desc

-- countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount desc

-- continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc

-- global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths$
-- WHERE location like '%states%'
where continent is not null
group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths$
-- WHERE location like '%states%'
where continent is not null
--group by date
order by 1,2

-- total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
from PortfolioProject1..CovidDeaths$ dea
join PortfolioProject1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use CTE

with PopvsVac (continent, location, date, population, New_Vaccinations, PeopleVaccinatedRolling)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinatedRolling
from PortfolioProject1..CovidDeaths$ dea
join PortfolioProject1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (PeopleVaccinatedRolling/population)*100
from PopvsVac

-- TEMP TABLE


DROP table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
PeopleVaccinatedRolling numeric,
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinatedRolling
from PortfolioProject1..CovidDeaths$ dea
join PortfolioProject1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (PeopleVaccinatedRolling/population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinatedRolling
from PortfolioProject1..CovidDeaths$ dea
join PortfolioProject1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated