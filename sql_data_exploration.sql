
-- Data Exploration using SQL
-- Farin Hossain

-- Count number of customers per gender

SELECT Gender, COUNT(Gender) as Count_Gender
FROM shopping_trends..shopping_trends
GROUP BY Gender

-- Count number of customers per state

SELECT Location, COUNT(Location) as Count_Location
FROM shopping_trends..shopping_trends
GROUP BY Location
ORDER BY Count_Location DESC

-- Counts the number of purchases made in each season

SELECT Season, COUNT(Season) as Count_Season
FROM shopping_trends..shopping_trends
GROUP BY Season
ORDER BY Count_Season DESC

-- Determine the age group that most customers fall into

-- Create a column that categorizes users based on their age

ALTER TABLE shopping_trends..shopping_trends
ADD Age_group AS
	CASE 
		WHEN (Age < 25) THEN '18 to 24' 
		WHEN (Age < 35) THEN '25 to 34' 
		WHEN (Age < 45) THEN '35 to 44' 
		WHEN (Age < 55) THEN '45 to 54' 
		WHEN (Age < 65) THEN '55 to 64' 
	ELSE '65 or over' 
END

SELECT Age_group, COUNT(Age_group) as age_group_count
FROM shopping_trends..shopping_trends
GROUP BY Age_group
ORDER BY age_group_count DESC

 -- Explore average rating per item

SELECT Item_Purchased, ROUND(AVG(Review_Rating), 2) as Avg_Rating
FROM shopping_trends..shopping_trends
GROUP BY Item_Purchased

-- Explore average rating per category

SELECT Category, ROUND(AVG(Review_Rating), 2) as Avg_Rating
FROM shopping_trends..shopping_trends
GROUP BY Category

  -- Determine most purhcased products per category by calculating the proportion of each item sales with the total sales of the category

WITH item_totals AS (
    SELECT Item_Purchased, Category, COUNT(Item_Purchased) AS item_total
    FROM shopping_trends..shopping_trends
    GROUP BY Item_Purchased, Category
),
category_totals AS (
    SELECT Category, COUNT(Category) AS category_total
    FROM shopping_trends..shopping_trends
    GROUP BY Category
)

SELECT DISTINCT(i.Item_Purchased), 
	   i.item_total, 
	   c.Category,
	   c.category_total, 
	   ROUND((CAST(i.item_total AS FLOAT)/C.category_total)*100,3 )as percent_of_total
FROM item_totals i
JOIN shopping_trends..shopping_trends t ON i.Item_Purchased = t.Item_Purchased
JOIN category_totals c ON t.Category = c.Category;

  -- Average price of items in each category

SELECT  DISTINCT(Category), AVG(Purchase_Amount_USD) OVER (PARTITION BY Category) as Avg_price
FROM shopping_trends..shopping_trends
ORDER BY Category

-- Count the number of subscribed customers per state

SELECT Location, COUNT(Subscription_Status) AS subscription
FROM shopping_trends..shopping_trends
GROUP BY Location
ORDER BY subscription DESC

-- Count how many subscribed customers use discounts

SELECT Subscription_Status, Discount_Applied, COUNT(Discount_Applied) as using_discount
FROM shopping_trends..shopping_trends
WHERE Subscription_Status = 'Yes'
GROUP BY Discount_Applied, Subscription_Status

-- Most used methods of payment

SELECT Payment_Method, COUNT(Payment_Method) as total_transactions
FROM shopping_trends..shopping_trends
GROUP BY Payment_Method
ORDER BY total_transactions DESC

-- Most common to least common interval between purchases (ordering frequency_of_purchases)

SELECT Frequency_of_Purchases, COUNT(Frequency_of_Purchases) as count_of_frequency
FROM shopping_trends..shopping_trends
GROUP BY Frequency_of_Purchases
ORDER BY count_of_frequency DESC

-- Calculates the percentage of promo code in relation to subscribtion status

SELECT Subscription_Status,
       Promo_Code_Used,
       COUNT(*) AS total,
       CAST(COUNT(*) AS FLOAT) / SUM(COUNT(*)) OVER (PARTITION BY subscription_status)* 100 AS percent_using_promo_code
FROM shopping_trends..shopping_trends
GROUP BY Subscription_Status, Promo_Code_Used
ORDER BY Subscription_Status, Promo_Code_Used

-- Percent of total shipments made though each shipping type

SELECT Shipping_Type,
       COUNT(Shipping_Type) AS count,
       CAST(COUNT(Shipping_Type) AS FLOAT)/ (SELECT COUNT(Shipping_Type) FROM shopping_trends..shopping_trends) * 100 AS percent_of_total_shipments
FROM shopping_trends..shopping_trends
GROUP BY Shipping_Type


-- Count number of purchases made in relation to subsciption status 

-- Create column that categorizes users based on their total number of purchases

ALTER TABLE shopping_trends..shopping_trends
ADD total_purchases_level AS
	CASE 
        WHEN Previous_Purchases > 40 THEN 'At least 40 purchases'
        WHEN Previous_Purchases > 30 THEN 'At least 30 purchases'
        WHEN Previous_Purchases > 20 THEN 'At least 20 purchases'
    ELSE 'Less than 20 purchases'
END


SELECT
    Subscription_Status, total_purchases_level, COUNT(*) AS amount_of_purchases
FROM
    shopping_trends..shopping_trends
GROUP BY Subscription_Status,total_purchases_level
ORDER BY amount_of_purchases;


-- Determine the most common mode of shipment among the top 40 customers (customers with the most previous purchases)

WITH top_40 AS (
	SELECT TOP 40 Previous_Purchases, Subscription_Status, Shipping_Type, Frequency_of_Purchases, Location
	FROM shopping_trends..shopping_trends
)
SELECT Shipping_Type, COUNT(Shipping_Type) AS number_of_shipments
FROM top_40
GROUP BY Shipping_Type
ORDER BY number_of_shipments DESC


-- Calculates the proportion of customers with a subscription among customers with over 20 puchases

WITH over_20 AS (
	SELECT Previous_Purchases, Subscription_Status, Discount_Applied, Frequency_of_Purchases
	FROM shopping_trends..shopping_trends
	WHERE Previous_Purchases > 20
)
SELECT Subscription_Status,
       COUNT(Subscription_Status) as total_purchases,
       SUM(CASE WHEN Subscription_Status = 'Yes' THEN 1 ELSE 0 END) AS subscriber_purchases,
       CAST(SUM(CASE WHEN Subscription_Status = 'Yes' THEN 1 ELSE 0 END) AS FLOAT)/ COUNT(Subscription_Status) AS subscribed_proportion
FROM over_20
GROUP BY Subscription_Status
ORDER BY Subscription_Status DESC


-- Determine the proportion of users with subscriptions using promo codes

SELECT Subscription_Status,
	   COUNT(Subscription_Status) AS total_purchases,
       SUM(CASE WHEN Promo_Code_Used = 'Yes' THEN 1 ELSE 0 END) AS promo_code_purchases,
       CAST(SUM(CASE WHEN Promo_Code_Used = 'Yes' THEN 1 ELSE 0 END) AS FLOAT)/ COUNT(Subscription_Status) AS promo_code_proportion
FROM shopping_trends..shopping_trends
GROUP BY Subscription_Status;

