USE hrs;
CREATE TABLE duplicate_hrs AS SELECT * FROM hr.hrs;
SELECT * FROM hrs LIMIT 50;

ALTER TABLE hrs
RENAME COLUMN ï»¿id TO emp_id;

SELECT birthdate FROM hrs LIMIT 50;

UPDATE hrs
SET birthdate= CASE 
    WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d') 
	WHEN birthdate LIKE '%-%' THEN DATE_FORMAT(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d') 
	ELSE NULL
END;

ALTER TABLE hrs
MODIFY COLUMN birthdate DATE;

UPDATE hrs
SET hire_date= CASE 
    WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d') 
	WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d') 
	ELSE NULL
END;
ALTER TABLE hrs
MODIFY COLUMN hire_date DATE;

UPDATE hrs
SET termdate=('%Y-%m-%d');

UPDATE hrs
SET termdate= 
(CASE 
	WHEN termdate is not null AND termdate!='' THEN DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC')) 
	ELSE termdate=NULL 
END);

ALTER TABLE hrs ADD COLUMN age INT;
SELECT * FROM hrs LIMIT 50;


---------------------------------------------------------------------------------------------------

SELECT(SELECT COUNT(*) FROM hrs WHERE AGE=''),(SELECT COUNT(*) FROM hrs WHERE AGE<0);

-- To get the age
UPDATE hrs
SET age=timestampdiff(YEAR, birthdate, CURDATE());


-- Group the distribution of age by label

SELECT 
MIN(age) 'Youngest',
MAX(age) 'Oldest'
FROM hrs;

SELECT COUNT(*) 'AGE<18' FROM hrs WHERE age<18;

-- What is the gender breakdown of employees in the company?
SELECT COUNT(*) 'Count', gender FROM hrs WHERE age>=18 AND termdate IS NULL GROUP BY gender ORDER BY Count DESC;
-- The WHERE clause filters for employees who are aged 18 and above (age >= 18) and have not yet terminated their employment.

-- What is the race/ethnicity breakdown of employees in the company?
SELECT COUNT(*) 'Count', race FROM hrs WHERE age>=18 AND termdate IS NULL  GROUP BY race ORDER BY Count DESC;

-- What is the age distribution of employees in the company?

SELECT gender, Count(*) AS 'Emp_Count', (
CASE 
	WHEN AGE>=18 AND AGE<=25 THEN "18-24" 
	WHEN AGE>=26 AND AGE<=34 THEN"25-34" 
	WHEN AGE>=35 AND AGE<=44 THEN "35-44" 
	WHEN AGE>=45 AND AGE<=54 THEN "44-54" 
	WHEN AGE>=55 AND AGE<=64 THEN "55-64" 
	ELSE '65+' 	
END) AS Age_group FROM hrs
WHERE age>=18 AND termdate IS NULL
GROUP BY Age_group, gender
ORDER BY Age_group, gender;

-- What is the distribution of employees across locations by city and state?
SELECT location_state, COUNT(*) 'emp_count' FROM hrs WHERE age>=18 AND termdate IS NULL GROUP BY 1 ORDER BY emp_count DESC;

-- How many employees work at headquarters versus remote locations?
SELECT location, COUNT(*) FROM hrs WHERE age>=18 AND termdate IS NULL GROUP BY location;

-- What is the average length of employement for employees who have been terminated?
SELECT ROUND((AVG(DATEDIFF(termdate, hire_date))/365),0) 'avg_length_employment' 
FROM hrs WHERE termdate<CURDATE() AND termdate IS NOT NULL AND age>=18; -- In years

-- How has the company's employees count changed over time based on hire team and term dates?
-- Here hire_date is the hiring date of an employee and termdate is indicating termination or end of employment

SELECT YEAR(hire_date) AS hire_year,Count(*) 'hire_count', COUNT(termdate) AS term_count FROM hrs GROUP BY hire_year;

SELECT hire_year, hires, terminations, hires-terminations 'Net Change', ROUND(hires-terminations/hires*100,2) AS Net_change_percentage FROM(
SELECT  YEAR(hire_date) 'hire_year', COUNT(*) AS hires, SUM(CASE WHEN termdate IS NOT NULL AND termdate<=CURDATE() THEN 1 ELSE 0 END) AS terminations 
FROM hrs WHERE age>=18 GROUP BY hire_year) AS S;

-- What is the tenure distribution for each department
-- Employee tenure is the length of time an employee works for an employer.

SELECT department, ROUND(AVG(DATEDIFF(termdate, hire_date)/365),0) 'Avg_emp_tenure', MIN(DATEDIFF(termdate, hire_date)) 'Min_tenure', MAX(DATEDIFF(termdate, hire_date)) 'Max_tenure' 
FROM hrs WHERE age>=18 AND termdate<=CURDATE() AND termdate IS NOT NULL GROUP BY department;

-- What is the distribution of jon titles across the company?
SELECT jobtitle, COUNT(*) 'Count' FROM hrs WHERE age>=18 AND termdate IS NULL GROUP BY jobtitle ORDER BY Count DESC;

-- How does the gender distribution vary across the departments and job titles?
SELECT department, gender, COUNT(*) 'Count' FROM hrs WHERE age>=18 AND termdate IS NULL GROUP BY 1,2 ORDER BY 1;

-- Which department has highest turnover?
-- How long the employees work in a company before they leave or fired

SELECT department, total_count, terminated_count, terminated_count/total_count AS termination_rate FROM(
SELECT department, count(*) 'total_count', SUM(CASE WHEN termdate IS NOT NULL AND termdate<=CURDATE() THEN 1 ELSE 0 END) 'terminated_count' FROM hrs GROUP BY 1) AS A 
ORDER BY termination_rate;


SELECT * FROM hrs LIMIT 50;
