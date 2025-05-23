---Author: Kyaw Htin Khaung Soe
---Objective: Top 10 Products sold in each region


USE [AdventureWorksDW]
GO
/****** Object:  StoredProcedure [dbo].[spTop10ProductByRegion]    Script Date: 5/9/2025 4:11:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spTop10ProductByRegion]
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
	@fromdate as date,
	@todate as date,
	@region as varchar(25)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 


with sales_cte
as
(
select * from
(select orderdate,
productkey,
salesterritorykey,
sum(orderquantity) qty
from dbo.factresellersales
group by orderdate,productkey,salesterritorykey
union
select orderdate,
productkey,
salesterritorykey,
sum(orderquantity) qty
from dbo.FactInternetSales
group by orderdate,productkey,salesterritorykey
)a1
where OrderDate between @FromDate and @Todate
)

select top(10)
p.EnglishProductName [Product Name],
psc.EnglishProductSubcategoryName [Product Subcategory],
pc.EnglishProductCategoryName [Product Category],
t.SalesTerritoryRegion [Region],
t.SalesTerritoryCountry Country,
t.SalesTerritoryGroup,
total_qty [Units Sold]
from
(
select productkey,
SalesTerritoryKey,
sum(qty) total_qty
from sales_cte
group by productkey, SalesTerritoryKey

) s

left join dbo.dimproduct p on p.productkey= s.ProductKey
left join dbo.dimProductSubcategory psc on p.ProductSubcategoryKey=psc.ProductSubcategoryKey
left join dbo.dimProductCategory pc on psc.ProductCategoryKey= pc.ProductCategoryKey
left join dbo.DimSalesTerritory t on t.SalesTerritoryKey=s.SalesTerritoryKey


where SalesTerritoryRegion in (select * from string_split(@region,','))

order by total_qty desc
END
