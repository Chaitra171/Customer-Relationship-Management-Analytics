---  Create Database 
create database crm;
use crm;


--- import all tables using table import wizard


--- check table structure data
select count(*) from `account`;
desc `account`;
select count(*) from `lead`;
desc `lead`;
select count(*) from `opportunity product`;
desc `opportunity product`;
select count(*) from `opportunity`;
desc `opportunity`;
select count(*) from user;
desc user;

--- Created View for Lead

CREATE OR REPLACE VIEW PowerBI_Dashboard_View AS
SELECT
    -- Lead Info
    leads.`Lead ID`,
    leads.`Converted`,
    leads.`Converted Account ID`,
    leads.`Converted Opportunity ID`,
  
    leads.`Created Date`,

    -- Account Info (only present for converted leads)
    acc.`Account ID`,
    acc.`Account Name`,
    acc.`Account Type`,
    acc.`Billing City`,
    acc.`Annual Revenue`,

    -- Opportunity Info
    opp.`Opportunity ID`,
    opp.`Close Date`,
    opp.`Amount`,
    opp.`Expected Amount`,
    opp.`Probability (%)`,
    opp.`Won`,
    opp.`Created By ID` AS `Opportunity Created By`,
    opp.`Last Modified By ID` AS `Opportunity Last Modified By`,

    -- Opportunity Product Info
    opp_prod.`Line Item ID`,
    opp_prod.`Product ID`,
    opp_prod.`Product Code`,
    opp_prod.`Quantity`,
    opp_prod.`Sales Price`,
    opp_prod.`Total Price`,

    -- User Info
    usr.`User ID` AS `User Managing Opportunity`,
    usr.`User Type`

FROM `leads`
LEFT JOIN `Account` acc 
    ON leads.`Converted Account ID` = acc.`Account ID`
LEFT JOIN `Opportunity` opp 
    ON leads.`Converted Opportunity ID` = opp.`Opportunity ID`
LEFT JOIN `Opportunity Product` opp_prod 
    ON opp.`Opportunity ID` = opp_prod.`Opportunity ID`
LEFT JOIN `User` usr 
    ON opp.`Created By ID` = usr.`User ID`;
    
/* Leads KPI */

--- 1) Total leads 2) converted leads 3) non converted 3) conversion rate

SELECT 
  COUNT(*) AS `Total Leads`,
  COUNT(CASE WHEN `Converted` = 'true' THEN 1 END) AS `Converted Leads`,
  COUNT(CASE WHEN `Converted` = 'false' THEN 1 END) AS `Non-Converted Leads`,
  ROUND(
    COUNT(CASE WHEN `Converted` = 'true' THEN 1 END) * 100.0 / COUNT(*),
    2
  ) AS `Conversion Rate (%)`
FROM 
  `Leads`;
  
  --- 5) Total Expected amount
  
SELECT 
  CONCAT(
    '$',
    ROUND(
      SUM(
        CAST(REPLACE(REPLACE(`Expected Amount`, '$', ''), ',', '') AS DECIMAL(18,2))
      ) / 1000000, 2
    ),
    ' M '
  ) AS `Total Expected Amount`
FROM PowerBI_Dashboard_View;


--- 

SELECT 
  COUNT(*) AS `Total Leads`,
  COUNT(CASE WHEN `Converted` = 'true' THEN 1 END) AS `Converted Leads`,
  COUNT(CASE WHEN `Converted` = 'false' THEN 1 END) AS `Non-Converted Leads`,
  ROUND(
    COUNT(CASE WHEN `Converted` = 'true' THEN 1 END) * 100.0 / COUNT(*),
    2
  ) AS `Conversion Rate (%)`
FROM PowerBI_Dashboard_View;

--- 6) Expected Amount from Converted Leads

SELECT 
  concat(
  '$',
  round(
  SUM(
    CAST(REPLACE(REPLACE(`Expected Amount`, '$', ''), ',', '') AS DECIMAL(18,2))
  )/1000000,2),
  'M')
  AS `Expected Amount from Converted Leads`
FROM PowerBI_Dashboard_View
WHERE 
  `Converted` = 'true'
  AND `Converted Account ID` IS NOT NULL
  AND `Converted Opportunity ID` IS NOT NULL
  AND `Expected Amount` IS NOT NULL;
  
--- 7) year and month wise expected amount

SELECT 
  YEAR(STR_TO_DATE(`Close Date`, '%m/%d/%Y')) AS `Year`,
  MONTHNAME(STR_TO_DATE(`Close Date`, '%m/%d/%Y')) AS `Month`,
  SUM(
    CAST(REPLACE(REPLACE(`Expected Amount`, '$', ''), ',', '') AS DECIMAL(18,2))
  ) AS `Expected Amount`
FROM PowerBI_Dashboard_View
WHERE `Close Date` IS NOT NULL
GROUP BY `Year`, `Month`
ORDER BY `Year`, FIELD(`Month`, 
  'January','February','March','April','May','June',
  'July','August','September','October','November','December');
  
--- 8) converted opportunity

SELECT 
  COUNT(DISTINCT `Converted Opportunity ID`) AS `Converted Opportunities`
FROM PowerBI_Dashboard_View
WHERE 
  `Converted` = 'true'
  AND `Converted Opportunity ID` IS NOT NULL;
  
--- 9) Year-Month wise converted Opportunity

SELECT 
  YEAR(STR_TO_DATE(`Close Date`, '%m/%d/%Y')) AS `Year`,
  MONTHNAME(STR_TO_DATE(`Close Date`, '%m/%d/%Y')) AS `Month`,
  COUNT(DISTINCT `Converted Opportunity ID`) AS `Converted Opportunities`
FROM PowerBI_Dashboard_View
WHERE 
  `Converted` = 'true'
  AND `Converted Opportunity ID` IS NOT NULL
  AND `Close Date` IS NOT NULL
GROUP BY 
  YEAR(STR_TO_DATE(`Close Date`, '%m/%d/%Y')),
	MONTHNAME(STR_TO_DATE(`Close Date`, '%m/%d/%Y')) 
ORDER BY 
  Year,
  MONTHname(STR_TO_DATE(`Close Date`, '%m/%d/%Y'));



 


