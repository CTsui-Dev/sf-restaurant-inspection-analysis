-- San Francisco Restaurant Inspection Analysis
-- Dataset: Health_Inspection_Scores_(2016-2019)_20261004.csv

-- ============================================================
-- ==                          Setup                         ==
-- ============================================================

-- Rename the imported table to a shorter, easier-to-use name
ALTER TABLE Health_Inspection_Scores
RENAME TO health_inspections;

-- ============================================================
-- ==                Initial data exploration                ==
-- ============================================================

-- View sample records
SELECT *
FROM health_inspections
LIMIT 10;
