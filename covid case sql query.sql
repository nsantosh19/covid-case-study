SELECT new_cases, location, date
 FROM `covid case study`.covid_death
 Where new_cases=0
 
select *
from `covid case study`.covid_death
order by 3,4

--select *
--from covid_vaccination.covid_vaccination
--order by 3,4

select location, date, total_cases, total_deaths, population
from `covid case study`.covid_death
order by 1,2

--looking at Total Cases vs Total Death
--shows likelihood of dying if you contract covid in Afganistan

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from `covid case study`.covid_death
where location like '%Nepal%'
order by 1,2

--looking at Total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as case_percentage
from `covid case study`.covid_death
where location like '%Nepal%'
order by 1,2

--looking at countries with highest infection rate compared to population 

select location, population, MAX(total_cases)as maximum_infection, max((total_cases/population))*100 as max_case_percentage
from `covid case study`.covid_death
group by location, population
order by maximum_infection desc

--Showing Countries with Highest Death per Population

select  location, max(total_deaths + CAST('total_deaths' AS SIGNED)) as Totaldeathcount
from `covid case study`.covid_death
where location !=  'Europe' or 'High income' or 'South America'
group by location
order by Totaldeathcount desc

-- Total number of deaths by continent

select continent, max(total_deaths + CAST('total_deaths' AS SIGNED)) as Totaldeathcount
from `covid case study`.covid_death
where continent is not null
group by continent
order by Totaldeathcount desc

-- Checking Global Covid Cases

-- Total death globally till 05/18/22
Select Sum(new_cases) as total_cases, Sum(new_deaths + cast('new_deaths' as signed)) as total_deaths, Sum(new_deaths + cast('new_deaths' as signed))/Sum(new_cases)*100 as Deathpercentage
from `covid case study`.covid_death
where continent is not null
-- group by date
order by 1,2

-- covid cases grouped by date
Select date, Sum(new_cases) as total_cases, Sum(new_deaths + cast('new_deaths' as signed)) as total_deaths, Sum(new_deaths + cast('new_deaths' as signed))/Sum(new_cases)*100 as Deathpercentage
from `covid case study`.covid_death
where continent is not null
group by date
order by 1,2

-- Joining covid death and vaccination table 

select *
from `covid case study`.covid_death death
Join `covid case study`.covid_vaccination vaccination
	on death.location = vaccination.location
    and death.date = vaccination.date
    
-- Checking total population and vaccination

Select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations, Sum(vaccination.new_vaccinations + cast('vaccination.new_vaccinations' as signed)) Over(partition by death.location order by death.location, death.date) as rolling_vaccination_count
from `covid case study`.covid_death death
Join `covid case study`.covid_vaccination vaccination
	on death.location = vaccination.location
    and death.date = vaccination.date
Where death.continent is not null
order by 1,2,3

-- use CTE
with populationvsvaccination (continent, location, date, population,new_vaccinations, rolling_vaccination_count)
as
(
Select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations, Sum(vaccination.new_vaccinations + cast('vaccination.new_vaccinations' as signed)) Over(partition by death.location order by death.location, death.date) as rolling_vaccination_count
from `covid case study`.covid_death death
Join `covid case study`.covid_vaccination vaccination
	on death.location = vaccination.location
    and death.date = vaccination.date
Where death.continent is not null
)
select *, (rolling_vaccination_count/population)*100
from populationvsvaccination

-- Temp table

Drop table if exists #Percentpopulationvaccinated
Create Table #Percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccination_count numeric
)
Insert into #Percentpopulationvaccinated
Select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations, Sum(vaccination.new_vaccinations + cast('vaccination.new_vaccinations' as signed)) Over(partition by death.location order by death.location, death.date) as rolling_vaccination_count
from `covid case study`.covid_death death
Join `covid case study`.covid_vaccination vaccination
	on death.location = vaccination.location
    and death.date = vaccination.date
Where death.continent is not null
order by 1,2,3

select *, (rolling_vaccination_count/population)*100
from #Percentpopulationvaccinated
 