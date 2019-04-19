select * from hosales.employees;
select * from HOSALES.DEPARTMENTS;
select * from HOSALES.JOBS;
select * from HOSALES.JOB_HISTORY;
select * from HOSALES.REGIONS;
select * from HOSALES.COUNTRIES;
select * from HOSALES.LOCATIONS;
select * from HOSALES.CUSTOMERS;
select * from HOSALES.PRODUCTS;
select * from HOSALES.ORDERS;
select * from HOSALES.ORDER_ITEMS;
select * from HOSALES.WAREHOUSES;
select * from HOSALES.INVENTORIES;
select * from HOSALES.PROMOTIONS;

create table employees as select * from hosales.employees;
create table departments as select * from hosales.departments;
create table jobs as select * from hosales.jobs;
create table job_history as select * from hosales.job_history;
create table regions as select * from hosales.regions;
create table countries as select * from hosales.countries;
create table locations as select * from hosales.locations;
create table customers as select * from hosales.customers;
create table products as select * from hosales.products;
create table orders as select * from hosales.orders;
create table order_items as select * from hosales.order_items;
create table warehouses as select * from hosales.warehouses;
create table inventories as select * from hosales.inventories;
create table promotions as select * from hosales.promotions;

-- Data Cleaning
--1
select * from employees;
select * from employees where salary < 0;
update employees set salary = 4800 where employee_id = 106;

select * from hosales.employees where salary < 0;
--2
select * from employees where manager_id is null;  
update employees set manager_id = 100 where employee_id = 100;

select * from hosales.employees where manager_id is null;
--3
select * from employees where department_id is null;
update employees set department_id = 80 where employee_id = 178;

select * from hosales.employees where department_id is null;
--4
select * from jobs;
select * from jobs where min_salary > max_salary;
update jobs set min_salary = 4500, max_salary = 5500
where job_id = 'ST_MAN';

select * from hosales.jobs where min_salary > max_salary;
--5
select * from countries;
select country_id, count(*) from countries 
group by country_id having count(*) > 1;
drop table countries;
create table countries as select distinct * from hosales.countries;


select country_id, count(*) from hosales.countries 
group by country_id having count(*) > 1;
--6
select * from customers;
select customer_id, count(*) from customers 
group by customer_id having count(*) > 1;
drop table customers;
create table customers as select distinct * from hosales.customers;

select * from customers;
select customer_id, count(*) from hosales.customers 
group by customer_id having count(*) > 1;
--7 
select * from products;
select * from products where list_price is null;
delete from products where list_price is null;

select * from hosales.products where list_price is null;
--8 
select * from products where min_price is null;
delete from products where min_price is null;

select * from hosales.products where min_price is null;
--9 & 10 ? 
-- order_id = 2359 is duplicated
select * from orders;
select order_id, count(*) from orders 
group by order_id having count(*) > 1;
select * from orders where order_id = 2359;


select order_id, count(*) from hosales.orders 
group by order_id having count(*) > 1;
-- order_id = 2459 is missing in orders table
select order_id, line_item_id from order_items 
where order_id not in (select order_id from orders);

select * from order_items where order_id = 2359;
select * from order_items where order_id = 2459;
select sum(unit_price*quantity) as total from order_items where order_id=2359;
select sum(unit_price*quantity) as total from order_items where order_id=2459;

update orders set order_id = 2459, order_total = 14051.4, total_price = 14051.4 
where order_id = 2359 and order_mode = 'direct'; 
select * from orders where order_id = 2459;

select * from orders where order_id = 2359 or order_id = 2459;

select order_id, line_item_id from hosales.order_items 
where order_id not in (select order_id from hosales.orders);
--11
select * from inventories;
select product_id, warehouse_id, count(*) from inventories 
group by product_id, warehouse_id having count(*) > 1;
drop table inventories;
create table inventories as select distinct * from hosales.inventories;

--12
select * from  customers;
select * from customers where cust_first_name is null and cust_last_name is null and city is null and cust_address is null;
delete from customers where cust_first_name is null and cust_last_name is null and city is null and cust_address is null;

select * from hosales.customers where cust_first_name is null and cust_last_name is null and city is null and cust_address is null;
-- Star Schema Version 1

-- Department_Dim
create table department_dim 
as select distinct department_id, department_name
from departments;


-- Job_Dim
create table job_dim
as select distinct job_id, job_title from jobs;

select * from job_dim;
-- location_dim
create table location_dim as 
select distinct city || '_' || country_id || '_' || region_id as location_id, city, country_name, region_name from
  (select distinct ct.city, c.country_id, r.region_id, c.country_name, r.region_name
  from customers ct, countries c, regions r 
  where ct.country_id = c.country_id and c.region_id = r.region_id
  union 
  select distinct l.city, c.country_id, r.region_id, c.country_name, r.region_name
  from locations l, countries c, regions r 
  where l.country_id = c.country_id and c.region_id = r.region_id);

select * from location_dim;
-- Credit_Type_Dim
create table credit_type_dim (credit_type_id varchar2(10), credit_type_name varchar2(20), 
    credit_type_desc varchar2(50));
    
insert into credit_type_dim values ('L', 'low credit', 'credit <= 1500');
insert into credit_type_dim values ('M', 'medium credit', '1500 < credit <= 3500');
insert into credit_type_dim values ('H', 'high credit', 'credit > 3500');

select * from credit_type_dim;
-- Season_Dim
create table season_dim 
(season_id varchar2(20),
season_period varchar2(20));

insert into season_dim values ('Summer', 'Dec-Feb');
insert into season_dim values ('Autumn', 'Mar-May');
insert into season_dim values ('Winter', 'Jun-Aug');
insert into season_dim values ('Spring', 'Sep-Nov');

select * from season_dim;
-- Order_Mode_Dim
create table order_mode_dim (order_mode_id varchar2(10), order_mode_desc varchar2(20));
insert into order_mode_dim values ('O', 'online');
insert into order_mode_dim values ('D', 'direct');

select * from order_mode_dim;
-- Year_Month
    -- Year
create table year(year varchar2(10));

insert into year values('2004');
insert into year values('2005');
insert into year values('2006');
insert into year values('2007');
insert into year values('2008');

    -- Month
create table month(month varchar2(10));

insert into month values('01');
insert into month values('02');
insert into month values('03');
insert into month values('04');
insert into month values('05');
insert into month values('06');
insert into month values('07');
insert into month values('08');
insert into month values('09');
insert into month values('10');
insert into month values('11');
insert into month values('12');   

    -- Year_Month
create table year_month as select distinct y.year || m.month as year_month_id, y.year, m.month from month m, year y;

select * from year_month;
-- Time_Dim
create table time_dim as select distinct year || month as time_id, year, month from
  (select distinct to_char(order_date, 'yyyy') as year, to_char(order_date, 'mm') as month from orders 
  union 
  select distinct year, month from year_month);
  
select * from time_dim;

-- Product_Dim
create table product_dim as
select distinct p.product_id, p.product_name, p.product_description as product_desc,
    1/count(*) as weight_factor, nvl(LISTAGG(i.warehouse_id, '_') 
    within group (order by i.warehouse_id), 'UNKNOWN') as Warehouse_Group_List
    from products p, inventories i
    where p.product_id = i.product_id (+)
    group by p.product_id, p.product_name, p.product_description;

select * from product_dim;
-- P_W_Bridge
create table p_w_bridge as select * from inventories;

select * from p_w_bridge;
-- Warehouse_Dim
create table warehouse_dim as select distinct warehouse_id, warehouse_name
from warehouses;

select * from warehouse_dim;
-- Product_Price_Dim
    -- Promotions_Temp
create table tmp_promotions as select discount, start_date, end_date from promotions;

delete from tmp_promotions where start_date is null;
insert into tmp_promotions values ('Full Price',to_date('20040101','yyyymmdd'),to_date('20070531','yyyymmdd'));
insert into tmp_promotions values ('Full Price',to_date('20070701','yyyymmdd'),to_date('20071109','yyyymmdd'));
insert into tmp_promotions values ('Full Price',to_date('20071112','yyyymmdd'),to_date('20071130','yyyymmdd'));
insert into tmp_promotions values ('Full Price',to_date('20080101','yyyymmdd'),to_date('20080531','yyyymmdd'));
insert into tmp_promotions values ('Full Price',to_date('20080701','yyyymmdd'),to_date('20081231','yyyymmdd'));

alter table tmp_promotions add discount_value numeric(3,2);

update tmp_promotions set discount_value = 0 where upper(discount) = 'FULL PRICE';
update tmp_promotions set discount_value = 0.3 where upper(discount) = '30% OFF';
update tmp_promotions set discount_value = 0.2 where upper(discount) = '20% OFF';
update tmp_promotions set discount_value = 0.1 where upper(discount) = '10% OFF';

    -- Product_Price_Dim
create table product_price_dim as 
  select  oi.product_id, p.start_date, p.end_date, p.discount, oi.unit_price * (1 - p.discount_value) as current_price
  from (select distinct product_id, unit_price from order_items) oi, tmp_promotions p;  

select * from product_price_dim;

    -- Employee_Temp_Fact
create table employee_temp_fact as 
  select e.employee_id, d.department_id, j.job_id, l.city || '_' || c.country_id || '_' || c.region_id as location_id, 
          e.salary, e.hire_date, y.year_month_id
  from employees e, departments d, jobs j, locations l, countries c , year_month y
  where e.department_id = d.department_id and 
  e.job_id = j.job_id and 
  l.location_id = d.location_id and 
  l.country_id = c.country_id and 
  to_char(e.hire_date, 'yyyymm') <= y.year_month_id;
  
-- Employee_Fact
create table employee_fact as
select department_id, job_id, year_month_id, location_id, 
    count(*) as No_Of_Employees, 
    sum(salary) as Total_Salary
from employee_temp_fact
group by department_id, job_id, year_month_id, location_id;
    
select * from employee_fact;

-- Customer_Temp_Fact
create table customer_temp_fact as
select ct.city || '_' || ct.country_id || '_' || c.region_id as location_id,
    ct.credit_limit 
from customers ct, countries c
where ct.country_id = c.country_id;

alter table customer_temp_fact add credit_type_id varchar2(10);

update customer_temp_fact 
set credit_type_id = 'L'
where credit_limit <= 1500;
update customer_temp_fact 
set credit_type_id = 'M'
where credit_limit > 1500 and credit_limit <= 3500;
update customer_temp_fact 
set credit_type_id = 'H'
where credit_limit > 3500;

select * from customer_fact;
select * from customer_temp_fact;


-- Customer_Fact
create table customer_fact as
select location_id, credit_type_id, count(*) as No_Of_Customers
from customer_temp_fact 
group by location_id, credit_type_id;

select * from customer_fact;
-- Sales_Order_Temp_Fact
create table sales_order_temp_fact as
select o.order_date, oi.product_id, oi.unit_price, oi.quantity, 
    ct.city || '_' || ct.country_id || '_' || c.region_id as location_id,
    p.discount, o.order_mode
from orders o, promotions p, order_items oi, countries c, customers ct 
where o.order_id = oi.order_id and
    o.customer_id = ct.customer_id and
    o.promotion_id = p.promotion_id and
    ct.country_id = c.country_id;
    
alter table sales_order_temp_fact add discount_value numeric(3,2);

update sales_order_temp_fact set discount_value = 0 where upper(discount) = 'FULL PRICE';
update sales_order_temp_fact set discount_value = 0.3 where upper(discount) = '30% OFF';
update sales_order_temp_fact set discount_value = 0.2 where upper(discount) = '20% OFF';
update sales_order_temp_fact set discount_value = 0.1 where upper(discount) = '10% OFF';

alter table sales_order_temp_fact add season_id varchar2(20);

update sales_order_temp_fact 
set season_id = 'Summer' 
where to_char(order_date, 'mm') in ('12','01','02');

update sales_order_temp_fact 
set season_id = 'Autumn' 
where to_char(order_date, 'mm') in ('03','04','05');

update sales_order_temp_fact 
set season_id = 'Winter' 
where to_char(order_date, 'mm') in ('06','07','08');

update sales_order_temp_fact 
set season_id = 'Spring' 
where to_char(order_date, 'mm') in ('09','10','11');

alter table sales_order_temp_fact add order_mode_id varchar2(10);

update sales_order_temp_fact 
set order_mode_id = 'O' 
where order_mode = 'online';

update sales_order_temp_fact 
set order_mode_id = 'D' 
where order_mode = 'direct';

-- Sales_Order_Fact
create table sales_order_fact as
select season_id, product_id, to_char(order_date, 'YYYYMM') as time_id,
    location_id, order_mode_id, count(*) as No_Of_Orders,
    sum(quantity * unit_price * (1 - discount_value)) as Total_Sales
from sales_order_temp_fact
group by season_id, product_id, to_char(order_date, 'YYYYMM'),
    location_id, order_mode_id;
    
select * from sales_order_fact;

-- Star Schema Ver2

