# SQL code

The files in this directory either contain relatively complex multi-step SQL
queries, or make changes to the underlying `hot.db` database.

- `cory-cuml-edits-old` was based on an old database version and is here for completeness only.

- `cory-cuml-edits` compiles all SQL queries that make changes to the database.  It should
be run after the database has been created and loaded.

- `db-initial-edits` makes initial changes to the database. This file is run as part of 
the database build.

- `sample_trips_entry_time` samples trips for specific gates and entry times, to 
create inputs for the VOT/VOR model.
