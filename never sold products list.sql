USE ADWorks_oord
--Products that are never sold.
SELECT p.ProductSKU,
p.ModelName,
p.ProductName,
p.ProductCost,
p.ProductPrice
FROM
(SELECT DISTINCT productkey FROM products
EXCEPT
SELECT DISTINCT productkey FROM
(SELECT DISTINCT productkey FROM Sales_2015
UNION
SELECT DISTINCT productkey FROM Sales_2016
UNION
SELECT DISTINCT productkey FROM sales_2017
) sales
) unsold 
LEFT JOIN products p 
ON unsold.ProductKey= p.ProductKey