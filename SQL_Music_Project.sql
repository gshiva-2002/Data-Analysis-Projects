-- Database creation 
create database music_store;

-- Database selection
use music_store;



/* Tables creation */
-- 1. Genre  
CREATE TABLE Genre ( 
genre_id INT PRIMARY KEY auto_increment, 
name VARCHAR(120) 
); 
select * from genre;


-- 2. MediaType
CREATE TABLE MediaType ( 
media_type_id INT PRIMARY KEY auto_increment, 
name VARCHAR(120) 
);
select * from mediatype; 


-- 3. Employee 
CREATE TABLE Employee ( 
 employee_id INT PRIMARY KEY auto_increment, 
 last_name VARCHAR(120), 
 first_name VARCHAR(120), 
 title VARCHAR(120), 
 reports_to INT, 
  levels VARCHAR(255), 
 birthdate DATE, 
 hire_date DATE, 
 address VARCHAR(255), 
 city VARCHAR(100), 
 state VARCHAR(100), 
 country VARCHAR(100), 
 postal_code VARCHAR(20), 
 phone VARCHAR(50), 
 fax VARCHAR(50), 
 email VARCHAR(100) 
);
select * from employee;

-- 4. Customer 
CREATE TABLE Customer ( 
 customer_id INT PRIMARY KEY auto_increment, 
 first_name VARCHAR(120), 
 last_name VARCHAR(120), 
 company VARCHAR(120), 
 address VARCHAR(255), 
 city VARCHAR(100), 
 state VARCHAR(100), 
 country VARCHAR(100), 
 postal_code VARCHAR(20), 
 phone VARCHAR(50), 
 fax VARCHAR(50), 
 email VARCHAR(100), 
 support_rep_id INT, 
 FOREIGN KEY (support_rep_id) REFERENCES Employee(employee_id)
 on delete set null on update cascade
); 
select * from customer;



-- 5. Artist 
CREATE TABLE Artist ( 
 artist_id INT PRIMARY KEY auto_increment, 
 name VARCHAR(120) 
);
select * from artist;



-- 6. Album 
CREATE TABLE Album ( 
 album_id INT PRIMARY KEY auto_increment, 
 title VARCHAR(160), 
 artist_id INT, 
 FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
 on delete cascade on update cascade
); 
select * from album;



-- 7. Track 
CREATE TABLE Track ( 
 track_id INT PRIMARY KEY auto_increment, 
 name VARCHAR(200), 
 album_id INT, 
 media_type_id INT, 
 genre_id INT, 
 composer VARCHAR(220), 
 milliseconds INT, 
 bytes INT, 
 unit_price DECIMAL(10,2), 
 FOREIGN KEY (album_id) REFERENCES Album(album_id)
  ON DELETE CASCADE ON UPDATE CASCADE, 
 FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id)
  ON DELETE CASCADE ON UPDATE CASCADE, 
 FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
  ON DELETE CASCADE ON UPDATE CASCADE
); 
select * from track;



-- 8. Invoice 
CREATE TABLE Invoice ( 
 invoice_id INT PRIMARY KEY auto_increment, 
 customer_id INT, 
 invoice_date DATE, 
 billing_address VARCHAR(255), 
 billing_city VARCHAR(100), 
 billing_state VARCHAR(100), 
 billing_country VARCHAR(100), 
 billing_postal_code VARCHAR(20), 
 total DECIMAL(10,2), 
 FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
 on delete cascade on update cascade
); 
select * from invoice;



-- 9. InvoiceLine 
CREATE TABLE InvoiceLine ( 
 invoice_line_id INT PRIMARY KEY auto_increment, 
 invoice_id INT, 
 track_id INT, 
 unit_price DECIMAL(10,2), 
 quantity INT, 
 FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id)
 on delete cascade on update cascade, 
 FOREIGN KEY (track_id) REFERENCES Track(track_id)
 on delete cascade on update cascade
);
select * from invoiceline; 



