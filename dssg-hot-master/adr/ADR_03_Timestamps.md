# Storage of timestamps in the database

* Status: accepted
* Date: 2019-06-27

## Context and Problem Statement

The trip records' times were recorded in local time strings, which uses more storage and leads to time inconsistencies.

## Considered Options
* Option 1: Keep local times string
* Option 2: Pretend local time is UTC and store times as Unix time
* Option 3: Convert local time to UTC 

## Decision Outcome

Chosen option: Option 2, because of efficiency of storage and not needing conversion

## Pros and Cons of the Options

### Option 1

* Good, because simplicity
* Bad, because takes more storage/processing
* Bad, because have to pretend we are working in UTC

### Option 2

* Good, because solves the storage/processing efficiency problem
* Bad, because implies data are actually in UTC, which could be confusing to some future researcher unless documented prominently

### Option 3

* Good, because of consistency
* Bad, because of hassle of converting to UTC
