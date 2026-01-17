USE it;

# Creating Table incidents
CREATE TABLE incidents (
incident_id INT,
category VARCHAR(50),
priority VARCHAR(10),
resolution_time_hours FLOAT,
root_cause VARCHAR(50),
customer_impact VARCHAR(5),
agent_id INT
);

select * from incidents;

# Problem Analysis
# 1. Top Issues
SELECT category, COUNT(*) FROM incidents
GROUP BY category
ORDER BY COUNT(*) DESC;

# Avg Resolution Time
SELECT priority, AVG(resolution_time_hours)
FROM incidents
GROUP BY priority;

# Which agents are resolving tickets fastest?
SELECT
  agent_id,
  AVG(resolution_time_hours) AS avg_resolution_time,
  RANK() OVER (ORDER BY AVG(resolution_time_hours)) AS performance_rank
FROM incidents
GROUP BY agent_id;

# Which category generates the most high-priority incidents?
SELECT
  category,
  COUNT(*) AS high_priority_count
FROM incidents
WHERE priority = 'High'
GROUP BY category
ORDER BY high_priority_count DESC;

# Which incidents are at risk of escalation due to very high resolution time?
SELECT *
FROM incidents
WHERE resolution_time_hours >
        (SELECT AVG(resolution_time_hours) + 2*STDDEV(resolution_time_hours)
         FROM incidents);

# What percentage of total incidents comes from each category?
SELECT
  category,
  COUNT(*) AS category_count,
  ROUND(
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage_contribution
FROM incidents
GROUP BY category;

# Which category has the highest customer impact rate?
SELECT
  category,
  COUNT(*) AS total_incidents,
  SUM(CASE WHEN customer_impact = 'Yes' THEN 1 ELSE 0 END) AS impacted_incidents,
  ROUND(
    SUM(CASE WHEN customer_impact = 'Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),  2 ) AS impact_percentage
FROM incidents
GROUP BY category;

# Which incidents are taking unusually long time compared to overall average resolution time?
SELECT
  incident_id,
  category,
  priority,
  resolution_time_hours
FROM incidents
WHERE resolution_time_hours >
      (SELECT AVG(resolution_time_hours) FROM incidents)
ORDER BY resolution_time_hours DESC;