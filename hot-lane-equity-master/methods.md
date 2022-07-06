---
layout: page
title: Methods
---

# Data and Data Preprocessing

## Trip data
We have data on every trip taken in the 405 HOT lanes in 2018 with information
on toll paid, whether the trip was HOV or SOV, trip entry and exit point, and
user account or license plate (hashed). This data is not publicly available and
cannot be shared outside of our team. We will, however, share our results and
merged tables back with WSDOT.

Numbers:

* Nearly 17 million trips in 2018
* 56 million toll plaza transactions
* 430,000 accounts with census block group level information

## Census data
Each HOT lane user account or license plate is associated with a census block
group presumably corresponding to the driver’s residence. We use 2016 5 Year
American Community Survey (ACS) census data to get information about income,
race, and transportation mode for each block group in our trip dataset. 

Numbers:
* 3,100 distinct census block groups

## Travel time, speed, and volume data
We have travel time, speed, and volume (number of cars passing/hour) data for
the entire 405 corridor in both general purpose (GP) and HOT lanes from loop
detector data, courtesy of WSDOT/TRACFLOW. We therefore have travel time for
every trip taken as well as the GP and HOT speed and volume upon entry for each
HOT trip.

## Customer survey data
We have WSDOT HOT lane user survey data from 2018, with information on income,
zip code, and why/how often they use the HOT lanes.

Numbers:
* 1,795 responses

## Travel shed data
We (will potentially) have travel shed data from Puget Sound Regional Council
(PSRC), which shows us who normally uses 405, what times they are using it at,
and where they are usually travelling to and from. This would allow us to
compare the 405 HOT lane user population to the overall 405 user population to
see if there is a difference in characteristics between the two.

## Crash data
We obtained crash data of I-405 (2012-2019) from WSDOT. This data can be
potentially used for a before after analysis as well as incorporating into our
value of time/reliability model.

Numbers:
* 7,000 crashes on the studying section


# Tools and Processes
Our data is housed in SQLCipher, an encrypted database tool that is stored on
our local machines. In order to access the database, a code that is only
available with our individual passwords must be entered. This ensures that user
data of the facility are not saved directly onto our computers or transmitted
across the internet.

Our team uses GitHub for a main repository and version-controlled source of
knowledge. To document our work, we use Jupyter Notebooks, a software that
allows text and code to be compiled in one, interactive document. We are using
a combination of R and Python to analyze our data and run statistical models. 

R and Python, while similar in their capabilities, can become increasingly
difficult to operate with differing dependencies. Though, since we are not
creating many new modules or functions, this is not as much of a problem for
our specific situation. If there are tables we all would like to use, we can
build new tables through SQL code in our individual terminals or rebuild the
database itself. This ensures we can have a wide range of experiences in both
languages while taking advantage of what each has to offer. 


# Methodology
The use of ACS data at the block group level, rather than individual income and
demographic information, created several methodological challenges.

## Fitting distributions to income histograms
The ACS reports, for each census block group, the fraction of households within
a series of income bins ($0–$35,000, $35,000–$50,000, etc.).  To estimate
income quantiles, and to be able to simulate incomes from each block group, a
distribution must be fit to the income bin percentages.  This may be done
parametrically or semiparametrically.

### Parametric approach: the Weibull and Dagum distributions
The two-parameter Weibull distribution and the three-parameter Dagum
distribution have been widely used to describe the distribution of income in
the developed world.  Both are supported on the nonnegative reals, and have one
or more shape parameters that control the variance, skewness and kurtosis of
the distribution.

We can fit these distributions to the data by recognizing that for a chosen
distribution and fixed set of parameters, the cumulative distribution function
predicts the fraction of households that should fall within each income bin.
Given a set of households—in a census block group or across the region—we can
model the likelihood of assignment to income bins as multinomial.  Minimizing
the negative log-likelihood across the parameter space for the distribution
then yields a best-fit distribution for the observed income bin counts.  With
the fitted distribution in hand, it is easy to estimate means and quantiles, as
both the Weibull and Dagum distribution have closed-form expressions for these
quantities. The inverse negative Hessian from the log-likelihood maximization
gives the estimated covariance matrix of the parameters, which can be used to
form uncertainty intervals around these same quantities of interest.

### Semiparametric approach: Means Constrained Integration over Brackets (MCIB)

A new approach by authors Jargowsky and Wheeler in 2018 uses both income bin
widths in addition to the number of households within each bin provided by the
census. Especially with an open-ended top bracket ($200,000 or more), mid-point
estimations and multiple parameter distributions can poorly represent the data.
This method calculates slopes for each of the income bin-widths based on the
change in number of households, and integrates the area under the slope and
constrained by the lower and upper bounds of the income. 

