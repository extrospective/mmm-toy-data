## Libraries
library(Robyn) 
library(readr)
library(data.table)
library(dplyr)
library(rlist)
## force multicore when using RStudio
Sys.setenv(R_FUTURE_FORK_ENABLE="true")
options(future.fork.enable = TRUE)

library('reticulate')

#
# Key configuration items
# 
window_start = "2021-01-01"                        # Robyn window start
window_end = "2021-12-31"                          # Robyn window end
trials =  5                                        # Robyn trials
iterations = 2000                                  # Robyn iterations
source_file = "../mmm-toy-data/data/robyn_toy_data_2paidvar_bal_eff2ratio_dimret_600000err.csv"   
                                                   # csv file with the source data
robyn_version_expected = '3.5.0.2'                 # assert correct version of Robyn
output_working_directory = 'e:\\repo\\robyn-mmm'   # where output will be stored
country_filter = "US"                              # for prophet to know country
envname = 'never2'                                 # name of conda env setup for nevergrad
set.seed(45)                                       # repeatability
options(digits=12)                                 # dataframe printing
cores = 6

#
# Configure across experiments
#
target_variable = 'bookings_noiseless'
paid_media_vars = c("tv", "fb")                          # variables to be tested, could be tv, fb
paid_media_spends = c("tv", "fb")                        # variables to be tested, could be tv, fb
paid_media_signs = c("positive", "positive")
context_vars = c()                                # context, could be c('context_0_center')
context_signs = c()                               # could be c('default')

# match number of media variables here; may need fb
hyperparameters <- list(
  tv_alphas = c(0.001, 2.0)  
  , tv_gammas = c(0.3, 1.0)
  , tv_thetas = c(0, 0.2) 
  , fb_alphas = c(0.001, 2.0)
  , fb_gammas = c(0.3, 1.0)
  , fb_thetas = c(0, 0.2)
)


#
# Check version
#

pkg_version = packageVersion('Robyn')
if (pkg_version != robyn_version_expected) {  
  writeLines(as.character(pkg_version))
  stop('Wrong pkg version')
} else {
  writeLines('Libraries loaded. Robyn package version tested')
}



## Configuration -------------------------------------------
#
# User needs to adjust this part specifically
#
# Beware that these are relative to *working directory* not where this R file
# is stored.  (In RStudio working directory can be changed under Tools/GlobalOptions)
setwd(output_working_directory)

## Testing conda
#
use_condaenv(envname,required = TRUE)       # loads conva environment and verifies
py_config()                                 # Check that everything is correct


adstock_model = 'geometric'
nevergrad_algo = "TwoPointsDE"

holidays_none = data_frame (
  holiday = 'NoHoliday',
  country = country_filter,
  year = c(2008),
  ds = as.Date(c('2008-02-01'))
)


# typically not modified
date_format = "%m/%d/%Y"                                                        # format of date in csv file
robyn_object <- paste0("output/mmm_", format(Sys.Date(), "%Y_%m_%d"), ".RDS")   # where to store output from run
plot_folder_sub = paste0(format(Sys.time(), "%Y-%m-%d_%H.%M"), "_init")
optimal_cores = future::availableCores() - 2

src_dt<- read.csv(source_file, header=TRUE, sep=',') 


################################################################
#### Step 2a: For first time user: Model specification in 4 steps

#### 2a-1: First, specify input data & model parameters

InputCollect <- robyn_inputs(
  dt_input = src_dt
  ,dt_holidays = holidays_none
  ### set variables
  ,date_var = "date" 
  ,dep_var = target_variable
  ,dep_var_type = "revenue" 
  
  ,prophet_vars = c("trend") 
  ,prophet_signs = c("positive")  
  ,prophet_country = country_filter
  
  ,paid_media_vars = paid_media_vars
  ,paid_media_spends = paid_media_spends
  , paid_media_signs = paid_media_signs
  , context_vars = context_vars
  , context_signs = context_signs
  
  ### set model parameters
  
  ## set cores for parallel computing
  ,cores = cores    # I am using 6 cores from 8 on my local machine. Use future::availableCores() to find out cores
  
  ## set rolling window start
  # doing full year model for test
  ,window_start = window_start
  ,window_end = window_end
  
  ## set model core features
  ,adstock = adstock_model # geometric or weibull. weibull is more flexible, yet has one more parameter and thus takes longer
  ,iterations = iterations
  
  ,nevergrad_algo = nevergrad_algo # recommended algorithm for Nevergrad, the gradient-free
  # optimisation library https://facebookresearch.github.io/nevergrad/index.html
  ,trials = trials
  )

