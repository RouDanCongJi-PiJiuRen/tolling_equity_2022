##############################################
# Functions to estiamte income quantiles     #
#   and make income plots                    #
##############################################

library(stats4)
library(MASS)
suppressMessages(library(VGAM))
suppressMessages(library(lubridate))
suppressWarnings(suppressMessages(library(tidyverse)))
suppressWarnings(suppressMessages(library(lme4)))

acs_bins = c(0, 35, 50, 75, 100, 125, 150, 200, Inf)
acs_fine_bins = c(0, 10, 15, 20, 25, 30, 35, 40, 45, 50, 60, 75, 100, 125, 150, 200, Inf)


# FITTING ######################################################################

# Fits a Weibull distribution to a vector of counts and a vector of bins.
# Returns a `fit_weibull` object
fit_weibull = function(counts, bins=acs_bins) {
    n_bins = length(bins) - 1
    bins.l = bins[1:n_bins]
    bins.r = bins[2:(n_bins+1)]
    N = sum(counts)
    
    fit_obj = function(pars, counts) {
        y = (pweibull(bins.r, pars[1], pars[2]) 
                 - pweibull(bins.l, pars[1], pars[2]))
        y = if_else(y==0, 1e-99, y)
        -sum(counts * log(y))
    }
    
    fit = suppressWarnings(optim(c(5, mean(bins.l)), fit_obj, gr=NULL, 
                                 counts, hessian=T))
    names(fit$par) = c("shape", "scale")
    fit$N = N
    fit$counts = counts
    fit$bins = c(bins.l[1], bins.r)
    fit$bins.l = bins.l
    fit$bins.r = bins.r
    class(fit) = c("fit_weibull", "list")
    return(fit)
}

# Fits a Dagum distribution to a vector of counts and a vector of bins.
# Returns a `fit_dagum` object
fit_dagum = function(counts, bins=acs_bins) {
    n_bins = length(bins) - 1
    bins.l = bins[1:n_bins]
    bins.r = bins[2:(n_bins+1)]
    N = sum(counts)
    
    fit_obj = function(pars, counts) {
        y = (pdagum(bins.r, pars[1], pars[2], pars[3])
                 - pdagum(bins.l, pars[1], pars[2], pars[3]))
        y = if_else(y==0, 1e-99, y)
        -sum(counts * log(y))
    }
    
    fit = suppressWarnings(optim(c(mean(bins.l), 1.5, 0.5), fit_obj, gr=NULL, 
                                 counts, hessian=T))
    names(fit$par) = c("b", "a", "p")
    fit$N = N
    fit$counts = counts
    fit$bins = c(bins.l[1], bins.r)
    fit$bins.l = bins.l
    fit$bins.r = bins.r
    class(fit) = c("fit_dagum", "list")
    return(fit)
}


# Generic functions for `fit_weibull` and `fit_dagum` objects

length.fit_weibull = function(f) 1
length.fit_dagum = function(f) 1

print.fit_weibull = function(f) {
    cat(paste0("A fitted Weibull distribution with scale = ", 
               round(f$par[2], 2), " and shape = ", 
               round(f$par[1], 2), "\n\n"))
    cat(paste0(f$N, " total observation(s)\n"))
    cat(paste0("Bins: ", paste(f$bins, collapse=" "), "\n"))
}
print.fit_dagum = function(f) {
    cat(paste0("A fitted Dagum distribution with b = ", 
               round(f$par[1], 2), ", a = ",
               round(f$par[2], 2), ", and p = ", 
               round(f$par[3], 2), "\n\n"))
    cat(paste0(f$N, " total observation(s)\n"))
    cat(paste0("Bins: ", paste(f$bins, collapse=" "), "\n"))
}


mean.fit_weibull = function(f) f$par[2] * gamma(1 + 1/f$par[1])
mean.fit_dagum = function(f) {
    a = f$par[2]
    if (a <= 1) return(NA)
    p = f$par[3]
    -f$par[1]/a * gamma(-1/a) * gamma(1/a + p) / gamma(p)
}

median.fit_weibull = function(f) f$par[2] * log(2)^(1 / f$par[1])
median.fit_dagum = function(f) f$par[1] * (0.5^(-1/f$par[3]) - 1)^(-1/f$par[2])

