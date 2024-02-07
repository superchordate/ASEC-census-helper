
Use the live app at: https://superchordate.shinyapps.io/ASEC-census-helper.

*Census source is in development. Some of the value mappings are not complete. Contributions are welcome. More to come!*  
*Data has not been updated since 2020. Contributions are invited to update to include the latest data. Otherwise, I'll updated it when I can find time.*  

# ASEC Census Helper

From [health.gov](https://health.gov/healthypeople/objectives-and-data/data-sources-and-methods/data-sources/current-population-survey-annual-social-and-economic-supplement-cps-asec):

> The Current Population Survey (CPS) is a monthly survey that provides current estimates and trends in employment, unemployment, earnings, and  other characteristics of the general labor force, the population as a  whole, and various population subgroups. The Annual Social and Economic  Supplement (CPS-ASEC) is conducted annually in the months of February, March, and April. In addition to the usual monthly labor force data, this supplement provides information on work experience, income, noncash benefits, and migration of Persons ages 15 years and older.

As you can imagine, this is a very powerful and comprehensive dataset that can support all kinds of research. 

Unfortunately though, it is very difficult to use. For example, here are some issues that this project seeks to address:

* Different years are in different files.
* Over 700 fields, making files unweildy.
* Field names are often not intuitive and must be paired with data dictionaries for comprehension. 
* Values are keys that must be mapped to values for comprehension. For example, instead of Male or Female you'll see numbers like 1 and 2.

This project packages up this data for easier use. 

Here are some links if you'd like to learn more:

* [About the Current Population Survey](https://www.census.gov/programs-surveys/cps/about.html)
* [Homepage for Annual Social and Economic Supplement (ASEC) of the Current Population Survey (CPS)](https://www.census.gov/programs-surveys/saipe/guidance/model-input-data/cpsasec.html)
* [Paper About Using ASEC](https://cps.ipums.org/cps/resources/linking/4.workingpaper16.pdf)
* [Download raw data](https://www.census.gov/data/datasets/time-series/demo/cps/cps-asec.2020.html)
* [Download My Full Processed Dataset](https://storage.googleapis.com/data-downloads-by-bryce/asec-clean-2019-2020.zip) (4 RDS files, ~60 MB). This data is easier to use than raw ASEC data but will require you to perform your own joins. RDS files can be read in using R or RStudio and from there can be converted to other formats. It is also possible to [read RDS into Power BI](https://www.sqlshack.com/import-data-using-r-in-power-bi/) using the `readRDS` function.


## Installing Locally

You may want to run this app locally. You can do so via these steps:

* Install R and RStudio and clone this repository to your local machine.
* Download [this data](https://storage.googleapis.com/data-downloads-by-bryce/asec-clean-2019-2020.zip) into `data/raw-data` and unzip with "Unzip Here" or similar. This will create folder `data/raw-data/asec-clean-2019-2020` with the necessary RDS files. 
* Run `data/build-data-fromexport.R` to build the app data files (RStudio will prompt you to install the necessary packages first).
* Run `app/global.R` to run the app (RStudio will prompt you to install the necessary packages first).

## Other Information

**WARNING**

There is a risk of double-counting metrics when mixing Household/Family characteristics with Person-level. Always use Person-level metrics if you are using Person-level data, or take special care to filter to distinct Households/Families before using Household/Family metrics. 

**How is the Data Prepared?**

See `data/scripts`. We use caching from `easyr` to avoid re-running steps unnecessarily. Each column is split to a distinct file so that scripts only need to read data that has been requested by the user. 

See `app/server/2-download/data.R` to review how the app prepares each specific download. 

**Terms of Use**

This project is licensed under GNU v3. See LICENSE file for more info. 

**Get Involved**

I'm not an expert in the ASEC data, so please reach out to me if you'd like enhancements or fixes to this application. If you use this data frequently, I'd love to collaborate with your team!  

I am an independent contractor. Please reach out to me if you would like some help building a custom cloud app or leveraging data science, visual analytics, or AI in your business. 

Good luck and enjoy!

Bryce Chamberlain  
_Independent Technical Contractor_  
bryce@bryce-chamberlain.com

