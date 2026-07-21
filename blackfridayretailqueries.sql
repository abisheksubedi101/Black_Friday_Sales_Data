USE project2;

CREATE view high_spending_customer_by_city_name AS
with top_spend AS(
select
city,
customer_id,
sum(purchase_amount) as total_price,
count(transaction_id) as total_transaction,
RANK() OVER (PARTITION BY city ORDER BY sum(purchase_amount) DESC) as customer_ranking
FROM cleaned_retail_black_friday_sales_100k
GROUP BY city,customer_id)
select
* FROM top_spend
WHERE customer_ranking <=10;

SELECT * FROM
high_spending_customer_by_city_name;


use project2;
create view hourly_sales_velocity as 
select 
purchase_hour,
sum(purchase_amount) as total_volume,
sum(sum(purchase_amount)) over(order by purchase_hour) as cum_sumtotal
from project2.cleaned_retail_black_friday_sales_100k
GROUP BY purchase_hour;

SELECT * FROM hourly_sales_velocity;

USE project2;
CREATE VIEW customer_segment_by_product AS
SELECT
customer_segment,
product_category,
sum(purchase_amount) as total_vol,
round(sum(purchase_amount)* 100/sum(sum(purchase_amount)) over(PARTITION BY product_category),2) as category_contribution_pct
FROM cleaned_retail_black_friday_sales_100k
GROUP BY customer_segment,product_category;

SELECT * FROM customer_segment_by_product;

USE project2;
CREATE VIEW month_over_month_ratio AS
with m_over_m AS(SELECT
month(purchase_date) as curr_month,
sum(purchase_amount) as total_sales
FROM cleaned_retail_black_friday_sales_100k
GROUP BY 1
)
select
curr_month,
total_sales,
LAG(total_sales) OVER(ORDER BY curr_month) as previous_sales,
round(total_sales-LAG(total_sales) OVER(ORDER BY curr_month)/LAG(total_sales) OVER(ORDER BY curr_month),2) as month_over_month_ratio
from m_over_m
ORDER BY month_over_month_ratio DESC;


USE project2;
CREATE view average_order_value as
select
payment_method,
count(transaction_id) as total_order,
sum(quantity) as total_quantity,
avg(purchase_amount) as average_order_val
from cleaned_retail_black_friday_sales_100k
GROUP BY payment_method
order by average_order_val DESC;


USE project2;

CREATE VIEW high_volume_repeated_order AS
SELECT
product_id,
product_category,
AVG(quantity) as average_transaction,
count(DISTINCT customer_id) as total_customers
from cleaned_retail_black_friday_sales_100k
GROUP BY product_id,product_category
ORDER BY average_transaction
LIMIT 10;

USE project2;

CREATE VIEW weekend_vs_weekday AS
SELECT 
is_weekend,
AVG(purchase_amount) as average_vol,
sum(purchase_amount) as total_volu,
avg(cleaned_discount_pct) as average_discount
from cleaned_retail_black_friday_sales_100k
GROUP BY is_weekend;

SELECT * FROM weekend_vs_weekday;

USE project2;

CREATE VIEW cumsum AS

with product_revenue AS(SELECT
product_id,
sum(purchase_amount) as total_product_revenue
from cleaned_retail_black_friday_sales_100k
GROUP BY product_id
),
runing_revenue as(
select
product_id,
total_product_revenue,
sum(total_product_revenue) over (order by total_product_revenue DESC) as cumutative_runing_total,
sum(total_product_revenue) over() as total_revenue 
from product_revenue
)

select
product_id,
total_product_revenue,
round((cumutative_runing_total/total_revenue)*100,2) as cumutative_pct
from runing_revenue
WHERE(cumutative_runing_total/total_revenue) <=0.80
order by total_product_revenue DESC;

SELECT * FROM cumsum;


USE project2;

CREATE VIEW demographic_matrix AS 
SELECT
age_group,
gender,
count(DISTINCT customer_id) as total_customer,
avg(purchase_amount) as spend_per_customer,
sum(purchase_amount) as gross_spend
from cleaned_retail_black_friday_sales_100k
GROUP BY age_group,gender;


use project2;

CREATE VIEW blackfriday AS 
SELECT
is_black_friday,
count(DISTINCT customer_id) as total_customer,
sum(purchase_amount) as revenue,
avg(purchase_amount) as average_rev,
AVG(cleaned_discount_pct) as average_discount
from cleaned_retail_black_friday_sales_100k
GROUP BY is_black_friday;

SELECT * FROM blackfriday;






