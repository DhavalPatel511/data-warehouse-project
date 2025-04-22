/*

------ Create Database and Schemas ------
---Script Purpose:
  This sscript creates a new database named 'Datawarehouse' after checking if it already exists.
  If the database exists,it is dropped and recreated. Additionally, the script sets up three schemas within the database: 'bronze','silver','gold'.

Warning:
  Running this script will drop the entrire 'Datawarehouse' database if it already exists.
  All data in the database will be permanently deleted. Proceed with caution and ensure you have proper backups before running this script.
*/
USE master;
GO

---Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sus.databases WHERE name = 'DataWarehouse' )
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

-- CREATE the 'Datawarehouse' database

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

---Create Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
