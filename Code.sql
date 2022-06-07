--1--


select drivers.driverId, drivers.forename, drivers.surname, drivers.nationality, lapTimes.milliseconds as time
from lapTimes, drivers, races, circuits
where races.year=2017 and circuits.country='Monaco' and drivers.driverId = lapTimes.driverId and races.raceId = lapTimes.raceId and circuits.circuitId = races.circuitId and lapTimes.milliseconds = (select MAX(lapTimes.milliseconds) from lapTimes, drivers, races, circuits where  races.year=2017 and circuits.country='Monaco' and drivers.driverId = lapTimes.driverId and races.raceId = lapTimes.raceId and circuits.circuitId = races.circuitId)
Order by drivers.forename, drivers.surname, drivers.nationality;


--2--


select constructors.name as constructor_name, constructors.constructorId, constructors.nationality,  sum(constructorResults.points) as points
from constructorResults, constructors, races
where races.year = 2012 and constructorResults.constructorId = constructors.constructorId and races.raceId = constructorResults.raceId
group by constructors.constructorId
Order by points desc, constructors.name asc, constructors.nationality asc, constructors.constructorId asc
limit 5;


--3--


WITH DP AS(
    select drivers.driverId, drivers.forename, drivers.surname, sum(results.points) as points
    from results, races, drivers
    where results.raceId = races.raceId and results.driverId = drivers.driverId and races.year Between 2001 and 2020
    group by drivers.driverId
)

select *
from(
    select *
    from DP
    where points = (
        select MAX(points)
        from DP
    )
)as DM
Order by DM.forename asc, DM.surname asc, DM.driverId asc; 


--4--


WITH DP AS(
    select constructors.constructorId, constructors.name, constructors.nationality, sum(results.points) as points
    from results, races, constructors
    where results.raceId = races.raceId and results.constructorId = constructors.constructorId and races.year Between 2010 and 2020
    group by constructors.constructorId
)

select * 
from (
    select * 
    from DP
    where points = (
        select MAX(points)
        from DP
    )
) as DM
Order by DM.name asc, DM.nationality asc, DM.constructorId asc; 


--5--


WITH DP AS(
    select drivers.driverId, drivers.forename, drivers.surname, count(results.positionOrder) as race_wins
    from results, drivers
    where results.driverId = drivers.driverId and results.positionOrder = 1
    group by drivers.driverId
)

select *
from (
    select* 
    from DP
    where race_wins=(
        select MAX(race_wins)
        from DP
    )
) as DM
Order by DM.forename asc, DM.surname asc, DM.driverId asc;


--6--



WITH DP0 AS(
    select constructorResults.raceId, MAX(constructorResults.points) as max_points 
    from constructorResults
    group by constructorResults.raceId
)

, DP1 AS(
    select constructorResults.constructorId, constructors.name, count(constructorResults.constructorId) as num_wins
    from DP0, constructorResults, constructors
    where DP0.raceId = constructorResults.raceId and DP0.max_points = constructorResults.points and constructors.constructorId = constructorResults.constructorId
    group by constructorResults.constructorId, constructors.name
)
select *
from (
    select* 
    from DP1
    where num_wins=(
        select MAX(num_wins)
        from DP1
    )
) as DM
Order by DM.name asc, DM.constructorId asc;


--7--


WITH DP0 AS(
    select results.driverId, races.year, sum(points) as total
    from races, results
    where races.raceId = results.raceId
    group by races.year, results.driverId
)
, DP1 AS(
    select DP0.year, MAX(DP0.total) as top_score_year
    from DP0
    group by DP0.year
)
, DP2 AS(
    select DP0.driverId, count(DP0.driverId) as topper
    from DP0, DP1
    where DP0.year = DP1.year and DP0.total = DP1.top_score_year
    group by DP0.driverId
)

, DP3 AS(
    select drivers.driverId
    from drivers
    except
    select DP2.driverId
    from DP2
)

, DP4 AS(
    select DP3.driverId, drivers.forename, drivers.surname, sum(results.points) as points
    from DP3, results, drivers
    where DP3.driverId = drivers.driverId and DP3.driverId = results.driverId
    group by DP3.driverId, drivers.forename, drivers.surname
)
select * 
from DP4
Order by DP4.points desc, DP4.forename asc, DP4.surname asc, DP4.driverId asc
limit 3;



--8--


WITH DP AS(
    select results.driverId, drivers.forename, drivers.surname, count(DISTINCT circuits.country) as num_countries
    from results, races, circuits, drivers
    where results.raceId = races.raceId and races.circuitId = circuits.circuitId and results.positionOrder = 1 and drivers.driverId = results.driverId
    group by results.driverId, drivers.forename, drivers.surname
)

