# SF Restaurant Inspection Trends Analysis

## 📊 Project Overview
Analyzing year-over-year trends in San Francisco restaurant health violations to identify patterns in compliance and public health outcomes. This analysis demonstrates how data can inform regulatory priorities and restaurant operational improvements.

## 🎯 Business Question
**How have restaurant inspection violation trends changed over time in San Francisco? Which violation types are increasing or decreasing?**

## 📁 Data Source
- **Dataset:** [Health Inspection Scores (2016–2019)](https://data.sf.gov/d/pyih-qa8i)
- **Publisher:** San Francisco Department of Public Health via DataSF
- **Geographic Scope:** San Francisco, California

## 🔍 Methodology

### Data Collection
- Downloaded SF Open Data restaurant inspection dataset from DataSF.
- Imported the CSV file into SQLite for querying and analysis.
- Examined inspection dates, inspection types, and violation descriptions to understand the structure and coverage of the data.

### Data Quality and Coverage
- Exploratory analysis revealed uneven monthly coverage in the imported dataset: 2016 records appear only from October through December, while 2019 inspection counts drop sharply beginning in October.
- Because these differences can distort comparisons of raw annual violation counts, the primary trend analysis compares **January through September** across **2017, 2018, and 2019**.
- October-December data will be omitted from data analysis for accuracy.

### Analysis Approach
1. **Temporal Aggregation:** Grouped violations by year and violation type
2. **Trend Calculation:** Calculated year-over-year changes and growth rates
3. **Pattern Identification:** Identified top increasing/decreasing violation types

### Tools Used
- **SQL** — Data extraction, aggregation, and trend analysis
- **SQLite** — Database for storing and querying restaurant inspection data
- **DBeaver** — SQL development environment for running queries and inspecting results
- **Google Docs** — Report writing and project documentation
- **GitHub** — Version control and project documentation

## 📈 Key Findings
*In progress — findings will be finalized after the comparable-period analysis.*

- **Finding 1:** [Violation type] increased by X% from 2016 to 2019
- **Finding 2:** [Neighborhood/category] shows [trend description]
- **Finding 3:** [Actionable insight for stakeholders]

**Impact:** These trends suggest [business implication for regulators/restaurants]

## 🚀 How to Use

1. Download the dataset from this link: https://data.sf.gov/Health-and-Social-Services/Health-Inspection-Scores-2016-2019-/pyih-qa8i/about_data/
2. Run the SQL queries in `queries.sql` against your database (author recommends SQLite)
3. Review findings in `analysis_report.md` [not created yet]

## 💡 Key Takeaways

This project demonstrates:
- ✅ SQL proficiency (aggregation, time-series analysis, filtering)
- ✅ Data storytelling (converting data into insights)
- ✅ Business analysis (identifying trends and implications)
- ✅ BI visualization (Power BI dashboard creation)

## 📧 Questions?

Feel free to reach out via LinkedIn or GitHub:
- GitHub: https://github.com/CTsui_Dev
- LinkedIn: https://linkedin.com/in/calvintsui
