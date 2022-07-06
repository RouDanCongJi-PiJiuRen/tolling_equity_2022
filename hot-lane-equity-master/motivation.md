---
layout: page
title: Motivation
---

# Background

Increasing motor vehicle usage and traffic congestion is a growing concern in
many urban and rural areas. Environmental degradation, petroleum-based fuel
usage and its resulting contribution to rising carbon dioxide levels, hours
spent sitting in traffic, and the lack of reliability in the time it takes to
travel from place to place are only a few of the problems caused by traffic
congestion which lead to a lowered quality of life. 

Congestion pricing is one of the congestion mitigation solutions that is
starting to be used across the globe to help alleviate these problems. A
variety of different approaches to congestion pricing exist. Each approach has
different strengths and weaknesses. High Occupancy Toll (HOT) lanes are
designed to improve the efficiency of roadways, given the inability to supply
roadway capacity to all of the people who would like to use it during peak
periods.  When congestion is present, HOT lanes help allocate the available
roadway space, by providing travelers with a price/performance choice that
allows each user to select for each trip they make whether to select a lower
cost, but slower and less reliable travel path, or a more expensive, but faster
and more reliable path.  

Relatively little work has been done exploring how this approach to pricing is
actually used. Do only high-income households pay for faster, more reliable
trips? Do low-income households use it, and if so, how often, and at what
price? From a policy perspective, public decision makers wish to understand the
equity aspects of HOT lanes.  Users of the HOT lanes pay more than non-users,
but they gain travel benefits from those payments.  Are the benefits of these
lanes equitably distributed or not?

It is important for any transportation agency operating a HOT lane to
understand the uses and benefits obtained from these systems, as well as their
impacts on different groups. Monitoring the use and performance of these
systems over time is also necessary to understand when changes in system
operations need to occur to ensure a more equitable outcome.

The Washington State Department of Transportation (WSDOT) implemented a HOT
facility along the I-405 corridor in the Puget Sound (Seattle) region in 2015,
following the implementation of one other HOT lane (SR 167) in the region, and
other  facilities in San Diego, Houston, Minneapolis and elsewhere. As policies
like congestion pricing and HOT lanes are more frequently implemented by cities
around the world, empirical analysis is critically important.  WSDOT has a
vested interest in the gap of quantitative analysis that currently exists in
the literature regarding how HOT facility use varies across user
characteristics such as income, race and commuting patterns.

Using data from I-405 HOT lane users for all of 2018, this report aims to
provide quantitative information about how the lanes are being used, how the
costs and benefits of the lanes are distributed, and how changes in facility
operations could affect these distributions.


# Research Questions

We specifically want to answer the following questions:

* How are the I-405 HOT lane facility’s benefits and costs distributed among and within different groups of users?
	
* Are there any inequitable distributions that could be better addressed or made known to WSDOT?

* What policy implications or recommendations can we make to address potential inequities?

When evaluating whether HOT lanes are equitable, many researchers point out
that in addition to evaluating absolute equity, relative equity must also be
considered via comparison against alternative methods of reducing congestion
such as roadway-network expansion. Most researchers also note that whether HOT
lanes are progressive or regressive (where progressiveness is taken as a proxy
for equitability) really depends on how revenue generated is spent. For the
purposes of our study, however, we focus explicitly and solely on
understanding the equitability of direct HOT lane use, access, costs, and
benefits, while acknowledging that this is a far from complete picture of
overall HOT lane equitability. 

We define equity in two ways:

* Horizontal equity (are members of the same group treated the same?)
* Vertical equity (are members of different groups treated the same?)

Benefits of the HOT lane facility that we will analyze include:

* Travel time savings
* Travel time reliability
* Revenue
* Safety

We will look within and across groups defined by:

* Income
* Geography
* Frequency of usage
* Race
* Mode of transportation (transit users, HOV users, SOV users)
* Time of day, day of week, and month
* Trip type (commute, commercial, recreational)

# Stakeholders

WSDOT is responsible for managing traffic across the state, and in particular
operating the I-405 HOT lane facility.  As WSDOT manages the dynamic pricing
system, reinvests toll revenues in corridor improvements, and can make policy
recommendations about the toll lanes, the agency’s decisions have major effects
on commuters.  Consequently, WSDOT is very interested in the equity impacts of
the facility—how the costs and benefits of HOT lanes are distributed among and
within different groups.  WSDOT is the primary stakeholder for our analysis.

But our analysis, through its effects on WSDOT’s decision-making, has the
potential to impact drivers on I-405, both in and out of the HOT lanes.  These
drivers may be classified into four main categories:

* General purpose (GP) lane drivers, who mostly drive single-occupancy vehicles (SOV)
* SOV drivers who pay a toll to use the HOT lanes
* High-occupancy vehicle (HOV) drivers who drive for free in the HOT lanes
* Transit users, who ride in the HOT lanes

Drivers may also be classified by income group, or geographic area.  Our
analysis must carefully consider the effects on each of these groups, and
ensure that the concept of HOT-lane equity we develop is not too narrow.

# Ethics

The primary ethical issue at stake in this project is that of privacy.  The
tolling system records each driver’s license plate, and, where present, the
RFID tag, which together allow drivers to be linked to an accounts database
containing sensitive information such as names, home address, and vehicle
models.  This personal information, along with the time and location
information associated with each toll transaction, could, in the wrong hands,
allow drivers’ movements to be tracked with a concerning level of precision.
WSDOT, aware of the major privacy risks associated with these data, provided us
with records where all personally identifiable information had either been
removed (home address, names, vehicle information) or obfuscated (account
number, RFID tag number, license plate) by means of a cryptographic hash
function.  Yet de-identifying records may not be enough when time and location
data are provided.  For an additional layer of security, the database
containing the tolling records was securely encrypted and decrypted for each
use.  Unencrypted data containing potentially identifying information was never
stored on disk or transmitted over the internet.

