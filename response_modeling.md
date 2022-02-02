# Robyn Response Modeling

**Purpose**: Evaluate Effectiveness of Robyn in Detecting Diminishing Paid Media Response

**How**: Using Two-Variable Toy Data Set with Diminishing Returns for One Variable (FB)

**Analysis**: pareto_media_transform_matrix.csv (not published to github due to filesize)

## Null Hypothesis

Robyn measures the response curve correctly for paid media with diminishing returns

Two questions:
* Is the estimate of the total effect correct?
* Is the marginal estimate (response curve) correct?

## Setup

[Case Diminishing](robyn_output/2022-02-01_18.45_init): Two variables (FB, TV) FB is non-linear in spend and TV
is linear in spend

Here we have a new case generated from the data set robyn_toy_data_2paidvar_bal_eff2ratio_dimret_600000err.csv.

The ipynb file generating this data set has supporting details on the mathematical equation used to create 
diminishing returns.  As with other data sets, there is a variable, fb, representing spend on fb, while there
is another variable, fb_contribution, representing the effect that spend has had.  In this case, fb_contribution
grows monotonically with fb spend, but with diminishing benefit to additional spend.


[Case Linear](robyn_output/2022-01-31_16.15_init): Two variables (FB, TV) where FB = 2 times the effect of TV
Here we simply use the same results from our effect ratio response study


## Results

### Accuracy

The question of accuracy we can take up using the diminishing results Robyn output files.

On inspection of the generated model one-pagers we can see that FB has a more flat response curve than TV.
So it appears at first blush that Robyn has successfully detected a diminishing return curve.  To quantify, we want to ask how 
accurate are these curves?

To measure accuracy, we take the output from the pareto_media_transform_matrix.csv, and we plot the 
decomp_media (response variable) against the raw spend.  We believe this gives us the closest measure of the 
response and is the basis for generating the response curves we see in model one-pagers.

We can overlap these response curves with the ground truth response curve.  We do this in our file
[AnalyzeDiminisingResponseAccuracy.ipynb](analysis/AnalyzeDiminishingResponseAccuracy.ipynb)

Here is an example from the ipynb of us overlaying an estimated response curve for one solution with ground truth:
![Example png file](robyn_output/2022-02-01_18.45_init/1_396_4_gt_response_compare.png)

In this image, we observe two things which are common across Pareto Front 1 solutions:
* the response curve from Robyn lies below the ground truth response curve
* the slope of the response curve from Robyn is similar to the ground truth response curve

#### Level Accuracy

Reviewing all_aggregated.csv we can see the xDecompAgg for all Pareto Front #1 solutions for fb 
coefficients.  These values average 282 million dollars.   From the ground truth data set we know
that we were looking for an overall contribution of 362 million.  Robyn has underestimated the total
effect of fb on our target variable, and this is consistent with the lower solution lines for all Pareto Front 1 models.

#### Slope Accuracy

We wish to estimate the slope around the mean.  The mean is selected since that would be a typical spend
level.  

At first, we tried to estimate the slope by selecting only one point below and above the mean spending level, but
we found this led to variable results.  To better estimate the slope, we then selected the 10 points closest to the 
mean spending (but below it) and the 10 points closest to the mean spending which are above the mean.  We took the average
effects for these two groups to estimate the slope in the vicinity of the mean.

Those slope values are what we have plotted in each graph.

Across all Pareto Front 1 models the mean slope was 64.26, not far off the ground truth of 66.2
The minimum from any Pareto Front 1 solution was 60.2 and the maximum was 76.2.  

From these observations we feel that Robyn provides a reasonable estimate of the slope in the diminishing returns
case.  Furthermore, examination of the model one pagers shows that Robyn consistently shows the 
slope of the FB spend to be more flat than the TV spend in the vicinity of the mean, correctly representing
that a significant difference exists in marginal impact of spending in these two channels.

Consider this one pager:
![1_500_1 png file](robyn_output/2022-02-01_18.45_init/1_500_1.png)

Examining the Response Curve chart (middle chart on the right side), Robyn shows that the tv spend
has considerably greater slope than the fb spend, as expected.  This finding gives us confidence
in the response curve results with stakeholders.

### Comparing Data Sets

As we just stated, the diminishing return case resulted in model one-pagers which consisently showed 
more flat returns for fb than tv.

We can review a chart from the 2:1 effectiveness study of fb and tv:
![1_65_1.png file](robyn_output/2022-01-31_16.15_init/1_65_1.png)

Here, we see that FB and TV look largely linear in the vicinity of their mean, and the FB chart is has
a higher slope in accordance with the greater effect.

While we have not quantified these slopes at this point, this lends credibility to Robyn's detection 
of response curve (slopes).
