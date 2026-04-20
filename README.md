# E-Commerce Checkout Funnel Analysis (GA4 & BigQuery)
End-to-end SQL and Power BI analysis of the Google Merchandise Store, identifying a $340k+ quarterly checkout bottleneck and making the business case for payment UI optimization.

##  Executive Summary
Analyzed 3 months of Google Analytics 4 (GA4) data for the Google Merchandise Store to identify bottlenecks in the user purchasing journey. By querying millions of raw event logs using **Google BigQuery**, I modeled a session-scoped checkout funnel and visualized the drop-offs in **Power BI**. 

**Key Finding:** There is a critical ~38% user drop-off specifically at the `Add Payment Info` stage. 
**Business Impact:** By optimizing the payment UI to recover just 5% of these abandoned sessions, the business could generate an estimated **$68,000 in annualized recovered revenue** (based on a calculated AOV of $81.35).

---

## Tools & Techniques
* **Google BigQuery (SQL):** Data extraction, cleaning, CTEs, Window Functions (`LAG`, `PARTITION BY`), and unnesting complex arrays (`UNNEST`).
* **Power BI:** Data visualization, Power Query transformations, and dashboard design.
* **Domain Knowledge:** E-commerce funnel tracking, GA4 schema, Session scoping, Conversion Rate Optimization (CRO).

---

## The Visualization: Finding the Bottleneck
![Power BI Funnel Chart](assets/power_bi_funnel_screenshot.png)

### Key Insights from the Data:
1. **Healthy Top-of-Funnel:** The transition from *View Item* to *Add to Cart* is relatively stable across all devices.
2. **The Shipping to Payment Cliff:** Nearly 100% of users who add shipping info proceed to the next step, but **~38% of those users abandon their carts when asked to enter payment info**.
3. **The Mobile Struggle:** The drop-off at the payment stage is particularly pronounced for mobile users, indicating high friction in the mobile UI.

---

## Data Pipeline & SQL Logic
Real-world GA4 data is heavily nested and prone to duplicate tracking. To ensure accurate, session-scoped metrics, I engineered a BigQuery SQL script to clean and structure the data before visualization.

**Key SQL Methodologies Used:**
* **Cost Optimization:** Utilized `_TABLE_SUFFIX BETWEEN '20201101' AND '20210131'` to strictly bound the query to a 3-month window, preventing massive cloud processing costs.
* **Session Scoping (Unnesting):** GA4 does not natively expose Session IDs. I used `UNNEST(event_params)` to extract the `ga_session_id` and concatenated it with the `user_pseudo_id` to create a globally unique session identifier. This prevents cross-session actions from artificially inflating funnel conversion rates.
* **Chronological Sequencing:** Deployed a `CASE` statement to assign integer values to funnel steps, followed by a `LAG()` window function partitioned by `device_category` to dynamically calculate the stage-to-stage drop-off percentage.

*(View the full SQL scripts in the [sql_queries/](sql_queries/) folder).*

---

## Business Recommendations
Based on the data, I recommend the following three actions to the Product and Marketing teams:

1. **Audit the Payment UI:** Investigate the *Add Payment Info* screen for technical errors, hidden shipping fees appearing at the last second, or forced account creation prompts.
2. **Implement Digital Wallets:** Integrate Apple Pay and Google Pay. Given the high mobile drop-off rate, allowing users to bypass manual credit card entry on small screens is critical.
3. **Deploy Cart Abandonment Triggers:** Set up an automated email sequence in the CRM targeting users who dropped off exactly at Step 5, offering a 5-10% discount code to complete their purchase. 

---

## Calculating the ROI (Average Order Value)
To quantify the problem, I ran a secondary query isolating successful `purchase` events to calculate the Average Order Value (AOV).
* **Calculated AOV:** $81.35
* **Abandoned Sessions at Payment Stage:** ~4,200
* **Conservative Recovery Goal:** 5% UI improvement (210 recovered sessions)
* **Financial Impact:** 210 recovered orders $81.35 = $17,083 per quarter ➔ **~$68,334 Annualized**.
