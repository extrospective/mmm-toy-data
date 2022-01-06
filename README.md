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

## Data Sets for Robyn

Run a script in Jupyter notebook to create output data sets.

* MMMToyDataSetOnePaidVar.ipynb: creates a data set with one paid variable
* MMMToyDataSetTwoPaidVar.ipynb: creates a data set with two paid variables

The data sets created by these two files are in the data directory so users do not have to recreate:
* robyn_toy_data_1paidvar_600000err.csv
* robyn_toy_data_2paidvar_600000err.csv

Additionally we have put in the data directory a data set which was used in early experimentation,
and differs primarily because a different number of random draws occurred:
* robyn_toy_data_600000.csv

## Execution of Script in Robyn

The example data script:
* robyn_toy_script.R: script to execute using a toy data set

A certain amount of configuration is required, such as working directory, number of cores, nevergrad environment, etc.  We presume the user is familiar with the Robyn getting started and demo script upon which this is based.

Additionally, some further configuration may be required as one runs various experiments in R.

# For [VAR Vector Autoregression](https://www.rdocumentation.org/packages/vars/versions/1.5-6/topics/VAR)

This section is a bit less developed, as we are not currently working on this code.  We expect to revisit shortly.

* PoisonToy.ipynb was created for VAR in order to determine how it would measure the impact of poison

The concept was that we had a variable which was good (food) and one which was occasional and bad (poison), and we wanted to identify whether VAR (or BigVAR) would correctly evaluate the impact of both food and poison on the outcome variable (health).

The data sets created by this are not in the data directory due to the size of some.
