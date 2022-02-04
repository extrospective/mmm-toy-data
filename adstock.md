# Adstock Test

**Purpose**: Evaluate Effectiveness of Robyn in Detecting Carryover in Adstock

**How**: Using Two-Variable Toy Data Set with Diminishing Returns for One Variable (FB) and Carryover for Second (TV)

**Analysis**: pareto_media_transform_matrix.csv (not published to github due to filesize)

**Data Set**: robyn_toy_data_2paidvar_bal_eff2ratio_dimret_carry_600000err.csv [described in README](README.md).

**Output**: 2022-02-03_19.21_init

## Input

FB contribution is generated with diminishing returns to spend, but no carryover.

TV contribution includes a carryover effect which lasts up to 10 days after each expenditure.

The logic:
```angular2html
    #
    # tv: carryover
    #
    tv_scale = 45
    carry = 0.8  # carryover multiplier
    context_scale = 800000
    
    df['tv_contribution_carry'] = (tv_scale * (df.tv.shift(1) * math.pow(carry,1) + 
                                              df.tv.shift(2) * math.pow(carry,2) +
                                             df.tv.shift(3) * math.pow(carry,3) +
                                             df.tv.shift(4) * math.pow(carry,4) +
                                             df.tv.shift(5) * math.pow(carry,5) +
                                             df.tv.shift(6) * math.pow(carry,6) +
                                             df.tv.shift(7) * math.pow(carry,7) +
                                             df.tv.shift(8) * math.pow(carry,8) +
                                             df.tv.shift(9) * math.pow(carry,9) +
                                             df.tv.shift(10) * math.pow(carry,10)
                                             )).round(0)
    df['tv_contribution'] = (df.tv * tv_scale + df.tv_contribution_carry).round(0)  # NA for early obs so cannot declare int
```

is intended to cause TV contribution to carryover with a diminishing amount per day (shift(N) means N days earlier
spend).  The tv_scale was selected so the total contribution of TV to bookings would be roughly comparable to the
FB contribution to bookings. For 2021, the TV contribution in the data set is expected to be about 372 million,
whereas the FB contribution should be about 363 million.  These figures are available in the [ipynb which
generates this data set](MMMToyDataSetTwoPaidVarBalSpendEffect2RatioDimRetCarryover.ipynb).

## Qualitative Findings

### Geometric Adstock Charts

#### TV shows greater adstock percentage in new analysis

We expect TV to show a greater adstock percentage than TV, and indeed we see that as in:
![pareto_3_425_4](robyn_output/2022-02-03_19.21_init/3_425_4.png)

#### But FB also sometimes has greater adstock percentage

One observation is that in some models, the FB adstock departs significantly from zero also, although
it may remains less than TV, as in:
![pareto_3_444_3](robyn_output/2022-02-03_19.21_init/3_444_3.png)

We expected the FB adstock to be close to 0%.  So it is possible that having some carryover for TV
contaminated the measurement of carryover for FB.

#### Prior analysis with same exact FB data has lower adstock percentage

We contrast this with the results from our diminishing study, where Robyn correctly estimated the 
geometric adstock decay rates at close to zero.

For example:
![pareto_1_396_4](robyn_output/2022-02-01_18.45_init/1_396_4.png)

and:
![pareto_1_441_4](robyn_output/2022-02-01_18.45_init/1_441_4.png)

and:
![pareto_1_492_3](robyn_output/2022-02-01_18.45_init/1_492_3.png)




### Response Curve

When studying the [diminshing effects response curve](response_modeling.md), we found that Robyn correctly 
distinguished FB as having a flatter effect from TV.  We are a bit surprised that in the case of 
carryover adstock, the TV effect now appears to be more flat than the FB effect.

Our sense is that the response to spend diagram should show the reverse. But we are not yet sure,
as the actual mathematics behind the model one-pager is adstock on the x-axis although the graph is labelled
spend.

Consider:
![pareto_3_425_4](robyn_output/2022-02-03_19.21_init/3_425_4.png)

In this chart we see a steeper response curve for the FB line in the middle right section.
This was typical of one pagers examined.


## Quantitative Findings

### Data Set with Carryover (FB diminishing): 2022-02-03_19.21_init

10 models are on Pareto Front 1.  We analyze those data sets.

* TV theta: Average 0.198, range 0.191-0.200
* FB theta: Average 0.042, range 0.014-0.098

The mathematics for our initial model setup was to assume about a 80% carryover of spend from one day
to the next.  We are unclear if that is identical to the [ad-stock theta percentage described](https://facebookexperimental.github.io/Robyn/docs/analysts-guide-to-MMM).
We might have expected TV thetas closer to 0.80 rather than 0.20, but have not rigorously calculated the implied atstock in our model 
for comparison.

### Data Set without Carryover (FB diminishing): 2022-02-01_18.45_init

23 models on Pareto Front 1 (so min/max may have wider range).

* TV Theta: Average 0.006, max 0.036
* FB Theta: Average 0.004, max 0.018

Conclusion - the carryover for TV in the data seems to cause Robyn to predict a carryover effect for FB
which (while small) is about 10x larger than a data set without TV carryover.
