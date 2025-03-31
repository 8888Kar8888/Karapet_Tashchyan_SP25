--The Shawshank Redemption 1001,The Godfather 1002,The Dark Knight 1003

--TaskN1


insert into public.film(title,description,release_year,language_id ,original_language_id,rental_duration,rental_rate,length,rating,special_features,fulltext)
values('The Shawshank Redemption','The Shawshank Redemption is a powerful tale of hope and resilience, following a wrongly imprisoned man who finds freedom through patience, friendship, and an unbreakable spirit.',1994,1,NULL,1,4.99,2.22,'R','{Trailers,Commentaries,Deleted Scenes,Behind the Scenes}', '''friendship'':9 ''freedom'':7 ''hope'':4 ''imprison'':6 ''patienc'':8 ''power'':1 ''resili'':5 ''spirit'':11 ''tale'':2 ''unbreak'':10'::tsvector),
('The Godfather','The Godfather is a gripping crime saga that follows the powerful Corleone mafia family, led by Vito Corleone, as his reluctant son Michael is drawn into the violent world of organized crime, ultimately transforming into a ruthless leader.',1972,1,NULL,2,9.99,2.55,'R','{Trailers,Commentaries,Deleted Scenes,Behind the Scenes,Interviews,Legacy & Impact,Historical Context}','''family'':10 ''power'':9 ''loyalty'':8 ''betrayal'':7 ''crime'':6 ''mafia'':11 ''tradition'':5 ''revenge'':4 ''respect'':3 ''violence'':2 ''legacy'':1'::tsvector),
('The Dark Knight','The Dark Knight follows Batman as he battles the Joker, testing his morals and Gotham''s fate.',2008,1,NULL,3,19.99,2.32,'PG-13','{Trailers,Commentaries,Deleted Scenes,Behind the Scenes,Interviews,IMAX Scenes,Visual Effects,Stunt Choreography}','''chaos'':10 ''joker'':11 ''batman'':9 ''justice'':8 ''fear'':7 ''corruption'':6 ''anarchy'':5 ''sacrifice'':4 ''morality'':3 ''crime'':2 ''hero'':1'::tsvector)
returning film_id,title;


insert into public.actor(first_name ,last_name)
values('AL','PACINO'), --actor_id 201 / film_id 1002
('JAMES','CAAN'),--202/1002
('TIM','ROBBINS'),--203/1001
('MORGAN','FREEMAN'),--204/1001
('CHRISTIAN','BALE'),--205/1003
('HEATH','LEDGER')
returning actor_id,first_name,last_name;--206/1003


insert into public.film_actor (actor_id,film_id)
values(201,1002),
(202,1002),
(203,1001),
(204,1001),
(205,1003),
(206,1003)
returning actor_id,film_id;

insert into public.inventory(film_id,store_id)
values(1001,1),
(1002,1),
(1003,1)
returning inventory_id, film_id, store_id;


select customer_id from customer
where customer_id in
(select customer_id from rental
group by customer_id
having count(rental_id)>=43
intersect 
select customer_id from payment
group by customer_id
having count(payment_id)>=43);


update customer
set first_name = 'Karapet',last_name='Tashchyan',email='tashchyankar@gmail.com',address_id = 416
where customer.customer_id =3
returning customer_id;

delete from rental 
where customer_id = 3
returning rental_id;

delete from payment 
where customer_id = 3
returning payment_id;


insert into rental(rental_date,inventory_id,customer_id,return_date,staff_id)
values('2017-02-15 16:45:21.914 +0400',4582,3,null,1),
('2017-02-16 16:45:21.914 +0400',4583,3,null,1),
('2017-02-17 16:45:21.914 +0400',4584,3,null,1)
returning rental_id;

insert into payment(customer_id,staff_id,rental_id,amount,payment_date)
values(3,1,32299,6.99,'2017-02-16 17:45:50.914 +0400'),
(3,1,32300,5.99,'2017-02-17 16:45:21.914 +0400'),
(3,1,32301,3.99,'2017-02-18 18:45:21.914 +0400')
returning payment_id;


