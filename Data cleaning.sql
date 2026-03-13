--- SQL Project - Data Cleaning --- Layoffs

Select * from layoffs;

-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens

CREATE TABLE layoffs.layoffs_staging 
LIKE layoffs.layoffs;

--- then insert same data which is there in raw table into layoffs_staging

Insert layoffs_staging
select * from layoffs.layoffs;

-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways

--- Remove duplicates 

# Lets check for duplicates

select * from layoffs;

--- Here it will give row_number for each row
select company, industry, total_laid_off, 'date',
row_number () over (partition by company, industry, total_laid_off, 'date') 
as r_n 
from
staging_layoffs; 

--- then we will find duplicate

select * from 
            (select company, industry, total_laid_off, 'date',
row_number () over (partition by company, industry, total_laid_off, 'date') 
as r_n 
from layoffs) duplicates
where r_n > 1;
--- Now we need to confirm if these true entries or not 
select * from staging_layoffs
where company = 'oda'; --- here you can entries are true but only company & industry & total_laid_off, date is duplicate but rest other true entries

--- now we need to find real duplicates with all coloumn names
 
select * 
  from 
  (select company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
  row_number () over (partition by company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions)
  as row_numb
from staging_layoffs
)duplicates
where row_numb > 1;

--- IF WE DELETE THE VALUES WHICH ROW_NUM > 1 USING DELETE CTE IT WONT WORK

with delete_CTE as 
(
select * from (
select *, row_number () over (partition by company, location, industry, 
total_laid_off, percentage_laid_off,'date', 
stage, country, funds_raised_millions) as r_n
from layoffs_staging)duplicates
where ROW_NUM > 1)
delete from delete_cte;

--- NOW WE NEED TO CREATE A NEW DELETE AND INSERT THE VALUES WITH ROW_NUM
CREATE TABLE `layoffs_staging1` (
  `company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
row_num INT
); -- HERE WE ADDED ROW_NUM AS NEW COLOUMN & UPDATING THE SAME DATA WHICH IS IN LAYOFFS_STAGING

INSERT INTO layoffs_staging1
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off,
            percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM layoffs_staging;

-- NOW IF WE SEARCH FOR DUPLICATE VALUES LIKE ROW_NUM>1 - THOSE ARE TRUE DUPLICATES WE CAN DELETE THEM

DELETE FROM layoffs_staging1
WHERE ROW_NUM >1;

--- NOW ALL DUPLICATES ARE DELETED

-- 2. Standardize Data

SELECT * 
FROM layoffs_staging1;

-- if we look at industry it looks like we have some null and empty rows, let's take a look at these
SELECT DISTINCT industry
FROM layoffs_staging1
ORDER BY industry;

SELECT *
FROM layoffs_staging1
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- let's take a look at these
SELECT *
FROM layoffs_staging1
WHERE company LIKE 'Bally%';
-- nothing wrong here
SELECT *
FROM layoffs_staging1
WHERE company LIKE 'airbnb%';

-- it looks like airbnb is a travel, but this one just isn't populated.
-- I'm sure it's the same for the others. What we can do is
-- write a query that if there is another row with the same company name, it will update it to the non-null industry values
-- makes it easy so if there were thousands we wouldn't have to manually check them all

-- we should set the blanks to nulls since those are typically easier to work with
UPDATE layoffs_staging1
SET industry = NULL
WHERE industry = '';

-- now if we check those are all null

SELECT *
FROM layoffs_staging1
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- now we need to populate those nulls if possible

UPDATE layoffs_staging1 t1
JOIN layoffs_staging1 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- and if we check it looks like Bally's was the only one without a populated row to populate this null values
SELECT *
FROM layoffs_staging1
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- ---------------------------------------------------

-- I also noticed the Crypto has multiple different variations. We need to standardize that - let's say all to Crypto
SELECT DISTINCT industry
FROM layoffs_staging1
ORDER BY industry;

UPDATE layoffs_staging1
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- OR WE CAN UPDATE LIKE THIS

UPDATE layoffs_staging1
SET industry = 'Crypto'
WHERE industry LIKE 'CRYPTO%'

-- now that's taken care of:
SELECT DISTINCT industry
FROM layoffs_staging1
ORDER BY industry;

-- --------------------------------------------------
-- we also need to look at 

SELECT *
FROM layoffs_staging1

-- everything looks good except apparently we have some "United States" and some "United States." with a period at the end. Let's standardize this.
SELECT DISTINCT country
FROM layoffs_staging1
ORDER BY country;

UPDATE layoffs_staging1
SET country = TRIM(TRAILING '.' FROM country);

-- now if we run this again it is fixed
SELECT DISTINCT country
FROM layoffs_staging1
ORDER BY country;


-- Let's also fix the date columns:
SELECT *
FROM layoffs_staging1

-- we can use str to date to update this field
UPDATE layoffs_staging1
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- now we can convert the data type properly
ALTER TABLE layoffs_staging1
MODIFY COLUMN `date` DATE;


SELECT *
FROM layoffs_staging1


-- 3. Look at Null Values

-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase

-- so there isn't anything I want to change with the null values


-- 4. remove any columns and rows we need to

SELECT *
FROM layoffs_staging1
WHERE total_laid_off IS NULL;


SELECT *
FROM layoffs_staging1
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use
DELETE FROM layoffs_staging1
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging1

ALTER TABLE layoffs_staging1
DROP COLUMN row_num;


SELECT * 
FROM layoffs_staging1
