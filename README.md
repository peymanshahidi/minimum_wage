# Replication Package
## Price Floors and Employer Preferences: Evidence from a Minimum Wage Experiment
by John Horton

This document describes the organization of code, data, and software associated with the "[Price Floors and Employer Preferences: Evidence from a Minimum Wage Experiment](https://www.aeaweb.org/articles?id=10.1257/aer.20170637)" paper (Horton, 2025a).
The code for this replication package is available at [johnjosephhorton/minimum_wage](https://www.github.com/johnjosephhorton/minimum_wage.git) Github repository (Horton, 2025b) as well as at [openICPSR repository 208551V1](http://doi.org/10.3886/E208551V1) (Horton, 2025c).

<br> 

# Overview
This project is largely self-documenting in the sense that the key recipes for building the project are captured in code. 
The key pieces for replicating this project are: 

1. A [Makefile](https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/Makefile) that gives recipes for how each figure, table, and called-out number is constructed in the paper. A comprehensive list of programs and files is also included in this README for the reader's convenience.

1. A [Dockerfile](Dockerfile) that describes the system set-up needed with respect to computing resources and packages. 

## File Organization

The main directories are:
```
-analysis
-codebooks
-writeup
```
When the project is being built, a `data` folder is automatically generated in the main directory and populated with the relevant datasets.
(There is no need to create an empty `data` folder manually.)

The figures, tables, and parameter files are stored in `writeup/plots`, `writeup/tables`, and `writeup/parameters`, respectively.

The code in [`analysis`]( https://www.github.com/johnjosephhorton/minimum_wage/blob/main/analysis) writes files to these locations.
In the git repository, these locations are empty by design.
When the project is built, these locations are populated with the necessary files. 

The main writeup of the paper is in [`writeup/minimum_wage.tex`](https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex).

## Programs List

The entire project has been implemented in R (version 4.4.1). The `analysis` folder contains 23 R scripts that utilize 10 datasets to generate all outputs reported in the paper. 
The table below provides a list of all 23 R scripts located in the `analysis` folder.

### R Scripts

| R Script                          | R Script                                |
|-----------------------------------|-----------------------------------------|
| `avg_wages_by_cat.R`             | `first_stage.R`                         |
| `jjh_misc.R`                      | `parameters.R`                          |
| `parameters_country_selection.R`  | `parameters_effects.R`                  |
| `plot_any_exper.R`               | `plot_application_event_study.R`        |
| `plot_composition.R`             | `plot_did_all_outcomes.R`               |
| `plot_event_study_hired_admin.R`  | `plot_event_study_hourly_rate_hired.R`  |
| `plot_feedback.R`                | `plot_fill_and_hours.R`                 |
| `plot_follow_on_openings.R`       | `plot_hours_zero.R`                     |
| `plot_organic_applications.R`     | `quantile_hours_worked.R`               |
| `randomization_check.R`          | `realized_wage_distro.R`                |
| `settings.R`                      | `table_any_prior.R`                     |
| `utilities_outcome_experimental_plots.R` |                                  |

### R Package Requirements

The complete list of R packages used in the scripts above, along with the versions I last used to run the code is give in table below.

### R Packages

| R Package (version)               | R Package (version)               |
|-----------------------------------|-----------------------------------|
| `cowplot (1.1.3)`                 | `data.table (1.16.2)`              |
| `directlabels (2024.1.21)`         | `dplyr (1.1.4)`                   |
| `ggplot2 (3.5.1)`                  | `ggrepel (0.9.6)`                 |
| `gridExtra (2.3)`                 | `gt (0.11.1)`                   |
| `lfe (3.1.1)`                     | `lmtest (0.9-40)`                |
| `lubridate (1.9.4)`               | `magrittr (2.0.3)`               |
| `plyr (1.8.9)`                    | `purrr (1.0.2)`                  |
| `quantreg (6.00)`                 | `sandwich (3.1-1)`               |
| `scales (1.3.0)`                  | `stargazer (5.1)`                |
| `tidyr (1.3.1)`                   |                                   |

## Files list

### Dataset list

The analysis uses 10 datasets, all of which are automatically stored in the `data` folder after initiating the data download procedure (more on this later):

1. [`df_mw_first.csv`](codebooks/df_mw_first.md): the main experimental outcomes at job post level (first observation).
1. [`df_mw_all.csv`](codebooks/df_mw_all.md): the main experimental outcomes at job post level (all observations).
1. [`df_mw_admin.csv`](codebooks/df_mw_admin.md): the main experimental outcomes at job post level for administrative data.
1. [`df_mw_lpw.csv`](codebooks/df_mw_lpw.md): the main experimental outcomes at job post level for low-paid wage positions.
1. [`df_exp_results.csv`](codebooks/df_exp_results.md): has aggregated experimental results and summary statistics.
1. [`hires_country_composition.csv`](codebooks/hires_country_composition.md): has information on geographic composition of hires.
1. [`event_study_windows.csv`](codebooks/event_study_windows.md): defines the time windows and intervals used in the event study analysis.
1. [`did_panel.csv`](codebooks/did_panel.md): the data used for the DiD analysis.
1. [`event_study_hired.csv`](codebooks/event_study_hired.md): has detailed hiring outcome data for use in event study analyses.
1. [`event_study_windows_hr_v_fp.csv`](codebooks/event_study_windows_hr_v_fp.md): has the composition of fixed price and hourly jobs over time.

### Figure list

Table below provides a detailed mapping between each figure used in the text of the paper, which R script generates it, and its dataset dependencies. 
All figures are stored in `writeup/plots`.

| Figure | R Script | Data Dependency | Location in Paper |
|--------|---------|-----------------|-------------------|
| Figure 1: Control Hired CDF | `analysis/realized_wage_distro.R` | `data/df_mw_first.csv` | Page 125 |
| Figure 2: All Hired CDF | `analysis/first_stage.R` | `data/df_mw_first.csv` | Page 126 |
| Figure 3: Firm Preference Diagram | None (TikZ Diagram) | None (TikZ Diagram) | Page 126 |
| Figure 4: Fill and Hours | `analysis/plot_fill_and_hours.R` | `data/df_mw_all.csv` <br> `data/df_mw_admin.csv` <br> `data/df_mw_lpw.csv` | Page 130 |
| Figure 5: Composition | `analysis/plot_composition.R` | `data/df_mw_all.csv`<br>`data/df_mw_admin.csv`<br>`data/df_mw_lpw.csv` | Page 134 |
| Figure 6: Event Study Hourly Rate | `analysis/plot_event_study_hourly_rate_hired.R` | `data/event_study_hired.csv` | Page 138 |
| Figure 7: DiD Outcomes | `analysis/plot_did_all_outcomes.R` | `data/did_panel.csv` | Page 140 |
| Figure 8: Application Event Study | `analysis/plot_application_event_study.R` | `data/event_study_windows.csv` | Page 143 |
| Figure A1: Organic Applications | `analysis/plot_organic_applications.R` | `data/df_mw_all.csv`<br>`data/df_mw_admin.csv`<br>`data/df_mw_lpw.csv` | Appendix |
| Figure A2: Follow-on Openings | `analysis/plot_follow_on_openings.R` | `data/df_mw_all.csv`<br>`data/df_mw_admin.csv`<br>`data/df_mw_lpw.csv` | Appendix |
| Figure A3: Average Wages by Category | `analysis/avg_wages_by_cat.R` | `data/df_mw_first.csv` | Appendix |
| Figure B1: Hours with 0 for Unfilled | `analysis/plot_hours_zero.R` | `data/df_mw_all.csv`<br>`data/df_mw_admin.csv`<br>`data/df_mw_lpw.csv` | Appendix |
| Figure B2: Any Experience | `analysis/plot_any_exper.R` | `data/df_mw_all.csv`<br>`data/df_mw_admin.csv`<br>`data/df_mw_lpw.csv` | Appendix |
| Figure B3: Feedback | `analysis/plot_feedback.R` | `data/df_mw_all.csv`<br>`data/df_mw_admin.csv`<br>`data/df_mw_lpw.csv` | Appendix |
| Figure B4: Event Study Hired Admin | `analysis/plot_event_study_hired_admin.R` | `data/event_study_hired.csv` | Appendix |

### Table list

Table below provides a detailed mapping between each table used in the text of the paper, which R script generates it, and its dataset dependencies. 
All figures are stored in `writeup/plots`.

| Table | R Script | Data Dependency | Location in Paper |
|-------|---------|-----------------|-------------------|
| Table A1: Randomization Check | `analysis/randomization_check.R` | `data/df_mw_first.csv` | Appendix |
| Table B1: Quantile Hours Worked | `analysis/quantile_hours_worked.R` | `data/event_study_windows_hr_v_fp.csv` | Appendix |
| Table B2: Any Prior | `analysis/table_any_prior.R` | `data/df_mw_first.csv` | Appendix |

### Parameter files

Some of the scripts do not generate tables or figures, but instead generate "parameters."
These are numbers that are called out in the text of the paper but are generated automatically. 
For example, after the project is built the `parameters/parameters.tex` file will contain a line `\newcommand{\numTotal}{159,656}` that is related to the total allocation to the experiment.
If we look in `parameters.R` script we see the corresponding code that creates this value.
```R
addParam("\\numTotal", formatC(dim(df.mw.first)[1], big.mark = ","))
```

The table below provides the mapping between each parameter file and the R script that generates it. 
All parameter files are saved in `writeup/parameters` after the corresponding R scripts is run.

| Parameter File | R Script | 
|----------------|---------|
| `parameters/parameters.tex` | `analysis/parameters.R` |
| `parameters/effects_parameters.tex` | `analysis/parameters_effects.R` |
| `parameters/parameters_fill_and_hours.tex` | `analysis/plot_fill_and_hours.R` |
| `parameters/did_parameters.tex` | `analysis/plot_did_all_outcomes.R` |
| `parameters/parameters_composition.tex` | `analysis/plot_composition.R` |
| `parameters/params_country_selection.tex` | `analysis/parameters_country_selection.R` |

### License for Code

The code is licensed under an MIT license. 

<br>

# Replication

A replicator will obtain a `.env` file from the author and can try one of three options to build the paper.

## Building the Paper
The building of this project is orchestrated by software called "[make](https://www.gnu.org/software/make/manual/make.html)".
From the `writeup` folder at the command line, the user simply types `make minimum_wage.pdf` which will then build the paper.
Below is a short tutorial on `make`. 
Familiar readers may skip the tutorial and go to the "Getting the Data" section directly.

#### A Short Make Tutorial
A Makefile lists recipes for how a particular output used in the paper is constructed.
The Makefile entry for the `first_stage.pdf` in the `plots` folder looks like this: 

```Makefile
plots/first_stage.pdf: ../analysis/first_stage.R  data/df_mw_first.csv
	cd ../analysis && Rscript first_stage.R
```

Note that the target, or output is `plots/first_stage.pdf` 
After the colon is what this output depends on, code-wise, which is an R file in the `analysis` folder called `first_stage.R`.
The tabbed-in-line below is the recipe for how the target is constructed. 
In this case, it is just by running `Rscript` on `first_stage.R.`

There is some code that is shared across multiple figures or tables in this repository. 
For example, `utilities_outcome_experimental_plots.R` has helper functions used in several plots.
To capture this dependency, there are entries in the Makefile that look like this: 

```Makefile
analysis/plot_any_exper.R: analysis/utilities_outcome_experimental_plots.R
	touch analysis/plot_any_exper.R
```
The command `touch` here updates the timestamp of `analysis/plot_any_exper.R` which in turn would cause the recipe for `any_exper.pdf` to be re-run, as `plot_any_exper.R` is a dependency.

## Getting the Data
To get the data, you need to obtain a `.env` file from the author and put it file in their `~/minimum_wage/writeup` folder. 
The `.env` file contains 1) a private URL to the zipped and encrypted data and 2) a key to decrypt the data. 
The `.env` file will look like this:

