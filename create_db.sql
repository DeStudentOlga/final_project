--создаем таблицу клиенты
create table clients (
clientid integer not null,
clientname character varying,
type char,
form character varying,
registerdate date,
constraint clients_pk primary key (ClientId));

--копируем данные о клиентах из csv файла
copy clients from '/Users/ovstoyanova/Clients.csv' DELIMITER ';' CSV HEADER;

--проверяем корректность загрузки данных
select * from clients;

--создаем таблицу счетов
create table account(
accountid integer not null,
accountnum character(20),
clientid integer,
dateopen date,
constraint account_pk primary key(accountid),
constraint account_clients_fk foreign key (clientid) references clients(clientid)
on update cascade on delete restrict)

--копируем данные о счетах из csv файла
copy account from '/Users/ovstoyanova/Account.csv' DELIMITER ';' CSV HEADER;

--проверяем корректность загрузки данных
select * from account;

--создаем таблицу операций
create table operation (
   accountdb	  integer,
   accountcr	  integer,
   dateop	  date,
   amount	  character varying (20),
   currency	  character varying (3),
   comment character varying,
constraint operation_acc_fk1 foreign key (accountdb) references account(accountid)
	on update cascade on delete restrict,
constraint operation_acc_fk2 foreign key (accountcr) references account(accountid)
	on update cascade on delete restrict);

--копируем данные об операциях из csv файла
copy operation from '/Users/ovstoyanova/Operation.csv' DELIMITER ';' CSV HEADER;

--проверяем корректность загрузки данных
select * from operation;

--заменяем разделитель десятичных разрядов
update operation
set amount=replace(amount,',','.');

--заменяем тип столбца amount
alter table operation
alter column amount type numeric(10,2) using amount::numeric(10,2);

--создаем таблицу валют
create table rate (
	currency	character varying (3),
	rate	character varying (50),
	ratedate	date);
	
--копируем данные в таблицу валют
copy rate from '/Users/ovstoyanova/Rate.csv' DELIMITER ';' CSV HEADER;

--проверяем корректность загрузки данных
select * from rate;

--заменяем разделитель десятичных разрядов
update rate
set rate=replace(rate,',','.');

--заменяем тип столбца amount
alter table rate
alter column rate type numeric(10,2) using rate::numeric(10,2);