                                 #CREATE DATABASE
                                 
CREATE DATABASE retail_analysis;

                                   #CREATE TABLE
CREATE TABLE online_retails(
InvoiceNumber VARCHAR(20),
StockCode VARCHAR(20),
Description TEXT,
Quantity INT,
InvoiceDate DATETIME,
Unitprice DECIMAL(10,2),
CustomerID INT,
Country VARCHAR(50));

                            #DATA IMPORT
                            
LOAD DATA LOCAL INFILE 'D:\Online Retail Ecommerce.csv'
INTO TABLE online_retails
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


                          #SCHEMA CORRECTION
SET GLOBAL local_infile = 1;

SELECT distinct COUNT(*) FROM online_retails WHERE CustomerID='';

SELECT COUNT(*)FROM online_retails WHERE Quantity <0;

SELECT COUNT(*)FROM online_retails WHERE InvoiceNumber LIKE'C%';

SELECT min(INVOICEDATE),max(INVOICEDATE)FROM online_retails;

SHOW warnings;

SELECT  distinct COUNT(*) FROM online_retails;

SELECT  count(*) FROM online_retails;

SELECT * FROM online_retails;

                          # DATA CLEANING
  
  SET SQL_SAFE_UPDATES=0;
  
DELETE FROM online_retails WHERE CustomerID='';     #REMOVE NULL VALUES
SELECT distinct COUNT(*) FROM online_retails WHERE CustomerID='' OR CustomerID IS null;

DELETE FROM online_retails WHERE InvoiceNumber LIKE'C%';   #REMOVE CANCELLED ORDERS
SELECT COUNT(*)FROM online_retails WHERE InvoiceNumber LIKE'C%';

DELETE FROM online_retails WHERE Quantity<=0;    #REMOVE RETURNS
SELECT COUNT(*)FROM online_retails WHERE Quantity <0;

DELETE FROM online_retails WHERE Unitprice<=0; #REMOVE ZERO PRICE PRODUCTS.
SELECT min(INVOICEDATE),max(INVOICEDATE)FROM online_retails;

 UPDATE online_retails SET InvoiceDate=str_to_date(InvoiceDate,'%d-%m-%Y %H:%i');  #CHANGE DATE FORMAT

SELECT  count(*) FROM online_retails;
SELECT  * FROM online_retails;

DESCRIBE online_retails;

                                   #CREATE REVENUE COLUMN

ALTER TABLE online_retails 
ADD COLUMN Revenue DECIMAL(10,2);
  
UPDATE online_retails
SET Revenue = Quantity * Unitprice;

                                          # CREATE RFM TABLE
CREATE TABLE RFM_Table AS SELECT CustomerID,
DATEDIFF('2011-12-10', MAX(invoicedate)) AS Recency,
COUNT(DISTINCT InvoiceNumber) AS Frequency,
SUM(Revenue) AS Monetary
FROM Online_retails
GROUP BY CustomerID;

SELECT COUNT(*) FROM rfm_table;

                                    #RFM SCORES
CREATE TABLE RFM_SCORES AS
SELECT
CUSTOMERID,
RECENCY,
FREQUENCY,
MONETARY,
NTILE(5) OVER (ORDER BY RECENCY DESC) AS RECENCY_SCORE,
NTILE(5) OVER (ORDER BY FREQUENCY DESC) AS FREQUENCY_SCORE,
NTILE(5) OVER (ORDER BY MONETARY DESC) AS MONETARY_SCORE
FROM rfm_table;
SELECT* FROM FRM_SCORES;
                                   #FINAL RFM SCORE
ALTER TABLE rfm_scores
ADD COLUMN RFM_SCORE VARCHAR(10);

UPDATE rfm_scores
SET RFM_SCORE= CONCAT(RECENCY_SCORE,FREQUENCY_SCORE,MONETARY_SCORE);

                                  #CUSTOMER SEGMENTATION
ALTER TABLE rfm_scores
ADD COLUMN SEGMENT VARCHAR(20);

UPDATE rfm_scores
SET SEGMENT =
CASE
WHEN RECENCY_SCORE >=4 AND FREQUENCY_SCORE >=4 AND MONETARY_SCORE >=4 THEN 'CHAMPIONS'
WHEN FREQUENCY_SCORE >=4 THEN'LOYAL CUSTOMER'
WHEN RECENCY_SCORE >=4 THEN 'POTENTIAL LOYALISTS'
WHEN RECENCY_SCORE <=2 AND FREQUENCY_SCORE <=2 THEN 'AT RISK'
ELSE'OTHERS'
END;

SELECT SEGMENT ,COUNT(*) FROM rfm_scores GROUP BY SEGMENT;









