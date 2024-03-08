*##Check total Ids in Sleepday

SELECT COUNT (DISTINCT Id) AS Total_Ids 
FROM `noted-casing-414414.Wellness.Sleepday`      IDs = 24

*##Check total Ids in DailyActivity

SELECT COUNT (DISTINCT Id) AS Total_Ids 
FROM `noted-casing-414414.Wellness.dailyactivity` IDs = 33


*##Check total Ids in hourlyintensities

SELECT COUNT (DISTINCT Id) AS Total_Ids 
FROM `noted-casing-414414.Wellness.hourlyIntensities` IDs= 33

*##Check total Ids in Hourlysteps

SELECT COUNT (DISTINCT Id) AS Total_Ids 
FROM `noted-casing-414414.Wellness.hourlySteps`       IDs = 33

*##Check total Ids in heartrate_seconds

SELECT COUNT (DISTINCT Id) AS Total_Ids 
FROM `noted-casing-414414.Wellness.heartrate_seconds`  IDs= 14

*##Check total Ids in HourlyCalories

SELECT COUNT (DISTINCT Id) AS Total_Ids 
FROM `noted-casing-414414.Wellness.hourlyCalories`      IDs= 33

*##Check total Ids in weightLogInfo_merged
SELECT COUNT (DISTINCT Id) AS Total_Ids 
FROM `noted-casing-414414.Wellness.wight`                IDs= 8

*Both the Heart Rate and Weight Log datasets do not include enough data to move forward with analysis. We will not use these sets of data.

*User Insights

*First, I wanted to see how many times each of the users wore/used the FitBit tracker:
SELECT Id,
COUNT(Id) AS Total_Id
FROM `noted-casing-414414.Wellness.dailyActivity`
GROUP BY Id

*RESULTAT - TABLEAU GOOGLE SHEETS
*INTERPRETATION: 64% of users kept track of data for the whole data time period (04–12–2016 to 05–12–2016): A DEVELOPPER
*REGROUPER LES UTILISATEURS SELON LE NOMBRE DE FOIS QU'ILS PORTENT LA MONTRE

*Active User — wore their tracker for 25–31 days
*Moderate User — wore their tracker for 15–24 days
*Light User — wore their tracker for 0 to 14 days

(SELECT Id,
COUNT(Id) AS Total_Logged_Uses,
CASE
WHEN COUNT(Id) BETWEEN 25 AND 31 THEN 'Active User'
WHEN COUNT(Id) BETWEEN 15 and 24 THEN 'Moderate User'
WHEN COUNT(Id) BETWEEN 0 and 14 THEN 'Light User'
END Fitbit_Usage_Type
FROM `noted-casing-414414.Wellness.dailyActivity`
GROUP BY Id)

*STATISQUES DESC of total steps, total distance, calories, and activity levels by ID.
*reduce results to averages of different types of minutes per Id

SELECT Id, 
avg(VeryActiveMinutes) AS Avg_Very_Active_Minutes,
avg(FairlyActiveMinutes) AS Avg_Fairly_Active_Minutes,
avg(LightlyActiveMinutes) AS Avg_Lightly_Active_Minutes,
avg(SedentaryMinutes) AS Avg_Sedentary_Minutes,
FROM `noted-casing-414414.Wellness.dailyActivity`
GROUP BY Id

