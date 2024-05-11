--ex1
WITH cte_product_spend_prespend AS (
  SELECT 
    EXTRACT(YEAR FROM transaction_date) AS year,
    product_id,
    SUM(spend) AS curr_year_spend,
    LAG(SUM(spend)) OVER(PARTITION BY product_id ORDER BY EXTRACT(YEAR FROM transaction_date)) AS prev_year_spend
  FROM user_transactions
  GROUP BY year, product_id
)
SELECT 
  *,
  ROUND(100 * ((curr_year_spend / prev_year_spend ) - 1), 2) AS yoy_rate
FROM cte_product_spend_prespend

--ex2
WITH tb AS (
SELECT 
card_name,
issued_amount,
CONCAT(issue_month,'-',issue_year) AS issued_date,
MIN(CONCAT(issue_month,'-',issue_year)) OVER(PARTITION BY card_name) AS launch_date
FROM monthly_cards_issued
)
SELECT 
card_name,
issued_amount
FROM tb 
WHERE issued_date = launch_date
ORDER BY issued_amount DESC

--ex3
WITH tb AS (
SELECT
*,
ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY transaction_date) AS rank
FROM transactions
)
SELECT 
user_id,
spend,
transaction_date 
FROM tb 
WHERE rank = 3

--ex4
WITH tb AS(
SELECT 
*,
RANK() OVER(PARTITION BY user_id ORDER BY transaction_date DESC) as RANK
FROM user_transactions
)
SELECT
transaction_date,
user_id,
count(product_id) as purchase_count
FROM tb
WHERE rank = 1
GROUP BY transaction_date,
user_id
ORDER BY transaction_date

--ex5
WITH tweet_data AS (
SELECT 
  user_id,
  tweet_date,
  tweet_count,
  LAG(tweet_count,1) OVER(PARTITION BY user_id) AS tweet_old_1,
  LAG(tweet_count,2) OVER(PARTITION BY user_id) AS tweet_old_2
FROM tweets
)
SELECT 
  user_id,
  tweet_date, 
  CASE 
    WHEN tweet_old_1 IS NULL THEN ROUND(tweet_count/1.0, 2)
    WHEN tweet_old_2 IS NULL THEN ROUND((tweet_count + tweet_old_1)/2.0, 2)
    ELSE ROUND((tweet_count + tweet_old_1 + tweet_old_2)/3.0, 2)
    END
  AS rolling_avg_3d
FROM
  tweet_data

--ex6
WITH tb AS(
SELECT 
*,
LAG(transaction_timestamp) OVER(PARTITION BY merchant_id,credit_card_id, amount 
ORDER BY transaction_timestamp) AS previous_transaction,
transaction_timestamp - (LAG(transaction_timestamp) OVER(PARTITION BY merchant_id,credit_card_id, amount 
ORDER BY transaction_timestamp))  AS diff
FROM transactions
)
SELECT 
COUNT(*)
FROM tb 
WHERE diff <= '00:10:00'

--ex7
with spend_tb as (
select category, product,
sum(spend) as total_spend,
RANK() over (PARTITION BY category ORDER BY SUM(spend) DESC) AS product_ranking
from product_spend
where extract(year from transaction_date) = 2022
group by category, product)
select category, product, total_spend
from spend_tb
where product_ranking <=2
order by category, product_ranking

--ex8
WITH cte AS
(
SELECT
a.artist_name,
DENSE_RANK() OVER(ORDER BY COUNT(b.song_id) DESC) AS artist_rank
FROM artists AS a 
INNER JOIN songs AS b ON a.artist_id = b.artist_id
INNER JOIN global_song_rank AS c ON b.song_id = c.song_id
WHERE c.rank <=10
GROUP BY a.artist_name
)
SELECT
artist_name, artist_rank
FROM cte
WHERE artist_rank <=5


