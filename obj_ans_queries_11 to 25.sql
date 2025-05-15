-- 11.Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it.
SELECT
    YEAR(Bank_DOJ) AS JoinYear,
    MONTH(Bank_DOJ) AS JoinMonth,
    COUNT(*) AS CustomersJoined
FROM customer_info
GROUP BY YEAR(Bank_DOJ), MONTH(Bank_DOJ)
ORDER BY JoinYear, JoinMonth;

-- 12. Analyze the relationship between the number of products and the account balance for customers who have exited.
SELECT
    NumOfProducts,
    COUNT(*) AS ExitedCustomers,
    ROUND(AVG(Balance), 2) AS AvgBalance
FROM bank_churn
WHERE Exited = 1
GROUP BY NumOfProducts
ORDER BY NumOfProducts;

-- 13. Identify any potential outliers in terms of balance among customers who have remained with the bank.
-- Step 1: Get total count of active customers
SELECT COUNT(*) AS TotalActive FROM bank_churn WHERE Exited = 0;

-- Step 2: Get Q1(25th Percentile)
SELECT Balance AS Q1
FROM bank_churn
WHERE Exited = 0
ORDER BY Balance
LIMIT 1 OFFSET 1989;

-- Step 3: Get Q3(75th Percentile)
SELECT Balance AS Q3
FROM bank_churn
WHERE Exited = 0
ORDER BY Balance
LIMIT 1 OFFSET 5971;
-- Step 4: To find Outliers
SELECT *
FROM bank_churn
WHERE Exited = 0
  AND Balance > 315980.45;

-- 15.Using SQL, write a query to find out the gender-wise average income of males and females in each geography id.
--  Also, rank the gender according to the average value.
SELECT
    GeographyID,
    GenderID,
    AVG(EstimatedSalary) AS Avg_Income,
    RANK() OVER (PARTITION BY GeographyID ORDER BY AVG(EstimatedSalary) DESC) AS Income_Rank
FROM
    customer_info
GROUP BY
    GeographyID,
    GenderID;

-- 16.Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).
SELECT
    CASE
        WHEN Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN Age BETWEEN 31 AND 50 THEN '31-50'
        ELSE '51+'
    END AS Age_Bracket,
    AVG(Tenure) AS Avg_Tenure
FROM
    bank_churn bc
JOIN
    customer_info ci ON bc.CustomerId = ci.CustomerId
WHERE
    Exited = 1
GROUP BY
    CASE
        WHEN Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN Age BETWEEN 31 AND 50 THEN '31-50'
        ELSE '51+'
    END;

-- 19. Rank each bucket of credit score as per the number of customers who have churned the bank.
SELECT 
    CreditScoreBucket,
    ChurnedCustomers,
    RANK() OVER (ORDER BY ChurnedCustomers DESC) AS Rnk
FROM (
    SELECT 
        CASE
            WHEN CreditScore BETWEEN 300 AND 499 THEN '300-499'
            WHEN CreditScore BETWEEN 500 AND 599 THEN '500-599'
            WHEN CreditScore BETWEEN 600 AND 699 THEN '600-699'
            WHEN CreditScore BETWEEN 700 AND 799 THEN '700-799'
            WHEN CreditScore BETWEEN 800 AND 900 THEN '800-900'
            ELSE 'Other'
        END AS CreditScoreBucket,
        COUNT(*) AS ChurnedCustomers
    FROM bank_churn
    WHERE Exited = 1
    GROUP BY CreditScoreBucket
) AS BucketCounts
ORDER BY Rnk;

-- 20.According to the age buckets find the number of customers who have a credit card. 
-- Also retrieve those buckets that have lesser than average number of credit cards per bucket.
WITH AgeBuckets AS (
    SELECT 
        CASE
            WHEN ci.Age BETWEEN 18 AND 25 THEN '18-25'
            WHEN ci.Age BETWEEN 26 AND 35 THEN '26-35'
            WHEN ci.Age BETWEEN 36 AND 45 THEN '36-45'
            WHEN ci.Age BETWEEN 46 AND 55 THEN '46-55'
            WHEN ci.Age BETWEEN 56 AND 65 THEN '56-65'
            WHEN ci.Age > 65 THEN '65+'
            ELSE 'Unknown'
        END AS AgeBucket,
        bc.HasCrCard
    FROM customer_info ci
    JOIN bank_churn bc ON ci.CustomerId = bc.CustomerId
),
CreditCardCounts AS (
    SELECT 
        AgeBucket,
        COUNT(*) AS TotalCustomers,
        SUM(CASE WHEN HasCrCard = 1 THEN 1 ELSE 0 END) AS CreditCardHolders
    FROM AgeBuckets
    GROUP BY AgeBucket
),
AverageCardHolders AS (
    SELECT AVG(CreditCardHolders) AS AvgCardHoldersPerBucket
    FROM CreditCardCounts
)
SELECT 
    c.AgeBucket,
    c.CreditCardHolders
FROM CreditCardCounts c
JOIN AverageCardHolders a
    ON c.CreditCardHolders < a.AvgCardHoldersPerBucket;

-- 21. Rank the Locations as per the number of people who have churned the bank and average balance of the customers.
SELECT 
    Location,
    Num_Churned_Customers,
    Avg_Balance,
    RANK() OVER (ORDER BY Num_Churned_Customers DESC, Avg_Balance DESC) AS Location_Rank
FROM (
    SELECT 
        g.GeographyLocation AS Location,
        COUNT(CASE WHEN bc.Exited = 1 THEN 1 END) AS Num_Churned_Customers,
        AVG(bc.Balance) AS Avg_Balance
    FROM 
        customer_info ci
    JOIN 
        bank_churn bc ON ci.CustomerId = bc.CustomerId
    JOIN 
        geography g ON ci.GeographyID = g.GeographyID
    GROUP BY 
        g.GeographyLocation
) AS RankedLocations;

-- 22.As we can see that the “CustomerInfo” table has the CustomerID and Surname, now if we have to join it with a table where 
-- the primary key is also a combination of CustomerID and Surname, come up with a column where the format is “CustomerID_Surname”.
SELECT 
    ci.CustomerID,
    ci.Surname,
    cd.*
FROM 
    CustomerInfo ci
JOIN 
    CustomerDetails cd
    ON CONCAT(ci.CustomerID, '_', ci.Surname) = cd.CustomerID_Surname;

-- 23.Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table?
SELECT 
    CustomerId,
    CreditScore,
    Tenure,
    Balance,
    NumOfProducts,
    HasCrCard,
    IsActiveMember,
    Exited,
    CASE 
        WHEN Exited = 1 THEN 'Exit'
        WHEN Exited = 0 THEN 'Retain'
        ELSE 'Unknown'
    END AS ExitCategory
FROM 
    Bank_Churn;

-- 25.Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.
SELECT ci.CustomerId, 
       ci.Surname, 
       bc.Exited
FROM customer_info ci
JOIN bank_churn bc ON ci.CustomerId = bc.CustomerId
WHERE ci.Surname LIKE '%on';



