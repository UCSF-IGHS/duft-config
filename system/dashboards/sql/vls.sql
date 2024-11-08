SELECT ag.paeds_adult_age_group as "Patient category","ART Number Legacy", "Date Of Birth","Current Age","Sex", "Last PBFW" as "Pregnancy/BF status", "Last Visit Date" as "Last appt date", "Last Next Visit Date" as "Next appt date", "Last Viral Load Order Date" as "Last VL order date", "Last Viral Load Result Date" as "Last VL result date" ,"Last Regimen" as "Current Regimen", "Last Regimen Date" as "Current regimen start date","ART Restart Date", "Last Viral Load Result" as "Last VL Result", "Last Viral Load Result Category" as "Last VL category",  "Client Status"  FROM analysis.fact_sentinel_event se INNER JOIN analysis.dim_age_group ag ON se."Current Age"=ag.age WHERE "TX Curr" = 'Yes'