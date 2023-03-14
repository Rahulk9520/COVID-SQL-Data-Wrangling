Select *
From SQLDataW..CovidDeaths
Where continent is not null
Order by 3,4

-- Select *
-- From SQLDataW..CovidVaccinations
-- Order by 3,4

-- Selecting Data we're going to use
Select Location, date, total_cases, new_cases, total_deaths, population
From SQLDataW..CovidDeaths
Where continent is not null
Order by 1,2

-- Total Cases vs Total Deaths
-- Represents likelihood of dying if you contact covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From SQLDataW..CovidDeaths
Where location like '%states%'
Where continent is not null
Order by 1,2

-- Total Cases vs Population 
-- Represents what percentage of population got Covid-19

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From SQLDataW..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Order by 1,2

-- Countries with Higest Infection Rate as compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From SQLDataW..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by Location, population
Order by PercentPopulationInfected desc

-- Represents Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLDataW..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by Location 
Order by TotalDeathCount desc

-- Represents Continents with the Highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLDataW..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by continent 
Order by TotalDeathCount desc

-- Global numbers 
-- Represents Total cases, Deaths and Death Percentage recorded on each date

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From SQLDataW..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2

-- Represents Total cases, Deaths and Death Percentage around the World

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From SQLDataW..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2

--- Covid Vaccinations----

Select *
From SQLDataW..CovidDeaths dea
Join SQLDataW..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date

-- Represents Total Population Vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) as UpdatedPeopleVaccinated
From SQLDataW..CovidDeaths dea
Join SQLDataW..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, UpdatedPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) as UpdatedPeopleVaccinated
From SQLDataW..CovidDeaths dea
Join SQLDataW..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
)
Select *, (UpdatedPeopleVaccinated/Population)*100 as DailyVaccPercentage
From PopvsVac

-- TEMP Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
UpdatedPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) as UpdatedPeopleVaccinated
From SQLDataW..CovidDeaths dea
Join SQLDataW..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null

Select *, (UpdatedPeopleVaccinated/Population)*100 as DailyVaccPercentage
From #PercentPopulationVaccinated

-- Creating View to Store Data for Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) as UpdatedPeopleVaccinated
From SQLDataW..CovidDeaths dea
Join SQLDataW..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated