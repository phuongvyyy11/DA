--q1
select * from SALES_DATASET_RFM_PRJ;

ALTER TABLE SALES_DATASET_RFM_PRJ 
ALTER COLUMN ordernumber TYPE integer USING (trim(ordernumber)::integer);

ALTER TABLE SALES_DATASET_RFM_PRJ 
ALTER COLUMN quantityordered TYPE integer USING (trim(quantityordered)::integer);

ALTER TABLE SALES_DATASET_RFM_PRJ 
ALTER COLUMN priceeach TYPE numeric USING (trim(priceeach)::numeric);

ALTER TABLE SALES_DATASET_RFM_PRJ 
ALTER COLUMN orderlinenumber TYPE integer USING (trim(orderlinenumber)::integer);

ALTER TABLE SALES_DATASET_RFM_PRJ 
ALTER COLUMN sales TYPE numeric USING (trim(sales)::numeric);

ALTER TABLE SALES_DATASET_RFM_PRJ 
ALTER COLUMN orderdate TYPE date USING (trim(orderdate):: date);

ALTER TABLE SALES_DATASET_RFM_PRJ 
ALTER COLUMN msrp TYPE integer USING (trim(msrp):: integer);

--q2
select 
*
from SALES_DATASET_RFM_PRJ
where 
ORDERNUMBER is null or QUANTITYORDERED is null or PRICEEACH is null or ORDERLINENUMBER is null
or SALES is null or ORDERDATE  is null

--q3
alter table SALES_DATASET_RFM_PRJ
add column CONTACTFIRSTNAME varchar(100);

update SALES_DATASET_RFM_PRJ
set CONTACTFIRSTNAME = UPPER(LEFT(CONTACTFULLNAME,1)) || SUBSTRING(contactfullname, 2, position('-' in contactfullname)-2);

alter table SALES_DATASET_RFM_PRJ
add column CONTACTLASTNAME varchar(100);

update SALES_DATASET_RFM_PRJ
set CONTACTLASTNAME = UPPER(LEFT(substring(contactfullname, position('-' in contactfullname)+1,
length(contactfullname)-length(contactfirstname)),1)) || right(substring(contactfullname, position('-' in contactfullname)+1,
length(contactfullname)-length(contactfirstname)), length(substring(contactfullname, position('-' in contactfullname)+1,
length(contactfullname)-length(contactfirstname)))-1)

--q4
alter table SALES_DATASET_RFM_PRJ
add column QTR_ID integer,
add column MONTH_ID integer,
add column YEAR_ID integer;

update SALES_DATASET_RFM_PRJ
set QTR_ID = extract(quarter from orderdate);

update SALES_DATASET_RFM_PRJ
set MONTH_ID = extract(month from orderdate);

update SALES_DATASET_RFM_PRJ
set YEAR_ID = extract(year from orderdate);

--q5
--box plot
with tb as(
select
q1-1.5*IQR as min,
q3+1.5*IQR as max
from(
select
percentile_cont(0.25) within group (order by quantityordered) as q1,
percentile_cont(0.75) within group (order by quantityordered) as q3,
percentile_cont(0.75) within group (order by quantityordered) - percentile_cont(0.25) within group (order by quantityordered) 
as IQR
from SALES_DATASET_RFM_PRJ)
	)
select * from SALES_DATASET_RFM_PRJ
where quantityordered < (select min from tb) or quantityordered > (select max from tb)
detele from SALES_DATASET_RFM_PRJ
where quantityordered in (select quantityordered from outliner)
--
--zscore
with tb as 
(
select 
orderdate,
quantityordered,
(select avg(quantityordered) from SALES_DATASET_RFM_PRJ) as avg,
(select stddev(quantityordered) from SALES_DATASET_RFM_PRJ) as stddev
from SALES_DATASET_RFM_PRJ
),
outliner as (
select 
orderdate,
quantityordered,
(quantityordered - avg)/stddev as zscore
from tb
where abs((quantityordered - avg)/stddev) > 3)
detele from SALES_DATASET_RFM_PRJ
where quantityordered in (select quantityordered from outliner)

--q6
create table SALES_DATASET_RFM_PRJ_CLEAN as (
with tb as 
(
select 
orderdate,
quantityordered,
(select avg(quantityordered) from SALES_DATASET_RFM_PRJ) as avg,
(select stddev(quantityordered) from SALES_DATASET_RFM_PRJ) as stddev
from SALES_DATASET_RFM_PRJ
),
outliner as (
select 
orderdate,
quantityordered,
(quantityordered - avg)/stddev as zscore
from tb
where abs((quantityordered - avg)/stddev) > 3)
update SALES_DATASET_RFM_PRJ
set quantityordered = (select avg(quantityordered) from SALES_DATASET_RFM_PRJ 
					   where quantityordered in (select quantityordered from outliner)
)