```bash
GPG_PASSPHRASE='<password>'
project_name="minimum_wage"
DROPBOX_URL="<url of dropbox link hosting the data>"(base)
```

These values are used in a bash script that fetches the data, at [fetch_data.sh](https://www.github.com/johnjosephhorton/minimum_wage/blob/main/fetch_data.sh) in the main directory.

There are three options:

#### 1) Non-Docker, Local Approach (Recommended)

The least error-prone method is run the following in commmand line:
```bash 
$ cd writeup 
$ make docker
```

The [system_update.sh](https://www.github.com/johnjosephhorton/minimum_wage/blob/main/system_update.sh) file in the main directory will automatically install the right dependencies on a Linux machine and the project is built.

```bash
git clone git@github.com:johnjosephhorton/minimum_wage.git
cd minimum_wage
cp ~/Downloads/.env writeup
sudo ./system_update.sh
```

#### 2) Docker Approach

You can just clone the repo and, assuming the `.env` file is in your Downloads folder:
```bash
git clone git@github.com:johnjosephhorton/minimum_wage.git
cd minimum_wage/writeup
cp ~/Downloads/.env . 
```

From here, running this will do everything:
```bash
make docker
```
The actual final PDF, will be inside the Docker container. It will, however, give you a localhost URL that will have the final PDF.

#### 3) Replit Approach (Convenient)

I have created a public replit "repl" here: https://replit.com/@johnhorton/minimumwage.
You can __fork__ this repository, then add the `.env` file to the `writeup` folder then just push the big green 'Run' button.
The dependencies are specified in the [replit.nix](https://www.github.com/johnjosephhorton/minimum_wage/blob/main/replit.nix.sh) file available in the main directory.
It will generate the PDF and store it in `writeup`.

<br>

# Data Availability and Provenance Statements

### Provenance

This data comes from a large online labor market (Anonymous Online Platform, 2025) that conducted the experiment described in the paper. The data was pulled from the company's database using SQL. The experiment described in the paper was conducted by the platform by changing the experience for some subset of users.  The data used for this analysis is proprietary.

### Statement about Rights

- [X] I certify that the author(s) of the manuscript have legitimate access to and permission to use the data used in this manuscript. 

- [ ] I certify that the author(s) of the manuscript have documented permission to redistribute/publish the data contained within this replication package. Appropriate permissions are documented in the [LICENSE.txt](LICENSE.txt) file.

### Summary of Availability

- [ ] All data **are** publicly available.
- [ ] Some data **cannot be made** publicly available.
- [X] **No data can be made** publicly available.


### Details on each Data Source

The data for this project are confidential, but may likely be obtained with Data Use Agreements with the data provider.
The data provider itself chooses to remain anonymous.
As such, researchers interested in access to the data may contact John Horton at jjhorton@mit.edu. 
The author will assist with any reasonable replication attempts for two years following publication.
All data files are CSVs. 

<br> 

# Computational Requirements
The computational requirements for reproducing this paper are minimal. 
It can be run on a modern laptop in about 20 minutes, using only open-source softwares.

The machine details when I last ran it are: 
System info:
- OS: "Ubuntu 20.04.6 LTS"
- Processor:  11th Gen Intel(R) Core(TM) i7-11850H @ 2.50GHz, 16 cores
- Memory available: 31GB memory

The code was last run on 2025-03-27 15:16:41.

The Linux dependencies are mostly either for LaTeX or dependencies for various R packages.

### Summary

Approximate time needed to reproduce the analyses on a standard 2023 desktop machine is about 20 minutes:

- [ ] <10 minutes
- [X] 10-60 minutes
- [ ] 1-2 hours
- [ ] 2-8 hours
- [ ] 8-24 hours
- [ ] 1-3 days
- [ ] 3-14 days
- [ ] > 14 days
- [ ] Not feasible to run on a desktop machine, as described below.

<br> 

# References

- Anonymous Online Platform. 2025. "Data For: Price Floors and Employer Preferences: Evidence from a Minimum Wage Experiment," Unpublished Data, Accessed March 29, 2025.

- Horton, John J. 2025a. “Price Floors and Employer Preferences: Evidence from a Minimum Wage Experiment.” American Economic Review 115, No. 1: 117–146. https://doi.org/10.1257/aer.20170637.

- Horton, John J. 2025b. “minimum_wage.” GitHub Repository. Accessed March 27, 2025. https://github.com/johnjosephhorton/minimum_wage.

- Horton, John J. 2025c. “Code For: Price Floors and Employer Preferences: Evidence from a Minimum Wage Experiment.” American Economic Association, Inter-university Consortium for Political and Social Research. http://doi.org/10.3886/E208551V1.