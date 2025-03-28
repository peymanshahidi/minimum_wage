ts := $(shell /bin/date "+%Y-%m-%d---%H-%M-%S")
project_name = minimum_wage
images = images/bidding_interface

include .env
export

##############
## Docker file
##############

.PHONY: docker

docker:
	@echo "Building docker image"
	@cd .. && sudo docker build -t minimum_wage .
	@echo "Running docker image"
	@echo "Navigate to: http://localhost:8080/writeup/minimum_wage.pdf"
	@cd .. & sudo docker run -p 8080:8000 minimum_wage


######################################
## Compress the data & move to Dropbox
######################################

.PHONE: fetch-data send-data

no-cards-up-sleeve:
	ls plots
	ls tables
	ls parameters

###############
## Get the data 
###############

project_name = minimum_wage
images = images/bidding_interface

DIRS := plots tables parameters

# Default target
all: create-dirs main

create-dirs:
	@mkdir -p $(DIRS)


../remote_data.tar.gz.gpg:
	cd .. && ./fetch_data.sh

fetch-data: ../remote_data.tar.gz.gpg
	echo "Fetching data"


tables = 
plots = 
parameters =



#################################################
## These are all "called out" numbers in the text
#################################################

parameters += parameters/parameters.tex
parameters/parameters.tex: ../analysis/parameters.R 
	cd ../analysis && Rscript parameters.R

parameters += parameters/effects_parameters.tex
parameters/effects_parameters.tex: ../analysis/parameters_effects.R
	cd ../analysis && Rscript parameters_effects.R 

parameters += parameters/parameters_fill_and_hours.tex
parameters/parameters_fill_and_hours.tex: ../analysis/plot_fill_and_hours.R 
	cd ../analysis && Rscript plot_fill_and_hours.R

parameters += parameters/did_parameters.tex
parameters/did_parameters.tex: ../analysis/plot_did_all_outcomes.R 
	cd ../analysis && Rscript plot_did_all_outcomes.R 

parameters += parameters/parameters_composition.tex
parameters/parameters_composition.tex: ../analysis/plot_composition.R
	cd ../analysis && Rscript plot_composition.R 

parameters += parameters/params_country_selection.tex
parameters/params_country_selection.tex: ../analysis/parameters_country_selection.R
	cd ../analysis && Rscript parameters_country_selection.R


##########
## Figures
##########

#############################################################################################
# These lines ensure that if the underlying utility R script changes, the main file is re-run
#############################################################################################

../analysis/plot_fill_and_hours.R: ../analysis/utilities_outcome_experimental_plots.R
	touch ../analysis/plot_fill_and_hours.R

../analysis/plot_composition.R: ../analysis/utilities_outcome_experimental_plots.R
	touch ../analysis/plot_composition.R

../analysis/plot_organic_applications.R: ../analysis/utilities_outcome_experimental_plots.R
	touch ../analysis/plot_organic_applications.R

../analysis/plot_follow_on_openings.R: ../analysis/utilities_outcome_experimental_plots.R
	touch ../analysis/plot_follow_on_openings.R

../analysis/plot_hours_zero.R: ../analysis/utilities_outcome_experimental_plots.R
	touch ../analysis/plot_hours_zero.R

../analysis/plot_any_exper.R: ../analysis/utilities_outcome_experimental_plots.R
	touch ../analysis/plot_any_exper.R

../analysis/plot_feedback.R: ../analysis/utilities_outcome_experimental_plots.R
	touch ../analysis/plot_feedback.R


# Figure 1: 
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L401 
plots += ./plots/realized_wage_distro.pdf
./plots/realized_wage_distro.pdf: ../analysis/realized_wage_distro.R ../data/df_mw_first.csv
	cd ../analysis && Rscript realized_wage_distro.R
# (additional facet)
plots += ./plots/realized_wage_distro_facet.pdf
./plots/realized_wage_distro_facet.pdf: ../analysis/realized_wage_distro.R 
	cd ../analysis && Rscript realized_wage_distro.R

# Figure 2
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L441
plots += ./plots/first_stage.pdf
./plots/first_stage.pdf: ../analysis/first_stage.R ../data/df_mw_first.csv
	cd ../analysis && Rscript first_stage.R

# Figure 3 is a TikZ diagram

data = ../data/df_mw_all.csv ../data/df_mw_admin.csv ../data/df_mw_lpw.csv

# Figure 4
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L638
plots += plots/fill_and_hours.pdf
./plots/fill_and_hours.pdf: ../analysis/plot_fill_and_hours.R $(data)
	cd ../analysis && Rscript plot_fill_and_hours.R

# Figure 5
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L654 
plots += plots/composition.pdf
./plots/composition.pdf: ../analysis/plot_composition.R $(data)
	cd ../analysis && Rscript plot_composition.R

# Figure 6
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L899
plots += ./plots/event_study_hourly_rate_hired.pdf
./plots/event_study_hourly_rate_hired.pdf: ../analysis/plot_event_study_hourly_rate_hired.R ../data/event_study_hired.csv
	cd ../analysis && Rscript plot_event_study_hourly_rate_hired.R

### Figure 7 
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L927
plots += plots/did_all_outcomes.pdf
./plots/did_all_outcomes.pdf: ../analysis/plot_did_all_outcomes.R ../data/did_panel.csv 
	cd ../analysis && ./plot_did_all_outcomes.R 

### Figure 7 
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L927
plots += plots/did_q_outcomes.pdf
./plots/did_q_outcomes.pdf: ../analysis/plot_did_all_outcomes.R ../data/did_panel.csv 
	cd ../analysis && ./plot_did_all_outcomes.R

