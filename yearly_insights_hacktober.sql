WITH yearly_totals AS (
    SELECT 
        year,
        SUM(amount) AS total_expense,
        SUM(investment_amount) AS total_investment,
        ROUND(SUM(amount) / 12, 2) AS avg_monthly_expense  -- Assumes 12 months for average
    FROM wrk
    GROUP BY year
),
category_expenses AS (
    SELECT 
        year,
        category,
        SUM(amount) AS category_expense
    FROM wrk
    GROUP BY year, category
),
needs_vs_wants AS (
    SELECT 
        year,
        SUM(CASE WHEN category = 'needs' THEN amount ELSE 0 END) AS total_needs,
        SUM(CASE WHEN category = 'wants' THEN amount ELSE 0 END) AS total_wants
    FROM wrk
    GROUP BY year
),
expense_growth AS (
    SELECT 
        year,
        total_expense,
        LAG(total_expense) OVER (ORDER BY year) AS previous_year_expense,
        ROUND((total_expense - LAG(total_expense) OVER (ORDER BY year)) / 
              NULLIF(LAG(total_expense) OVER (ORDER BY year), 0) * 100, 2) AS growth_rate
    FROM yearly_totals
)

-- Combining all insights into a single output
SELECT 
    yt.year,
    yt.total_expense,
    yt.total_investment,
    yt.avg_monthly_expense,
    ce.category,
    ce.category_expense,
    nw.total_needs,
    nw.total_wants,
    eg.previous_year_expense,
    eg.growth_rate
FROM yearly_totals AS yt
LEFT JOIN category_expenses AS ce ON yt.year = ce.year
LEFT JOIN needs_vs_wants AS nw ON yt.year = nw.year
LEFT JOIN expense_growth AS eg ON yt.year = eg.year
ORDER BY yt.year, ce.category;
