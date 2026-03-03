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
select 
