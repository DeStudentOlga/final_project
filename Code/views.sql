--Создание представлений (витрин)

-- Представление (витрина) corporate_payments

-- Создание вспомогательных представлений

-- Представление для дебетовых транзакций счета
create or replace view dbt as
(
	select accountid, accountdb, accountcr, amount, currency, dateop, comment
	from operation join account on accountdb=accountid
)

-- Представление для кредитовых транзакций счета
create or replace view crt as
(
	select accountid, accountdb, accountcr, amount, currency, dateop, comment
	from operation join account on accountcr=accountid
)

-- Создание итогового представления (витрины) corporate_payments
create view corporate_payments as(
with dbt_ as (
	select distinct accountid, sum(amount*rate) over (partition by accountdb) as "PaymentAmt", 
	sum(amount*rate) filter (where accountcr in (select accountid from account where accountnum like '40702%')) 
	over(partition by accountdb) as "TaxAmt",
	sum(amount*rate) filter (where comment not like any (array(select pattern from list2)))  
	over(partition by accountdb) as "CarsAmt"
	from dbt join rate using (currency)
	where ratedate=(select max(ratedate) from rate)
),
crt_ as(
	select distinct accountid, dateop, sum(amount*rate) over (partition by accountcr) as "EnrollementAmt",
	sum(amount*rate) filter (where accountdb in (select accountid from account where accountnum like '40802%')) 
	over(partition by accountcr) as "ClearAmt",
	sum(amount*rate) filter (where comment like any (array(select pattern from list2))) 
	over(partition by accountcr) as "FoodAmt"
	from crt join rate using (currency)
	where ratedate=(select max(ratedate) from rate)
)
select accountid as "AccountId", clientid as "ClientId", "PaymentAmt", "EnrollementAmt", "TaxAmt", "ClearAmt", "CarsAmt","FoodAmt", dateop as "CutoffDt"
from dbt_ full join crt_ using (accountid) join account using (accountid)
	);
	
-- Проверка работы представления
select * from corporate_payments;
	
-- Представление (витрина) corporate_account

create view corporate_account as(
select "AccountId", accountnum as "AccountNum", dateopen as "DateOpen", "ClientId", clientname as "ClientName", 
coalesce("PaymentAmt",0) + coalesce("EnrollementAmt",0) as "TotalAmt",  "CutoffDt"
from corporate_payments join account on "AccountId"=accountid join clients using(clientid));

-- Проверка работы представления
select * from corporate_account;

-- Представление (витрина) corporate_info

create or replace view corporate_info as (
select clientid, clients.clientname, type, form, registerdate, sum("TotalAmt") over (partition by clientid, "CutoffDt") as "TotalAmt",  "CutoffDt"
from clients join corporate_account on clientid="ClientId"
order by clientid)

-- Проверка работы представления
select * from corporate_info;