### Figure 7 
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L927
plots += plots/did_match_outcomes.pdf
./plots/did_match_outcomes.pdf:  ../analysis/plot_did_all_outcomes.R ../data/did_panel.csv 
	cd ../analysis && ./plot_did_all_outcomes.R

### Figure 7 
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L927
plots += plots/did_ll_subst_outcomes.pdf
./plots/did_ll_subst_outcomes.pdf:  ../analysis/plot_did_all_outcomes.R ../data/did_panel.csv 
	cd ../analysis && ./plot_did_all_outcomes.R


#  Figure 8
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L1040
plots += ./plots/application_event_study.pdf
./plots/application_event_study.pdf: ../analysis/plot_application_event_study.R ../data/event_study_windows.csv
	cd ../analysis && Rscript plot_application_event_study.R


###################
## End of Main Body
###################


# Figure A1
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L1200
plots += plots/organic_applications.pdf
./plots/organic_applications.pdf: ../analysis/plot_organic_applications.R $(data)
	cd ../analysis && Rscript plot_organic_applications.R

# Figure A2: 
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L1222
plots += plots/follow_on_openings.pdf
./plots/follow_on_openings.pdf: ../analysis/plot_follow_on_openings.R $(data)
	cd ../analysis && Rscript plot_follow_on_openings.R

# Figure A3
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L1301
plots += ./plots/avg_wages_by_cat.pdf 
./plots/avg_wages_by_cat.pdf: ../analysis/avg_wages_by_cat.R 
	cd ../analysis && Rscript avg_wages_by_cat.R

# Figure B1
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L1355
plots += plots/hours_zero.pdf
./plots/hours_zero.pdf: ../analysis/plot_hours_zero.R $(data)
	cd ../analysis && Rscript plot_hours_zero.R

# Figure B2
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L1383
plots += plots/any_exper.pdf
./plots/any_exper.pdf: ../analysis/plot_any_exper.R $(data)
	cd ../analysis && Rscript plot_any_exper.R

# Figure B3
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L1406
plots += plots/feedback.pdf
./plots/feedback.pdf: ../analysis/plot_feedback.R $(data)
	cd ../analysis && Rscript plot_feedback.R

# Figure B4
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L1441
plots += ./plots/event_study_hired_admin.pdf
./plots/event_study_hired_admin.pdf: ../analysis/plot_event_study_hired_admin.R ../data/event_study_hired.csv
	cd ../analysis && Rscript plot_event_study_hired_admin.R

# Table A1: 
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L1155
tables += ./tables/randomization_check.tex
./tables/randomization_check.tex: ../analysis/randomization_check.R ../data/df_mw_first.csv 
	cd ../analysis && Rscript randomization_check.R

# Table B1
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L1353
tables += tables/quantile_hours_worked.tex
./tables/quantile_hours_worked.tex: ../analysis/quantile_hours_worked.R ../data/event_study_windows_hr_v_fp.csv
	cd ../analysis && Rscript quantile_hours_worked.R

# Table B2
# https://www.github.com/johnjosephhorton/minimum_wage/blob/main/writeup/minimum_wage.tex#L1414
tables += ./tables/any_prior.tex
./tables/any_prior.tex: ../analysis/table_any_prior.R 
	cd ../analysis && Rscript table_any_prior.R

../backups/$(project_name)_$(ts).tar.gz:
	tar --exclude='../backups' --exclude='../.git' -zcvf ../backups/$(project_name)_$(ts).tar.gz ../

backup: ../backups/$(project_name)_$(ts).tar.gz
	echo "Making backup"
	cp ../backups/$(project_name)_$(ts).tar.gz ~/Dropbox/backups/$(project_name)/

snapshot: $(project_name).pdf
	@echo Timestamp is $(ts)
	cp $(project_name).pdf ../snapshots/$(project_name)_$(ts).pdf

website: $(project_name).pdf
	printf 'cd papers\nput $<\n' \ | sftp -oPort=2222 johnjhorton@104.198.96.220

purge:
	-rm -rf ../data
	-rm ../remote_data.tar.gz
	-rm ../remote_data.tar.gz.gpg
	-cd plots && find . -maxdepth 1 -type f -print0 | xargs -0 -I {} mv {} unused && touch PLACEHOLDER.txt
	-cd tables && find . -maxdepth 1 -type f -print0 | xargs -0 -I {} mv {} unused && touch PLACEHOLDER.txt
	-cd parameters && find . -maxdepth 1 -type f -print0 | xargs -0 -I {} mv {} unused && touch PLACEHOLDER.txt


$(project_name).pdf: create-dirs fetch-data $(project_name).tex $(project_name).bib $(parameters) $(LEVEL_PLOTS) $(LINE_PLOTS) $(WRAPPERS) $(COMBINED_TABLES) $(plots) $(tables)
	pdflatex -shell-escape -interaction=batchmode $(project_name)
	pdflatex -shell-escape -interaction=batchmode $(project_name)
	bibtex $(project_name) 
	pdflatex -shell-escape -interaction=batchmode $(project_name)
	pdflatex -shell-escape -interaction=batchmode $(project_name)
	gs -q -dNOPAUSE -dBATCH -dPDFSETTINGS=/prepress -sDEVICE=pdfwrite -sOutputFile=tmp.pdf $(project_name).pdf
	rm -f *.aux *.log *.out *.bbl *.blg *.toc *.lof *.lot *.bcf tmp.pdf

toread: $(project_name).pdf
	scp $(project_name).pdf bandit-local.local:/home/john/Dropbox/toread/$(project_name)_$(ts).pdf || cp $(project_name).pdf ~/Dropbox/toread/$(project_name)_$(ts).pdf 
