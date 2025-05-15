-- 1.Customer Behavior Analysis: What patterns can be observed in the spending habits of long-term 
-- customers compared to new customers, and what might these patterns suggest about customer loyalty?
SELECT 
    CASE 
        WHEN bc.Tenure >= 5 THEN 'Long-term'
        WHEN bc.Tenure <= 2 THEN 'New'
        ELSE 'Mid-term'
    END AS CustomerType,
    
    COUNT(*) AS TotalCustomers,
    AVG(bc.Balance) AS AvgBalance,
    AVG(bc.NumOfProducts) AS AvgNumOfProducts,
    AVG(ci.EstimatedSalary) AS AvgEstimatedSalary,
    AVG(bc.HasCrCard) AS CreditCardUsageRate,
    AVG(bc.Exited) AS ChurnRate

FROM bank_churn bc
JOIN customer_info ci ON bc.CustomerId = ci.CustomerId

GROUP BY 
    CASE 
        WHEN bc.Tenure >= 5 THEN 'Long-term'
        WHEN bc.Tenure <= 2 THEN 'New'
        ELSE 'Mid-term'
    END
ORDER BY CustomerType;

-- 2.Product Affinity Study: Which bank products or services are most 
-- commonly used together, and how might this influence cross-selling strategies?
SELECT 
    -- Product affinity combinations
    SUM(CASE WHEN bc.HasCrCard = 1 AND bc.Balance > 0 THEN 1 ELSE 0 END) AS CrCard_And_Savings,
    SUM(CASE WHEN bc.HasCrCard = 1 AND bc.NumOfProducts >= 2 THEN 1 ELSE 0 END) AS CrCard_And_MultiProduct,
    SUM(CASE WHEN bc.Balance > 0 AND bc.NumOfProducts >= 2 THEN 1 ELSE 0 END) AS Savings_And_MultiProduct,
    SUM(CASE WHEN bc.HasCrCard = 1 AND bc.Exited = 1 THEN 1 ELSE 0 END) AS CrCard_And_Active,
    SUM(CASE WHEN bc.NumOfProducts = 1 AND ci.EstimatedSalary > 100000 THEN 1 ELSE 0 END) AS HighSalary_SingleProduct,
    COUNT(*) AS TotalCustomers
FROM bank_churn bc
JOIN customer_info ci 
    ON bc.CustomerId = ci.CustomerId;

