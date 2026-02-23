create database  Hr_analytics;
use  Hr_analytics;
select * from hr_analytics_intermediate_dataset;

# 1.What is the attrition rate per department as a percentage of department size?
select department,count(*) as No_of_Employees,sum(attrition='Yes') as Attrition_employees,round(sum(attrition='Yes')*100/count(*),2) as Attrition_Percentage
from hr_analytics_intermediate_dataset
group by department 
order by Attrition_Percentage desc;

#2. Which employees earn more than their department’s average salary?
with deptsal as 
(select department,avg(salary) as AvgSalary
from hr_analytics_intermediate_dataset
group by department)
select e.name,e.department,e.salary
from  hr_analytics_intermediate_dataset as e
join deptsal as d on e.department = d.department
where e.salary > d.AvgSalary;

#3. 	What is the current active headcount by location and department?
select department,location,count(attrition) as Activecount
from hr_analytics_intermediate_dataset
where attrition='No'
group by department,location;

#4.	Which departments have the highest average salary?
select department,round(avg(salary),2) as Avgsal 
from hr_analytics_intermediate_dataset
group by department
order by Avgsal 
limit 3;

#5.	Which job roles have the highest attrition count?
select job_role,count(attrition) as Attrition
from hr_analytics_intermediate_dataset
where attrition='No'
group by job_role
order by Attrition;

#6.	List employees who haven’t been promoted in the last 3 years.
select name,year(last_promotion_date) as Promotion from hr_analytics_intermediate_dataset
where last_promotion_date not in('2025','2024','2023')
order by promotion;

#7.	Who are the top 3 earners in each department?
with ranked_salaries as
(select department,name as Top_earners,salary,rank() over(partition by department order by salary desc ) as dept_salary_rank
from hr_analytics_intermediate_dataset)
select * from ranked_salaries
where dept_salary_rank<=3;

#8.	Which employees had low performance ratings (less than 3) and have also left the company?
select name,performance_rating,attrition
from hr_analytics_intermediate_dataset
where performance_rating<3 and attrition='Yes';

#9. 9.	What is the average performance rating per department?

select department,round(avg(performance_rating),1) as avg_rating
from hr_analytics_intermediate_dataset
group by department;

# 10.	Which departments have the highest proportion of high performers (rating 4 or 5)?

select department,performance_rating,count(*) as performers,
count(*)*1.0/sum(count(*)) over (order by performance_rating desc) as proportion
from hr_analytics_intermediate_dataset
where performance_rating>3
group by department,performance_rating;

# 11.	How many years has each employee worked in the company (rounded)?
select name,round(datediff(curdate(),hire_date)/365,0) as Years_emp_worked
from hr_analytics_intermediate_dataset
order by Years_emp_worked desc;

# 12.	Group employees into tenure buckets:	< 1 Year 1–3 Years 3–5 Years 	5+ Years
	

select name,round(datediff(curdate(),hire_date)/365,0) as experience,
CASE
WHEN experience BETWEEN 3 AND 5 THEN '3-5 years'
WHEN experience BETWEEN 1 AND 3 THEN '1-3 years'
WHEN experience <1 then '<1 year'
else '>5 years'
END AS emp_t
from hr_analytics_intermediate_dataset
order by experience desc;

#13 . What is the average tenure per department?
with tenure as
(select department,round(datediff(curdate(),hire_date)/365,0) as experience
from hr_analytics_intermediate_dataset)
select department,round(avg(experience),2) as avg_tenure
from tenure
group by department;


#14. How many employees were hired monthly in the last 2 years?

select monthname(hire_date) as  Month, date_format(hire_date,'%Y-%m') as Date ,count(*) employees
from hr_analytics_intermediate_dataset
where date_format(hire_date,'%Y-%m') between '2023-01' and '2025-12'
group by Month,Date
order by Date desc;

#15.  Who has completed more than 5 years in the organization?
select name,round(datediff(curdate(),hire_date)/365,0) as Year
from  hr_analytics_intermediate_dataset
where round(datediff(curdate(),hire_date)/365,0)>5
order by Year;

#16. Which department has the highest attrition rate?
with attrition_count as 
(select department,count(*) as No_ofemployees,
count(case when attrition='Yes' then 1 end) as Attrition
from  hr_analytics_intermediate_dataset
group by department)
select department,round((Attrition/No_ofemployees)*100,1) as Attrition_rate
from attrition_count
order by Attrition_rate desc
limit 1;

#17.  What percentage of employees were promoted in the last 2 years?
with promotion as 
(select year(last_promotion_date) as promotion_date,count(employee_id) as employees
from hr_analytics_intermediate_dataset
group by year(last_promotion_date))
select promotion_date,round((sum(employees)/300)*100,1) as '%ofemppromoted'
from promotion
where promotion_date between '2023' and '2025'
group by promotion_date
order by promotion_date;

#18.  What is the most common education level among those who left?
select education_level,attrition,count(*) as emp_left
from hr_analytics_intermediate_dataset
where attrition='Yes'
group by education_level
order by emp_left desc
limit 1;

#19.  Identify “at-risk” employees (low performance, no promotion, specific age criteria).

select name,performance_rating,year(last_promotion_date) as promotion,age
from hr_analytics_intermediate_dataset
where performance_rating<3 and
year(last_promotion_date) not between '2023' and '2025' and
age between '30' and  '50'
order by promotion;

#20. What percentage of each department’s employees are “at-risk”?
with percentage as 
(select count(*) as employees,department,
count(case when performance_rating<3 then 1 end) as at_risk
from hr_analytics_intermediate_dataset
group by department)
select employees,department,at_risk,round((at_risk*100)/employees,1) as risk_rate
from percentage 
order by risk_rate desc;





