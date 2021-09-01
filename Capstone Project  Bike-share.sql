/*
 Skills used in this project are : joins, temp table, views, subqueries, case statement
*/



# let's have a glimpse at the 1st table

# trips table

select * from cyclistic.trips limit 20;

# let's check the uniqueness of the trip_id

select count(distinct trip_id)
from cyclistic.trips;

# we see that the result is same as the total number of records.
# so the granularity of the table is each observation is for a single trip.

# lets check the data types of the columns

# thanks to bigQuery we can easily see the data types

# I will make some changes

# trip_id should be string

select cast(trips.trip_id as string) as trip_id
from cyclistic.trips;

#let's extract the date parts from the start time and end time(put it in a view for reusability) 

# Here , I embeded few things, 
# I extrcted the days of the  week and assigned them the names
# The number 1 being sunday
# DAYOFWEEK: Returns values in the range [1,7] with Sunday as the first day of of the week

with new_table as (
select *
 from 
(
select *, case 
        when dn = 1 then 'sunday'
        when dn = 2 then 'monday'
        when dn = 3 then 'tuesday'
        when dn = 4 then 'wednesday'
        when dn = 5 then 'thursday'
        when dn = 6 then 'friday'
        when dn = 7 then 'saturday'
        else null end as days_of_week
from ( 
        select *, 
        extract(DAYOFWEEK from trips.starttime) as dn ,
        cast(starttime as date) sdate,
        extract(TIME from trips.starttime) as stime,
        cast(trips.stoptime as date) edate,
        extract(TIME from trips.stoptime) as etime
    from 
cyclistic.trips
        )
)
)

#let's group our trip duration by days.

select usertype,
        days_of_week,
        avg(new_table.tripduration)
        from new_table 
        group by 1,2
        order by 2;




#Lets create a view for reusability

create view  cyclistic.final_table as 
select *, case 
        when dn = 1 then 'sunday'
        when dn = 2 then 'monday'
        when dn = 3 then 'tuesday'
        when dn = 4 then 'wednesday'
        when dn = 5 then 'thursday'
        when dn = 6 then 'friday'
        when dn = 7 then 'saturday'
        else null end as days_of_week
from ( 
        select *, 
        extract(DAYOFWEEK from trips.starttime) as dn ,
        cast(starttime as date) sdate,
        extract(TIME from trips.starttime) as stime,
        cast(trips.stoptime as date) edate,
        extract(TIME from trips.stoptime) as etime
    from 
cyclistic.trips
        );



#lets check if the view works

select * from cyclistic.final_table;

#Great !!  the view works, let's begin our analysis


/*####################*/

#Q1 : which type of user use mostly the cycle on average ?


Select usertype,
        round(avg(tripduration),2) as average_usage
from `eddy-project-317819.cyclistic.final_table`
group by 1
order by 2 desc;

# apparently the customers use more the cycle.



#Q2 : lets break it down in days of the week

Select usertype,
        days_of_week,
        round(avg(tripduration),2) as average_usage
from `eddy-project-317819.cyclistic.final_table`
group by 1,2;



#Q3 : lets check on weekdays and weekends.

select usertype,
        case when days_of_week in ('monday','tuesday','wednesday','thursday','friday') then 'weekdays'
             when days_of_week in ('saturday','sunday') then 'weekends'
             else null end as days,
             avg(average_usage) as average
from 
(
        Select usertype,
        days_of_week,
        round(avg(tripduration),2) as average_usage
from `eddy-project-317819.cyclistic.final_table`
group by 1,2
)
group by 1,2
order by 2;

# We see that there is no big difference between the two.
# the subscribers still use less than customers on both weekend and weekdays



select * from cyclistic.final_table;


#Q4 Which day is the most busy ?

select usertype,
        days_of_week,
        count(trip_id) as number_of_trips
from cyclistic.final_table
group by 1,2
order by 3 desc ;

#We see that the weekends are extensively used by the customers 


# Q5 Lets have a look at the peaks hours broken by days 


select usertype,
    days_of_week,
    count(usertype)
from cyclistic.final_table
where stime >= '07:00:00' and etime <= '09:00:00'
group by 1,2
order by 2;

# We see that most days , at peak time, the subscribers are more active. 
# Only sundays, that the customers are first.
# we cab say that the susbcribers use the cycle mostly to commute to work. 



##Now lets check the station table.


select * from cyclistic.stations;


# Q6  what is the most used stations ?
# for this we will use a join

select name,
        count(trip_id) as number_of_trips
from cyclistic.stations s
join cyclistic.trips t
on t.from_station_id = s.id
group by 1
order by 2 desc 
limit 3;

# Millennium Park appears to be the most petronized stations.
# Maybe the company can advertise at these stations if they want to attain more people.



## I'll bring the view to tableau for visual insight. So excited !!!