# Compute standard error of median estimate
median_se = function(f) UseMethod("median_se")
median_se.fit_weibull = function(f) {
    # Simulate parameter values
    est.cov = abs(solve(-f$hessian))
    N = 5e3
    pars = mvrnorm(N, f$par, est.cov)
    pars = pars[pars[,1]>0 & pars[,2]>0,]
    # Simulate medians from parameter values (using theoretical formula)
    medians = pars[,2] * log(2) ^ (1 / pars[,1])
    sd(medians) # Compute s.d. of simulated medians
}
median_se.fit_dagum = function(f) {
    est.sd = sqrt(diag(abs(solve(-f$hessian))))
    N = 5e3
    b = rnorm(N, f$par[1], est.sd[1])
    a = rnorm(N, f$par[2], est.sd[2])
    p = rnorm(N, f$par[3], est.sd[3])
    medians = b * (0.5^(-1/p) - 1)^(-1/a)
    sd(medians[!is.nan(medians)])
}


# Compute fraction falling into each bin
bin_pcts = function(f) UseMethod("bin_pcts")
bin_pcts.fit_weibull = function(f) {
    pweibull(f$bins.r, f$par[1], f$par[2]) - 
        pweibull(f$bins.l, f$par[1], f$par[2])
}
bin_pcts.fit_dagum = function(f) {
    pdagum(f$bins.r, f$par[1], f$par[2], f$par[3]) - 
        pdagum(f$bins.l, f$par[1], f$par[2], f$par[3])
}

# compute the (negative) Gini coefficient for the fitted distribution
gini = function(f) UseMethod("gini")
gini.fit_weibull = function(f) 2^(-1/fit$par[1]) - 1
gini.fit_dagum = function(f) {
    a = f$par[2]
    p = f$par[3]
    1 - (gamma(p) * gamma(2*p + 1/a)) / (gamma(2*p) * gamma(p + 1/a))
}


# distribution functions
# like qnorm, pnorm, dnorm, rnorm, etc.
qinc = function(p, f) UseMethod("qinc", f)
qinc.fit_weibull = function(p, f) qweibull(p, f$par[1], f$par[2])
qinc.fit_dagum = function(p, f) qdagum(p, f$par[1], f$par[2], f$par[3])

pinc = function(q, f) UseMethod("pinc", f)
pinc.fit_weibull = function(q, f) pweibull(q, f$par[1], f$par[2])
pinc.fit_dagum = function(q, f) pdagum(q, f$par[1], f$par[2], f$par[3])

dinc = function(x, f) UseMethod("dinc", f)
dinc.fit_weibull = function(x, f) dweibull(x, f$par[1], f$par[2])
dinc.fit_dagum = function(x, f) ddagum(x, f$par[1], f$par[2], f$par[3])

rinc = function(n, f) UseMethod("rinc", f)
rinc.fit_weibull = function(n, f) rweibull(n, f$par[1], f$par[2])
rinc.fit_dagum = function(n, f) rdagum(n, f$par[1], f$par[2], f$par[3])


# ECOLOGICAL INFERENCE #########################################################

# Return a data frame of census block groups, with a column for the count of 
# trips or users (see `type` parameter) by block group and by a specified
# grouping variable. Counts are normalized by household, and an income column is
# returned, divided by 1,000,000 for numerical stability reasons
block_counts_by = function(trips, group_var, acs, type="trips") {
	group_var = enquo(group_var)

	if (type=="trips") {
		fips_counts = trips %>%
			select(fips, !!group_var, id) %>%
			group_by(fips, !!group_var) %>%
			summarize(count=n())
	} else {
		fips_counts = trips %>%
			select(fips, !!group_var, id) %>%
			distinct() %>%
			group_by(fips, !!group_var) %>%
			summarize(count=n())
	}

	# grab data, if trips is a database 
	if ("tbl_sql" %in% class(trips)) {
		fips_counts = execute(fips_counts, col_types="cci")
	}

	fips_counts %>%
		drop_na %>%
		inner_join(acs, by="fips") %>%
		ungroup %>%
		mutate(tract = paste0("53", county, tract),
			   hh_income = mean_inc/1e6,
			   hh_counts = count/households) %>%
		select(fips, tract, !!group_var, hh_income, hh_counts, households)
}

