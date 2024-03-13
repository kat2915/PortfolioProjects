--Dataset
Select * 
From CovidDeaths
Where continent is not null
order by 3, 4

Select * 
From CovidVaccinations
Where continent is not null
order by 3, 4

-- Looking at Total Cases / Total Deaths -- likelihood of dying

Select Location, Date, Total_cases, Total_Deaths, (Total_deaths/Total_Cases)*100 as DeathPercentage
From CovidDeaths
Where location like 'Hungary'
Order by Location, Date

--Looking at Total Cases vs Population -- percentage of population got Covid

Select Location, Date, Population, Total_cases, (Total_cases/population)*100 as CasePercentage
From CovidDeaths
Where location like 'Hungary'
Order by Location, Date

-- Looking at Countries with Highest Infection rate compared to Population

Select Location, Population, Max(Total_cases) as HighestInfectioncount, MAX((total_cases/population))*100 as CasePercentage
From CovidDeaths
Group by location, population
Order by 4 desc

-- Looking at countries with highest death count per population

Select Location, Max(Total_Deaths) as TotalDeathsCount
From CovidDeaths
Where continent is not null
Group by location
Order by 2 desc

-- Looking at continents with highest death count per population

Select continent, Max(Total_Deaths) as TotalDeathsCount
From CovidDeaths
Where continent is not null
Group by continent
Order by 2 desc



-- Global numbers

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not null
--group by date
order by 1,2

-- Looking at total population vs vaccinations

select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(vac.new_vaccinations) over (partition by dea.location)
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinations,
--(RollingVaccinations/dea.population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinations
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingVaccinations/Population)*100 as RollingVaccinationPercentage
From PopvsVac

--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinations numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinations
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null

Select *, (RollingVaccinations/Population)*100 as RollingVaccinationPercentage
From #PercentPopulationVaccinated

-- Creating View to store data for visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinations
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea. continent is not null
