SELECT
    CONCAT('Previous Week (', drw.previous_week_dates, ')') AS report_week_dates,
    cfg.FacilityBiomServer AS facility_name
FROM
    duft.dim_reporting_week drw
CROSS JOIN
    ctc_a_source.dbo.tblConfig cfg;