-- Department_Dim_v2
create table department_dim_v2 
as select distinct department_id, department_name
from departments;

select * from department_dim_v2;
-- Job_Dim Ver2 
create table job_dim_v2
as select distinct job_id, job_title from jobs;

select * from job_dim_v2;
-- Year_Month Ver2
create table year_month_v2 as select distinct y.year || m.month as year_month_id, y.year, m.month from month m, year y;

select * from year_month_v2;
-- Country_Dim Ver2
create table country_dim_v2 as select * from countries;

select * from country_dim_v2;
-- Region_Dim Ver2
create table region_dim_v2 as select * from regions;

select * from cus_city_dim_v2;
-- Emp_Location_Dim Ver2
create table emp_location_dim_v2 as select * from locations;

-- Cus_City_Dim Ver2
create table cus_city_dim_v2 as select distinct city, country_id from customers; 

-- Credit_Type_Dim Ver2
create table credit_type_dim_v2 (credit_type_id varchar2(10), credit_type_name varchar2(20), 
    credit_type_desc varchar2(50));
    
insert into credit_type_dim_v2 values ('L', 'low credit', 'credit <= 1500');
insert into credit_type_dim_v2 values ('M', 'medium credit', '1500 < credit <= 3500');
insert into credit_type_dim_v2 values ('H', 'high credit', 'credit > 3500');

select * from time_dim_v2;
-- Time_Dim Ver2
create table time_dim_v2 as select distinct year || month as time_id, year, month from
  (select distinct to_char(order_date, 'yyyy') as year, to_char(order_date, 'mm') as month from orders 
  union 
  select distinct year, month from year_month_v2);


-- Season_Dim Ver2
create table season_dim_v2 
(season_id varchar2(20),
season_period varchar2(20));

insert into season_dim_v2 values ('Summer', 'Dec-Feb');
insert into season_dim_v2 values ('Autumn', 'Mar-May');
insert into season_dim_v2 values ('Winter', 'Jun-Aug');
insert into season_dim_v2 values ('Spring', 'Sep-Nov');

select * from season_dim_v2;
-- Order_Mode_Dim Ver2
create table order_mode_dim_v2 (order_mode_id varchar2(10), order_mode_desc varchar2(20));
insert into order_mode_dim_v2 values ('O', 'online');
insert into order_mode_dim_v2 values ('D', 'direct');

select * from p_w_bridge_v2;
-- P_W_Bridge Ver2
create table p_w_bridge_v2 as 
select distinct i.product_id, w.warehouse_name
from inventories i, warehouses w
where i.warehouse_id = w.warehouse_id;


-- Product_Dim Ver2
    -- tmp_promotions Ver2
create table tmp_promotions_v2 as select discount, start_date, end_date from promotions;

delete from tmp_promotions_v2 where start_date is null;
insert into tmp_promotions_v2 values ('Full Price',to_date('20040101','yyyymmdd'),to_date('20070531','yyyymmdd'));
insert into tmp_promotions_v2 values ('Full Price',to_date('20070701','yyyymmdd'),to_date('20071109','yyyymmdd'));
insert into tmp_promotions_v2 values ('Full Price',to_date('20071112','yyyymmdd'),to_date('20071130','yyyymmdd'));
insert into tmp_promotions_v2 values ('Full Price',to_date('20080101','yyyymmdd'),to_date('20080531','yyyymmdd'));
insert into tmp_promotions_v2 values ('Full Price',to_date('20080701','yyyymmdd'),to_date('20081231','yyyymmdd'));

alter table tmp_promotions_v2 add discount_value numeric(3,2);

update tmp_promotions_v2 set discount_value = 0 where upper(discount) = 'FULL PRICE';
update tmp_promotions_v2 set discount_value = 0.3 where upper(discount) = '30% OFF';
update tmp_promotions_v2 set discount_value = 0.2 where upper(discount) = '20% OFF';
update tmp_promotions_v2 set discount_value = 0.1 where upper(discount) = '10% OFF';

alter table tmp_promotions_v2 add current_flag varchar2(2);

update tmp_promotions_v2 set current_flag = 'Y' where upper(discount) = 'FULL PRICE'; 
update tmp_promotions_v2 set current_flag = 'N' where upper(discount) <> 'FULL PRICE'; 

select * from tmp_promotions_v2;

create table product_dim_v2 as 
select oi.product_id, t.start_date, t.end_date, oi.unit_price, t.discount, 
    oi.unit_price * (1 - t.discount_value) as Current Price,
    t.discount, t.current_flag