# Fit an ecological regression model and return the model object.
# Model regresses counts (by block group--i.e., the output of `block_counts_by`)
# on income, with intercepts and/or slopes varying by tract.  `vary_slopes`
# determines whether slopes are allowed to vary by tract.
fit_ecolg = function(block_counts, vary_slopes=T) {		
    group_var = names(select(block_counts, -fips, -tract, -hh_income, 
							 -hh_counts, -households))
	re_term = if (!vary_slopes) "+(1|tract)" else "+(log(hh_income)|tract)"
	m_form = paste0("log(hh_counts) ~ log(hh_income)*", group_var, re_term)

    
	m = lmer(m_form, data=block_counts, 
			 control=lmerControl(check.nobs.vs.nRE="ignore", 
								 optCtrl=list(ftol_abs=1e-9, xtol_abs=1e-9)))
	attr(m, "group_var") = group_var

	return(m)
}

# Take a fitted ecological regression model (from `fit_ecolg`) and estimate
# quantiles from the resulting income distribution. `q` is the quantiles,
# `ref_fit` is the overall population income distribution (a `fit_weibull` or
# `fit_dagum` object), and `N` controls the number of simulated individuals to 
# use in the quantile calculation.
ecolg_quantiles = function(m, q, ref_fit, N=4000) {
	group_var = attr(m, "group_var")
	groups = sort(unique(m@frame[,group_var]))
	g = length(groups)
	fit.d = tibble(hh_income = rinc(N*g, ref_fit)/1e3,
				   tract = "all")
	fit.d[,group_var] = rep(groups, N)
	fit.d$.count = exp(predict(m, newdata=fit.d, allow.new.levels=T))

    q = unique(round(q, 2))
    names = paste0("est_", sprintf("%02d", 100*q))
	est_quantiles = function(row, ...) {
	    ests = spread(tibble(par=names, 
	                         est=1e6*quantile(row$hh_income, q)), 
	                  par, est)
	    ests$count = mean(row$count)
	    #ests$count = sum(row$.count)
	    return(ests)
	}

	fit.d %>%
	    group_by_at(group_var) %>%
	    mutate(count=sum(.count)*ref_fit$N/N) %>%
	    ungroup() %>%
	    sample_frac(80.0, replace=T, weight=.count) %>%
	    group_by_at(group_var) %>%
	    group_modify(est_quantiles) %>%
	    ungroup()
}

# Take a fitted ecological regression model (from `fit_ecolg`) and estimate
# the mean of the resulting income distribution. `q` is the quantiles,
# `ref_fit` is the overall population income distribution (a `fit_weibull` or
# `fit_dagum` object), and `N` controls the number of simulated individuals to 
# use in the mean calculation.
ecolg_mean = function(m, ref_fit, N=4000) {
	group_var = attr(m, "group_var")
	groups = sort(unique(m@frame[,group_var]))
	g = length(groups)
	fit.d = tibble(hh_income = rinc(N*g, ref_fit)/1e3,
				   tract = "all")
	fit.d[,group_var] = rep(groups, N)
	fit.d$.count = exp(predict(m, newdata=fit.d, allow.new.levels=T))

	fit.d %>%
	    group_by_at(group_var) %>%
	    summarize(mean=weighted.mean(1e6*hh_income, .count)) %>%
	    ungroup()
}


# DATA AGGREGATION #############################################################

# fits a distribution to the whole population or a subset
fit_population = function(acs_subset, method=fit_dagum) {
	all_counts = acs %>% 
		mutate(group="All") %>%
		inc_distr_by(group, weight=population) %>%
		gather(inc_group, pct, -group, -count) %>%
		mutate(count = count*pct)

	method(all_counts$count, acs_bins)
}

# Creates an income distribution by a grouping variable
inc_distr_by = function(df, ..., weight=NULL) {
    group_var = enquos(...)
    weight_var = enquo(weight)

    if (is.null(weight)) {
        df %>%
            group_by(!!!group_var) %>%
            summarize_at(vars(starts_with("inc")), mean, na.rm=T) %>%
            left_join(df %>%
                          group_by(!!!group_var) %>%
                          summarize(count=n()),
                      by=sapply(group_var, rlang::quo_text)) %>%
            drop_na(!!!group_var)
    } else {
        df %>%
            group_by(!!!group_var) %>%
            summarize_at(vars(starts_with("inc")), 
                         ~ sum(. * !!weight_var, na.rm=T)) %>%
            left_join(df %>%
                          group_by(!!!group_var) %>%
                          summarize(count=sum(!!weight_var)),
                      by=sapply(group_var, rlang::quo_text)) %>%
            mutate_at(vars(starts_with("inc")), ~ . / count) %>%
            drop_na(!!!group_var)
    }
}