This process, while seemingly accurate, has not been widely explored in the
literature and is computationally intensive. 


## Estimating distribution of income across factors of interest
Without individual-level income information, we cannot with full certainty
generate the distribution of income across factors of interest.  We must
instead make assumptions about how individuals within and across census blocks
use the HOT facility, and use these to estimate the overall distribution of
income.

### Bad assumption: usage is independent of income, given a neighborhood
If we assume that HOT facility usage is entirely explained by where one lives,
we can simply average the income bin fractions (see above) across census block
groups, weighting by the number of trips (or users) originating from that block
group.  This yields an overall income histogram, to which a parametric or
semiparametric distribution may be fitted.  Unfortunately, this assumption is
not plausible on its face—we expect usage patterns to vary strongly by
individual income, regardless of geography.

### Better assumption: usage is independent of neighborhood’s income, given neighborhood location and individual income
This assumption is more nuanced, but much more plausible.  Given an
individual’s income, and the census _tract_ they live in (census tracts
generally contain between two and five block groups), we would not expect the
individual’s usage to vary depending on the overall level of income in their
block group.  For instance, take two individuals, Bob and Jane, who live in
adjacent block groups in the same census tract.  Both make $50,000 per year.
Bob’s block group is wealthier than Jane’s block group.  Without knowing any
more information (such as where Bob and Jane work), we have no reason to
believe that Bob or Jane is more likely to use the facility—they make the same
amount and live in the same area. 

With this assumption, we may regress usage on income, with each observation a
block group (rather than an individual).  Letting the intercept and slope vary
by census tract, we can interpret the resulting coefficients as the
coefficients we would have estimated if we had regressed on individual income
instead.  This allows us to simulate incomes from the overall population
distribution (itself fit using one of the methods detailed above), then use the
model to predict usage for each simulated individual.  From this synthetic
population, quantities of interest are easily calculated.


# Analyses
As described in the [motivation](/motivation/) section, our overall analysis
consists of two main sections: analyzing use patterns by factors of interest,
and analyzing facility benefits and how they are distributed across factors of
interest.

## Analyzing use patterns
These analyses primarily involve grouping the data by the factor of interest
and calculating the income distribution by group (see above for methodology).
We also examine overall volume by factor of interest, spatial distributions by
factor of interest, and relative HOV/SOV usage by factor of interest.   Factors
of interest generally include user frequency (whether a user is a monthly,
weekly, or daily user, for instance), toll paid, time of day, day of week,
month, mode (HOV/SOV), user type (commercial, peak user, off-peak user, etc.),
and route (direction, entry, and exit points).

## Analyzing facility benefits
The facility generates revenue for WSDOT, which by law must be spent on
corridor improvements, which necessarily accrue to wide swaths of the driving
population.  For users, the facility provides time benefits, both directly in
time savings, and also in reliability savings.  Drivers build a “buffer time”
into their commute to ensure they arrive on time with a probability exceeding
50%.  HOT lane usage can reduce this buffer time by reducing travel time
variability, independent of overall travel time savings.  Following the
convention in the literature, we define reliability as the difference between
the 80th and 50th percentiles of travel time.  This has the benefit of putting
reliability on the same scale as travel time, allowing for a direct comparison
of benefits and their monetary value to drivers.

## Analyzing distribution of facility benefits
We can study how use patterns and facility benefits intersect, and ask how 
facility benefits are distributed across groups of interest.


# Limitations
Of course, with more complete income data, our analyses would be much more
precise. Given this fact, our estimations of equitable distributions are made
less precise by trying to estimate individual demographics from where people
live. This is called “ecological inference” in many fields of research. We have
attempted multiple methodological approaches to overcome this, but they could
of course always be improved. Additional shortcomings are discussed in the
methodological assumptions.


# Reproducibility

Because the trip data provided to us by WSDOT cannot be shared publicly, we
cannot release our software and data as a package to the public for
reproduction of our results. We can, however, release our software and data to
WSDOT and TRAC for reproduction. For releasing our software and data to WSDOT
and TRAC, we plan to deliver the following:

1. A Dockerfile to generate the exact R environment we have done our analyses in, together with the R Jupyter Notebook analyses we did to generate all of our R results and figures.
2. A Dockerfile to generate the exact Python environment we have done our analyses in, together with the Python Jupyter Notebook analyses we did to generate all of our Python results and figures.
3. `hot-v3.db`, our encrypted SQLCipher database containing our ACS and joined trips/travel time/speed/volume data.