from (select distinct product_id, unit_price from order_items) oi, temp_promotions t;

create table product_price_dim_v2 as 
select  oi.product_id, p.start_date, p.end_date, oi.unit_price, oi.unit_price * (1 - p.discount_value) as current_price, p.discount
from (select distinct product_id, unit_price from order_items) oi, tmp_promotions p; 

alter table product_price_dim_v2 add current_flag varchar2(2);

update product_price_dim_v2 set current_flag = 'N' where upper(discount) = 'FULL PRICE'; 
update product_price_dim_v2 set current_flag = 'Y' where upper(discount) <> 'FULL PRICE'; 

select * from product_price_dim_v2;
-- Employee_Temp_Fact Ver2
create table employee_temp_fact_v2 as 
  select e.employee_id, d.department_id, j.job_id, l.city || '_' || c.country_id || '_' || c.region_id as location_id, 
          e.salary, e.hire_date, y.year_month_id
  from employees e, departments d, jobs j, locations l, countries c , year_month y
  where e.department_id = d.department_id and 
  e.job_id = j.job_id and 
  l.location_id = d.location_id and 
  l.country_id = c.country_id and 
  to_char(e.hire_date, 'yyyymm') <= y.year_month_id;
  
-- Employee_Fact Ver2
create table employee_fact_v2 as
select department_id, job_id, year_month_id, location_id, 
    count(*) as No_Of_Employees, 
    sum(salary) as Total_Salary
from employee_temp_fact
group by department_id, job_id, year_month_id, location_id;
    
select * from employee_fact_v2;
-- Customer_Temp_Fact Ver2
create table customer_temp_fact_v2 as
select ct.city || '_' || ct.country_id || '_' || c.region_id as location_id,
    ct.credit_limit 
from customers ct, countries c
where ct.country_id = c.country_id;

alter table customer_temp_fact_v2 add credit_type_id varchar2(10);

update customer_temp_fact_v2 
set credit_type_id = 'L'
where credit_limit <= 1500;
update customer_temp_fact_v2 
set credit_type_id = 'M'
where credit_limit > 1500 and credit_limit <= 3500;
update customer_temp_fact_v2 
set credit_type_id = 'H'
where credit_limit > 3500;


-- Customer_Fact Ver2
create table customer_fact_v2 as
select location_id, credit_type_id, count(*) as No_Of_Customers
from customer_temp_fact 
group by location_id, credit_type_id;

select * from customer_fact_v2;
-- Sales_Order_Temp_Fact Ver2
create table sales_order_temp_fact_v2 as
select o.order_date, oi.product_id, oi.unit_price, oi.quantity, 
    ct.city || '_' || ct.country_id || '_' || c.region_id as location_id,
    p.discount, o.order_mode
from orders o, promotions p, order_items oi, countries c, customers ct 
where o.order_id = oi.order_id and
    o.customer_id = ct.customer_id and
    o.promotion_id = p.promotion_id and
    ct.country_id = c.country_id;
    
alter table sales_order_temp_fact_v2 add discount_value numeric(3,2);

update sales_order_temp_fact_v2 set discount_value = 0 where upper(discount) = 'FULL PRICE';
update sales_order_temp_fact_v2 set discount_value = 0.3 where upper(discount) = '30% OFF';
update sales_order_temp_fact_v2 set discount_value = 0.2 where upper(discount) = '20% OFF';
update sales_order_temp_fact_v2 set discount_value = 0.1 where upper(discount) = '10% OFF';

alter table sales_order_temp_fact_v2 add season_id varchar2(20);

update sales_order_temp_fact_v2 
set season_id = 'Summer' 
where to_char(order_date, 'mm') in ('12','01','02');

update sales_order_temp_fact_v2 
set season_id = 'Autumn' 
where to_char(order_date, 'mm') in ('03','04','05');

update sales_order_temp_fact_v2 
set season_id = 'Winter' 
where to_char(order_date, 'mm') in ('06','07','08');

update sales_order_temp_fact_v2 
set season_id = 'Spring' 
where to_char(order_date, 'mm') in ('09','10','11');

alter table sales_order_temp_fact_v2 add order_mode_id varchar2(10);

update sales_order_temp_fact_v2 
set order_mode_id = 'O' 
where order_mode = 'online';

update sales_order_temp_fact_v2 
set order_mode_id = 'D' 
where order_mode = 'direct';

