# Process and host download statistics for Anaconda packages

The Anaconda project publishes summarized download counts of conda packages distributed via the  Anaconda Distribution, and the conda-forge and bioconda channels (https://www.anaconda.com/announcing-public-anaconda-package-download-data/).  The  data are available in the Parquet file format on Amazon S3  and can be parsed relatively easily in Python (full details at https://github.com/ContinuumIO/anaconda-package-data).  

However reading these data this is non-trivial in R.  This repository provides TSV and RDS tables of aggregated monthly counts for all packages across all architectures.  This summarisation level was choosen to match the download statistics reported by the Bioconductor project (http://bioconductor.org/packages/stats/) and to that end we also make available count tables containing only Bioconductor packages distributed via bioconda.

## Data tables

Tab-separated and serialized R-object files for the two count tables can be found in the *tsv* and *rdata* folders respectively.  These are updated monthly with some lag behind the release of the data from Anaconda.  The TSV files are UTF-8 encoded text files and the RDS file contain the data as a `tibble`.

### All Anaconda packages

Summarised counts for all packages distributed via Anaconda can be found in `all_counts.tsv` and `all_counts.rds`.  Both are four column tables, with column names preserved from the Anaconda source files e.g.

```
> all_counts %>% filter(pkg_name == "bioconductor-deseq2")
# A tibble: 29 x 4
   pkg_name            year  month counts
   <chr>               <chr> <chr> <dbl>
 1 bioconductor-deseq2 2017  Mar      88
 2 bioconductor-deseq2 2017  Apr     709
 3 bioconductor-deseq2 2017  May     765
 4 bioconductor-deseq2 2017  Jun     876
# … with 25 more rows
```

### Bioconductor packages

The `bioc_counts.tsv` and `bioc_counts.rds` files contain a subset of the download data relating only to Bioconductor packages.  In these tables the package names have been transformed from their bioconda format (all lower case, prefixed with bioconductor) to how they appear in the Bioconductor repository e.g. `bioconductor-deseq2` 🠪 `DESeq2`. The column names have also been changed to match the tables produced by Bioconductor e.g.

```
bioc_counts %>% filter(Package == "DESeq2")

# A tibble: 29 x 4
   Package Year  Month Nb_of_downloads
   <chr>   <chr> <chr>           <dbl>
 1 DESeq2  2017  Mar                88
 2 DESeq2  2017  Apr               709
 3 DESeq2  2017  May               765
 4 DESeq2  2017  Jun               876
 # … with 25 more rows
 ```

## R code

Scripts for producing the count tables can be found in the *R* folder:

- `download_functions.R`: Contains functions to download and process the parquet files containing the package download counts.
- `process_existing.R`: Initial script used to process all existing data.  *Should not need to be run again.*
- `update_tables.R`: Identifies the last month for which we have processed statistics, and tries to find any additional data uploaded between then and now.  *Intended to be run on a monthly basis via cron*.

## Singularity image

The **singularity** folder provides a Singularity definition file to create a Singularity image containing R and the Tidyverse packages alongside an installation of Apache Arrow and the apache-arrow R package.  The apache-arrow packge provides functionailty for reading parqet files, and this image is used as the base for reading the download files.
