# EVT-ICA Empirical Section

This repo contains scripts used in the empirical example for a research paper
related to extreme value theory and independent component analysis. Intended to
be used with `54datasets3.csv` in data/. To execute in Linux environment use
```
./run.sh
```

Description of the scripts:

## ica_for_data.r

Reads the cashflow-data `54datasets3.csv` from data/ and outputs the following files there

1. `sobi_holidays_0.csv`
2. `sobi_holidays_1.csv`

where the first contains the "independent components" extracted from the first 10 companies time series when
the holidays have been removed from the data and the second one the same with the holidays

