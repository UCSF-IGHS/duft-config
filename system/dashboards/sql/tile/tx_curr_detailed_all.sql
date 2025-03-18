SELECT  "ART Number","Sex", "Date Of Birth",  "ART Start Date","Last Visit Date","Last Next Visit Date" as "Next Visit","MMP Status",  "ART Outcomes" 
FROM analysis.fact_sentinel_event 
WHERE "TX Curr" = 'Yes' 