-- Sales_Order_Fact Ver2
create table sales_order_fact_v2 as
select season_id, product_id, to_char(order_date, 'YYYYMM') as time_id,
    location_id, order_mode_id, count(*) as No_Of_Orders,
    sum(quantity * unit_price * (1 - discount_value)) as Total_Sales
from sales_order_temp_fact_v2
group by season_id, product_id, to_char(order_date, 'YYYYMM'),
    location_id, order_mode_id;
    
select * from sales_order_fact_v2

-- C.4.Report1

SELECT decode(GROUPING(order_mode_id), 1, 'All Orders', order_mode_id) AS order_mode, decode(GROUPING(season_id), 1, 'All Seasons', season_id) AS season, count(order_mode_id) AS number_sold
FROM sales_order_fact
GROUP BY CUBE (order_mode_id, season_id);

-- c.4.Report2

SELECT decode(GROUPING(country_id), 1, 'All Coutries', country_id), decode(GROUPING(level_no), 1, 'All Levels', level_no), count(level_no)
FROM customer_fact
GROUP BY CUBE(country_id, level_no);


-- c.4.Report3

Select * from(
select s.product_id, t.year, l.country_name, sum(s.total_sales),rank() over (order by sum(s.total_sales) desc) as custom_rank, percent_rank() over (order by sum(s.total_sales) desc) as "Percent Rank"
from sales_order_fact s, time_dim t, location_dim l
where s.time_id = t.time_id AND s.location_id  = l.location_id AND t.year = '2008'
group by s.product_id, t.year, l.country_name)
where "Percent Rank" < 0.1;

-- c.4.Report4

Select l.country_name, d.department_id, sum(e.total_salary),rank() over (order by sum(e.total_salary) desc) as custom_rank, percent_rank() over (order by sum(e.total_salary) desc) as "Percent Rank"
from employee_fact e, location_dim l, department_dim d
where e.location_id = l.location_id AND e.department_id = d.department_id
group by l.country_name, d.department_id;

--c.4.Report5

select ti.year,mo.order_MODE_ID,sum(ord.total_sales) as Total,
RANK() OVER (PARTITION BY ti.year
ORDER BY SUM(ord.total_sales)DESC) AS RANK_BY_YEAR,
RANK() OVER (PARTITION BY mo.order_mode_id
ORDER BY SUM(ord.total_sales)DESC) AS RANK_BY_MODE
FROM sales_order_fact ord,order_mode_dim mo,time_dim ti
where ord.ORDER_MODE_ID=mo.order_MODE_ID and ord.time_id=ti.time_id
group by ti.year, mo.order_mode_id;


--c.4.Report6

select yea.year, jobs.job_title, sum(emp.total_salary) as Total,
RANK() OVER (PARTITION BY yea.year
ORDER BY SUM(emp.total_salary)DESC) AS RANK_BY_YEAR,
RANK() OVER (PARTITION BY jobs.job_title
ORDER BY SUM(emp.total_salary)DESC) AS RANK_BY_job
FROM employee_fact emp,year_month yea,job_dim jobs
where emp.job_id=jobs.job_id and emp.year_month_id=yea.year_month_id
group by yea.year,jobs.job_title;

--c.4.Report7

select sea.season_period,mo.order_MODE_ID,sum(ord.total_sales) as Total,
TO_CHAR(SUM(SUM(ORD.TOTAL_SALES)) OVER (PARTITION BY SEA.SEASON_PERIOD ORDER BY SEA.SEASON_PERIOD ROWS UNBOUNDED PRECEDING),'9,999,999.99') 
AS TOTAL_SALES_SEASON,
TO_CHAR(SUM(SUM(ORD.TOTAL_SALES)) OVER (PARTITION BY MO.ORDER_MODE_ID ORDER BY MO.ORDER_MODE_ID ROWS UNBOUNDED PRECEDING),'9,999,999.99') 
AS TOTAL_SALES_MODE
FROM sales_order_fact ord,order_mode_dim mo,season_dim sea
where ord.ORDER_MODE_ID=mo.order_MODE_ID and ord.season_id=sea.season_id
GROUP BY SEA.SEASON_PERIOD, mo.order_MODE_ID;

--c.4.Report 8