select *
from (
    select* 
    from DP
    where num_countries=(
        select MAX(num_countries)
        from DP
    )
) as DM
Order by DM.forename asc, DM.surname asc, DM.driverId asc;


--9--


WITH DP AS(
    select drivers.driverId, drivers.forename, drivers.surname
    from results, drivers
    where results.positionOrder = 1 and results.grid = 1 and drivers.driverId = results.driverId    
)

select DP.driverId, DP.forename, DP.surname, count(DP.driverId) as num_wins
from DP
group by DP.driverId, DP.forename, DP.surname
order by num_wins desc, DP.forename asc, DP.surname asc, DP.driverId asc
LIMIT 3;





--10--


WITH DP AS(
    select results.raceId, pitStops.stop, results.driverId, drivers.forename, drivers.surname, circuits.circuitId, circuits.name
    from results, pitStops, drivers, circuits, races
    where results.driverId = pitStops.driverId and results.raceId = pitStops.raceId and results.positionOrder = 1 
    and drivers.driverId = results.driverId and races.raceId = results.raceId and circuits.circuitId = races.circuitId

)
select DP.raceId, DP.stop, DP.driverId, DP.forename, DP.surname, Dp.circuitId, DP.name
from DP
where DP.stop = (select MAX(DP.stop) from DP)
order by DP.forename asc, DP.surname asc, DP.name asc, DP.circuitId asc, DP.name asc;



--11--


WITH DP AS(
    select races.raceId, circuits.name, circuits.location, count(results.statusId) as num_collisions
    from races, results, status, circuits
    where races.raceId = results.raceId and status.statusId = results.statusId and circuits.circuitId = races.circuitId and results.statusId = 4
    group by races.raceId, circuits.name, circuits.location
)


select *
from (
    select* 
    from DP
    where num_collisions=(
        select MAX(num_collisions)
        from DP
    )
) as DM
Order by DM.name asc, DM.location asc, DM.raceId asc;


--12--


WITH DP AS(
    select drivers.driverId, drivers.forename, drivers.surname, count(results.rank) as count
    from results, drivers
    where results.driverId = drivers.driverId and results.positionOrder = 1 and results.rank = 1
    group by drivers.driverId, drivers.forename, drivers.surname
)


select *
from (
    select* 
    from DP
    where count=(
        select MAX(count)
        from DP
    )
) as DM
Order by DM.forename asc, DM.surname asc, DM.driverId asc;


--13--
/* year, point diff (constructor1 points - constructor2 points),constructor1 id (constructor who finished first), constructor1 name, constructor2 id (constructor who finished second),  constructor2 name*/
/* 1.constructor1 name (ascending order) 2.constructor2 name (ascending order). 3.constructor1 id(ascending order) 4.constructor2 id(ascending order)*/


-- WITH DP0 AS(
--     select constructorResults.constructorId, races.year, sum(points) as total
--     from constructorResults, races
--     where races.raceId = constructorResults.raceId
--     group by constructorResults.constructorId, races.year
-- )
-- , DP1 As(
--     select DP0.year, MAX(DP0.total) as top_score_year
--     from DP0
--     group by DP0.year
-- )
-- , DP2 As(
--     select DP0.constructorId, count(DP0.constructorId) as topper
--     from DP1, DP0
--     where DP0.year = DP1.year and DP0.total = DP1.top_score_year
--     group by DP0.constructorId
-- )

-- , DP11 AS(
--     select constructors.Id, constructors.forename, constructors.surname, DP2.topper as num_champs
--     from DP2, constructors
--     where DP2.constructorId = constructors.constructorId
-- )

-- , DP3 AS(
--     select constructors.constructorId
--     from constructors
--     except
--     select DP2.constructorId
--     from DP2
-- )




-- , DP4 AS(
--     select constructorId, constructorRef, name, nationality
--     from constructors, DP3
--     where constructors.constructorId = DP3.constructorId
-- )

-- , DP5 AS(
--     select DP4.constructorId, races.year, sum(points) as total1
--     from DP4, races
--     where races.raceId = DP4.raceId
--     group by DP4.constructorId, races.year
-- )
-- , DP6 As(
--     select DP5.year, MAX(DP5.total1) as top_score_year1
--     from DP5
--     group by DP5.year
-- )
-- , DP7 As(
--     select DP5.constructorId, count(DP5.constructorId) as topper1
--     from DP6, DP5
--     where DP5.year = DP6.year and DP5.total = DP6.top_score_year1
--     group by DP5.constructorId
-- )

