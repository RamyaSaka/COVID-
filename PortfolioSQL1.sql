select * 
from PortfolioProject..CovidDeaths 
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths 
order by 1,2


--looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage 
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage 
from PortfolioProject..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

--looking at total cases vs population
--shows what percentage of poulation got covid

select location, date, population, total_cases, (total_cases/population)*100 as percentage_poulation_infected
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
order by 1,2


--Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as Highest_Infection_Count, max((total_cases/population))*100 as percentage_poulation_infected
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
group by location,population
order by percentage_poulation_infected

--showing countries with highest death count per population

select location, max(cast(total_deaths as bigint)) as Total_Death_Count
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
group by location
order by Total_Death_Count desc

--breaking things down by continent
--showing continents with highest death count per population
select continent, max(cast(total_deaths as bigint)) as Total_Death_Count
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
group by continent
order by Total_Death_Count desc


--global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as bigint)) as total_deaths, sum(cast(new_deaths as bigint))/sum(new_cases)*100 as death_percentage 
from PortfolioProject..CovidDeaths
--where location like '%states%' and 
where continent is not null
--group by date
order by 1,2


select * from PortfolioProject..CovidVaccinations

--Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--use CTE

with popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (rolling_people_vaccinated/population) * 100
from popvsvac


--temporary table
drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #percentagepopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


select *, (rolling_people_vaccinated/population) * 100
from #percentagepopulationvaccinated



--creating view to store data for later visualizations

create view PercentagePopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


select * from PercentagePopulationVaccinated