# takes a grouped df and computes quantile estimates
est_quantiles = function(df, q, counts, bins=acs_bins, f=fit_weibull, se=T) {
    q = unique(round(q, 2))
    names = paste0("est_", sprintf("%02d", 100*q))
    counts = substitute(counts)

    make_cols = function(fit) {
        ests = tibble(par=names, est=1000*qinc(q, fit))
        if (0.5 %in% q && se) {
            ests = bind_rows(ests, tibble(par="med_se", 
                                          est=1000*median_se(fit)))
        }
        ests = bind_rows(ests, tibble(par="count", est=fit$N))
        ests
    }

    group_modify(df, ~ make_cols(f(eval(counts, .x), bins))) %>%
        spread(par, est)
}

# take income distribution by grouping variables, and estimate quantiles
inc_quantiles = function(df, q, bins=acs_bins, f=fit_weibull, se=T) {
    group_var = names(select(df, -contains("inc"), -count))
    df %>%
        drop_na %>%
        select(-contains("med_inc")) %>%
        gather(inc_group, pct, -group_var, -count) %>%
        arrange(!!!sapply(group_var, as.symbol), inc_group) %>%
        group_by_at(group_var) %>%
        est_quantiles(q, pct*count, bins, f, se)
}


# Tets for some of the above functions.
test_inc_fitting = function() {
    bins = c(0, 1, 2, 3, Inf)
    counts = c(5, 12, 10, 8)

    pct = pweibull(bins[2:5], 5, 3) - pweibull(bins[1:4], 5, 3)
    fitw = fit_weibull(1000*pct, bins)
    if (sum(fitw$par - c(5, 3)) > 0.01) stop("FAIL: Weibull did not fit fake data")

    pct = pdagum(bins[2:5], 5, 3, 1) - pdagum(bins[1:4], 5, 3, 1)
    fitd = fit_dagum(1000*pct, bins)
    if (sum(fitd$par - c(5, 3, 1)) > 0.01) stop("FAIL: Dagum did not fit fake data")

    fitw = fit_weibull(counts, bins)
    fitd = fit_dagum(counts, bins)

    if (mean(fitw) <= median(fitw)) stop("FAIL: Weibull mean/median reversed")
    if (mean(fitd) <= median(fitd)) stop("FAIL: Dagum mean/median reversed")

    if (qinc(0.5, fitw) != median(fitw)) stop("FAIL: Weibull qinc != median")
    if (qinc(0.5, fitd) != median(fitd)) stop("FAIL: Dagum qinc != median")

    cat("Passed all tests.\n")
}


# PLOTTING #####################################################################

# Plots a `fit_weibull` or `fit_dagum` object. Plots histograms for actual and
# estimated counts, and a continuous probability density function.
plot.fit_income = function(f, xmax=NULL) {
    if (is.null(xmax)) xmax = max(f$bins.l*1.25)

    bins.r = f$bins.r
    bins.r[bins.r == Inf] = xmax
    widths = bins.r - f$bins.l
    pct.actual = f$counts / f$N / widths
    pct.distr = bin_pcts(f) / widths
    x = seq(1e-8, xmax, length.out=500)

    tibble(l=f$bins.l, r=bins.r, actual=pct.actual, fit=pct.distr) %>%
        gather(type, pct, -l, -r) %>%
    ggplot(aes(xmin=l, xmax=r, ymin=0, ymax=pct, fill=type)) +
        geom_rect(alpha=0.5) +
        annotate("line", x=x, y=dinc(x, f)) + 
        scale_fill_manual(values=c("actual"="#444444", "fit"="red")) +
        labs(x="Income", y="Density", fill="")
}
plot.fit_weibull = plot.fit_income
plot.fit_dagum = plot.fit_income

