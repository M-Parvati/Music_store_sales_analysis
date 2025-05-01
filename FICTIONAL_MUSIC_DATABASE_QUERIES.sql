-- BASIC :
-- Q1: Find the most senior employee based on job title.
select * from employee
order by levels desc limit 1;



-- Q2: Determine which countries have the most invoices. 
select billing_country,
       count(*)as total
    from invoice
	group by billing_country
	order by total desc;


-- Q3: Identify the top 3 invoice totals. 

select total from invoice 
order by total desc limit 3;


-- Q4: Find the city with the highest total invoice amount to determine the best location for 
-- a promotional event. 

select billing_city,
       sum(total)as total_invoice
	   from invoice
	   group by billing_city
	   order by total_invoice desc limit 1;

-- Q5: Identify the customer who has spent the most money.

select customer.customer_id,
       concat(customer.first_name||customer.last_name)as full_name,
       sum(invoice.total)as most_money_spent
	   from customer
	   join invoice 
	   on invoice.customer_id =customer.customer_id
	   group by customer.customer_id
	   order by most_money_spent desc limit 1;


-- INTERMEDIATE :
-  Q1: Find the email, first name, and last name of customers who listen to Rock music. 
 select distinct c.email,
        c.first_name,
		c.last_name
	 from customer c
		join invoice i
		 on c.customer_id =i.customer_id
		join invoice_line il
		 on il.invoice_id =i.invoice_id
		where track_id in(select track_id from track t
		join genre g
		 on t.genre_id=g.genre_id
		where g.name = 'Rock')
		order by c.email;


-- Q2: Identify the top 10 rock artists based on track count.
select ar.artist_id,ar.name,
       count(ar.artist_id)as track_count
       from artist ar
		join album  a
		on ar.artist_id=a.artist_id
		join track t
		on t.album_id = a.album_id
		join genre g
		on g.genre_id =t.genre_id
		where g.name = 'Rock'
		group by ar.artist_id
		order by track_count desc limit 10;
		

-- Q3: Find all track names that are longer than the average track length. 

select name ,
      milliseconds
      from track
      where milliseconds >(select avg(milliseconds)as average_length from track)
      order by milliseconds desc;


-- ADVANCED :
-- Q1: Calculate how much each customer has spent on each artist.
with best_selling_artist as(
   select ar.artist_id as artist_id,ar.name as artist_name,
   sum(il.unit_price*il.quantity)as total_sales
   from invoice_line il
   join track t
   on t.track_id = il.track_id
   join album a
   on a.album_id = t.album_id
   join artist ar
   on ar.artist_id = a.artist_id
   group by 1
   order by 3 desc
   limit 1
)
select c.customer_id,c.first_name,c.last_name,bsa.artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as amount_spent
from invoice
join customer c
on c.customer_id = invoice.customer_id
join invoice_line
on invoice_line.invoice_id = invoice.invoice_id
join track
on track.track_id = invoice_line.track_id
join album
on album.album_id=track.album_id
join best_selling_artist bsa 
on bsa.artist_id =album.artist_id
group by 1,2,3,4
order by 5 desc;



-- Q2: Determine the most popular music genre for each country based on purchases.
with popular_genre as(
select count(il.quantity)as purchases,c.country,g.name,g.genre_id,
row_number()over(partition by c.country order by count(il.quantity)desc)as row_no
from invoice_line il
join invoice i
on il.invoice_id = i.invoice_id
join customer c 
on c.customer_id = i.customer_id
join track t
on t.track_id = il.track_id
join genre g
on g.genre_id = t.genre_id
group by 2,3,4
order by 2 asc ,1 desc
)
select * from popular_genre where row_no <=1 ;



-- -Q3: Identify the top-spending customer for each country. 

WITH customer_with_country AS (
 SELECT 
  c.customer_id,
  first_name ,
  last_name,
  billing_country,
  SUM(total) AS total_spending,
  row_number()over(partition by billing_country order by sum(total)desc)as row_no
  FROM customer c
  JOIN invoice i ON c.customer_id = i.customer_id
   GROUP BY 1,2,3,4
order by 4 asc, 5 desc)
select * from customer_with_country where row_no <=1

  


	   