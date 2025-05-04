-- Task 1 
-- Create a database, import, and check the data
CREATE DATABASE IF NOT EXISTS pandemic;
USE pandemic;

-- Select top 20 rows from the infectious_cases table
SELECT * FROM infectious_cases LIMIT 20;

-- Count the number of rows in the infectious_cases table
SELECT COUNT(*) FROM infectious_cases;


-- Task 2
-- Drop tables if exists 
-- Drop infectious_normalized table first, because it has FOREIGN KEY reference to entities
DROP TABLE IF EXISTS infectious_normalized;
-- Drop the table entities
DROP TABLE IF EXISTS entities;

-- Create a new table for entities:
CREATE TABLE entities (
    entity_id INT AUTO_INCREMENT PRIMARY KEY,
    entity_name VARCHAR(255),
    code VARCHAR(50)
);

-- Create a new table for infectious cases normalized
CREATE TABLE infectious_normalized (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_id INT,
    year INT,
    number_yaws INT,
    polio_cases INT,
    guinea_worm_cases INT,
    number_rabies FLOAT,
    number_malaria FLOAT,
    number_hiv FLOAT,
    number_tuberculosis FLOAT,
    number_smallpox INT,
    number_cholera_cases INT,
    FOREIGN KEY (entity_id) REFERENCES entities(entity_id)
);

-- Insert data into the entities table
INSERT INTO entities (entity_name, code)
SELECT DISTINCT Entity, Code FROM infectious_cases;

-- Insert data into the infectious_normalized table

INSERT INTO infectious_normalized (
    entity_id,
    year,
    number_yaws,
    polio_cases,
    guinea_worm_cases,
    number_rabies,
    number_malaria,
    number_hiv,
    number_tuberculosis,
    number_smallpox,
    number_cholera_cases
)
SELECT 
    e.entity_id,
    ic.Year,
    ic.Number_yaws,
    ic.polio_cases,
    ic.cases_guinea_worm,
    ic.Number_rabies,
    ic.Number_malaria,
    ic.Number_hiv,
    ic.Number_tuberculosis,
    ic.Number_smallpox,
    ic.Number_cholera_cases
FROM infectious_cases ic
JOIN entities e ON ic.Entity = e.entity_name AND ic.Code = e.code;

-- Check the data in the entities table
SELECT * FROM entities;
-- Check the data in the infectious_normalized table
SELECT * FROM infectious_normalized LIMIT 20;

-- Task 3
-- Analyze the data: aggregate the number of rabies cases by entity
SELECT 
    e.entity_name,
    e.code,
    AVG(inor.number_rabies) AS avg_rabies,
    MIN(inor.number_rabies) AS min_rabies,
    MAX(inor.number_rabies) AS max_rabies,
    SUM(inor.number_rabies) AS total_rabies
FROM infectious_normalized inor
JOIN entities e ON inor.entity_id = e.entity_id
WHERE inor.number_rabies IS NOT NULL
GROUP BY e.entity_name, e.code
ORDER BY avg_rabies DESC
LIMIT 10;

-- Task 4
-- Column with diff between year and current date

SELECT 
    id,
    year,
    DATE(CONCAT(year, '-01-01')) AS year_date,
    CURRENT_DATE() AS c_date,
    TIMESTAMPDIFF(YEAR, DATE(CONCAT(year, '-01-01')), CURRENT_DATE()) AS year_difference
FROM infectious_normalized;

-- Task 5
-- Create function to calculate the difference between the year and the current date

DROP FUNCTION IF EXISTS year_diff;

DELIMITER //

CREATE FUNCTION year_diff(input_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, DATE(CONCAT(input_year, '-01-01')), CURRENT_DATE());
END //


DELIMITER ;

-- Example of usage
SELECT 
    id, 
    year, 
    year_diff(year) AS year_difference
FROM infectious_normalized;
