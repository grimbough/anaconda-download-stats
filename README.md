# Process and host download statistics for Anaconda packages

The Anaconda project publishes summarized download counts of conda packages distributed via the Anaconda Distribution, and the conda-forge and bioconda channels (https://www.anaconda.com/announcing-public-anaconda-package-download-data/).  The  data are available in the Parquet file format on Amazon S3  and can be parsed relatively easily in Python (full details at https://github.com/ContinuumIO/anaconda-package-data).  

However reading these data this is non-trivial in R.  This repository provides TSV and RDS tables of monthly download counts for all packages, aggregated across all platforms and versions.  This summarisation level was chosen to match the download statistics reported by the Bioconductor project (http://bioconductor.org/packages/stats/) and to that end we also make available count tables containing only Bioconductor packages distributed via bioconda.

## Data tables

Tab-separated and serialized R-object files for the two count tables can be found in the *tsv* and *rdata* folders respectively.  These are updated monthly with some lag behind the release of the data from Anaconda.  The TSV files are UTF-8 encoded text files and the RDS file contain the data as a `tibble`.

### All Anaconda packages

Summarised counts for all packages distributed via Anaconda can be found in `all_counts.tsv` and `all_counts.rds`.  Both are four column tables, with column names preserved from the Anaconda source files e.g.

```r
all_counts %>% filter(pkg_name == "bioconductor-deseq2")

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

```r
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
- `update_tables.R`: For all months from January 2017 to today, downloads and collates the daily count data into the complete tables.  *Intended to be run on a monthly basis via cron*.

## Singularity and Docker image

The **singularity** and **docker** folders provide the definition files to create a container image that includes R and the Tidyverse packages alongside an installation of Apache Arrow and the apache-arrow R package.  The apache-arrow package provides functionality for reading parquet files, and the docker image is used by the Github Workflow that generates the final tables.
