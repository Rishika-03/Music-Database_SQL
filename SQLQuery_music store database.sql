
/*Q1 Who is the senior most employee ?*/

select top 1 * from dbo.employee
order by levels desc 

/*Q2 Which countries  have the most invoices ? */

select count(*) as c ,billing_country 
from dbo.invoice
group by billing_country
order by c desc

/* What are top 3 values of total invoice? */

select top 3 total as ttl from dbo.invoice
order by ttl desc

/*Q4 Which city has the best customers? Write a query that returns one city that has highest sum of invoice totals. return both city name and sum of all invoice totals */

select top 1 billing_city ,sum (total) invoice_total
from dbo.invoice
group by billing_city
order by invoice_total desc

/*Q5 Who is the best customer ? Write a query that returns the person who has spent the most money. */

select top 1  dbo.customer.customer_id , dbo.customer.first_name as fn , customer.last_name as ln , sum (invoice.total) as total
from dbo.customer
join dbo.invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id,dbo.customer.first_name, customer.last_name
order by total desc

/*Q6 Write a query to return the email, first name and last name and genre of all Rock music listeners. Return list ordered alphabetically with emails starting with A.*/

select email, first_name , last_name
from dbo.customer
join dbo.invoice on customer.customer_id=invoice.customer_id
join dbo.invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in (
           select track_id from dbo.track
		   join dbo.genre on track.genre_id = genre.genre_id
           where genre.name like 'Rock' )
group by email , first_name , last_name
order by email

/*Q7 Write a query that returnss artists name and total track count of top 10 rock bands*/

select top 10 artist.artist_id , artist.name , count(artist.artist_id) as number_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id , artist.name
order by number_of_songs desc

/*Q8 Return all track names that have a song length longer than average song length. Return name and miliseconds for each track. order by the song length with the longest songs list first. */

select name , milliseconds
from dbo.track
where milliseconds > (
           select AVG ( milliseconds) from dbo.track )
order by  milliseconds desc


/*Q9 Find how much amount spent by each customer on artists? Write query to return customer name, artist name and total spent.*/

with best_selling_artist as (
    select top 1 artist.artist_id as artist_id , artist.name as artist_name ,
	sum (invoice_line.unit_price * invoice_line.quantity) as total_spent
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id= album.artist_id
	group by artist.artist_id ,artist.name
	order by 3 desc
	)

select c.customer_id , c.first_name , c.last_name, bsa.artist_name, sum (il.unit_price * il.quantity) as amt_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by c.customer_id , c.first_name , c.last_name, bsa.artist_name
order by 5 desc;

/*Q10 Write query that returns each country along with top genre. For countries where maximum number of purchases is shared return all genres. */

with popular_genre as (
            select count(invoice_line.quantity) as purchases , customer.country , genre.name , genre.genre_id,
			ROW_NUMBER() over(partition by customer.country order by count (invoice_line.quantity) desc) as row_no
			from invoice_line
			join invoice on invoice.invoice_id= invoice_line.invoice_id
			join customer on customer.customer_id = invoice.customer_id
			join track on track.track_id=invoice_line.track_id
			join genre on genre.genre_id=track.genre_id
			group by customer.country , genre.name , genre.genre_id
			)
select * from popular_genre where row_no <= 1

/*Q11 Write a query that determines the customer thst has spent the most on music for each country. write a query that returns the country along with top customer and how much they spent. For shared max amount , return all customers who spent the amount. */

with cust_with_country as (
	        select customer.customer_id , first_name, last_name , billing_country , sum (total) as total_spending,
		    row_number()over(partition by billing_country order by sum(total) desc) as row_no
			from invoice
			join customer on customer.customer_id=invoice.customer_id
			group by customer.customer_id , first_name, last_name , billing_country
			 )
select * from cust_with_country where row_no <= 1