select jobs.job_title,dep.DEPARTMENT_NAME,sum(emp.TOTAL_SALARY) as Total,
TO_CHAR(SUM(SUM(emp.total_salary)) OVER (PARTITION BY jobs.JOB_TITLE ORDER BY jobs.JOB_TITLE ROWS UNBOUNDED PRECEDING),'9,999,999.99') 
AS TOTAL_SALARY_JOB,
TO_CHAR(SUM(SUM(emp.total_salary)) OVER (PARTITION BY dep.DEPARTMENT_NAME ORDER BY dep.DEPARTMENT_NAME ROWS UNBOUNDED PRECEDING),'9,999,999.99') 
AS TOTAL_SALES_MODE
FROM employee_fact emp,department_dim dep,job_dim jobs
where emp.DEPARTMENT_ID=dep.DEPARTMENT_ID and emp.JOB_ID=jobs.JOB_ID group by jobs.job_title, dep.DEPARTMENT_NAME;

-- c.5. Report1

SELECT decode(GROUPING(order_mode_id), 1, 'All Orders', order_mode_id) AS order_mode, decode(GROUPING(season_id), 1, 'All Seasons', season_id) AS season, count(order_mode_id) AS number_sold
FROM sales_order_fact
GROUP BY CUBE (order_mode_id, season_id);

--c.5. Report2

SELECT decode(GROUPING(country_id), 1, 'All Coutries', country_id), decode(GROUPING(level_no), 1, 'All Levels', level_no), count(level_no)
FROM customer_fact
GROUP BY CUBE(country_id, level_no);

--c.5. Report3
--1
Select * from(
select s.product_id, t.year, l.country_name, sum(s.total_sales),rank() over (order by sum(s.total_sales) desc) as custom_rank, percent_rank() over (order by sum(s.total_sales) desc) as "Percent Rank"
from sales_order_fact s, time_dim t, location_dim l
where s.time_id = t.time_id AND s.location_id  = l.location_id AND t.year = '2008'
group by s.product_id, t.year, l.country_name)
where "Percent Rank" < 0.1;

--2
Select * from(
select /*+ USE_MERGE (s l) */ s.product_id, t.year, l.country_name, sum(s.total_sales),rank() over (order by sum(s.total_sales) desc) as custom_rank, percent_rank() over (order by sum(s.total_sales) desc) as "Percent Rank"
from sales_order_fact s, time_dim t, location_dim l
where s.time_id = t.time_id AND s.location_id  = l.location_id AND t.year = '2008'
group by s.product_id, t.year, l.country_name)
where "Percent Rank" < 0.1;

--c.5.Report 4
--1
Select * from(
select s.product_id, t.year, l.country_name, sum(s.total_sales),rank() over (order by sum(s.total_sales) desc) as custom_rank, percent_rank() over (order by sum(s.total_sales) desc) as "Percent Rank"
from sales_order_fact s, time_dim t, location_dim l
where s.time_id = t.time_id AND s.location_id  = l.location_id AND t.year = '2008'
group by s.product_id, t.year, l.country_name)
where "Percent Rank" < 0.1
--2
Select /*+ use_nl (e l) */ l.country_name, d.department_id, sum(e.total_salary),rank() over (order by sum(e.total_salary) desc) as custom_rank, percent_rank() over (order by sum(e.total_salary) desc) as "Percent Rank"
from employee_fact e, location_dim l, department_dim d
where e.location_id = l.location_id AND e.department_id = d.department_id
group by l.country_name, d.department_id;

--c.5.Report 5
--1
select ti.year,mo.order_MODE_ID,sum(ord.total_sales) as Total,
RANK() OVER (PARTITION BY ti.year
ORDER BY SUM(ord.total_sales)DESC) AS RANK_BY_YEAR,
RANK() OVER (PARTITION BY mo.order_mode_id
ORDER BY SUM(ord.total_sales)DESC) AS RANK_BY_MODE
FROM sales_order_fact ord,order_mode_dim mo,time_dim ti
where ord.ORDER_MODE_ID=mo.order_MODE_ID and ord.time_id=ti.time_id
group by ti.year, mo.order_mode_id;

--2
select  /*+ USE_MERGE (ord mo) */ ti.year,mo.order_MODE_ID,sum(ord.total_sales) as Total,
RANK() OVER (PARTITION BY ti.year
ORDER BY SUM(ord.total_sales)DESC) AS RANK_BY_YEAR,
RANK() OVER (PARTITION BY mo.order_mode_id
ORDER BY SUM(ord.total_sales)DESC) AS RANK_BY_MODE
FROM sales_order_fact ord,order_mode_dim mo,time_dim ti
where ord.ORDER_MODE_ID=mo.order_MODE_ID and ord.time_id=ti.time_id
group by ti.year, mo.order_mode_id;

