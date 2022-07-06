# Choosing SQLite as a database engine

* Date: 2019-06-27


## Context and Problem Statement

We need to store our data in a database.  It has been sent to us in Postgres
form.  We are trying to decide between Postgres and SQLite to store and access
the data.

## Decision Drivers <!-- optional -->

* Ease of use
* Speed
* Security

## Considered Options

* SQLite
* Postgres

## Decision Outcome

Chose SQLite, because it is faster, easier to use, and meets our security
requirements.  This was informed by a [checklist provided by
Vaughn](https://sqlite.org/whentouse.html).

### Positive Consequences <!-- optional -->

* Fellows need only install one additional package for security purposes
* Fellows will be able to work locally

### Negative Consequences <!-- optional -->

* There will be four copies of the database, which could diverge if multiple
  people are editing it.
* Depending on local machines' processing power, performance could vary.
* SQLite supports fewer native data types (see [ADR 3](ADR_03_TimeStamp.md)).
