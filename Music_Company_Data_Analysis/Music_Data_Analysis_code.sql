/* Q1: Who is the senior most employee based on job title? */

SELECT * 
FROM employee
ORDER BY levels DESC
LIMIT 1

/* Q2: Which top 5 countries have the most Invoices? */
SELECT COUNT(*) AS invoice_count, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC 
LIMIT 5

/* Q3: What are top 3 values of total invoice? */
SELECT total 
FROM invoice
ORDER BY total DESC

/* Q4: Which city has the best customers? Find top 3 cities that has the highest sum of invoice totals We would like to throw a promotional Music Festival.*/

SELECT  billing_city, SUM(total) AS total_invoice 
FROM invoice
GROUP BY billing_city
ORDER BY total_invoice DESC
LIMIT 3

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT customer.customer_id, first_name,last_name, SUM(invoice.total) AS total_spent
FROM customer
INNER JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spent DESC
LIMIT 3

/* Q6: Return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT  DISTINCT email,first_name, last_name
FROM customer AS cs 
JOIN invoice AS iv ON cs.customer_id = iv.customer_id
JOIN invoice_line AS ivl ON iv.invoice_id = ivl.invoice_id
WHERE track_id IN(
	SELECT track.track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE '%Rock%')
ORDER BY email


/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.name, COUNT(track.track_id) AS total_track
FROM artist 
JOIN album ON artist.artist_id = album.artist_id
JOIN track ON album.album_id = track.album_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE '%Rock%'
GROUP BY artist.name
ORDER BY total_track DESC
LIMIT 10

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name, milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) avg_track_length 
	FROM track)
ORDER BY milliseconds DESC

/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/*Step 1: find which artist has earned the most according to the InvoiceLines*/

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY artist.artist_id
	ORDER BY total_sales DESC
	LIMIT 3
)
/*Step 2: which customer spent the most on this artist.*/

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(inl.unit_price*inl.quantity) AS amount_spent
FROM invoice AS iv
JOIN customer AS c ON c.customer_id = iv.customer_id
JOIN invoice_line AS inl ON inl.invoice_id = iv.invoice_id
JOIN track AS t ON t.track_id = inl.track_id
JOIN album AS alb ON alb.album_id = t.album_id
JOIN best_selling_artist AS bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;

