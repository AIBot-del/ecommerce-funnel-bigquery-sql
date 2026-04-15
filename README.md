# ecommerce-funnel-bigquery-sql
End-to-end e-commerce funnel, marketing, and revenue analysis using BigQuery SQL

📊 E-Commerce Funnel & Revenue Analytics (SQL + BigQuery)
📌 Project Overview

This project analyzes a real-world e-commerce event dataset using SQL in Google BigQuery.

The goal was to simulate a real business environment and answer key questions around:

Customer conversion behavior
Funnel drop-offs
Marketing channel performance
Revenue generation efficiency

Instead of working with clean sales tables, I worked with raw event-level data to reflect real industry conditions.

🎯 Business Questions
Where are users dropping off in the funnel?
Which marketing channels drive actual buyers?
How fast do users convert from view → purchase?
How much revenue does each visitor generate?
Which channels should the company invest in?
🗂️ Dataset Structure

The dataset includes user-level event tracking:

user_id
event_type (page_view, add_to_cart, checkout_start, payment_info, purchase)
event_date
traffic_source
amount (revenue)
🧮 Analysis Performed
1. Conversion Funnel Analysis
Built a full multi-step funnel
Calculated stage-by-stage conversion rates
Measured overall conversion rate
2. Marketing Channel Analysis
Compared performance across:
Organic
Social
Paid Ads
Email
Measured:
Views
Add-to-cart
Purchases
Conversion rates
3. Time-to-Conversion Analysis
Measured how long users take to move through the funnel
View → Cart
Cart → Purchase
Full journey duration
4. Revenue Analysis
Total revenue
Average order value (AOV)
Revenue per visitor
Revenue per buyer
📊 Key Insights
4,291 users entered the funnel
709 completed purchases (16.5% conversion rate)
Traffic Performance:
Email: 34% conversion rate (highest)
Paid Ads: 21%
Organic: 17%
Social: 7% (lowest despite high traffic)
Revenue:
Total Revenue: ~$87,975
Average Order Value: ~$106
Revenue per visitor: ~$17.60
🚨 Key Findings
Checkout flow is highly optimized (no major friction)
Drop-off happens early in the funnel (before cart)
Social media drives high traffic but low-quality users
Email is the highest-performing conversion channel
💡 Recommendations
Do not modify checkout flow (already performing well)
Improve landing pages and product pages for top-of-funnel users
Shift social strategy from “traffic” → “retargeting + lead capture”
Invest heavily in email marketing and automation
Optimize ad spend based on conversion efficiency, not traffic volume
🛠️ Tools Used
SQL
Google BigQuery
Data Analysis
Funnel Analysis
Revenue Analytics
📌 Key Takeaway

This project demonstrates how raw event data can be transformed into actionable business insights using SQL.

It shows how data can guide:

Marketing spend decisions
UX improvements
Revenue optimization
📎 Author

Built by a data analyst exploring real-world e-commerce analytics using SQL and BigQuery.
