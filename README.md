# Data-Warehouse-Project

## Data Architecture
The data architecture for this project follows the Medallion Architecture pattern with Bronze, Silver, and Gold layers:

-Bronze Layer: Stores raw data ingested as-is from CSV files into a SQL Server database.

-Silver Layer: Cleansed and standardized data. This layer includes transformations such as deduplication, typecasting, and normalization to prepare data for modeling.

-Gold Layer: Business-ready, analytical data structured into a Star Schema (Fact and Dimension tables) for efficient reporting and dashboarding.

## Project Overview
This project involves:

-Data Architecture: Designing a modern data warehouse using the Medallion Architecture.

-ETL Pipelines: Extracting, transforming, and loading data from flat files into a SQL Server-based data warehouse.

-Data Modeling: Building star schema models with fact and dimension tables to support fast analytical queries.

-Analytics & Reporting: Creating SQL-based scripts and dashboards to support business decisions and uncover insights.

## SQL Analytics Scripts
This repository also includes a comprehensive collection of SQL queries designed for:

-Database exploration and profiling
-Key metrics and performance measures
-Time-based and cumulative analytics
-Segmentation and cohort analysis
-Star schema-based query patterns

These scripts demonstrate best practices and are helpful for analysts and BI engineers working with structured data.
