-- Netflix Project
Drop Table if exists netflix;

create Table Netflix
(
show_id	Varchar(10),
type	varchar (10),
title	Varchar(120),
director	Varchar(220),
casts	varchar(800),
country	Varchar(130),
date_added	varchar(50),
release_year int,
rating	varchar(10),
duration	varchar(15),
listed_in	Varchar (90),
description Varchar (280)
);

SELECT * FROM Netflix;


SELECT count(*) as Total_count
FROM 
Netflix;



-- 15 Business Problems & Solutions

1. Count the number of Movies vs TV Shows

	Select
		type,
		count(*) as Show_count
		from 
	Netflix
		group by type;

2. Find the most common rating for movies and TV shows

Select type,
rating
from
	(Select 
		type,
		rating,
		count(*),
		rank() over(Partition by type order by count(*) Desc) as Ranking
		From 
	Netflix
	group by 1,2) as t1
	where Ranking =1;


3. List all movies released in a specific year (e.g., 2020)

	Select title,
	release_year
	from
	Netflix
	where release_year = 2020


4. Find the top 5 countries with the most content on Netflix

	SELECT 
	unnest(STRING_TO_ARRAY(Country,',')) AS COUNTRY, 
	count(show_id) as content
	FROM netflix
	where country is not Null
	group by 1
	order by 2 Desc
	limit 5;


5. Identify the longest movie

	Select title,duration from netflix
	where type = 'Movie' and duration is not null
	order by split_part(duration,' ',1)::int desc
	limit 1 ;


6. Find content added in the last 5 year

SELECT
  date_added,
  CASE
    WHEN date_added ~ '^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{2}$'
      THEN TO_DATE(date_added, 'DD-Mon-YY')
    WHEN date_added ~ '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$'
      THEN TO_DATE(date_added, 'Month DD, YYYY')
    WHEN date_added ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
      THEN TO_DATE(date_added, 'YYYY-MM-DD')
    ELSE NULL
  END AS converted_date
FROM netflix
WHERE date_added IS NOT NULL;

7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

	Select * From
	netflix
	where director ilike '%Rajiv Chilaka%'

8. List all TV shows with more than 5 seasons

	with seasion as (
	Select *, split_part(duration,' ',1)::int as TI,
	split_part(duration,' ',2) as PI
	from 
	netflix)
	
	Select * from seasion
	where TI > 5 and PI ='Seasons'
	order by TI;

9. Count the number of content items in each genre

	Select
	unnest(STRING_TO_ARRAY(listed_in,',')) as genre,
	count(show_id) as item_count
	from
	netflix 
	group by genre
	order by item_count desc;

10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!


11. List all movies that are documentaries

	 Select *
	 from netflix,
	 Lateral unnest(STRING_TO_ARRAY(listed_in,',')) as Genre
	 where type ='Movie' 
	 and Trim(Lower(Genre)) = 'documentaries'


12. Find all content without a director

	Select title From
	netflix where director is null;


13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

	SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10


14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

Select unnest(STRING_TO_ARRAY(Casts,',')),count(*) from 
netflix
where Country = 'India'
group by 1
order by 2 desc
limit 10;


15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.

Select title, category,type,description,
count(*)
from
(Select *, 
 case when description ilike '%kill%' or description ilike '%violence%' then 'Bad'
 else 'Good'
 End as Category
 from netflix) as categorize
 where Category = 'Bad'
 group by 1,2,3,4
