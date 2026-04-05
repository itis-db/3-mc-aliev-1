explain analyze
select
    b.book_id,
    b.title,
    ts_rank(b.search_vector, q) as rank
from book b,
     to_tsquery('russian','борщ') q
where b.search_vector @@ q
order by rank desc
limit 5;

explain analyze
select
    b.book_id,
    b.title
from book b
where b.title ilike 'т%';

explain analyze
select
    b.book_id,
    b.title,
    ts_rank(b.search_vector, q) as rank
from book b,
     to_tsquery('russian','рецепт') q
where b.search_vector @@ q
  and b.description ilike 'секрет%';