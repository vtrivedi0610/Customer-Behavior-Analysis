-- Which Membership Type (Gold, Silver, Bronze) generates the highest total revenue?

SELECT
	membership_type,
	Round(SUM(total_spend::Numeric),2) As total_revenue
From 
	customers
group by 
	membership_type
order by 
	total_revenue desc;

-- What is the average order value (Total Spend divided by Items Purchased) for each city?

select
	city,
	round((SUM(TOTAL_SPEND::numeric) / SUM(ITEMS_PURCHASED)),2) as Average_order_value
from 
	customers
group by 
	city;
	
-- Are Bronze members significantly more "Unsatisfied" than Gold members? 
SELECT
	MEMBERSHIP_TYPE,
	COUNT(*) FILTER (
		WHERE
			SATISFACTION_LEVEL = 'Unsatisfied'
	) AS UNSATISFIED_COUNT
FROM
	CUSTOMERS
WHERE
	MEMBERSHIP_TYPE IN ('Gold', 'Bronze')
GROUP BY
	MEMBERSHIP_TYPE;
 
---- Does offering a discount increase customer satisfaction levels, or does it have no impact?
 
SELECT 
    satisfaction_level,
    COUNT(*) AS total_customers,
    COUNT(CASE WHEN discount_applied = TRUE THEN 1 END) AS received_discount,
    COUNT(CASE WHEN discount_applied = FALSE THEN 1 END) AS no_discount,
    ROUND((COUNT(CASE WHEN discount_applied = TRUE THEN 1 END)::numeric / COUNT(*)) * 100, 1) AS discount_rate_pct
FROM 
    customers
GROUP BY 
    satisfaction_level
ORDER BY 
    discount_rate_pct DESC;

--Which City has the highest average Satisfaction Level?

SELECT
	CITY,
	ROUND(
		AVG(
			CASE
				WHEN SATISFACTION_LEVEL = 'Satisfied' THEN 3
				WHEN SATISFACTION_LEVEL = 'Neutral' THEN 2
				WHEN SATISFACTION_LEVEL = 'Unsatisfied' THEN 1
				ELSE NULL
			END
		),
		2
	) AS AVG_SATISFACTION_SCORE,
	COUNT(*) AS TOTAL_RESPONSE
FROM
	CUSTOMERS
GROUP BY
	CITY
ORDER BY
	AVG_SATISFACTION_SCORE DESC;
 
--Is there a specific Gender preference for certain membership types or cities?

SELECT 
    city,
    membership_type,
    COUNT(*) AS total_members,
    COUNT(*) FILTER (WHERE gender = 'Male') AS male_count,
    COUNT(*) FILTER (WHERE gender = 'Female') AS female_count,
    ROUND(100.0 * COUNT(*) FILTER (WHERE gender = 'Male') / COUNT(*), 2) AS male_percentage,
    ROUND(100.0 * COUNT(*) FILTER (WHERE gender = 'Female') / COUNT(*), 2) AS female_percentage
FROM 
    customers
GROUP BY 
    city, 
    membership_type
ORDER BY 
    city, 
    membership_type;

--- Which Age group (e.g., 20-29, 30-39, 40+) spends the most money and buys the most items?

WITH age_buckets AS (
    SELECT 
        *,
        CASE 
            WHEN age BETWEEN 20 AND 29 THEN '20-29'
            WHEN age BETWEEN 30 AND 39 THEN '30-39'
            WHEN age >= 40 THEN '40+'
            ELSE 'Other'
        END AS age_group
    FROM 
        customers
)
SELECT 
    age_group,
    COUNT(*) AS total_customers,
    SUM(total_spend) AS total_money_spent,
    ROUND(AVG(total_spend)::numeric,2) AS avg_spend_per_customer,
    SUM(items_purchased) AS total_items_bought,
    ROUND(AVG(items_purchased)::numeric, 1) AS avg_items_per_customer
FROM 
    age_buckets
WHERE 
    age_group != 'Other'
GROUP BY 
    age_group
ORDER BY 
    total_money_spent DESC, 
    total_items_bought DESC;