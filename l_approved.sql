create database bank_loan;
use bank_loan;

select * from loan_approved_clean;
select count(*) from loan_approved_clean;

alter table loan_approved_clean rename to l_approved;
select * from l_approved;

alter table l_approved drop column Myunknowncolumn;
select * from l_approved;

-- SECTION 1 - Basic SQL Queries 
-- 1. View the first 10 records from the table. 
select * from l_approved limit 10;

-- 2. Count the total number of loan applications. 
select count(*) as total_applicants from l_approved;

-- 3. List all unique property areas. 
select distinct(property_area) from l_approved;

-- 4. Show all applicants who are self-employed and have an income above 5000. 
select * from l_approved where Self_Employed = 'Yes' and ApplicantIncome>5000;
select count(*) from l_approved where Self_Employed = 'Yes' and ApplicantIncome>5000;

-- 5. Find the total number of approved loans. 
select count(*) from l_approved where loan_status = 'Y';

-- SECTION 2 - Aggregation & Grouping 
-- 6. Find average loan amount by education level. 
select education, round(avg(loanamount), 2) as avg_loan_amount from l_approved group by education;

-- 7. Find average total income (Applicant + Coapplicant) by marital status.
select Married, round(avg(applicantincome+coapplicantincome), 2) as avg_total_income 
from l_approved group by Married;
 
-- 8. Show average loan amount by credit history. 
select Credit_History, round(avg(loanamount), 2) as avg_loan_amount from l_approved
group by Credit_History;

-- 9. Find total applications and approval rate by gender. 
select
      gender,
      count(*) as applicants,
      sum(case when loan_status = 'Y' then 1 else 0 end) as approved,
      sum(case when loan_status = 'Y' then 1 else 0 end)/count(*)*100 as approval_rate
      from l_approved
group by Gender;

-- 10. Show approval rate by property area.

-- SECTION 3 - Filtering & Conditions 
-- 11. Show applicants who are graduates, not self-employed, and have loan amount greater than 150.
select * from l_approved where Education = 'Graduate' and Self_Employed = 'No' and
LoanAmount>150;
select count(*) from l_approved where Education = 'Graduate' and Self_Employed = 'No' and
LoanAmount>150;
 
-- 12. Display approved loans from urban area with good credit history. 
select * from l_approved where Property_Area = 'urban' and
Credit_History = 1;
select count(*) from l_approved where Property_Area = 'urban' and
Credit_History = 1;

-- 13. List top 5 applicants with highest total income.
select * from l_approved order by ApplicantIncome+CoapplicantIncome desc limit 5;

-- SECTION 4 - Derived Columns & CASE WHEN 
-- 14. Create derived columns for total income for each applicant. 
select *, ApplicantIncome+CoapplicantIncome as total_income from l_approved;

-- 15. Classify applicants into income groups (Low, Medium, High) based on applicant income. 
select * from l_approved;
select Loan_id,
       applicantincome,
       case
           when applicantincome <= 3000 then 'Low Income'
           when applicantincome > 3000 and applicantincome <= 5000 then 'Medium Income'
           else 'High Income'
       end as Income_group
from l_approved;

-- 16. Find average loan amount for each income group.
select 
      case
          when applicantincome <= 3000 then 'Low Income'
          when applicantincome > 3000 and applicantincome <= 5000 then 'Medium Income'
          else 'High Income'
	  end as Income_group,
	  round(avg(loanamount),2) as avg_laonamount
from l_approved group by Income_group;

-- SECTION 5 — Subqueries & Nested Analysis 
-- 17. Find applicants whose loan amount is greater than the overall average loan amount. 
select * from l_approved 
where loanamount > (select avg(loanamount) from l_approved);

-- 18. Identify the property area with the highest average total income. 
select property_area, avg(applicantincome+coapplicantincome) as avg_total_income from l_approved
group by property_area order by avg_total_income desc limit 1;

-- 19. List all applicants whose income is above the average income of their education category. 

-- SECTION 6 — Window Functions 
-- 20. Rank applicants based on total income (highest income rank = 1). 
select Loan_ID, 
       applicantincome+coapplicantincome as total_income,
       rank() over(order by (applicantincome+coapplicantincome) desc) as Rank_number
from l_approved;

-- 21. Show average loan amount per property area using a window function. 
select property_area,
       avg(loanamount) over(partition by property_area) as avg_area_loan
from l_approved;

-- OR
select distinct(property_area), 
       avg(loanamount) over(partition by property_area) as avg_area_loan 
from l_approved;

-- 22. Calculate approval rate by education using grouping or window function. 

-- SECTION 7 — Business Insights & Combined Analysis
-- 23. Compare approval rate by credit history and education level to find which combination 
-- performs best. 
select credit_History,
       education, 
	   count(*) as total_applicants, 
       sum(case when loan_status = 'Y' then 1 else 0 end) as approvals,
	   round(sum(case when loan_status = 'Y' then 1 else 0 end)/count(*)*100, 2) as approval_rate
from l_approved group by credit_History, education
order by approval_rate desc;

-- 24. Find the combination of property area and education with the highest approval rate. 
select property_Area,
       education, 
	   count(*) as total_applicants, 
       sum(case when loan_status = 'Y' then 1 else 0 end) as approvals,
	   round(sum(case when loan_status = 'Y' then 1 else 0 end)/count(*)*100, 2) as approval_rate
from l_approved group by property_Area, education
order by approval_rate desc;

-- 25. Compare approval rate for self-employed vs non-self-employed applicants by credit 
-- history.
select Self_Employed,
       Credit_History, 
	   count(*) as total_applicants, 
       sum(case when loan_status = 'Y' then 1 else 0 end) as approvals,
	   round(sum(case when loan_status = 'Y' then 1 else 0 end)/count(*)*100, 2) as approval_rate
from l_approved group by Self_Employed, Credit_History
order by approval_rate desc;