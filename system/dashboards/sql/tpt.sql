SELECT ag.paeds_adult_age_group as "Patient category", "First Name", "Last Name","ART Number Legacy", "Date Of Birth","Contact Number", "Alt Contact Number","Current Age","Sex", "Last PBFW" as "Pregnancy/BF status", "Last Visit Date" as "Last appt date", "Last Next Visit Date" as "Next appt date", "Last Viral Load Order Date" as "Last VL order date", "Last Viral Load Result Date" as "Last VL result date",  "TPT Start Date", "TPT Type" as "TPT Regimen", "TPT Actual Stop Date","TPT Expected Stop Date", "TBT Regimen" as "TB treatment", "TBT Start Date" as "TB tx start date", "TBT Expected Stop Date" as "TB tx end date", "TBT Outcome" as "Last TB screening outcome","Last Regimen" as "Current Regimen", "Last Regimen Date" as "Current regimen start date", "TPT Status Two", "Client Status" FROM analysis.fact_sentinel_event se INNER JOIN analysis.dim_age_group ag ON se."Current Age"=ag.age WHERE  "TX Curr" = 'Yes'