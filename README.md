Use the live app at: https://rshiny-7bzbiothyq-uc.a.run.app.

This dataset is also available on Kaggle at: https://www.kaggle.com/datasets/brycechamberlain/us-census-cps-asec-cleaned-2019-through-2023. 

## About Me

I'm an independent contractor providing flexible end-to-end analytics support for startups and small teams. I offer low introductory rates, free consultation and estimates, and no minimums, so contact me today and let's chat about how I can help!

https://www.brycechamberlainllc.com

This project demos my skill in R Shiny and data engineering using R (I'm also proficient in Python). 

* R Shiny code is in the [app/ folder](https://github.com/superchordate/ASEC-census-helper/tree/main/app).
* See the [data/scripts/ folder](https://github.com/superchordate/ASEC-census-helper/tree/main/data/scripts) for my data engineering scripts, including [parsing PDFs](https://github.com/superchordate/ASEC-census-helper/blob/main/data/scripts/2-data-dictionary.R) and [applying the resulting mapping](https://github.com/superchordate/ASEC-census-helper/blob/main/data/scripts/3-aggregate-clean.R) to re-map hundreds of millions of values in just a few minutes.

## About the Project

From [health.gov](https://health.gov/healthypeople/objectives-and-data/data-sources-and-methods/data-sources/current-population-survey-annual-social-and-economic-supplement-cps-asec):

> The Current Population Survey (CPS) is a monthly survey that provides current estimates and trends in employment, unemployment, earnings, and  other characteristics of the general labor force, the population as a  whole, and various population subgroups. The Annual Social and Economic  Supplement (CPS-ASEC) is conducted annually in the months of February, March, and April. In addition to the usual monthly labor force data, this supplement provides information on work experience, income, noncash benefits, and migration of Persons ages 15 years and older.

This is a comprehensive dataset that can support all kinds of research. Unfortunately though, it is very difficult to use. Here are some issues that this project seeks to address:

* Different years are in different files.
* It is difficult to find the field you need: there are over 700 of them!
* Field names are often not intuitive and must be paired with data dictionaries for comprehension. 
* Many values are keys that must be mapped for comprehension. For example, instead of Male or Female you'll see numbers like 1 and 2.

This project packages up this data for easier use and provides an interface to more quickly get the data you need. This requires some intense data engineering, including parsing a PDF for each year to get the value mappings, and applying this to map hundreds of millions of values. 

## WARNING

This is a personal project, so it hasn't been fully tested. Here are a few things to watch out for:

* I recommend using it like this: use the app to find the fields you want and get an estimate of the result, select the results you want to use, then verify those results manually by downlading and mapping the the raw data for yourself. Please let me know if you find any errors and I'll correct them. In particular, I mapped values automatically using PDFs like [this one](https://www2.census.gov/programs-surveys/cps/datasets/2023/march/asec2023_ddl_pub_full.pdf). This automation might make mistakes so it'll be smart to verify correct values are being used.

* There is a risk of double-counting metrics when mixing Household/Family characteristics with Person-level. Always use Person-level metrics if you are using Person-level data, or take special care to filter to distinct Households/Families before using Household/Family metrics. 

## Learn More About CPS-ASEC

Here are some links if you'd like to learn more:

* [Homepage for Annual Social and Economic Supplement (ASEC) of the Current Population Survey (CPS)](https://www.census.gov/programs-surveys/saipe/guidance/model-input-data/cpsasec.html)
* [Paper About Using ASEC](https://cps.ipums.org/cps/resources/linking/4.workingpaper16.pdf)
* [Download My Full Processed Data](https://storage.googleapis.com/data-downloads-by-bryce/asec-clean-2020-2024-rds.zip) (4 RDS files, ~150 MB). This data is easier to use than raw ASEC data but will require you to perform your own joins. RDS files can be read in using R or RStudio and from there can be converted to other formats. It is also possible to [read RDS into Power BI](https://www.sqlshack.com/import-data-using-r-in-power-bi/) using the `readRDS` function.

## Installing Locally

You may want to run this app locally. You can do so via these steps:

* Install R and RStudio and clone this repository to your local machine.
* Download [this data](https://storage.googleapis.com/data-downloads-by-bryce/asec-clean-2020-2024-rds.zip) into `data/raw-data` and unzip with "Unzip Here" or similar. This will create folder `data/raw-data/asec-clean-2019-2023` with the necessary RDS files. 
* Run `data/build-data-fromexport.R` to build the app data files (RStudio will prompt you to install the necessary packages first).
* Run `app/global.R` to run the app (RStudio will prompt you to install the necessary packages first).

You can also build from the raw data, if you'd like to dig into the data engineering, by going to `data/scripts/1-read-raw.R` and following the comments to find the datasets, saving them at `data/raw-data` and running `data/build-data.R`.

## Other Information

**How is the Data Prepared?**

* See `data/scripts`.
* See `app/server/2-download/data.R` to review how the R Shiny app prepares each specific download. 

**Terms of Use**

This project is licensed under GNU v3. See LICENSE file for more info. 

**Get Involved**

I'm not an expert in the ASEC data, so please reach out to me if you'd like enhancements or fixes. If you use this data frequently, I'd love to collaborate with your team!  

**Update Process**

* Download the new year of data. 
* Change `doyrs` at `data/scripts/1-read-raw.R` to include the new year. You may run out of memory if you use too many years so increment the minimum as well as the maximum. 
* Run `build-data.R`. 
* Update the various public datasets. 
   - https://www.kaggle.com/datasets/brycechamberlain/us-census-cps-asec-cleaned-2019-through-2023 (using `forkaggle = TRUE`).
   - [R Shiny App](https://rshiny-7bzbiothyq-uc.a.run.app/)
   - [RDS Files](https://storage.googleapis.com/data-downloads-by-bryce/asec-clean-2020-2024-rds.zip) (using `forkaggle = FALSE`).
   - Raw data folder (TODO)

