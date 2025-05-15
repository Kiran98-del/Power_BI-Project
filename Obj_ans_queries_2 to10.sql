use bank_churn;
-- 2.Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. 

SELECT 
    CustomerId,
    EstimatedSalary,
    Bank_DOJ_Date
FROM 
    customer_info
WHERE 
    MONTH(Bank_DOJ_Date) IN (10, 11, 12)
ORDER BY 
    EstimatedSalary DESC
LIMIT 5;

-- 3.Calculate the average number of products used by customers who have a credit card. 
SELECT 
    AVG(NumOfProducts) AS Avg_Products_With_CreditCard
FROM 
    Bank_Churn
WHERE 
    HasCrCard = 1;

-- 4.Determine the churn rate by gender for the most recent year in the dataset.
SELECT 
    g.gender,
    COUNT(*) AS total_customers,
    SUM(bc.Exited) AS churned_customers,
    ROUND(SUM(bc.Exited) / COUNT(*) * 100, 2) AS churn_rate_percent
FROM customer_info ci
JOIN bank_churn bc ON ci.CustomerId = bc.CustomerId
JOIN (
    SELECT 1 AS GenderID, 'Male' AS gender
    UNION
    SELECT 2, 'Female'
) g ON ci.GenderID = g.GenderID
WHERE YEAR(ci.Bank_DOJ) = (
    SELECT MAX(YEAR(Bank_DOJ)) FROM customer_info
)
GROUP BY g.gender;

-- 5.Compare the average credit score of customers who have exited and those who remain.
SELECT 
    Exited,
    ROUND(AVG(CreditScore), 2) AS avg_credit_score,
    COUNT(*) AS total_customers
FROM bank_churn
GROUP BY Exited;

-- 6.Which gender has a higher average estimated salary, and how does it relate to the number of active accounts?
SELECT 
    g.gender,
    ROUND(AVG(ci.EstimatedSalary), 2) AS avg_estimated_salary,
    count(bc.Exited) AS active_accounts
FROM customer_info ci
JOIN bank_churn bc ON ci.CustomerId = bc.CustomerId
JOIN (
    SELECT 1 AS GenderID, 'Male' AS gender
    UNION
    SELECT 2, 'Female'
) g ON ci.GenderID = g.GenderID
where bc.Exited = 0
GROUP BY g.gender;

-- 7.Segment the customers based on their credit score and identify the segment with the highest exit rate. 
SELECT
    CASE
        WHEN CreditScore < 600 THEN 'Low'
        WHEN CreditScore BETWEEN 600 AND 699 THEN 'Medium'
        ELSE 'High'
    END AS CreditSegment,
    COUNT(*) AS TotalCustomers,
    SUM(Exited) AS ExitedCustomers,
    ROUND(AVG(Exited) * 100, 2) AS ExitRatePercentage
FROM bank_churn
GROUP BY
    CASE
        WHEN CreditScore < 600 THEN 'Low'
        WHEN CreditScore BETWEEN 600 AND 699 THEN 'Medium'
        ELSE 'High'
    END
ORDER BY ExitRatePercentage DESC;

-- 8.Find out which geographic region has the highest number of active customers with a tenure greater than 5 years.
SELECT 
    g.GeographyLocation AS Region,
    COUNT(*) AS ActiveCustomersWithHighTenure
FROM bank_churn bc
JOIN customer_info ci ON bc.CustomerId = ci.CustomerId
JOIN geography g ON ci.GeographyID = g.GeographyID
WHERE bc.Exited = 0
  AND bc.Tenure > 5
GROUP BY g.GeographyLocation
ORDER BY ActiveCustomersWithHighTenure DESC
LIMIT 1;

-- 9.What is the impact of having a credit card on customer churn, based on the available data?
SELECT
    HasCrCard,
    COUNT(*) AS TotalCustomers,
    SUM(Exited) AS ExitedCustomers,
    ROUND(AVG(Exited) * 100, 2) AS ExitRatePercentage
FROM bank_churn
GROUP BY HasCrCard;

-- 10.For customers who have exited, what is the most common number of products they have used?
SELECT 
    NumOfProducts,
    COUNT(*) AS ExitedCustomerCount
FROM bank_churn
WHERE Exited = 1
GROUP BY NumOfProducts
ORDER BY ExitedCustomerCount DESC
LIMIT 1;

























