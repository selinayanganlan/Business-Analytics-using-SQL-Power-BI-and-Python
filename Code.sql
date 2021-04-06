--Q1
--Simple Ranking
--Top 5 customers sales who purchased product category “Phones”
select top 5 c.NAME as CUSTOMER_NAME, sum(o.SALES) as SALE
from Orders o
inner join Customer c
on o.CUSTOMER_ID = c.ID
inner join Product p
on o.PRODUCT_ID = p.ID
where p.CATEGORY = 'Phones'
group by c.NAME
order by SALE desc

--Q2
--Ranking Within a Group
--Top 2 customers sales per product category
select CUSTOMER_NAME, CATEGORY, SALE, RANK
from (
select c.NAME as CUSTOMER_NAME
, p.CATEGORY
, sum(o.SALES) as SALE
, rank() over(partition by p.CATEGORY order by sum(o.SALES) desc) as RANK
from Orders o
inner join Customer c
on o.CUSTOMER_ID = c.ID
inner join Product p
on o.PRODUCT_ID = p.ID
group by c.NAME, p.CATEGORY
) as new
where RANK <= 2

--Q3
--Percentage Distribution
--Total sales by product category and the contribution against total sales
select p.CATEGORY
, sum(o.SALES) as SALE
, round((100 * sum(o.SALES) / (select sum(SALES) from Orders)), 2) as '%'
from Orders o
inner join Customer c
on o.CUSTOMER_ID = c.ID
inner join Product p
on o.PRODUCT_ID = p.ID
group by p.CATEGORY
order by SALE desc

select sum(SALES)
from Orders

--Q4
--Whole Number Allocation
select sum(Spread)
from (
select p.CATEGORY
, sum(o.SALES) as SALE
, round(sum(o.SALES) / (select sum(SALES) from Orders), 4) as '%'
, round((round((sum(o.SALES) / (select sum(SALES) from Orders)), 4)*2000), 0) as Spread
from Orders o
inner join Customer c
on o.CUSTOMER_ID = c.ID
inner join Product p
on o.PRODUCT_ID = p.ID
group by p.CATEGORY
order by SALE desc --comment out when running the whole
) x

select sum(Spread_2)
from (
select 
p.CATEGORY
, sum(o.SALES) as SALE
, sum(o.SALES) / (select sum(SALES) from Orders) as '%'
, (sum(o.SALES) / (select sum(SALES) from Orders))*2000 as Spread
, cast((sum(o.SALES) / (select sum(SALES) from Orders))*2000 as int) as Spread_2
, cast((sum(o.SALES) / (select sum(SALES) from Orders))*2000 as int) - (sum(o.SALES) / (select sum(SALES) from Orders))*2000 as New
from Orders o
inner join Customer c
on o.CUSTOMER_ID = c.ID
inner join Product p
on o.PRODUCT_ID = p.ID
group by p.CATEGORY
order by New desc --comment out when running the whole
) x

--Q5
--Basket Data
--What are the 2 most common products purchased together in an order?
SELECT c.PRODUCT_1, c.PRODUCT_2, count(*) as COUNT
FROM (
  SELECT a.PRODUCT_ID as PRODUCT_1, b.PRODUCT_ID as PRODUCT_2
  FROM Orders a
  INNER JOIN Orders b
  ON a.ORDER_ID = b.ORDER_ID AND a.PRODUCT_ID != b.PRODUCT_ID
  ) c
GROUP BY c.PRODUCT_1, c.PRODUCT_2
ORDER BY COUNT desc