-- 10. Playlist 
CREATE TABLE Playlist ( 
  playlist_id INT PRIMARY KEY auto_increment, 
 name VARCHAR(255) 
);
select * from playlist;



-- 11. PlaylistTrack 
CREATE TABLE PlaylistTrack ( 
 playlist_id INT, 
 track_id INT, 
 PRIMARY KEY (playlist_id, track_id), 
 FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id)
 ON DELETE CASCADE ON UPDATE CASCADE, 
 FOREIGN KEY (track_id) REFERENCES Track(track_id) 
 ON DELETE CASCADE ON UPDATE CASCADE
); 
select * from playlisttrack;




-- 1. Who is the senior most employee based on job title? 
select * from employee;
select employee_id,last_name,first_name,title from employee
order by levels desc limit 1;


-- 2. Which countries have the most Invoices?
select billing_country,count(invoice_id) as total_invoices from invoice
group by billing_country order by count(invoice_id) desc;


-- 3. What are the top 3 values of total invoice? 
select total as total_invoice from invoice
order by total desc limit 3;


/* 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals */
select billing_city, sum(total) from invoice
group by billing_city order by sum(total) desc limit 1;



/* 5. Who is the best customer? The customer who has spent the most money will be declared 
the best customer. Write a query that returns the person who has spent the most money. */
select c.customer_id,c.first_name,c.last_name,sum(i.total) as total_spent 
from customer c
join invoice i on c.customer_id=i.customer_id
group by c.customer_id,c.first_name,c.last_name 
order by total_spent desc 
limit 1;



-- 6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. 
  /* Return your list ordered alphabetically by email starting with A */
select c.email,c.first_name,c.last_name,g.name 
from customer c
join invoice i on c.customer_id  = i.customer_id
join invoiceline il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
where g.name = "Rock"
order by c.email asc;



/* 7. Let's invite the artists who have written the most rock music in our dataset. Write a query that 
returns the Artist name and total track count of the top 10 rock bands   */
select a.name as artist_name,count(t.track_id) as track_count
from artist a
join album al on a.artist_id = al.artist_id
join track t on al.album_id = t.album_id
join genre g on t.genre_id = g.genre_id
where g.name = "Rock"
group by a.artist_id,artist_name
order by count(t.track_id) desc 
limit 10;



/* 8. Return all the track names that have a song length longer than the average song length.- 
Return the Name and Milliseconds for each track. Order by the song length, with the longest 
songs listed first */
select t.name,t.milliseconds 
from track t
where t.milliseconds > (select avg(milliseconds) from track)
order by t.milliseconds desc;



/* 9. Find how much amount is spent by each customer on artists? Write a query to return customer name, 
artist name and total spent  */
select c.first_name,c.last_name,a.name as artist_name,sum(il.unit_price * il.quantity) as artist_total_spent
from customer c
join invoice i on c.customer_id = i.customer_id
join invoiceline il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join album al on t.album_id = al.album_id
join artist a on al.artist_id = a.artist_id
group by c.customer_id,a.artist_id
order by artist_total_spent desc;



/* 10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount 
of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared, 
return all Genres  */
with genre_purchase as (
select i.billing_country as country,g.name as genre,count(invoice_line_id) as purchase_count 
from invoice i
join invoiceline il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
group by country,genre 
),
rank_genre as (
select country,genre,purchase_count,
rank() over(partition by country order by purchase_count desc) as rnk
from genre_purchase
)
select country,genre,purchase_count
from rank_genre
where rnk = 1;



/* 11. Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
WITH customer_spending AS (
    SELECT c.customer_id,c.first_name,c.last_name,i.billing_country AS country,SUM(i.total) AS total_spent
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
),
ranked_customers AS (
    SELECT *,
	RANK() OVER (PARTITION BY country ORDER BY total_spent DESC) AS rnk
    FROM customer_spending
)
SELECT country, first_name, last_name, total_spent
FROM ranked_customers
WHERE rnk = 1;





