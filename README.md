# SQL---Portfolio-Project---Data-Cleaning.sql
Raw data comes → stays in staging → gets cleaned → then moved to final tables.

External Data
      ↓
STAGING TABLE (raw)
      ↓
CLEANING + TRANSFORMATION
      ↓
FINAL TABLE (analytics ready)


SQL Data cleaning checks
--------------------------
1.Check for NULL Values - Its effects the calculation & breakdown the total value
2.Check for duplicate values - Duplicates inflate revenue and totals.
3.Check Data Types - Dates are DATE type, Amounts are DECIMAL, IDs are INT (Wrong datatype = wrong sorting & calculations)
4.Check for Negative or Impossible Values - Business logic validation is critical.
5.Check Date Ranges - Future or very old dates = entry error.
6.Check Referential Integrity - Missing customer means broken relationship.
7.Check Outliers -Extremely high numbers may be wrong entries.
8.Check Consistency (Text Columns) 
9.Check Missing Categories
10.Validate Business Logic


