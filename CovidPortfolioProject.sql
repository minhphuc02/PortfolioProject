select *
from PortfolioProject..CovidDeaths
order by 3,4 

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2
 
-- looking at total cases and total deaths
-- show likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercent
from PortfolioProject..CovidDeaths
where location Like '%states%' and continent is not null
order by 1,2

-- looking at total cases and population
select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercent
from PortfolioProject..CovidDeaths
where location Like '%states%'
order by 1,2
--Countries with highest infection rate compered to population
select location,population,MAX( total_cases) as HighestInfectionCountry, MAX(total_cases/population)*100 as PopulationPercent
from PortfolioProject..CovidDeaths
group by location,population
order by PopulationPercent DESC
-- Countries with highest death count per population
select location,MAX(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount DESC
-- let's break thing down by continent
-- show continents with the highest death count per population
select continent,MAX(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount DESC



-- GLOBAL NUMBER
select  Sum(new_cases) as SumNew_Cases, sum(cast(new_deaths as int)) as SumNewDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as PerDeaths
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total Population vs Vaccinations
with PopvsVac(Continent,Location,Date,Population,New_Vaccination,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,population, vac.new_vaccinations, 
Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations  vac
	on dea.location=vac.location 
	and dea.date= vac.date
	where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp table
drop table if exists #PercentPopultionVaccinated 
Create table #PercentPopultionVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopultionVaccinated
select dea.continent,dea.location,dea.date,population, vac.new_vaccinations, 
Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations  vac
	on dea.location=vac.location 
	and dea.date= vac.date
--	where dea.continent is not null
--order by 2,3
Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopultionVaccinated

-- create view to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 