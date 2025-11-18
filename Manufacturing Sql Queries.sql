-- ============================================
-- Manufacturing Dataset Setup Script (MySQL)
-- ============================================

-- 1️⃣ Create Database
CREATE DATABASE IF NOT EXISTS manufacturing;
USE manufacturing;

-- 2️⃣ Drop Old Table (if any)
DROP TABLE IF EXISTS manufacturing_data;

-- 3️⃣ Create Table
CREATE TABLE manufacturing_data (
    Buyer VARCHAR(50),
    Cust_Code VARCHAR(50),
    Cust_Name VARCHAR(100),
    Delivery_Period VARCHAR(50),
    Department_Name VARCHAR(100),
    Designer BOOLEAN,
    Doc_Date DATE,
    Doc_Num BIGINT,
    Emp_Code VARCHAR(50),
    Emp_Name VARCHAR(100),
    Per_Day_Machine_Cost DECIMAL(10,2),
    Press_Qty INT,
    Processed_Qty INT,
    Produced_Qty INT,
    Rejected_Qty INT,
    Repeat_Qty INT,
    Today_Manufactured_Qty INT,
    Total_Qty INT,
    Total_Value DECIMAL(12,2),
    WO_Qty INT,
    Machine_Code VARCHAR(50),
    Operation_Name VARCHAR(100),
    Operation_Code VARCHAR(50),
    Item_Code VARCHAR(50),
    Item_Name VARCHAR(255)
);

-- 4️⃣ Import Data
-- You can use MySQL Workbench → Table Data Import Wizard
-- to load your “Manufacturing Dataset.xlsx” into this table.

ALTER TABLE manufacturing_data 
MODIFY COLUMN Designer VARCHAR(10);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Manufacturing_Dataset.csv'
INTO TABLE manufacturing_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================
-- 5️⃣ Create Analytical Views (for Tableau / Power BI)
-- ============================================

-- Total Manufactured Quantity
CREATE OR REPLACE VIEW v_manufactured_qty AS
SELECT 
    ROUND(SUM(Today_Manufactured_Qty)/1000000, 2) AS Manufactured_Million_Qty
FROM manufacturing_data;

-- Total Rejected Quantity
CREATE OR REPLACE VIEW v_rejected_qty AS
SELECT 
    ROUND(SUM(Rejected_Qty)/1000000, 2) AS Rejected_Million_Qty
FROM manufacturing_data;

-- Total Processed Quantity
CREATE OR REPLACE VIEW v_processed_qty AS
SELECT 
    ROUND(SUM(Processed_Qty)/1000000, 2) AS Processed_Million_Qty
FROM manufacturing_data;

-- Total Wastage Quantity (if available)
CREATE OR REPLACE VIEW v_wastage_qty AS
SELECT 
    ROUND(SUM(WO_Qty)/1000000, 2) AS Wastage_Million_Qty
FROM manufacturing_data;

-- Buyer-Wise Rejected Quantity
CREATE OR REPLACE VIEW v_buyerwise_rejected AS
SELECT 
    Buyer,
    SUM(Rejected_Qty) AS Total_Rejected
FROM manufacturing_data
GROUP BY Buyer
ORDER BY Total_Rejected DESC;

-- Employee-Wise Rejected Quantity
CREATE OR REPLACE VIEW v_empwise_rejected AS
SELECT 
    Emp_Name,
    SUM(Rejected_Qty) AS Total_Rejected
FROM manufacturing_data
GROUP BY Emp_Name
ORDER BY Total_Rejected DESC;

-- Machine-Wise Rejected Quantity
CREATE OR REPLACE VIEW v_machinewise_rejected AS
SELECT 
    Machine_Code,
    SUM(Rejected_Qty) AS Total_Rejected
FROM manufacturing_data
GROUP BY Machine_Code
ORDER BY Total_Rejected DESC;

-- Department-Wise Manufacture vs Rejected
CREATE OR REPLACE VIEW v_deptwise_mfr_vs_rejected AS
SELECT 
    Department_Name,
    SUM(Today_Manufactured_Qty) AS Manufactured_Qty,
    SUM(Rejected_Qty) AS Rejected_Qty
FROM manufacturing_data
GROUP BY Department_Name;

-- Manufacture vs Rejected (overall ratio)
CREATE OR REPLACE VIEW v_mfr_vs_rejected_ratio AS
SELECT 
    ROUND(SUM(Rejected_Qty) / SUM(Today_Manufactured_Qty) * 100, 2) AS Rejection_Percentage
FROM manufacturing_data;

-- Production Comparison Trend (by Month)
CREATE OR REPLACE VIEW v_monthly_production_trend AS
SELECT 
    DATE_FORMAT(Doc_Date, '%Y-%m') AS Month_Year,
    SUM(Today_Manufactured_Qty) AS Total_Manufactured,
    SUM(Rejected_Qty) AS Total_Rejected,
    SUM(Processed_Qty) AS Total_Processed
FROM manufacturing_data
GROUP BY DATE_FORMAT(Doc_Date, '%Y-%m')
ORDER BY Month_Year;


SELECT * FROM v_manufactured_qty;
SELECT * FROM v_rejected_qty;
SELECT * FROM v_processed_qty;
SELECT * FROM v_wastage_qty;
SELECT * FROM v_buyerwise_rejected;
SELECT * FROM v_empwise_rejected;
SELECT * FROM v_machinewise_rejected;
SELECT * FROM v_deptwise_mfr_vs_rejected;
SELECT * FROM v_mfr_vs_rejected_ratio;
SELECT * FROM v_monthly_production_trend;