# takes in quantile estimates (e.g. from `inc_quantiles`) and plots median
# income by a single grouping variable
plot_med_inc = function(df, trend=NULL, xlab=NULL, ref_val=NULL) {
    group_var = names(df)[1]

    if (is.null(xlab)) xlab = str_to_title(str_replace_all(group_var, "_", " "))

    p = ggplot(df, aes_string(group_var, "est_50")) + 
        #geom_ribbon(aes(ymin=est_50-2*med_se, ymax = est_50+2*med_se, group=1), alpha=0.5) +
        geom_line(aes(group=1)) + 
        geom_point(aes(size=count)) + 
        scale_y_continuous(label=scales::dollar, name="Median Income") +
        labs(x=xlab) +
        guides(size=F)
    
    if (!is.null(trend)) p = p + geom_smooth(method=trend, fill="blue", alpha=0.2)

    if (!is.null(ref_val)) p = p + geom_hline(yintercept=ref_val, color="red") 

    p
}
# takes in quantile estimates (e.g. from `inc_quantiles`) and plots boxplots
# of income by a single grouping variable
plot_inc_distr = function(df, xlab=NULL, ref_distr=NULL, x_ref=0, ref_label="Metro area") {
    group_var = names(df)[1]

	if (is.null(xlab)) xlab = str_to_title(str_replace_all(group_var, "_", " "))

	p = ggplot(df, aes_string(group_var, "est_50")) + 
		geom_errorbar(aes(ymin=est_10, ymax=est_90)) +
		geom_crossbar(aes(ymin=est_25, ymax=est_75, fill=count)) +
		scale_fill_viridis_c(labels=scales::comma, name="Volume") +
		scale_y_continuous(labels=scales::dollar, name="Income") +
		guides(size=F) +
		labs(x=xlab)

    if (!is.null(ref_distr)) {
		p = p +
			geom_errorbar(aes(x=x_ref, ymin=est_05, ymax=est_95),
						  data=ref_distr, width=0.6) +
			geom_crossbar(aes(x=x_ref, y=est_50, ymin=est_25, ymax=est_75), 
						  data=ref_distr, fill="white", width=0.5) +
			annotate("text", x=x_ref, y=1.05*ref_distr$est_50, angle=90, 
					 hjust="left", label=ref_label)
	}

    p
}

# takes in quantile estimates (e.g. from `inc_quantiles`) and makes boxplots 
# of income by a single grouping variable

# Takes income shares and makes a stacked bar plot
plot_inc_stacked = function(df, xlab=NULL) {
    group_var = names(select(df, -contains("inc"), -contains("count")))[1]

    df = gather(df, inc_group, pct, -!!as.symbol(group_var), -contains("count"))

    if (is.null(xlab)) xlab = str_to_title(str_replace_all(group_var, "_", " "))
    inc_min = parse_number(str_sub(unique(df$inc_group), 5, 7))
    inc_max = suppressWarnings(parse_number(str_sub(unique(df$inc_group), 9, 11)))
    labels = paste0("$", inc_min, ",000 - $", inc_max, ",000")
    labels[1] = paste0("$0 - $", inc_max[1], ",000")
    labels[length(labels)] = paste0("$", inc_min[length(labels)], ",000+")

	stacking = if(is.numeric(pull(df, !!group_var))) geom_area else geom_col

    ggplot(df, aes_string(group_var, "pct", fill="inc_group")) + 
		stacking() +
        scale_fill_viridis_d(labels=labels, name="Income Bracket") +
        scale_y_reverse(labels=scales::percent) +
        labs(x=xlab, y="Percentage")
}

# Takes income shares and makes a line plot
plot_inc_lines = function(df, xlab=NULL) {
    group_var = names(select(df, -contains("inc"), -count))[1]

    df = gather(df, inc_group, pct, -!!as.symbol(group_var), -count)

    if (is.null(xlab)) xlab = str_to_title(str_replace_all(group_var, "_", " "))
    inc_min = parse_number(str_sub(unique(df$inc_group), 5, 7))
    inc_max = suppressWarnings(parse_number(str_sub(unique(df$inc_group), 9, 11)))
    labels = paste0("$", inc_min, ",000 - $", inc_max, ",000")
    labels[1] = paste0("$0 - $", inc_max[1], ",000")
    labels[length(labels)] = paste0("$", inc_min[length(labels)], ",000+")

    ggplot(df, aes_string(group_var, "pct", color="inc_group", group="inc_group")) + 
		geom_line() + 
		geom_point(aes(size=count)) +
        scale_color_viridis_d(labels=labels, name="Income Bracket") +
        scale_y_continuous(labels=scales::percent) +
        scale_size_continuous(labels=scales::comma) +
        labs(x=xlab, y="Percentage", size="Volume")
}

