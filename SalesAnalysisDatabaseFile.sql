-- use the database
use salesstore;

-- create tables for the exported data
create table products (
productid integer,
productname varchar(100),
category varchar(100),
price decimal(5,2)
);

 LOAD DATA INFILE
"C:/SalesAnalysisSQL/Products.csv"
INTO TABLE products
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

create table firstyearsales (
saleid integer,
productid integer,
salesmanid integer,
storeid integer,
saledate date,
quantity integer,
totalamount decimal(6,2)
);


LOAD DATA INFILE
"C:/SalesAnalysisSQL/firstyearsales.csv"
INTO TABLE firstyearsales
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;


create table secondyearsales (
saleid integer,
productid integer,
salesmanid integer,
storeid integer,
saledate date,
quantity integer,
totalamount decimal(6,2)
);

LOAD DATA INFILE
"C:/SalesAnalysisSQL/secondyearsales.csv"
INTO TABLE secondyearsales
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;


create table salesman (
salesmanid integer,
name varchar(100),
storeid integer
);

LOAD DATA INFILE
"C:/SalesAnalysisSQL/Salesman.csv"
INTO TABLE salesman
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;


create table store (
storeid integer,
storename varchar(100),
location varchar(100)
);

LOAD DATA INFILE
"C:/SalesAnalysisSQL/Stores.csv"
INTO TABLE store
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;
-- use salesstore;

-- total product sold in the first year
select sum(quantity)
from firstyearsales;

-- total products sold in the second year
select sum(quantity)
from secondyearsales;

-- -- total revenue of first year
select sum(totalamount)
from firstyearsales;

-- -- total revenue of second year
select sum(totalamount)
from secondyearsales;

-- the highest and least sold products in 2023 
SELECT productid, sum(quantity)
FROM firstyearsales
GROUP BY productid
order by sum(quantity) DESC;


-- the highest and least sold products in 2024 
SELECT productid, sum(quantity)
FROM secondyearsales
GROUP BY productid 
order by sum(quantity) DESC;

-- number of products sold and revenue by each salesman in 2023
select salesmanid, sum(quantity), sum(totalamount)
from firstyearsales
group by salesmanid
order by sum(quantity) desc;


-- number of products sold and revenue by each salesman in 2024
select salesmanid, sum(quantity), sum(totalamount)
from secondyearsales
group by salesmanid
order by sum(quantity) desc;


-- number of products sold by each salesman in 2024 GOOD
use salesstore;
SELECT @@sql_mode;
SET SESSION sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
select salesman.salesmanid, salesman.name, sum(quantity), sum(totalamount), secondyearsales.productid
from secondyearsales, salesman
where secondyearsales.salesmanid = salesman.salesmanid
-- group by salesman.salesmanid
group by secondyearsales.productid, secondyearsales.salesmanid
order by sum(quantity) desc;


-- which store sold the most in 2023
select storeid, sum(quantity)
from firstyearsales
group by storeid
order by sum(quantity) desc;

-- which store sold the most in 2024
select storeid, sum(quantity)
from secondyearsales
group by storeid
order by sum(quantity) desc;

-- how much each product was sold at each location 2023
SELECT 
    store.storeid,
    store.location,
    p.productname AS topsoldproduct,
    SUM(fys.quantity) AS total_quantity
FROM store
INNER JOIN firstyearsales fys ON store.storeid = fys.storeid
INNER JOIN products p ON fys.productid = p.productid
GROUP BY store.storeid, store.location, p.productname
ORDER BY store.storeid, total_quantity DESC;


-- how much each product sold at each location 2024
SELECT 
    store.storeid,
    store.location,
    p.productname AS topsoldproduct,
    SUM(fys.quantity) AS total_quantity
FROM store
INNER JOIN secondyearsales fys ON store.storeid = fys.storeid
INNER JOIN products p ON fys.productid = p.productid
GROUP BY store.storeid, store.location, p.productname
ORDER BY store.storeid, total_quantity DESC;

-- top sold products 
SELECT store.storeid,
       store.location,
       p.productname AS topsoldproduct,
       SUM(fys.quantity) AS total_quantity
FROM store
INNER JOIN firstyearsales fys ON store.storeid = fys.storeid
INNER JOIN products p ON fys.productid = p.productid
GROUP BY store.storeid, store.location, p.productname
HAVING SUM(fys.quantity) = (
    SELECT MAX(total_quantity)
    FROM (
        SELECT SUM(fys2.quantity) AS total_quantity
        FROM firstyearsales fys2
        WHERE fys2.storeid = store.storeid
        GROUP BY fys2.productid
    ) AS subquery
)
ORDER BY store.storeid;


-- how much each store sold for each product
SELECT store.storeid,
       store.location,
       p.productname AS topsoldproduct,
       SUM(fys.quantity) AS total_quantity
FROM store
INNER JOIN firstyearsales fys ON store.storeid = fys.storeid
INNER JOIN products p ON fys.productid = p.productid
GROUP BY store.storeid, store.location, p.productname



-- top sold products
SELECT store.storeid, store.location, products.productname, SUM(firstyearsales.quantity)
FROM store, products, firstyearsales
where store.storeid = firstyearsales.storeid AND 
	  products.productid = firstyearsales.productid
group by store.storeid, store.location, products.productname
-- having sum(firstyearsales.quantity) = max(sum(firstyearsales.quantity))
-- order by store.storeid
having sum(firstyearsales.quantity) = (
		select max(items) from (
		select sum(firstyearsales.quantity) as items
        from firstyearsales
        where firstyearsales.storeid = store.storeid
		group by firstyearsales.productid) AS sub
 --        where sub.storeid = store.storeid
	)
order by store.storeid;



      
