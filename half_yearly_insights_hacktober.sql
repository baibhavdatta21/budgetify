WITH six_month_totals AS (
    SELECT 'H1' AS period,
           SUM(amount) AS total_expense,
           SUM(investment_amount) AS total_investment,
           ROUND(SUM(amount) / 6, 2) AS avg_monthly_expense
    FROM wrk
    WHERE month IN ('January', 'February', 'March', 'April', 'May', 'June')
    UNION ALL
    SELECT 'H2',
           SUM(amount),
           SUM(investment_amount),
           ROUND(SUM(amount) / 6, 2)
    FROM wrk
    WHERE month IN ('July', 'August', 'September', 'October', 'November', 'December')
),
category_expenses AS (
    SELECT CASE 
               WHEN month IN ('January', 'February', 'March', 'April', 'May', 'June') THEN 'H1' 
               ELSE 'H2' 
           END AS period,
           category,
           SUM(amount) AS category_expense
    FROM wrk
    GROUP BY period, category
),
needs_vs_wants AS (
    SELECT CASE 
               WHEN month IN ('January', 'February', 'March', 'April', 'May', 'June') THEN 'H1' 
               ELSE 'H2' 
           END AS period,
           SUM(CASE WHEN category = 'needs' THEN amount ELSE 0 END) AS total_needs,
           SUM(CASE WHEN category = 'wants' THEN amount ELSE 0 END) AS total_wants
    FROM wrk
    GROUP BY period
),
expense_growth AS (
    SELECT period,
           total_expense,
           LAG(total_expense) OVER (ORDER BY period) AS previous_period_expense,
           ROUND((total_expense - LAG(total_expense) OVER (ORDER BY period)) / 
                 NULLIF(LAG(total_expense) OVER (ORDER BY period), 0) * 100, 2) AS growth_rate
    FROM six_month_totals
)

-- Combine all insights in one output
SELECT st.period,
       st.total_expense,
       st.total_investment,
       st.avg_monthly_expense,
       cg.category,
       cg.category_expense,
       nw.total_needs,
       nw.total_wants,
       eg.previous_period_expense,
       eg.growth_rate
FROM six_month_totals AS st
LEFT JOIN category_expenses AS cg ON st.period = cg.period
LEFT JOIN needs_vs_wants AS nw ON st.period = nw.period
LEFT JOIN expense_growth AS eg ON st.period = eg.period
ORDER BY st.period, cg.category;
