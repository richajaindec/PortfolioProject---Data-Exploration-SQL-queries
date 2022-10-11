/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/



Select *
From PortfolioProject..CovidDeaths$
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--Order By 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order By 1,2

-- Looking at total cases vs Total deaths
-- Showing likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths$
Where Location like '%states%'
Order By 1,2

-- Looking at total cases vs Population 
-- Shows what percentage of population got covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as Deathpercentage
From PortfolioProject..CovidDeaths$
--Where Location like '%states%'
Order By 1,2

-- Looking at countries with Highest Infection rate compared to population

Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
--Where Location like '%states%'
Group By Location , Population
Order By PercentagePopulationInfected desc

--Showing Countries with Highest Death count per Population
Select Location, Max(Cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where Location like '%states%'
where continent is Not Null
Group By Location
Order By TotalDeathCount desc

-- Showing continents with highest death count per population

Select Continent, Max(Cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where Location like '%states%'
where continent is Not Null
Group By continent
Order By TotalDeathCount desc

-- Global Numbers

Select Sum(new_cases) as total_cases, Sum(Cast(New_deaths as int))as total_deaths, Sum(Cast(new_deaths as int))/ Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where Location like '%states%'
where continent is Not Null
--Group By date
Order By 1,2

Select *
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date

--Looking at total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int))
OVER (Partition by dea.location Order by dea.Location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int))
OVER (Partition by dea.location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


--TEMP TABLE

DROP Table if Exists #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int))
OVER (Partition by dea.location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPeopleVaccinated

--Creating View to store Data for later Visualizations

Create View PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int))
OVER (Partition by dea.location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*
From PercentPeopleVaccinated








