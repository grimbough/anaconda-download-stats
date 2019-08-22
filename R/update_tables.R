source("download_functions.R")

## load the existing table of counts - bioc is sufficient
bioc_counts <- readRDS(file = "rdata/bioc_counts.rds")

## find the most recent month we have records for
max_month <- bioc_counts %>% 
    mutate(date = ymd(paste0(year, month, "01"))) %>%
    summarise(month = max(date)) %>%
    magrittr::extract2('month')
    
## for any months between then and now try and download data
next_month <- ymd(max_month) %m+% months(1)
while(next_month < floor_date(today(), unit = "month")) {
    message(last_month) 
    downloads_per_month(last_month)
    last_month <- last_month %m+% months(1)
}

#####################################
## re-write the complete tables
#####################################

bioc_files <- list.files(pattern = "bioc", path = "rdata/monthly/", full.names = TRUE)
bioc_counts <- compileCompleteTable(monthly_files = bioc_files)
readr::write_tsv(bioc_counts, path = "tsv/bioc_counts.tsv")
readr::write_rds(bioc_counts, path = "rdata/bioc_counts.rds", compress = "gz")


all_files <- list.files(pattern = "all", path = "rdata/monthly", full.names = TRUE)
all_counts <- compileCompleteTable(monthly_files = all_files)
readr::write_tsv(all_counts, path = "tsv/all_counts.tsv")
readr::write_rds(all_counts, path = "rdata/all_counts.rds", compress = "gz")
