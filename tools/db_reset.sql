select count(*) AS categories_count from categories;
select count(*) AS featured_movies_count from featured_movies;
select count(*) AS locations_count from locations;
select count(*) AS movie_categories_count from movie_categories;
select count(*) AS movie_tags_count from movie_tags;
select count(*) AS movies_count from movies;
select count(*) AS sns_accounts_count from sns_accounts;
select count(*) AS tag_count from tags;
select count(*) AS users_count from users;
select count(*) AS video_artists_count from video_artists;

delete from categories;
delete from featured_movies;
delete from locations;
delete from movie_categories;
delete from movie_tags;
delete from movies;
delete from sns_accounts;
delete from tags;
delete from users;
delete from video_artists;
