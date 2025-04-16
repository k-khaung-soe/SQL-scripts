use ADWorks_oord;
--Net Sales of products after returns.
with sales
as
(

Select orderdate, 
		s.territorykey [Tkey],
		t.Region,t.Country,
		s.productkey Pkey, 
		p.productname product,
		p.modelname model,
		p.productcost [cost],
		p.productprice-p.productcost [Profit],
		sum(orderquantity) as total_units_sold
		
from 
(select * from sales_2015
union
select * from sales_2016
union
select * from sales_2017) s
left join Products p
on s.productkey=p.productkey

left join dbo.territories t
on s.TerritoryKey= t.salesterritorykey



group by orderdate,
s.territorykey,t.region,t.country,
s.productkey,p.productname,p.modelname,p.productcost, (p.productprice-p.productcost)
)

select --orderdate,
Product, Model ,
region,country,
cast(cost as decimal(18,2)) Cost, cast(profit as  decimal(18,2)) Profit,
sum(total_units_sold) UnitsSolds,
ISNULL(sum(r.ReturnQuantity),0) ReturnedUnits,
cast(((cost)* (sum(total_units_sold)-ISNULL(sum(r.ReturnQuantity),0))) +( profit * (sum(total_units_sold)-ISNULL(sum(r.ReturnQuantity),0))) as decimal(18,2))
NetSales
from sales
left join Returns r
on r.ReturnDate= orderdate and
 r.territoryKey=Tkey
and r.productkey=Pkey
group by --orderdate, 
Product, Model,Region, Country,cost,profit
order by UnitsSolds desc