--c.5.Report6
--1
select yea.year, jobs.job_title, sum(emp.total_salary) as Total,
RANK() OVER (PARTITION BY yea.year
ORDER BY SUM(emp.total_salary)DESC) AS RANK_BY_YEAR,
RANK() OVER (PARTITION BY jobs.job_title
ORDER BY SUM(emp.total_salary)DESC) AS RANK_BY_job
FROM employee_fact emp,year_month yea,job_dim jobs
where emp.job_id=jobs.job_id and emp.year_month_id=yea.year_month_id
group by yea.year,jobs.job_title;

--2
select  /*+ USE_NL (emp jobs) */ yea.year, jobs.job_title, sum(emp.total_salary) as Total,
RANK() OVER (PARTITION BY yea.year
ORDER BY SUM(emp.total_salary)DESC) AS RANK_BY_YEAR,
RANK() OVER (PARTITION BY jobs.job_title
ORDER BY SUM(emp.total_salary)DESC) AS RANK_BY_job
FROM employee_fact emp,year_month yea,job_dim jobs
where emp.job_id=jobs.job_id and emp.year_month_id=yea.year_month_id
group by yea.year,jobs.job_title;

--c.5.Report7
--1
select sea.season_period,mo.order_MODE_ID,sum(ord.total_sales) as Total,
TO_CHAR(SUM(SUM(ORD.TOTAL_SALES)) OVER (PARTITION BY SEA.SEASON_PERIOD ORDER BY SEA.SEASON_PERIOD ROWS UNBOUNDED PRECEDING),'9,999,999.99') 
AS TOTAL_SALES_SEASON,
TO_CHAR(SUM(SUM(ORD.TOTAL_SALES)) OVER (PARTITION BY MO.ORDER_MODE_ID ORDER BY MO.ORDER_MODE_ID ROWS UNBOUNDED PRECEDING),'9,999,999.99') 
AS TOTAL_SALES_MODE
FROM sales_order_fact ord,order_mode_dim mo,season_dim sea
where ord.ORDER_MODE_ID=mo.order_MODE_ID and ord.season_id=sea.season_id
GROUP BY SEA.SEASON_PERIOD, mo.order_MODE_ID;

--2
select /*+ USE_NL (ord mo) */ sea.season_period,mo.order_MODE_ID,sum(ord.total_sales) as Total,
TO_CHAR(SUM(SUM(ORD.TOTAL_SALES)) OVER (PARTITION BY SEA.SEASON_PERIOD ORDER BY SEA.SEASON_PERIOD ROWS UNBOUNDED PRECEDING),'9,999,999.99') 
AS TOTAL_SALES_SEASON,
TO_CHAR(SUM(SUM(ORD.TOTAL_SALES)) OVER (PARTITION BY MO.ORDER_MODE_ID ORDER BY MO.ORDER_MODE_ID ROWS UNBOUNDED PRECEDING),'9,999,999.99') 
AS TOTAL_SALES_MODE
FROM sales_order_fact ord,order_mode_dim mo,season_dim sea
where ord.ORDER_MODE_ID=mo.order_MODE_ID and ord.season_id=sea.season_id
GROUP BY SEA.SEASON_PERIOD, mo.order_MODE_ID;

--c.5.Report8
--1
select jobs.job_title,dep.DEPARTMENT_NAME,sum(emp.TOTAL_SALARY) as Total,
TO_CHAR(SUM(SUM(emp.total_salary)) OVER (PARTITION BY jobs.JOB_TITLE ORDER BY jobs.JOB_TITLE ROWS UNBOUNDED PRECEDING),'9,999,999.99') 
AS TOTAL_SALARY_JOB,
TO_CHAR(SUM(SUM(emp.total_salary)) OVER (PARTITION BY dep.DEPARTMENT_NAME ORDER BY dep.DEPARTMENT_NAME ROWS UNBOUNDED PRECEDING),'9,999,999.99') 
AS TOTAL_SALES_MODE
FROM employee_fact emp,department_dim dep,job_dim jobs
where emp.DEPARTMENT_ID=dep.DEPARTMENT_ID and emp.JOB_ID=jobs.JOB_ID group by jobs.job_title, dep.DEPARTMENT_NAME;

--2


