CREATE OR REPLACE VIEW Opportunity_Dashboard_View AS
SELECT
    -- Opportunity Info
    opp.`Opportunity ID`,
    opp.`Stage`,
    opp.`Amount`,
    opp.`Expected Amount`,
    opp.`Probability (%)`,
    opp.`Won`,
    opp.`Close Date`,
    opp.`Opportunity Type`,
    opp.`Lead Source`,
    opp.`Industry` AS `Opportunity Industry`,

    -- Lead Info
    leads.`Lead ID`,
    leads.`Lead Source` AS `Lead Source (from Lead)`,
    leads.`Industry` AS `Lead Industry`,

    -- Account Info
    acc.`Account ID`,
    acc.`Account Name`,
    acc.`Account Type`,
    acc.`Industry` AS `Account Industry`,

    -- Opportunity Product Info
    opp_prod.`Product ID`,
    opp_prod.`Product Code`,
    opp_prod.`Quantity`,
    opp_prod.`Sales Price`,
    opp_prod.`Total Price`,

    -- User Info
    usr.`User ID` AS `Created By User ID`,
    usr.`Full Name` AS `Created By User Name`

FROM `Opportunity` opp
LEFT JOIN `Account` acc
    ON opp.`Account ID` = acc.`Account ID`
LEFT JOIN `leads`
    ON leads.`Converted Opportunity ID` = opp.`Opportunity ID`
LEFT JOIN `Opportunity Product` opp_prod
    ON opp.`Opportunity ID` = opp_prod.`Opportunity ID`
LEFT JOIN `User` usr
    ON opp.`Created By ID` = usr.`User ID`;
    
select * from Opportunity_Dashboard_View ;

    --- 1) Total expected amount
   SELECT 
  concat(
  '$',
  round(
  SUM(
    CAST(REPLACE(REPLACE(`Expected Amount`, '$', ''), ',', '') AS DECIMAL(18,2))
  ) / 1000000,3),
  ' M')
  AS `Total Expected Amount`
FROM Opportunity_Dashboard_View;


--- 2) Active Opportunity

SELECT COUNT(DISTINCT `Opportunity ID`) AS `Active Opportunities`
FROM Opportunity_Dashboard_View
WHERE `Won` = 'true' ;


--- 3) total opp 4) lose opp 5) won oppr 6) win rate 7) lose rate
SELECT 
  COUNT(DISTINCT `Opportunity ID`) AS `Total`,
  COUNT(DISTINCT CASE WHEN `Won` = 'true' THEN `Opportunity ID` END) AS `Won`,
  COUNT(DISTINCT CASE WHEN `Won` = 'false' THEN `Opportunity ID` END) AS `Lost`,
  ROUND(
    COUNT(DISTINCT CASE WHEN `Won` = 'true' THEN `Opportunity ID` END) * 100.0 /
    COUNT(DISTINCT `Opportunity ID`), 2
  ) AS `Winning Rate (%)`,
  ROUND(
    COUNT(DISTINCT CASE WHEN `Won` = 'false' THEN `Opportunity ID` END) * 100.0 /
    COUNT(DISTINCT `Opportunity ID`), 2
  ) AS `Losing Rate (%)`
FROM Opportunity_Dashboard_View;

--- 8) Expected revenue
SELECT 
  `Opportunity Type`,
  SUM(
    CAST(REPLACE(REPLACE(`Expected Amount`, '$', ''), ',', '') AS DECIMAL(18,2))
  ) AS `Expected Revenue`
FROM Opportunity_Dashboard_View
WHERE `Opportunity Type` IS NOT NULL
GROUP BY `Opportunity Type`
ORDER BY `Expected Revenue` DESC;


--- 9) Industry wise opportunity count
SELECT 
  COALESCE(`Opportunity Industry`, `Lead Industry`, `Account Industry`) AS `Industry`,
  COUNT(DISTINCT `Opportunity ID`) AS `Opportunity Count`
FROM Opportunity_Dashboard_View
GROUP BY COALESCE(`Opportunity Industry`, `Lead Industry`, `Account Industry`)
ORDER BY `Opportunity Count` DESC;

--- 10) Year-Month wise Expected Amount
SELECT 
  YEAR(STR_TO_DATE(`Close Date`, '%m/%d/%Y')) AS `Year`,
  MONTHNAME(STR_TO_DATE(`Close Date`, '%m/%d/%Y')) AS `Month`,
  SUM(
    CAST(REPLACE(REPLACE(`Expected Amount`, '$', ''), ',', '') AS DECIMAL(18,2))
  ) AS `Expected Amount`
FROM Opportunity_Dashboard_View
WHERE `Close Date` IS NOT NULL
GROUP BY `Year`, `Month`
ORDER BY `Year`, FIELD(`Month`, 
  'January','February','March','April','May','June',
  'July','August','September','October','November','December');



select sum(CAST(REPLACE(REPLACE(`Amount`, '$', ''), ',', '') AS DECIMAL(18,2))) FROM `opportunity`;





