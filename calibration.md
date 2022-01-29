# Calibration Test

Objective: Assess Impact of Calibration on Robyn Solutions

Approach: Use toy data set, one time with calibration and one time without

Calibration: A single day of one channel. The smallest calibration possible within Robyn.

|             | 2022-01-28 18.52     | 2022-01-28 20.01                                       |
|-------------|----------------------|--------------------------------------------------------|
| calibration | no                   | yes                                                    |
| target      | bookings_noiseless   | bookings_noiseless                                     |
| predictors  | FB & TV (no context) | FB & TV (no context)                                   |\
| calibration data | none                 | July 1 2021, FB only - using ground truth contribution |
| data set | robyn_toy_data_2paidvar_bal_effratio_600000err.csv| robyn_toy_data_2paidvar_bal_effratio_600000err.csv     | 

Note: in selecting this *effectiveness ratio* data set, we know that FB has three times the effect of TV
on bookings.  This adds an extra challenge to Robyn, which inherently prefers solutions where
the *average* effectiveness of all channels is equivalent.  (The decomp.RSSD minimization is solved
by having every variable have the same *average* effectiveness.)

Further note: one critique of the Robyn "equal average effect" optimization target is that it contradicts
marketing's optimization target which should be "equal marginal effect".  However, as many marketing departments
are less sophisticated or do not have tools to measure marginal effect, it is possible that the Robyn target
is an approximation for marginal effects which could be acceptable.  However, we do not think this is an 
aspiration for marketing!



## Pareto Fronts Compared

### Uncalibrated
The uncalibrated Pareto Front shows values which range from best NRMSE (0.02) to best DECOMP.RSSD (0.0) at 
NRMSE > 0.04.  Of course we know the ground truth is closer to the 0.02 NRMSE.

![Uncalibrated Pareto Front]("robyn_output/2022-01-28 18.52 init/pareto_front.png")


### Calibrated

The calibrated Pareto Front shows that there are points near the uncalibrated Pareto Front, but these are 
disqualified as potential solutions.  When doing a calibrated run, the Pareto Front shows dots in gray
rather than on the blue spectrum if they are disqualified.

![Calibrated Pareto Front]("robyn_output/2022-01-28 20.01 init/pareto_front.png")

#### Disqualification

Disqualification when uncalibrated
* Worst 10% of NRMSE solutions
* Worst 10% of decomp.RSSD solutions

Note: when doing an uncalibrated Pareto Front the disqualified data points are not colored distinctly from the
qualified data points. 

Rationale: We expect the Robyn team has disqualified certain data points because they may seem "extreme".
These extreme points could otherwise occur at the two ends (or wings) of the Pareto Front.  If you look at a
Pareto Front and notice certain data points which look like they belong to the Pareto Front, but occur
at either extreme, their exclusion may be due to disqualification.

Implication: Since nevergrad is optimizing to a mix of decomp.RSSD and NRMSE, its exploration may not include
much analysis favoring either variable on its own.  The lack of exploration may contribute to 
disqualification, since disqualification is not based on poor performance but instead on lack of *popularity* in the
solution space.  Therefore, good solutions for ground truth could be disqualified from the Pareto Front simply
due to sitting far away from the nevergrad optimization target.  Thus, while the Pareto Front visually suggests
that Robyn has pushed the Robyn front in all ways as much as possible, in reality the balanced target for nevergrad
causes greatest exploration near the balanced target, and less exploration on the wings of the Pareto Front.

Disqualification for calibrated data sets:
* Worst 10% of NRMSE solutions
* Worst 10% of decomp.RSSD solutions
* Worth 90% of calibration solutions (based on MAPE) - tunable coefficient

To explain this, first we need to explain the MAPE calculation.

The calibration data input identifies one or more days and channels for which input is provided.
The MAPE calculation (summarized in all_aggregated.csv) simply calculates the Mean Absolute Percentage Error
for the target contribution during the calibrated period.

The MAPE calculation is: abs(observed - calibrated) / calibrated.
When reproducing this calculation, note the denominator is the calibrated value.

Every solution has a MAPE calculation.  These are then ranked to compute the 10th percentile, and
any solutions achieving worse than 10th percentile (i.e 90% of the solutions) will be disqualified.  The
Pareto Front diagram then marks the iteration as NA in the code, resulting in gray rather than blue dots.

The user can tune the calibration constraint, although without source code changes can only make the calibration
constant more *restrictive*.  calibration_constant=0.1 by default meaning 90% of models are disqualified.  If one
set the calibration_constant=0.02 it would mean that 98% of models are disqualified.

Our *sense* of how this should work is that disqualification should bear some proportion to the amount of 
calibration information provided, and as we see in the case documented here, with a single day calibration it
feels like the ten percent *least restrictive* assumption is actually *too* restrictive.

But this brings us to another point: there is a distinction between the nevergrad optimization and disqualification.

### Nevergrad and Solution Generation

Disqualification occurs at the end of the solution search, when a small subset of solutions are proposed
for the Pareto front. However, more important is the process by which nevergrad searches in that solution space.

When engaged in calibrated search, nevergrad shifts from optimizing two values (nrmse, decomp.rssd) to optimizing three 
simultaneous targets (nrmse, decomp.rssd, and mape).  This means that nevergrad will iterate towards solutions
which optimize these three values more.'

In practice, this has some important implications on how Robyn runs:
* NRMSE (which we believe may be most important for ground truth) now has two competitors
* Search space will increasingly target around low values of MAPE

When we get to disqualification, nevergrad's actions have implications:
As the search space targets around low values of MAPE, we may have spent less time around the best
values for the other parameters.  Each of these three values have percentile based disqualification, in which
case *where nevergrad spends it's time impacts popularity of solutions, which in turn drives disqualification*.
So solutions which might have been closer to ground truth can be removed from the Pareto Front simply due to 
how nevergrad search was impacted.  Thus the calibration may have a profound impact on solutions proposed.

Looking again at the calibrated solution we can see some of this:
![Calibrated Pareto Front]("robyn_output/2022-01-28 20.01 init/pareto_front.png")

Firstly, we note that the Pareto Front is sort of a hybrid between a 2-D and a 3-D front.
The fact is that the front shown may look suboptimal, because the solutions are "interior" to the dots.
But in reality there is a third dimenion, MAPE, which one could imagine coming out of the paper towards the viewer,
and the solutions have to exist above a certain MAPE slice to be considered.

However, the Pareto Front is not a 3-D front of these three variables, but appears to be a 2-D front of the two
variables (decomp.RSSD and NRMSE), with a cutoff (disqualification) for MAPE which is rather strict.

Thus, the MAPE criteria becomes the *strictest* criteria in the Pareto Front generation space, and subject
to that MAPE *constraint* the Pareto Front is generated.

And again our critique is that if we had much information, this approach would seem reasonable, but as the user
may have little experimental data, the fact that this large impact occurs with even a day of experimental data 
should give our user pause, or at least suggest why they might need to modify the code and allow much more 
relaxed calibration_constraints.

