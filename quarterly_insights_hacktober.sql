SELECT 'Q1' AS quarter, SUM(amount) AS total_expense
FROM wrk
WHERE month IN ('April', 'May', 'June')
UNION
SELECT 'Q2', SUM(amount)
FROM wrk
WHERE month IN ('July', 'August', 'September')
UNION
SELECT 'Q3', SUM(amount)
FROM wrk
WHERE month IN ('October', 'November', 'December')
UNION
SELECT 'Q4', SUM(amount)
FROM wrk
WHERE month IN ('January', 'February', 'March');