#### 2a-2: Second, define and add hyperparameters
# helper plots: set plot to TRUE for transformation examples
plot_adstock(TRUE) # adstock transformation example plot,
# helping you understand geometric/theta and weibull/shape/scale transformation
plot_saturation(TRUE) # s-curve transformation example plot,
# helping you understand hill/alpha/gamma transformation


## 3. set each hyperparameter bounds. They either contains two values e.g. c(0, 0.5),
# or only one value (in which case you've "fixed" that hyperparameter)

# Run ?hyper_names to check parameter definition
hyper_names(adstock = InputCollect$adstock, all_media = InputCollect$all_media)


#### 2a-3: Third, add hyperparameters into robyn_inputs()
print("RStudio code: invoking robyn_inputs")
InputCollect <- robyn_inputs(InputCollect = InputCollect, 
                             hyperparameters = hyperparameters)
print('RStudio code: robyn_inputs complete')

#### 2a-4: Fourth (optional), model calibration / add experimental input
# NA


################################################################
#### Step 2b: For known model specification, setup in one single step


################################################################
#### Step 3: Build initial model

# Run ?robyn_run to check parameter definition
print('robyn_run started')
OutputCollect <- robyn_run(
  InputCollect = InputCollect # feed in all model specification
  , plot_folder = robyn_object # plots will be saved in the same folder as robyn_object
  , plot_folder_sub = plot_folder_sub
  , pareto_fronts = 3
  , csv_out = "all"  # code modification to ensure all csv output in our fork of Robyn
  # we are using seed above only and do not want to put it here as well  , seed=seed
  , plot_pareto = TRUE  # can make FALSE To save time but then we dont have the output images
  , unconstrained_intercept = TRUE  # allows negative intercept in our fork of Robyn
  , saveInputCollectSelector = TRUE # save the input collector because we will need it for the allocator to be pulled up separately
)
print('robyn_run complete')

print('intentional stop')
stop()
################################################################
#### Step 4: Select and save the initial model

# budget allocation

# select a particular model
select_model = '1_248_6'

# this version has bug where channel_constr_low and channel_construct_up must have same length as paid_media_vars (2)
channel_constr_low = c(0.6, 0.6)  # NOTE: this line will essentially restrict the range of solutions the optimizer could consider
channel_constr_up = c(20, 20)
alloc = robyn_allocator(InputCollect=InputCollect, OutputCollect=OutputCollect, select_model=select_model, channel_constr_low=channel_constr_low, channel_constr_up=channel_constr_up)


# run with future spend

if (FALSE) {
  AllocatorCollect <- robyn_allocator(
    InputCollect=InputCollect, 
    OutputCollect=OutputCollect, 
    select_model=select_model,
    scenario = "max_response_expected_spend",
    channel_constr_low = c(0.01, 0.01),
    channel_constr_up = c(20, 20),
    expected_spend = 3608511,  # match historical for this test
    expected_spend_days = 365
  )
  
  
  AllocatorCollect <- robyn_allocator(
    InputCollect=InputCollect, 
    OutputCollect=OutputCollect, 
    select_model=select_model,
    scenario = "max_response_expected_spend",
    channel_constr_low = c(1, 1),
    channel_constr_up = c(200, 1),
    expected_spend = 3608511*2,  # double th spend in the future
    expected_spend_days = 365
  )
  
  AllocatorCollect <- robyn_allocator(
    InputCollect=InputCollect, 
    OutputCollect=OutputCollect, 
    select_model=select_model,
    scenario = "max_response_expected_spend",
    channel_constr_low = c(2, 1),
    channel_constr_up = c(2, 1),
    expected_spend = 5406087,  # ideally one would double the first channel and input the value here
    expected_spend_days = 365
  )  
  
  AllocatorCollect <- robyn_allocator(
    InputCollect=InputCollect, 
    OutputCollect=OutputCollect, 
    select_model=select_model,
    scenario = "max_response_expected_spend",
    channel_constr_low = c(1.5, 0.8),
    channel_constr_up = c(1.5, 0.8),
    expected_spend = 4154463,  # ideally one would double the first channel and input the value here
    expected_spend_days = 365
  )  
}