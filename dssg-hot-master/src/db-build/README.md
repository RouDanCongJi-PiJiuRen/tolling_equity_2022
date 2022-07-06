## Encrypted HOT database build instructions

### Install dependencies

The database was only built and tested on computers running MacOS 10.13 and 10.14. The scripts in this directory should also be usable under Linux, provided the same dependencies are installed.

Dependencies for MacOS are installed using the [Homebrew](https://brew.sh/) package manager. Once Homebrew is installed, the remaining dependencies can be installed with:

```sh
brew install gawk
brew install postgresql
brew install sqlcipher
```

### Assumptions

*  Postgres binary dump files are in a directory off the user home directory named `~/TRAC_backups`
*  Names of above files have not been changed from hard coded values they had when received from TRAC (see "Source file names and signatures" section below)
*  The environment variable HOT_KEY contains a valid 256-bit random "raw key" encoded as 64 hexadecimal characters (e.g. set as `export HOT_KEY=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef`)

### To build

* Run the script `./make_db.sh` in this directory
* The output database `hot.db` is written to this directory, along with a variety of temporary and diagnostic files.
* All of the output files can be removed with `./clean_sh`

### To use

* The resulting database is a [Sqlcipher](https://www.zetetic.net/sqlcipher/) database (.db) file
* Briefly, Sqlcipher is an open source **encrypted** database that is a "drop-in" replacement for the popular open-source [Sqlite](https://sqlite.org/index.html) embedded database
* The key used to build the database (in the `HOT_KEY` environment variable) is also used to access the database at runtime via a sqlite "pragma command", for example:
``` 
PRAGMA key = "x'0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'";
```
* See the [Sqlcipher documentation](https://www.zetetic.net/sqlcipher/sqlcipher-api/) for command details.
* When working on the command line, it is a useful shortcut to load the key into the shell environment variable `HOT_KEY`, and then start the database as:
```
sqlcipher -cmd "PRAGMA key = \"x'$HOT_KEY'\";" hot.db
```

### Processing performed

The database build process harmonizes the source data sets to make them easier and more efficient to access and query using Sqlite:

* All of the various date formats are converted to 64-bit UNIX time values, represented as _local time_ in the `America/Los_Angeles` time zone. Since the database does not contain transactions for weekends, there are no ambiguous times associated with DST transitions.
* All of the various 64 character hexadecimal encoded (256-bit) hashed ID values in the source databases are truncated to 16 characters and then converted to signed 64-bit integers in the output database. Uniqueness of the resulting IDs were checked to verify the assuption that this operation does not result in any loss of information.
* Fields are set to appropriate types for efficient storage, so for example "T/F" fields are converted to boolean values, and NULL values are properly processed and stored as such
* Duplicated records of various kinds present in the source database are detected and logged to files prefixed with "bad" in the output directory
* Various small anomalies are detected and corrected (e.g. string fields with embedded commas are truncated at the comma). All such corrections are logged to STDERR as processing proceeds.

### Source file names and signatures

The source files obtained from the TRAC website and used to build the database versions used for this project have the following names and MD5 sum signatures. These were calculated using `md5 *.{backup,xlsx}`.
```
MD5 (accts_plates_census.backup) = f1227dac52a01f1dc84585cb79383d26
MD5 (extract2018.backup) = c8eabafb8f5a865c3eed179cc70c86f4
MD5 (extract2018cumulative.backup) = 77d35f07b76c0bc98bba8bd0db1d2feb
MD5 (trip_data.backup) = 62545d7fa2cfacf602f3f2780fca9b9d
MD5 (HOV_Acct_Translation_Table.xlsx) = cefa873b9a3242f0a2fe3054dfc2e8a7
```

Note that the file `HOV_Acct_Translation_Table.xlsx` was manually converted to a TSV file using MS-Excel, and that file (`HOV_Acct_Translation_Table.tsv`, MD5 = `e05596ee242635ce708d6f4e5926419a`) served as the input of that data to the build process.
