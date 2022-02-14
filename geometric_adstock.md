## Geometric Adstock Test

**Purpose**: Evaluate Effectiveness of Robyn in Detecting Carryover in Geometric Adstock

**How**: Using Two-Variable Toy Data Set with Diminishing Returns for One Variable (FB) and Carryover for Second (TV)

**Analysis**: all_hyperparameters.csv

**Data Set**: robyn_toy_data_2paidvar_bal_eff2ratio_dimret_carry_600000err.csv [described in README](README.md).

**Options**: tv_theta set to 0-0.999 for this analysis

**Output**: 2022-02-10_15.50_init

**Findings**: 
* Robyn does detect and *estimates accurately* geometric adstock effect for TV variable
* Robyn *underestimates* impact on bookings for both variables in our example

## Input

FB contribution is generated with diminishing returns to spend, but no carryover.

TV contribution includes a carryover effect which lasts up to 10 days after each expenditure.

The toy data set logic:
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
spend).  The tv_scale (45) was selected so the total contribution of TV to bookings would be roughly comparable to the
FB contribution to bookings.

In the data set, the contribution which was used to set the bookings is parceled out among tv_contribution, fb_contribution, and a constant.
Therefore, we can see that for 2021 (period of analysis), the TV contribution in the data set is expected to be about 372 million,
whereas the FB contribution should be about 363 million.  These figures are available in the [ipynb which
generates this data set](MMMToyDataSetTwoPaidVarBalSpendEffect2RatioDimRetCarryover.ipynb).

## Qualitative Findings

### Geometric Adstock Charts

#### TV shows greater adstock percentage in new analysis

We expect TV to show a greater adstock percentage than TV, and indeed we see that as in:
![pareto_5_479_1](robyn_output/2022-02-10_15.50_init/5_479_1.png)


### Response Curve

The current response curve charts may be a bit difficult for stakeholders to understand when carryover
is significant, as the x-axis is labelled "Spend" and a mean data point is shown in term of spend, but the
curve is actually in terms of AdStock effects, which in this case is much higher than spend and does not
intersect with the spend point on these charts.


## Quantitative Findings: Geometric Adstock

We are using Geometric adstock for all Robyn runs to date.

* Data Set with Carryover (FB diminishing): 2022-02-10_15.50_init

### Theta Estimation (Carryover)

10 models are on Pareto Front 1.  We analyze the range of hyperparameters found in these sets (all_hyperparameters.csv):

* TV theta: Range 0.791-0.792
* FB theta: 0.01-0.04 (most around 0.01)

The mathematics for our initial model setup was to assume about a 80% carryover of spend from one day
to the next.  We are unclear if our 0.8 is identical to the [ad-stock theta percentage described](https://facebookexperimental.github.io/Robyn/docs/analysts-guide-to-MMM).
However, it appears the Robyn model estimated the TV theta fairly precisely and landed at the number input
in the toy data set.

### Contribution to Bookings Estimation

* FB is estimated to contribute $258 million to bookings (mean for Pareto Front 1), with a range on this front from
$214 million to $272 million.
* TV is estimated to contribute $267 million to bookings (mean), with a range from $266 million to $271 million.

Both estimates of contributions fell short of the values in the input data set, by about $100 million on $363-$372 million.

Robyn seems to underestimate the impact on bookings. One possible contributor is that Robyn has assigned an $80 million
contribution to trend on average across these models, ranging from $31 million to $132 million.

## Further Notes When Examining Hyperparameters

It is imperative that the hyperparameter range is sufficient to allow this type of modeling.
An earlier version of this analysis, 2022-02-03_19.21_init, was impacted by the fact that theta was
overly constrained.

Users should always review hyperparmeters.png and look for evidence of overly constrained search spaces.  
One indicator would be seeing hyperparameters pinned up against one end of a search range.