# MMM Toy Data

Meta (Facebook) Experimental [Robyn](https://github.com/facebookexperimental/Robyn) is a novel tool used to measure the impact of paid media on target variables (such as revenue, bookings, visits or conversions.)

This repository provides some tools to perform your own testing of the Robyn technology.

The concept is to provide data sets with known variable relationships.  Given these data sets one can:
* Evaluate whether Robyn (or any MMM technology) correctly identifies the known relationships, and
* Whether the technology reaches false conclusions.

An alternative technology we have used is VAR: Vector Autoregression.  These data sets may also be useful in evaluating VAR measurement of paid media variables.

Here we have provided:
* Source code used to generate the data sets (ipynb files for ipython Jupyter notebooks).
* In some cases, the actual data sets
* Sample code which can be used to run Robyn and use these data sets

# For [Robyn](https://github.com/facebookexperimental/Robyn)

## Insights and Analysis

The purpose of these data sets are to support insights and analyses.  Select analyses we have performed are included in this repo:

* [Calibration](calibration.md) - How Robyn calibration performs and is reported
* [Robyn Effect Ratio Detection](robyn_effect_ratio_response.md) - How Robyn performs when average effects are unequal
* [Response Modeling: Diminishing Returns](response_modeling.md) - How Robyn performs with paid media variables with diminishing returns
* [Adstock](adstock.md) - How Robyn performs with marketing with carryover effects

## Data Sets for Robyn

### Data Sets
The data sets created by these two files are in the data directory so users do not have to recreate:
* robyn_toy_data_1paidvar_600000err.csv: one paid media variable is the only driver for bookings
* robyn_toy_data_2paidvar_balanced_600000err.csv: two paid media each with identical effect and similar spend levels
* robyn_toy_data_2paidvar_bal_effratio_600000err.csv: two paid media with uneven effect (3:1 ratio) but similar spend levels
* robyn_toy_data_2paidvar_bal_eff2ratio_600000err.csv: two paid media with uneven effect (2:1 ratio) but similar spend levels
* robyn_toy_data_2paidvar_bal_eff2ratio_dimret_600000err.csv: two paid media with uneven effect and diminishing returns for fb variable
* robyn_toy_data_2paidvar_bal_eff2ratio_dimret_carry_600000err.csv: two paid media, uneven effect, dim returns for fb, carryover returns for tv

We expect to retire use of this data set:
* robyn_toy_data_2paidvar_imbalanced_600000err.csv: originally the 2 paid variable data set, but vastly unequal spend is not consistent with typical MMM ground truth or Robyn's approach.

### Generating Scripts

These scripts can be reviewed to understand how the data sets were created and some summary statistics.

* MMMToyDataSetOnePaidVar.ipynb: creates data set with one paid variable
* MMMToyDataSetTwoPaidVarBalancedSpend.ipynb: created data set with two paid variables, balanced spend and effect
* MMMToyDataSetTwoPaidVarBalSpendEffectRatio.ipynb: creates data set two paid variables, balanced spend but imbalandced and known effect (3:1)
* MMMToyDataSetTwoPaidVarBalSpendEffect2Ratio.ipynb: creates data set two paid variables, balanced spend but imbalandced and known effect (2:1)
* MMMToyDataSetTwoPaidVarBalSpendEffect2RatioDimRet.ipynb: creates data set two paid variables, balanced spend and diminishing return for one variable

Expect to retire:
* MMMToyDataSetTwoPaidVarImbalancedSpend.ipynb: 

Additionally we have put in the data directory a data set which was used in early experimentation,
and differs primarily because a different number of random draws occurred:
* robyn_toy_data_600000.csv

## Execution of Script in Robyn

The example data script:
* robyn_toy_script.R: script to execute using a toy data set

A certain amount of configuration is required, such as working directory, number of cores, nevergrad environment, etc.  We presume the user is familiar with the Robyn getting started and demo script upon which this is based.

Additionally, some further configuration may be required as one runs various experiments in R.

Note: our local Vistaprint version of Robyn has an argument "unconstrained_intercept" which allows Robyn
to have negative intercepts. We believe this is critical for equation fitting.  If you are using a version
of Robyn which does not support this argument you will have to comment out this one line.

### Specific scripts

Although very similar, for documentation reasons we are going to push up scripts actually used.  These should be fairly self-explanatory from naming.

* robyn_two_var_fb_only.R: two variable, balanced, only FB variable considered as driver
* robyn_two_var_tv_fb_calibration.R: two variable code for TV and FB with optional calibration

# For [VAR Vector Autoregression](https://www.rdocumentation.org/packages/vars/versions/1.5-6/topics/VAR)

This section is a bit less developed, as we are not currently working on this code.  We expect to revisit shortly.

* PoisonToy.ipynb was created for VAR in order to determine how it would measure the impact of poison

The concept was that we had a variable which was good (food) and one which was occasional and bad (poison), and we wanted to identify whether VAR (or BigVAR) would correctly evaluate the impact of both food and poison on the outcome variable (health).

The data sets created by this are not in the data directory due to the size of some.
