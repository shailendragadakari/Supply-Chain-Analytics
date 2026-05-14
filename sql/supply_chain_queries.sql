-- =======================================================
-- Supply Chain Analytics
-- Database: supply_chain
-- Table: supply_chain_features (180,519 rows)
-- =======================================================
-- All queries run against supply_chain_features.
-- Verified figures match Notebooks 1-4 ground truths.
-- =======================================================

-- =======================================================
-- QUERY 1: Overall Business KPIs 
-- =======================================================
-- Expected: 65,752 unique orders | $36,784,735.01 revenue
--			 $3,966,902.97 profit | 10.78% margin
--			 2.05% cancellation
-- =======================================================

SELECT
	count(DISTINCT "Order Id") AS total_orders,
	count(*) AS total_order_lines,
	count(DISTINCT "Customer Id") AS unique_customers,
	count(DISTINCT "Product Name") AS unique_products,
	round(sum("Sales")::NUMERIC, 2) AS total_revenue,
	round(sum("Order Profit Per Order")::NUMERIC, 2) AS total_profit,
	round(
		(sum("Order Profit Per Order") / NULLIF(sum("Sales"), 0) * 100)::NUMERIC, 2
		) AS profit_margin_pct,
	round(
		(sum(is_cancelled)::NUMERIC / count(*) * 100)::NUMERIC, 2
		) AS cancellation_rate_pct
FROM
	supply_chain_features;

-- =======================================================
-- QUERY 2: Overall Delivery Performance
-- =======================================================
-- Expected: Late delivery - 54.83% | Advance - 23.04%
--			 On time - 17.84% | Canceled - 4.3%
-- =======================================================

SELECT
	"Delivery Status",
	count(*) AS order_count,
	round((count(*) * 100.0 / sum(count(*)) OVER ())::NUMERIC, 2) AS pct_of_total,
	round(avg(delivery_delay_days)::NUMERIC, 2) AS avg_delay_days
FROM
	supply_chain_features
GROUP BY
	"Delivery Status"
ORDER BY
	order_count DESC;


-- =======================================================
-- QUERY 3: Late Delivery Rate by Shipping Mode
-- =======================================================
-- Expected: First Class - 95.32% | Second Class - 76.63%
--			 Same Say - 45.74% | Standard Class - 38.07%
-- =======================================================

SELECT 
	"Shipping Mode",
	count(*) AS total_orders,
	sum(late_delivery_flag) AS late_orders,
	round(
		(sum(late_delivery_flag)::NUMERIC / count(*) * 100)::NUMERIC, 2
	) AS late_delivery_rate_pct,
	round(avg(delivery_delay_days)::NUMERIC, 3) AS avg_delay_days,
	round(avg("Days for shipment (scheduled)")::NUMERIC, 2 )AS avg_scheduled_days
FROM
	supply_chain_features
GROUP BY
	"Shipping Mode"
ORDER BY
	late_delivery_rate_pct DESC;

-- =======================================================
-- QUERY 4: Delivery Performance by Market
-- =======================================================
-- Expected: All markets cluster tightly at 54-55% late
-- 			 rate. Europe is highest at 55.21%, LATAM
--			 is lowest at 54.36%
-- =======================================================

SELECT 
	"Market",
	count(*) AS total_orders,
	sum(late_delivery_flag) AS late_orders,
	round(
		(sum(late_delivery_flag)::NUMERIC / count(*) * 100)::NUMERIC, 2
	) AS late_delivery_rate_pct,
	round(sum("Sales")::NUMERIC, 2) AS total_revenue,
	round(
		(sum("Sales") * 100.0 / sum(sum("Sales")) OVER ())::NUMERIC, 2
	) AS revenue_share_pct
FROM
	supply_chain_features
GROUP BY
	"Market"
ORDER BY
	total_revenue DESC;

