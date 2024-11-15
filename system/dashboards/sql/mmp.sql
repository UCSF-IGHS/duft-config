SELECT ag.paeds_adult_age_group as "Patient category", "First Name", "Last Name",  "ART Number Legacy", "Date Of Birth", "Contact Number", "Alt Contact Number", "Current Age","Sex", "Last PBFW" as "Pregnancy/BF status", "Last Visit Date" as "Last appt date", "Last Next Visit Date" as "Next appt date", "Last Viral Load Order Date" as "Last VL order date", "Last Viral Load Result Date" as "Last VL result date" ,"Last Regimen" as "Current ART Regimen", "Last Regimen Date" as "Current ART Regimen start date","ART Restart Date", "MMP Status",  "Client Status" FROM analysis.fact_sentinel_event se INNER JOIN analysis.dim_age_group ag ON se."Current Age"=ag.age WHERE "TX Curr" = 'Yes'