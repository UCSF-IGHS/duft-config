SELECT category, sum("Not Initiated") as "Not Initiated", sum(Initiated)  as Initiated FROM vw_diagnosed_vs_initiated_vs_exited GROUP BY category ORDER BY parsed_date;