-- =======================================================
-- QUERY 5: Top 10 Product Categories by Revenue
-- =======================================================
-- Expected: Fishing - $6,929,653.69(#1) |
-- 			 Cleats - $4,431,942.78 (#2) |
-- 			 Camping & Hiking $4,118,425.57 (#3)
-- =======================================================

SELECT 
	"Category Name",
	count(*) AS order_lines,
	round(sum("Sales")::NUMERIC, 2) AS total_revenue,
	round(sum("Order Profit Per Order")::NUMERIC, 2) AS total_profit,
	round(
		(sum("Order Profit Per Order") / NULLIF(sum("Sales"), 0) * 100)::NUMERIC, 2
	) AS profit_margin_pct,
	round(
		(sum("Sales") * 100.0 / sum(sum("Sales")) OVER ())::NUMERIC, 2
	) AS revenue_share_pct
FROM
	supply_chain_features
GROUP BY
	"Category Name"
ORDER BY
	total_revenue DESC
LIMIT 10;

-- =======================================================
-- QUERY 6: Revenue & Profitability by Customer Segment
-- =======================================================
-- Expected: Consumer - 51.91% revenue share |
-- 			 Corporate - 30.36% | Home Office - 17.73% |
-- 			 All Segments - ~10.5-10.9% margin
-- =======================================================

SELECT 
	"Customer Segment",
	count(*) AS order_lines,
	count(DISTINCT "Order Id") AS unique_orders,
	round(sum("Sales")::NUMERIC, 2) AS total_revenue,
	round(sum("Order Profit Per Order")::NUMERIC, 2) AS total_profit,
	round(
		(sum("Order Profit Per Order") / NULLIF(sum("Sales"), 0) * 100)::NUMERIC, 2
	) AS profit_margin_pct,
	round(
		(sum("Sales") * 100.0 / sum(sum("Sales")) OVER ())::NUMERIC, 2
	) AS revenue_share_pct
FROM
	supply_chain_features
GROUP BY
	"Customer Segment"
ORDER BY
	total_revenue DESC;

-- =======================================================
-- QUERY 7: Top 10 Categories by Profit Margin
-- =======================================================
-- Expected: Fitness Accessories - 14.77% (#1) |
--			 Toys - 14.75% (#2) | Soccer 14.74% (#3)
-- =======================================================

SELECT 
	"Category Name",
	count(*) AS order_lines,
	round(sum("Sales")::NUMERIC, 2) AS total_revenue,
	round(sum("Order Profit Per Order")::NUMERIC, 2) AS total_profit,
	round(
		(sum("Order Profit Per Order") / NULLIF(sum("Sales"), 0) * 100)::NUMERIC, 2
	) AS profit_margin_pct
FROM
	supply_chain_features
GROUP BY
	"Category Name"
HAVING
	count(*) >= 100
ORDER BY
	profit_margin_pct DESC
LIMIT 10;

-- =======================================================
-- QUERY 8: Revenue, Profit & Market Share by Market
-- =======================================================
-- Expected: Europe - $10.87M (29.56%) | 
--			 LATAM - $10.27M (27.94) |
-- 			 Pacific Asia - $8.27M (22.49%) |
-- 			 USCA - $5.06M (13.77%) |
--	    	 Africa - $2.29M (6.24%)
-- =======================================================

SELECT 
	"Market",
	count(*) AS order_count,
	round(sum("Sales")::NUMERIC, 2) AS total_revenue,
	round(sum("Order Profit Per Order")::NUMERIC, 2) AS total_profit,
	round(
		(sum("Order Profit Per Order") / NULLIF(sum("Sales"), 0) * 100)::NUMERIC, 2
	) AS profit_margin_pct,
	round(
		(sum("Sales") * 100.0 / sum(sum("Sales")) OVER ())::NUMERIC, 2
	) AS revenue_share_pct
FROM
	supply_chain_features
GROUP BY
	"Market"
ORDER BY
	total_revenue DESC;

-- =======================================================
-- QUERY 9: Monthly Order Volume & Revenue Trend
--			 (non-cancelled orders only - matches
--	     									prophet input)
-- =======================================================
-- Expected: Stable ~5,000-5,300 orders/month Jan 2015
-- 			 to Sept 2017. Sharp drop to ~2,000 from Oct
-- 			 2017 (data truncation). Feb consistently
-- 			 lowest each year.
-- =======================================================

SELECT 
	date_trunc('month', "order date (DateOrders)")::date AS order_month,
	count(*) AS order_count,
	round(sum("Sales")::NUMERIC, 2) AS monthly_revenue,
	round(avg("Sales")::NUMERIC, 2) AS avg_order_value,
	sum(late_delivery_flag) AS late_orders,
	round(
		(sum(late_delivery_flag)::NUMERIC / count(*) * 100)::NUMERIC, 2
	) AS monthly_late_rate_pct
FROM
	supply_chain_features
WHERE
	is_cancelled = 0
GROUP BY
	date_trunc('month', "order date (DateOrders)")
ORDER BY
	order_month;

-- =======================================================
-- QUERY 10: Discount Impact by Department

-- =======================================================
-- Expected: Fan Shop - $1,740,068.66 total discount 
-- 			 (10.17% of revenue). All departments
--			 cluster at ~10.1-10.2% discount rate. Total
-- 			 discount across all orders - $3,740,585.18
-- =======================================================

SELECT
	"Department Name",
	count(*) AS order_lines,
	round(sum("Sales")::NUMERIC, 2) AS total_revenue,
	round(sum(discount_impact)::NUMERIC, 2) AS total_discount_given,
	round(
		(sum(discount_impact) / NULLIF(sum("Sales"), 0) * 100)::NUMERIC, 2
	) AS discount_pct_of_revenue,
	round((avg("Order Item Discount Rate") * 100)::NUMERIC, 2) AS avg_discount_rate_pct,
	round(sum("Order Profit Per Order")::NUMERIC, 2) AS total_profit
FROM
	supply_chain_features
GROUP BY
	"Department Name"
ORDER BY
	total_discount_given DESC;