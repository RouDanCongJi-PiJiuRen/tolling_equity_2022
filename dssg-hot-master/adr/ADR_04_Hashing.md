# Dealing with large hashes by only keeping the first 64 bits

* Date: 2019-06-27

## Context and Problem Statement

The PIIDs in the dataset are salted and hashed 256-hashed integers encoded as 64 byte hexadecimal strings, which is a bit overboard for acheiving the type of encrypted data we need. We are solely interested in the hashing property of being a "one-way function," remaining unique and private. 

## Decision Drivers 

* Performance
* Privacy

## Considered Options

* Keeping hashed ID's in their current form
* Only storing the first 64 bits as an integer

## Decision Outcome

Chosen option: We decided to only store the first 64 bits due to its increased performance and neglible negative consequences. 

### Positive Consequences 

* Performance (will save 56 bytes per hashed value)
* Maintained privacy and uniqueness (values are still salted)

### Negative Consequences 

* Increases chances of possible collision (the odds of this happening are now around 1 in 100 million)
