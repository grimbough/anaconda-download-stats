library(dplyr)
library(lubridate)
library(arrow)
library(stringr)
library(readr)
library(magrittr)

## download tables for all recorded Bioconductor packages
## we use this to match the all lower case conda names with Bioconductor pacakages
bioc_tables <- c("http://bioconductor.org/packages/stats/bioc/bioc_pkg_stats.tab",
                 "http://bioconductor.org/packages/stats/data-annotation/annotation_pkg_stats.tab",
                 "http://bioconductor.org/packages/stats/data-experiment/experiment_pkg_stats.tab",
                 "http://bioconductor.org/packages/stats/workflows/workflows_pkg_stats.tab")
bioc_avail <- lapply(bioc_tables, readr::read_tsv, col_types = "ccccc") %>%
    bind_rows() %>%
    extract2('Package') %>% 
    unique()

## downloads & processed all available parquet files for a given month
## arguments:
## input: string of the format YEAR-MONTH-DAY e.g. "2019-06-01"
downloads_per_month <- function(input) {
    
    month_start <- ymd(input)
    
    output_file <- paste0('rdata/monthly/', substr(month_start, 1,7), "_all.rds" )
    if(file.exists(output_file)) {
        message('File exists')
        return( NULL )
    }
    
    n_days <- lubridate::days_in_month(month_start)
    
    month <- month_start %>%
        month() %>%
        stringr::str_pad(2, pad = "0")
    
    year <- year(month_start) %>%
        as.character()
    
    res <- lapply(seq_len(n_days), FUN = function(day) {  
        
        url <- paste0("https://anaconda-package-data.s3.amazonaws.com/conda/hourly/", 
                      year, "/", month, "/", 
                      year, "-", month, "-", stringr::str_pad(day, 2, pad = "0"), ".parquet")
        
        tf <- tempfile()
        
        dl_ok <- !httr::http_error(url)
        
        if(dl_ok) {
            
            download.file(url = url, destfile = tf, quiet = TRUE)
            
            count_table <- read_parquet(tf) %>% 
                mutate(counts = as.numeric(counts)) %>%
                group_by(pkg_name) %>% 
                summarise(total_count = sum(counts)) 
            return(count_table)
        } else {
            return(NULL)
        }
        
    })
    
    all_pkgs <- bind_rows(res) %>%
        group_by(pkg_name) %>%
        summarise(counts = sum(total_count))
    
    ## filter only bioconductor packages and format names correctly
    bioc_pkg <- all_pkgs %>%
        filter(grepl(pkg_name, pattern = "^bioconductor")) %>%
        mutate(pkg_name = stringr::str_remove(pkg_name, "bioconductor-")) %>%
        mutate(pkg_name = bioc_avail[match(pkg_name, tolower(bioc_avail))]) %>%
        filter(!is.na( pkg_name ))
    
    saveRDS(all_pkgs, file = output_file)
    saveRDS(bioc_pkg, file = paste0('rdata/monthly/', substr(month_start, 1,7), "_bioc.rds" ))
    
    return(all_pkgs)
}

compileCompleteTable <- function(monthly_files) {
    all_counts <- lapply(monthly_files, function(x) {
        counts <- readRDS(x) %>%
            mutate(year = substr(basename(x), 1, 4),
                   month = month.abb[as.integer(substr(basename(x), 6, 7))]) %>%
            dplyr::select(pkg_name, year, month, counts)
    }) %>%
        dplyr::bind_rows() %>%
        arrange(pkg_name) 
    return(all_counts)
}

