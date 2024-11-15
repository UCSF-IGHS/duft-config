SELECT ag.paeds_adult_age_group as "Patient category", "First Name", "Last Name", "ART Number Legacy", "Date Of Birth", "Contact Number" as "Phone 1", "Alt Contact Number" as "Phone 2","Current Age","Sex", "Ts Name" as "Treatment Supporter Name","Ts Cell Phone Number" as "Treatment Supporter Cell Phone Number","Ts Second Name" as "Treatment Supporter Second Name", "Ts Second Cell Phone Number" as "Treatment Supporter Second Cell Phone Number", "Last PBFW" as "Pregnancy/BF status", "Last Visit Date", "Last Next Visit Date" as "Next Follow-up Date", "Last Viral Load Order Date" as "Last VL order date", "Last Viral Load Result Date" as "Last VL result date" ,"Last Regimen" as "Current ART Regimen", "Last Regimen Date" as "Current ART Regimen start date","ART Restart Date", "Retention Status", "Client Status"  FROM analysis.fact_sentinel_event se INNER JOIN analysis.dim_age_group ag ON se."Current Age"=ag.age