-- , DP12 AS(
--     select DP4.constructorId, DP4.forename, DP4.surname, DP7.topper1 as num_champs1
--     from DP7, DP4
--     where DP7.constructorId = DP4.constructorId
-- )


/*WITH DP AS(
    select races.year
    from constructorResults, races
    where constructorResults.raceId = races.raceId
)*//*wrong*/





--14--


WITH DP AS(
    select drivers.driverId, drivers.forename, drivers.surname, circuits.circuitId, circuits.country, (results.grid) as pos
    from results, races, drivers, circuits
    where results.raceId = races.raceId and drivers.driverId = results.driverId and circuits.circuitId = races.circuitId and results.positionOrder = 1 and races.year = 2018
)

select *
from (
    select* 
    from DP
    where pos=(
        select MAX(pos)
        from DP
    )
) as DM
Order by DM.forename desc, DM.surname asc, DM.country asc, DM.driverId asc, DM.circuitId asc;


--15--


WITH DP AS(
    select constructors.constructorId, constructors.name, count(results.statusId) as num
    from results, constructors, races, status
    where status.statusId = results.statusId and races.raceId = results.raceId 
    and constructors.constructorId = results.constructorId and results.statusId = 5 and races.year Between 2000 and 2021
    group by constructors.constructorId, constructors.name
)
select *
from (
    select* 
    from DP
    where num=(
        select MAX(num)
        from DP
    )
) as DM
Order by DM.name asc, DM.constructorId asc;


--16--


WITH DP AS(
    select DISTINCT drivers.driverId, drivers.forename, drivers.surname
    from results, races, circuits, drivers
    where drivers.driverId = results.driverId and results.raceId = races.raceId 
    and races.circuitId = circuits.circuitId and circuits.country = 'USA' and drivers.nationality = 'American' and results.positionOrder = 1
)

select *
from DP
Order by DP.forename asc, DP.surname asc, DP.driverId asc
limit 5;



--17--



WITH DP0 AS(
    select results.raceId, results.constructorId
    from results, races
    where results.positionOrder <= 2 and races.year >= 2014 and races.raceId = results.raceId
)

, DP1 AS(
    select DP0.raceId, DP0.constructorId, count(DP0.raceId) as total
    from DP0
    group by DP0.raceId, DP0.constructorId
)

, DP2 As(
    select DP1.constructorId, count(DP1.constructorId) as count 
    from DP1
    where DP1.total = 2
    group by DP1.constructorId
)

select *
from (
    select DP2.constructorId, constructors.name, DP2.count
    from DP2, constructors
    where count=(
        select MAX(count)
        from DP2
    ) and DP2.constructorId = constructors.constructorId
) as DM
Order by DM.name asc, DM.constructorId asc;




--18--



WITH DP0 AS(
    select lapTimes.driverId, count(lapTimes.position) as num_laps
    from lapTimes
    where lapTimes.position = 1
    group by lapTimes.driverId 
)

, DP1 AS(
    select drivers.driverId, drivers.forename, drivers.surname, DP0.num_laps
    from DP0, drivers
    where DP0.driverId = drivers.driverId
)
select *
from (
    select* 
    from DP1
    where num_laps=(
        select MAX(num_laps)
        from DP1
    )
) as DM
Order by DM.forename asc, DM.surname asc, DM.driverId asc;





--19--


WITH DP AS(
    select drivers.driverId, drivers.forename, drivers.surname, count(results.positionOrder) as count
    from drivers, results
    where drivers.driverId = results.driverId and results.positionOrder <= 3
    group by drivers.driverId, drivers.forename, drivers.surname
)
select *
from (
    select* 
    from DP
    where count=(
        select MAX(count)
        from DP
    )
) as DM
Order by DM.forename asc, DM.surname desc, DM.driverId asc;



--20--

WITH DP0 AS(
    select results.driverId, races.year, sum(points) as total
    from races, results
    where races.raceId = results.raceId
    group by races.year, results.driverId
)
, DP1 AS(
    select DP0.year, MAX(DP0.total) as top_score_year
    from DP0
    group by DP0.year
)
, DP2 AS(
    select DP0.driverId, count(DP0.driverId) as topper
    from DP0, DP1
    where DP0.year = DP1.year and DP0.total = DP1.top_score_year
    group by DP0.driverId

)


select drivers.driverId, drivers.forename, drivers.surname, DP2.topper as num_champs
from DP2, drivers
where DP2.driverId = drivers.driverId
order by DP2.topper desc, drivers.forename asc, drivers.surname desc, drivers.driverId asc
LIMIT 5;





