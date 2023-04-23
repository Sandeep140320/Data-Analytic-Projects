Select *
From Portfolioproject..CovidDeaths
order by 3,4
Select *
From Portfolioproject..CovidVaccinations
order by 3,4

-- select data we are going to use

Select Location,date,total_cases,new_cases,total_deaths,population
from Portfolioproject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths 

Select Location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Portfolioproject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- % of population who got Covid

Select Location,date,total_cases,population,(total_cases/population)*100 as DeathPercentage
from Portfolioproject..CovidDeaths
--where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location,population,max(total_cases) as HightestInfectionCount, max((total_cases/population))*100 as PopulationInfected
from Portfolioproject..CovidDeaths
--where location like '%states%'
group by Location,population
order by PopulationInfected desc

-- Countries with Hoghest Death count
Select Location,Max(Cast(Total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc

-- Breaking things down by Continent

--Showing continents with highest death count per population

Select Continent,Max(Cast(Total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers

Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from Portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from Portfolioproject..CovidDeaths
where continent is not null
order by 1,2

-- Looking for Total Population VS Vaccination

Select *
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 1,2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as peoplevaccinated
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

-- USE CTE

with PopvsVac (continent, location,date,population,new_vaccinations,peoplevaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as peoplevaccinated
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)
	Select *,(peoplevaccinated/population)*100 from PopvsVac


--Temp Table

drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
peoplevaccinated numeric
)


Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as peoplevaccinated
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3
	

Select *,(peoplevaccinated/population)*100 from #PercentagePopulationVaccinated

-- Creating view to store data for later visualisation

create view PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as peoplevaccinated
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


select * from PercentagePopulationVaccinated