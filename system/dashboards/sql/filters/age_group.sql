SELECT 
    tri_pillar_age_group 
FROM 
(
    SELECT DISTINCT tri_pillar_age_group, tri_pillar_age_group_val from analysis.dim_age_group ORDER BY tri_pillar_age_group_val
) a