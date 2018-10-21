# LAMP collectd

#### Author:   Rudy Gevaert (Graduated GCAP 2018)
#### Updated:  Sunday, October 21, 2018
#### Status:   Work in progress

To show how to get from LAMP stack metrics to PDQ model parameters.

## Requirements

To get started you need to have [Virtualbox](https://www.virtualbox.org)
and [Vagrant](https://vagrantup.com) installed.

A load testing tool. E.g. [Apache JMeter](https://jmeter.apache.org/)

## Getting started

After that run `vagrant up`. This will download a Vagrant box with Debian
Stretch. Point your HTTP load testing tool to http://localhost:8080 and
see in the `collectd-data` directory CSV files with the relevant metrics.

## Further work

To be done:

- running the loadtest
- taking the CSV files and using R to apply PDQ
