# Olist Analysis

This folder contains the cleaned and organized SQL workflow for the Olist Brazilian E-commerce analysis project.

## File structure

- `01_Database_Setup.sql` — Primary/Foreign Keys and structural setup.
- `02_Data_Exploration.sql` — First look at tables, columns, categories and basic distributions.
- `03_Data_Quality_Checks.sql` — NULLs, duplicates, invalid ranges and standardization checks.
- `04_Data_Cleaning.sql` — Cleaning actions applied after investigation.
- `05_Descriptive_Analysis.sql` — Core descriptive KPIs and summaries.
- `06_Business_Analysis.sql` — Portfolio-ready business questions and analysis.

## Recommended execution order

1. Import the CSV files.
2. Run `02_Data_Exploration.sql`.
3. Run `03_Data_Quality_Checks.sql`.
4. Apply only the appropriate actions from `04_Data_Cleaning.sql`.
5. Add relational constraints from `01_Database_Setup.sql` after the data is validated.
6. Run `05_Descriptive_Analysis.sql`.
7. Run `06_Business_Analysis.sql`.

## Important analytical note

Several business analyses combine order-level, item-level and review-level tables. Before using those results in a final dashboard, validate that one-to-many joins are not multiplying rows in a way that biases averages or sums.
