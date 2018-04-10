Use sakila;

/* 1a. You need a list of all the actors.  display the first and last names of all actors from the table actor.*/

Select first_name, last_name 
From actor;

/*1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.*/

Select CONCAT(UPPER(first_name), ' ', UPPER(last_name)) 
As "Actor Name" 
From actor; 

/*2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
What is one query would you use to obtain this information?*/

Select actor_id, first_name, last_name 
From actor Where first_name="Joes";

/*2b. Find all actors whose last name contain the letters GEN:*/

Select first_name, last_name 
From actor 
Where last_name like '%GEN%';

/*2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:*/

Select last_name, first_name 
From actor 
Where last_name like '%LI%' ;

/*2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:*/

Select country_id, country 
From country 
Where country in ('Afghanistan', 'Bangladesh', 'China');

/*3a. Add a middle_name column to the table actor. Position it between first_name and last_name. 
Hint: you will need to specify the data type.*/

Alter table actor 
Add Column middle_name VARCHAR(50) After first_name;

/*3b. You realize that some of these actors have tremendously long last names. 
Change the data type of the middle_name column to blobs.*/

Alter table actor 
Modify Column middle_name Blob;

/*3c. Now delete the middle_name column.*/

SET SQL_SAFE_UPDATES = 0;

Alter Table actor 
Drop Column middle_name; 

/*4a. List the last names of actors, as well as how many actors have that last name.*/

Select last_name, Count(last_name) as actors_name 
From actor 
Group By last_name;

/*4b. List last names of actors and the number of actors who have that last name, 
but only for names that are shared by at least two actors*/

Select last_name, Count(last_name) as actors_name 
From actor 
Group By last_name Having Count(*)>=2;

/*4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.*/

Update actor Set first_name = "Harpo" 
Where first_name = "Groucho" and last_name = "Williams";


/*4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is 
currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO 
GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE 
THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)*/

Update actor Set first_name = (Case When first_name = 'Harpo' then 'Groucho'  Else 'Mucho Groucho'  end) 
Where actor_id = 10;

/*5a. You cannot locate the schema of the address table. Which query would you use to re-create it?*/

CREATE TABLE address
(address_id smallint(5)unsigned NOT NULL AUTO_INCREMENT,
  address varchar(50) NOT NULL,
  address2 varchar(50) DEFAULT NULL,
  district varchar(20) NOT NULL,
  city_id smallint(5) unsigned NOT NULL,
  postal_code varchar(10) DEFAULT NULL,
  phone varchar(20) NOT NULL,
  location geometry NOT NULL,  
  last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (address_id),
  KEY idx_fk_city_id (city_id),
  SPATIAL KEY idx_location (location),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE) 
  ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

/*6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:*/

Select first_name, last_name, address 
From staff s Inner Join address a on s.address_id = a.address_id;

/*6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.*/

Select s.staff_id, first_name, last_name, SUM(amount) as "Total Amount" 
From staff s Inner Join payment p On s.staff_id = p.staff_id 
WHERE payment_date BETWEEN '2005-08-01 00:00:00' and '2005-09-01 00:00:00' Group By s.staff_id;

/*6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.*/

Select title, Count(*) as number_actors 
From film Join film_actor 
On film.film_id = film_actor.film_id 
Group By title;

/*6d. How many copies of the film Hunchback Impossible exist in the inventory system?*/

Select title, Count(inventory_id) 
From inventory 
Join film on inventory.film_id= film.film_id 
Where title= 'Hunchback Impossible' Group By title;

/*6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
List the customers alphabetically by last name:*/

Select c.first_name, c.last_name, Sum(amount) 
From customer c Join payment p on p.customer_id=c.customer_id 
Group By first_name, last_name 
Order By last_name ASC;


/*7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.*/

Select title
From film
Where language_id IN
(Select language_id From language
Where name="English")
And (title Like "K%") Or (title Like "Q%");


/*7b. Use subqueries to display all actors who appear in the film Alone Trip.*/

Select first_name, last_name From actor
Where actor_id in
(Select actor_id 
From film_actor
Where film_id in
(Select film_id
From film
Where title="Alone Trip"));


/*7c. You want to run an email marketing campaign in Canada, f
or which you will need the names and email addresses of all Canadian customers. 
Use joins to retrieve this information.*/

Select customer.first_name, customer.last_name, customer.email, country.country
From customer
Left Join address
On customer.address_id = address.address_id
Left Join city 
On city.city_id = address.city_id
Left Join country
on country.country_id=city.country_id
Where country= "Canada";


/*7d. Sales have been lagging among young families, and you wish to target all family 
movies for a promotion. Identify all movies categorized as famiy films.*/

Select *
From film
Where film_id in
(Select film_id 
From film_category
Where category_id in
(Select category_id From category
Where name ="Family"));


/*7e. Display the most frequently rented movies in descending order.*/

Select f.title, Count(r.rental_id) As "Rentals"
From film f
Right Join inventory i
on f.film_id=i.film_id
Join rental r
on r.inventory_id=i.inventory_id
Group By f.title
Order by count(r.rental_id) DESC;


/*7f. Write a query to display how much business, in dollars, each store brought in.*/

Select s.store_id, Sum(amount) as "Revenue" 
From store s
Right Join staff st
On s.store_id = st.store_id
Left Join payment p
On st.staff_id = p.staff_id
Group By s.store_id;

/*7g. Write a query to display for each store its store ID, city, and country.*/

Select s.store_id, city.city, country.country 
From store s
Join address a
on s.address_id = a.address_id
Join city 
Join country 
On city.country_id = country.country_id;

/*7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the 
following tables: category, film_category, inventory, payment, and rental.)*/

Select c.name, sum(p.amount) As "Revenue" 
From category c
Join film_category fc
On c.category_id = fc.category_id
Join inventory i
On fc.film_id = i.film_id
Join rental r
On r.inventory_id = i.inventory_id
Join payment p
On p.rental_id = r.rental_id
Group by name;

/*8a. In your new role as an executive, you would like to have an easy way of viewing the 
Top five genres by gross revenue. Use the solution from the problem above to create a view. 
If you haven't solved 7h, you can substitute another query to create a view.*/

Create View top_five_genres As
Select c.name, sum(p.amount) As "Revenue" 
From category c
Join film_category fc
On c.category_id = fc.category_id
Join inventory i
On fc.film_id = i.film_id
Join rental r
On r.inventory_id = i.inventory_id
Join payment p
On p.rental_id = r.rental_id
Group by name
Order By Sum(p.amount) Desc
Limit 5;

/*8b. How would you display the view that you created in 8a?*/

Select * 
From top_five_genres;

/*8c. You find that you no longer need the view top_five_genres. Write a query to delete it.*/

Drop View top_five_genres;

