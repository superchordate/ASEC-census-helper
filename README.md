
View the live site at: https://superchordate.shinyapps.io/ASEC-census-helper 

# Why ASEC Census Helper?

[Annual Social and Economic Supplements](https://www.census.gov/data/datasets/2020/demo/cps/cps-asec-2020.html) data (ASEC) is incredibly valuable, but existing tools for finding and extracting data are difficult to use. **ASEC Census Helper** provides a fast and user-friendly tool to select and download data from the ASEC in a user-friendly format.

I built this tool as a submission for Posit's annual competition in 2021.

*Census source is in development. Some of the value mappings are not complete. More to come!*  
*The app hasn't been updated since 2020.*

Here are some ways that ASEC Census Helper improves on Census.gov.

| Census.gov                                    | ASEC Census Helper                                               |
| --------------------------------------------- | ------------------------------------------------------------ |
| Different years are in different files.       | 2019 and 2020 are combined. This makes it easy to compare years. Long term, we'd like to get the last 10 years into the app. |
| Over 700 fields.                              | Only download the fields you need.                           |
| Field names are not intuitive.                | Field names are replaced with their human-readable descriptions and tagged with the table they come from. |
| Values are keys (1, 2, 3 vs. high, med, low). | Values are human-readable and ready-to-use.                  |


# Quickstart

How to get the most out of Census Source:

1. **Select Data Fields**: Click tables and fields to add the fields you need.
2. **Preview Your Data**: Click Preview to see information about your download before taking the time to create the full file. Previews are grouped, but downloads will give you data that is not summarized.
3. **Download Your Data**: Click Download to get your data in CSV format. The app will find your data and perform necessary joins so you get a single, ready-to-use ASEC dataset. Downloads will include relevant record keys to connect observations over time. FH_SEQ & FFPOS connect records across years, and FILEDATE is the date of the survey (MMDDYY).
4. **Continue Exploring**: Plop your data into Power BI or Tableau to build your charts and tables. 

*Pro Tip: **Bookmark** or **Share** the URL to select the same fields again later.* 


# About the Data

**What are the Supplements?**

From [health.gov](https://health.gov/healthypeople/objectives-and-data/data-sources-and-methods/data-sources/current-population-survey-annual-social-and-economic-supplement-cps-asec):

> The Current Population Survey (CPS) is a monthly survey that provides  current estimates and trends in employment, unemployment, earnings, and  other characteristics of the general labor force, the population as a  whole, and various population subgroups. The Annual Social and Economic  Supplement (CPS-ASEC) is conducted annually in the months of February,  March, and April. In addition to the usual monthly labor force data, this supplement provides information on work experience, income, noncash benefits, and migration of persons ages 15 years and older.

Here are some links if you'd like to learn more about this dataset:

* [About the Current Population Survey](https://www.census.gov/programs-surveys/cps/about.html)
* [Homepage for Annual Social and Economic Supplement (ASEC) of the Current Population Survey (CPS)](https://www.census.gov/programs-surveys/saipe/guidance/model-input-data/cpsasec.html)
* [Paper About Using ASEC](https://cps.ipums.org/cps/resources/linking/4.workingpaper16.pdf)
* [Download raw data](https://www.census.gov/data/datasets/time-series/demo/cps/cps-asec.2020.html)

**How is the Data Prepared?**

File preparation steps can be viewed at `data/scripts`. We use caching from `easyr` to avoid re-running steps unnecessarily. Each column is split to a distinct file so that scripts only need to read data that has been requested by the user. 

See `app/server/data.R` to review how the app prepares each specific download. 

# Terms of Use

This project is licensed under GNU v3. See LICENSE file for more info. 

## Get Involved

I'm not an expert in the ASEC data, so please reach out to me if you'd like enhancements or fixes to this application. If you use this data frequently, I'd love to collaborate with your team!  

I am an independent contractor. Please reach out to me if you would like some help building a custom cloud app or leveraging data science, visual analytics, or AI in your business. 

Good luck and enjoy!

Bryce Chamberlain  
_Independent Technical Contractor_  
bryce@bryce-chamberlain.com

