
-----CASE STUDY: RETAIL DATA ANALYSIS---------------


----------**** DATA PREPARATION AND UNDERSTANDING ****----------------
/* 
--Q1)  
  Total number of recordes in Customer table: 5647
  Total number of recordes in Transaction table: 23,053
  Total number of recordes in prod_cat_info table: 23
  */ 

--Query
  SELECT C.*, T.*, PCI.*
  FROM
  (SELECT COUNT(*) AS _rowsCustomer
  FROM Customer ) AS C,
 
  (SELECT COUNT(*) AS _rowsTransaction  
  FROM Transactions) AS T,

  (SELECT COUNT(*) AS _rowsProd_cat_info
  FROM  prod_cat_info ) AS PCI
 
--Q2) 2177

--Query:
SELECT COUNT(Qty) AS _return
FROM Transactions
WHERE Qty<0


--Q3) DATE(tran_date) UPDATED AS REQUIRED.


--Q4)

SELECT DATEDIFF(DAY, MIN(tran_date), MAX(tran_date)) AS _RangeOfDay,
DATEDIFF(MONTH, MIN(tran_date), MAX(tran_date)) AS _RangeOfMonth,
DATEDIFF(YEAR, MIN(tran_date), MAX(tran_date)) AS _RangeOfYear
FROM Transactions


--Q5) Books

--Query:
SELECT prod_cat FROM prod_cat_info
WHERE prod_subcat= 'DIY'



--------------------- ***** DATA ANALYSIS****-------------------------
--Q1)

SELECT TOP 1 Store_type, COUNT(Store_type) AS [#ofTimesUsed] FROM Transactions
GROUP BY Store_type
ORDER BY 2 DESC

--Q2) 
SELECT 
SUM(CASE WHEN UPPER(Gender)= 'M' THEN 1 ELSE 0 END) AS Male, 
SUM(CASE WHEN UPPER(Gender)= 'F' THEN 1 ELSE 0 END) AS Female
FROM Customer 

--Q3)

SELECT TOP 1 city_code, Count(customer_Id) AS totalCustomer FROM Customer
GROUP BY city_code
ORDER BY totalCustomer DESC

--Q4)

SELECT COUNT(prod_subcat) AS TotalSubcatForBooks
FROM prod_cat_info
WHERE prod_cat='Books';

--5)

SELECT Max(ABS(Qty)) AS _MaxQuantity
FROM Transactions

--Q6)

SELECT SUM(TRevenue) AS TotalRevenue
FROM
(
SELECT SUM(total_amt) AS TRevenue
FROM Transactions AS T JOIN prod_cat_info AS PCI ON T.prod_cat_code=PCI.prod_cat_code
WHERE prod_cat IN ('Electronics', 'Books')
)
AS T

--Q7)

---- --excluding negative values from Qty column----

SELECT SUM(__TotalTId)
FROM
(
SELECT Qty, COUNT(transaction_id) AS __TotalTId
FROM Transactions AS T, Customer AS C
WHERE Qty>0 AND T.cust_id=C.customer_Id
GROUP BY Qty
HAVING COUNT(transaction_id)>10
) AS T

--Q8)

SELECT SUM(total_amt) AS TotalRevenue
FROM Transactions AS T JOIN prod_cat_info AS PCI ON T.prod_cat_code=PCI.prod_cat_code
WHERE prod_cat IN ('Electronics', 'Clothing') AND Store_type Like 'Flag%' 


--Q9)

SELECT prod_subcat, SUM(total_amt) AS _sum
FROM Transactions AS T JOIN prod_cat_info AS PCI ON T.prod_cat_code=PCI.prod_cat_code
JOIN Customer AS C ON T.cust_id=C.customer_Id
WHERE Gender='M' AND prod_cat Like 'Ele%'
GROUP BY prod_subcat

--Q10)
 
 SELECT prod_subcat, SUM(total_amt) AS _sum, 
 total_amt*100/(SELECT SUM(total_amt) FROM Transactions) AS [% of Sales]
 FROM Transactions AS T, prod_cat_info AS PCI
 WHERE T.prod_cat_code=PCI.prod_cat_code 
 GROUP BY prod_subcat, total_amt
 ORDER BY _sum DESC
 OFFSET 0 ROWS
 FETCH FIRST 5 ROWS ONLY;

--Q11)

SELECT SUM(_sum) AS _netRevenue
FROM
(
SELECT SUM(total_amt) AS _sum
FROM Transactions AS T JOIN Customer AS C ON T.cust_id=C.customer_Id
GROUP BY total_amt, DOB, tran_date
HAVING (DATEDIFF(Year, DOB, GETDATE()) BETWEEN 25 AND 35) AND (tran_date BETWEEN DATEADD(day, -30, MAX(tran_date)) AND MAX(tran_date)) 
) AS T

--Q12)
SELECT prod_cat, COUNT(prod_cat) AS [#ofreturn]
FROM
(
SELECT prod_cat, MAX(Qty) AS _maxQty, tran_date FROM prod_cat_info AS PCI , Transactions AS T
WHERE T.prod_cat_code=PCI.prod_cat_code AND Qty<0 
GROUP BY prod_cat, Qty, tran_date 
HAVING MAX(tran_date)>= (SELECT DATEADD(month, -3, MAX(tran_date))FROM Transactions)
ORDER BY _maxQty
OFFSET 0 ROWS

) AS T
GROUP BY prod_cat
ORDER BY 2 DESC
OFFSET 0 ROWS
FETCH FIRST 1 ROWS ONLY

--Q13)

SELECT TOP 1 Store_type, MAX(Qty) AS _maxQty, SUM(total_amt) AS _MaxSales
FROM Transactions
GROUP BY Store_type, qty
ORDER BY 3 DESC, 2

--Q14)

SELECT prod_subcat, AVG(total_amt) AS _avgRevenue
FROM prod_cat_info AS PCI , Transactions AS T
WHERE T.prod_cat_code=PCI.prod_cat_code
GROUP BY prod_subcat
HAVING AVG(total_amt)>(SELECT AVG(total_amt) AS _avgRevenue FROM Transactions)


--Q15)

SELECT TOP 5 prod_cat, prod_subcat, Qty, AVG(total_amt) AS _avgRevenue, SUM(total_amt) AS _totalSum
FROM prod_cat_info AS PCI , Transactions AS T
WHERE T.prod_cat_code=PCI.prod_cat_code
GROUP BY prod_subcat, Qty, prod_cat
ORDER BY Qty DESC

-----------------------------------END---------------------------------------------------------------------