-- 3.Geographic Market Trends: How do economic indicators in different geographic regions correlate
--  with the number of active accounts and customer churn rates?
SELECT 
    g.GeographyLocation AS Region,
    COUNT(c.CustomerId) AS Total_Customers,
    AVG(c.EstimatedSalary) AS Avg_Estimated_Salary,
    SUM(CASE WHEN b.Exited = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Active_Percentage,
    SUM(CASE WHEN b.Exited = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Churn_Percentage
FROM 
    customer_info c
JOIN 
    bank_churn b ON c.CustomerId = b.CustomerId
JOIN 
    geography g ON c.GeographyID = g.GeographyID
GROUP BY 
    g.GeographyLocation;

-- 4.Risk Management Assessment: Based on customer profiles, which demographic segments appear to
--  pose the highest financial risk to the bank, and why?
SELECT 
    g.GeographyLocation AS Region,
    FLOOR(c.Age / 10) * 10 AS Age_Group,
    COUNT(c.CustomerId) AS Total_Customers,
    round(AVG(b.CreditScore),2) AS Avg_CreditScore,
    round(AVG(b.Balance),2) AS Avg_Balance,
    round(SUM(CASE WHEN b.Exited = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS Churn_Percentage
FROM 
    customer_info c
JOIN 
    bank_churn b ON c.CustomerId = b.CustomerId
JOIN 
    geography g ON c.GeographyID = g.GeographyID
GROUP BY 
	g.GeographyLocation, FLOOR(c.Age / 10) * 10
ORDER BY 
    Churn_Percentage DESC;

-- 7. Customer Exit Reasons Exploration: Can you identify common characteristics or trends
--  among customers who have exited that could explain their reasons for leaving?
-- SQL query to for number of products:
SELECT 
    NumOfProducts,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS Exited_Customers,
    ROUND(
        SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS Churn_Rate_Percent
FROM 
    bank_churn
GROUP BY 
    NumOfProducts
ORDER BY 
    Churn_Rate_Percent DESC;

-- SQL query for tenure:
SELECT 
    Tenure,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS Exited_Customers,
    ROUND(
        SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS Churn_Rate_Percent
FROM 
    bank_churn
GROUP BY 
    Tenure
ORDER BY 
    Churn_Rate_Percent DESC;

-- SQL query for Location:
SELECT 
    g.GeographyLocation,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN bc.Exited = 1 THEN 1 ELSE 0 END) AS Exited_Customers,
    ROUND(
        SUM(CASE WHEN bc.Exited = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS Churn_Rate_Percent
FROM 
    bank_churn bc 
    join customer_info c 
    on bc.customerID = c.customerID
    join geography g 
    on c.GeographyID = g.GeographyID
GROUP BY 
    g.GeographyLocation
ORDER BY 
    Churn_Rate_Percent DESC;

-- 8. Are 'Tenure', 'NumOfProducts', 'IsActiveMember', and 'EstimatedSalary' important for predicting 
-- if a customer will leave the bank?
-- For number of products and tenure , I have used the same query as in the q.7
-- SQL query for Estimated salary:
SELECT 
    CASE 
        WHEN ci.EstimatedSalary < 50000 THEN 'Under 50K'
        WHEN ci.EstimatedSalary BETWEEN 50000 AND 100000 THEN '50K - 100K'
        WHEN ci.EstimatedSalary BETWEEN 100001 AND 150000 THEN '100K - 150K'
        ELSE '150K+' 
    END AS SalaryRange,
    COUNT(bc.CustomerId) AS TotalCustomers,
    SUM(bc.Exited) AS ExitedCustomers,
    ROUND(SUM(bc.Exited) * 100.0 / COUNT(bc.CustomerId), 2) AS ChurnRate
FROM 
    bank_churn bc
JOIN 
    customer_info ci ON bc.CustomerId = ci.CustomerId
GROUP BY 
    SalaryRange
ORDER BY 
    ChurnRate DESC;

-- 9. Utilize SQL queries to segment customers based on demographics and account details.
-- SQL query for Segment by Age Group
SELECT 
    CASE 
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age BETWEEN 30 AND 50 THEN '30-50'
        ELSE 'Over 50'
    END AS Age_Group,
    COUNT(*) AS Customer_Count
FROM customer_info
GROUP BY Age_Group;

-- SQL query to Segment by Gender and Churn Status
SELECT 
    CASE GenderID
        WHEN 1 THEN 'Male'
        WHEN 2 THEN 'Female'
    END AS Gender,
    bc.Exited,
    COUNT(*) AS Customer_Count
FROM customer_info ci
JOIN bank_churn bc ON ci.CustomerId = bc.CustomerId
GROUP BY GenderID, bc.Exited;

-- SQL query to Segment by Geography and Account Activity
SELECT g.GeographyLocation,
    bc.Exited,
    COUNT(*) AS Customer_Count
FROM customer_info ci
JOIN bank_churn bc ON ci.CustomerId = bc.CustomerId
join geography g 
on g.GeographyID = ci.GeographyID
GROUP BY g.GeographyLocation, bc.Exited;

-- SQL query to Segment by Credit Score Range
SELECT 
    CASE 
        WHEN CreditScore < 600 THEN 'Low'
        WHEN CreditScore BETWEEN 600 AND 750 THEN 'Medium'
        ELSE 'High'
    END AS CreditScore_Segment,
    COUNT(*) AS Customer_Count
FROM bank_churn
GROUP BY CreditScore_Segment;

-- 14.. In the “Bank_Churn” table how can you modify the
--  name of the “HasCrCard” column to “Has_creditcard”?
ALTER TABLE Bank_Churn
RENAME COLUMN HasCrCard TO Has_creditcard;
