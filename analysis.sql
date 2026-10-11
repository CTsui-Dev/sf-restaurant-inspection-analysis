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


/* Though the dataset covers 2016-2019, that does not necessarily mean each calendar year has equally complete coverage. */

SELECT
    -- Count unique inspections (one inspection may have multiple violations)
    substr(inspection_date, 1, 4) AS year,
    substr(inspection_date, 6, 3) AS month,
    -- Count rows where a violation was actually recorded/documented
    -- This distinguishes between inspections WITH violations vs WITHOUT
    COUNT(DISTINCT inspection_id) AS total_inspections,
    SUM(
        CASE
            WHEN TRIM(COALESCE(violation_description, '')) <> ''
            THEN 1
            ELSE 0
        END
    ) AS recorded_violation_entries
FROM health_inspections
WHERE inspection_date IS NOT NULL
GROUP BY
    -- Group by year (first 4 characters of date string: "2017 Sep 25...")
    substr(inspection_date, 1, 4),
    -- Convert month abbreviation to numeric order (Jan=1, Feb=2, etc.)
    -- This ensures proper chronological sorting in results
    CASE substr(inspection_date, 6, 3)
        WHEN 'Jan' THEN 1
        WHEN 'Feb' THEN 2
        WHEN 'Mar' THEN 3
        WHEN 'Apr' THEN 4
        WHEN 'May' THEN 5
        WHEN 'Jun' THEN 6
        WHEN 'Jul' THEN 7
        WHEN 'Aug' THEN 8
        WHEN 'Sep' THEN 9
        WHEN 'Oct' THEN 10
        WHEN 'Nov' THEN 11
        WHEN 'Dec' THEN 12
    END,
    -- Also keep month abbreviation for readability in output
    substr(inspection_date, 6, 3)
ORDER BY
    -- Sort chronologically by year first
    year,
    -- Then by numeric month within each year
    CASE substr(inspection_date, 6, 3)
        WHEN 'Jan' THEN 1
        WHEN 'Feb' THEN 2
        WHEN 'Mar' THEN 3
        WHEN 'Apr' THEN 4
        WHEN 'May' THEN 5
        WHEN 'Jun' THEN 6
        WHEN 'Jul' THEN 7
        WHEN 'Aug' THEN 8
        WHEN 'Sep' THEN 9
        WHEN 'Oct' THEN 10
        WHEN 'Nov' THEN 11
        WHEN 'Dec' THEN 12
    END;

/* 2016 was a partial year, covering only October to December. Similarly, 2019 was a partial year, showing that November only had 1 inspection and December had none. */
/* The official DataSF description identifies this as a historical dataset covering 2016–2019, not four guaranteed complete calendar years. */
/* Therefore, commit to January to September months for the years 2017 to 2019 as the primary comparison. */


/* Every CSV does their date format a little differently. Run this command to see how sf.data formats their dates. */
-- Check inspection date values and their stored data type
SELECT 
    inspection_date,
    typeof(inspection_date)
FROM health_inspections;
/* Inspection dates are stored as TEXT in the format YYYY Mon DD HH:MM:SS AM/PM. */

/* */
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
    -- Overall absolute change from 2016 to 2019
    count_2019 - count_2016 AS count_change,
    -- Overall percentage change from 2016 to 2019
    CASE
        WHEN count_2016 > 0 THEN
            ROUND(
                (count_2019 - count_2016) * 100.0 / count_2016,
                2
            )
    END AS percent_change,
    -- Year-over-year absolute changes
    count_2017 - count_2016 AS change_2016_2017,
    count_2018 - count_2017 AS change_2017_2018,
    count_2019 - count_2018 AS change_2018_2019,
    -- Year-over-year percentage changes
    CASE
        WHEN count_2016 > 0 THEN
            ROUND(
                (count_2017 - count_2016) * 100.0 / count_2016,
                2
            )
    END AS pct_change_2016_2017,
    CASE
        WHEN count_2017 > 0 THEN
            ROUND(
                (count_2018 - count_2017) * 100.0 / count_2017,
                2
            )
    END AS pct_change_2017_2018,
    CASE
        WHEN count_2018 > 0 THEN
            ROUND(
                (count_2019 - count_2018) * 100.0 / count_2018,
                2
            )
    END AS pct_change_2018_2019,
    -- Classify the overall trend between 2016 and 2019
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
-- Show categories with a 2016 baseline first, ordered by percentage change
ORDER BY
    CASE WHEN count_2016 = 0 THEN 1 ELSE 0 END,
    percent_change DESC;


SELECT
    substr(inspection_date, 1, 4) AS year,
    COUNT(DISTINCT inspection_id) AS total_inspections,
    COUNT(DISTINCT business_id) AS businesses_inspected,
    SUM(
        CASE
            WHEN TRIM(COALESCE(violation_description, '')) <> ''
            THEN 1
            ELSE 0
        END
    ) AS recorded_violation_entries,
    COUNT(
        DISTINCT CASE
            WHEN TRIM(COALESCE(violation_description, '')) <> ''
            THEN inspection_id
        END
    ) AS inspections_with_violations,
    ROUND(
        1.0 * SUM(
            CASE
                WHEN TRIM(COALESCE(violation_description, '')) <> ''
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(DISTINCT inspection_id), 0),
        2
    ) AS violations_per_inspection
FROM health_inspections
WHERE inspection_date IS NOT NULL
GROUP BY substr(inspection_date, 1, 4)
ORDER BY year;

/* */
SELECT
    substr(inspection_date, 1, 4) AS year,

    COUNT(DISTINCT inspection_id) AS total_inspections,

    COUNT(DISTINCT business_id) AS businesses_inspected,

    SUM(
        CASE
            WHEN TRIM(COALESCE(violation_description, '')) <> ''
            THEN 1
            ELSE 0
        END
    ) AS recorded_violation_entries,

    COUNT(
        DISTINCT CASE
            WHEN TRIM(COALESCE(violation_description, '')) <> ''
            THEN inspection_id
        END
    ) AS inspections_with_violations,

    ROUND(
        1.0 * SUM(
            CASE
                WHEN TRIM(COALESCE(violation_description, '')) <> ''
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(DISTINCT inspection_id), 0),
        2
    ) AS violations_per_inspection

FROM health_inspections
WHERE inspection_date IS NOT NULL
GROUP BY substr(inspection_date, 1, 4)
ORDER BY year;

