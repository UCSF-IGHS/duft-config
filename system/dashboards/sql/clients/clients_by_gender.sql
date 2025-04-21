SELECT gender as category, COUNT(client_id) as value from dim_client group by category
