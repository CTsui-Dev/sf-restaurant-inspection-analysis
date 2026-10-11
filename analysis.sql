-- San Francisco Restaurant Inspection Analysis
-- Dataset: Health_Inspection_Scores_(2016-2019)_20261004.csv

-- ============================================================
-- ==                          Setup                         ==
-- ============================================================

-- Rename the imported table to a shorter, easier-to-use name
ALTER TABLE Health_Inspection_Scores
RENAME TO health_inspections;

-- ============================================================
-- ==                    Data exploration                    ==
-- ============================================================

-- View sample records
SELECT *
FROM health_inspections
LIMIT 10;

/* Every CSV does their date format a little differently. Run this command to see how sf.data formats their dates. */
-- Check inspection date values and their stored data type
SELECT 
    inspection_date,
    typeof(inspection_date)
FROM health_inspections;
/* Inspection dates are stored as TEXT in the format YYYY Mon DD HH:MM:SS AM/PM. */

-- Counts how often each violation description appears in each year.
SELECT
    substr(inspection_date, 1, 4) AS year,
    violation_description,
    COUNT(*) AS total_violations
FROM health_inspections
WHERE violation_description IS NOT NULL
  AND TRIM(violation_description) <> ''
GROUP BY substr(inspection_date, 1, 4), violation_description
ORDER BY year, total_violations DESC;
/*Note: A higher count doesn't necessarily mean a violation became more common: there might have been more inspections that year.
It is time to compare each violation type across years and identify which increased or decreased. */

-- Compare violation trends from 2016 to 2019
WITH violation_by_year AS (
    -- Count occurrences of each violation description per year
    SELECT
        substr(inspection_date, 1, 4) AS year,
        TRIM(violation_description) AS violation_description,
        COUNT(*) AS total_violations
    FROM health_inspections
    WHERE inspection_date IS NOT NULL
      AND violation_description IS NOT NULL
      AND TRIM(violation_description) <> ''
    GROUP BY
        substr(inspection_date, 1, 4),
        TRIM(violation_description)
),
violation_trends AS (
    -- Pivot yearly counts into separate columns for comparison
    SELECT
        violation_description,
        SUM(CASE WHEN year = '2016' THEN total_violations ELSE 0 END) AS count_2016,
        SUM(CASE WHEN year = '2017' THEN total_violations ELSE 0 END) AS count_2017,
        SUM(CASE WHEN year = '2018' THEN total_violations ELSE 0 END) AS count_2018,
        SUM(CASE WHEN year = '2019' THEN total_violations ELSE 0 END) AS count_2019
    FROM violation_by_year
    GROUP BY violation_description
)
SELECT
    violation_description,
    count_2016,
    count_2017,
    count_2018,
    count_2019,

    -- Calculate the absolute change in recorded counts
    count_2019 - count_2016 AS count_change,

    -- Calculate percentage change when a 2016 baseline exists
    CASE
        WHEN count_2016 > 0 THEN
            ROUND(
                (count_2019 - count_2016) * 100.0 / count_2016,
                2
            )
    END AS percent_change,

    -- Classify the trend between the first and last years
    CASE
        WHEN count_2016 = 0 AND count_2019 > 0
            THEN 'No 2016 baseline'
        WHEN count_2019 > count_2016
            THEN 'Increased'
        WHEN count_2019 < count_2016
            THEN 'Decreased'
        ELSE 'No change'
    END AS trend

FROM violation_trends

-- Show larger percentage increases first; put zero-baseline types last
ORDER BY
    CASE WHEN count_2016 = 0 THEN 1 ELSE 0 END,
    percent_change DESC;