*User Types by Activity Levels
*The CDC recommends 150 minutes of physical activity each week. (https://www.cdc.gov/physicalactivity/basics/adults/index.htm)
*So, we add up the average minutes of Very Active and Fairly Active to see if each unique ID was meeting the CDC’s guidelines for activity.
SELECT Id, 
avg(VeryActiveMinutes) + avg(FairlyActiveMinutes) AS Total_Avg_Active_Minutes
FROM `noted-casing-414414.Wellness.dailyActivity`
GROUP BY Id
*the results showed that most users were not engaging in milder activity for at least 150 minutes each day.

*COMPARAISON AVEC CDC_Recommendations

SELECT Id, 
avg(VeryActiveMinutes) + avg(FairlyActiveMinutes) + avg(LightlyActiveMinutes) AS Total_Avg_Active_Minutes,
CASE 
WHEN avg(VeryActiveMinutes) + avg(FairlyActiveMinutes) + avg(LightlyActiveMinutes) >= 150 THEN 'Meets CDC Recommendation'
WHEN avg(VeryActiveMinutes) + avg(FairlyActiveMinutes) + avg(LightlyActiveMinutes) <150 THEN 'Does Not Meet CDC Recommendation'
END CDC_Recommendations
FROM `noted-casing-414414.Wellness.dailyActivity`
GROUP BY Id

*Removing the light activity stage

SELECT Id, 
SUM(VeryActiveMinutes + FairlyActiveMinutes) AS Total_Avg_Active_Minutes,
CASE 
WHEN SUM(VeryActiveMinutes + FairlyActiveMinutes) >= 150 THEN 'Meets CDC Recommendation'
WHEN SUM(VeryActiveMinutes + FairlyActiveMinutes) <150 THEN 'Does Not Meet CDC Recommendation'
END CDC_Recommendations
FROM `noted-casing-414414.Wellness.dailyActivity`
WHERE ActivityDate BETWEEN '2016-04-17' AND '2016-04-23'
GROUP BY Id

*Counting LightlyActiveMinutes 

SELECT Id, 
SUM(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) AS Total_Avg_Active_Minutes,
CASE 
WHEN SUM(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) >= 150 THEN 'Meets CDC Recommendation'
WHEN SUM(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) <150 THEN 'Does Not Meet CDC Recommendation'
END CDC_Recommendations
FROM `noted-casing-414414.Wellness.dailyActivity`
WHERE ActivityDate BETWEEN '2016-05-01' AND '2016-05-07'
GROUP BY Id

*User Types by Total Steps
SELECT Id,
avg(TotalSteps) AS Avg_Total_Steps,
CASE
WHEN avg(TotalSteps) < 5000 THEN 'Inactive'
WHEN avg(TotalSteps) BETWEEN 5000 AND 7499 THEN 'Low Active User'
WHEN avg(TotalSteps) BETWEEN 7500 AND 9999 THEN 'Average Active User'
WHEN avg(TotalSteps) BETWEEN 10000 AND 12499 THEN 'Active User'
WHEN avg(TotalSteps) >= 12500 THEN 'Very Active User'
END User_Type
FROM `noted-casing-414414.Wellness.dailyActivity`
GROUP BY Id

*Calories, Steps & Active Minutes by ID
SELECT Id, 
Sum(TotalSteps) AS Sum_total_steps,
SUM(Calories) AS Sum_Calories, 
SUM(VeryActiveMinutes + FairlyActiveMinutes) AS Sum_Active_Minutes
FROM `noted-casing-414414.Wellness.dailyActivity`
GROUP BY Id

*Total Steps by Day
SELECT Activity_Day,
ROUND (avg(TotalSteps), 2) AS Average_Total_Steps,
FROM `noted-casing-414414.Wellness.dailyActivity`
GROUP BY Activity_Day
ORDER BY Average_Total_Steps DESC

*StepTotal by HOUR
SELECT 
ActivityHour,
SUM(StepTotal) AS Total_Steps_By_Hour
FROM `noted-casing-414414.Wellness.dailySteps`
GROUP BY ActivityHour
ORDER BY Total_Steps_By_Hour DESC

*Sleeping time analysis
SELECT 
SleepDay,
SUM(TotalMinutesAsleep) AS Total_Minutes_Asleep
FROM `noted-casing-414414.Wellness.Sleepday`
WHERE SleepDay IS NOT NULL
GROUP BY SleepDay

*Average Slept, total steps and calories by user Id
SELECT a.Id,
avg(a.TotalSteps) AS AvgTotalSteps,
avg(a.Calories) AS AvgCalories,
avg(s.TotalMinutesAsleep) AS AvgTotalMinutesAsleep,
FROM `scenic-kiln-368505.Bellabeat.Dailyactive` AS a
INNER JOIN `scenic-kiln-368505.Bellabeat.Sleepday` AS s ON a.Id=s.Id
GROUP BY a.Id









