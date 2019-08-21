source("download_functions.R")

bioc_counts <- read.delim("tsv/bioc_counts.tsv", sep = "\t", stringsAsFactors = FALSE) %>%
    as_tibble()

## find the most recent month we have records for
max_month <- bioc_counts %>% 
    filter(year == lubridate::year(lubridate::today())) %>% 
    mutate(date = paste(year, month, "01", sep = "-")) %>%
    mutate(date = ymd(date)) %>%
    summarise(month = max(date)) %>%
    magrittr::extract2('month')
    
## for any months between then and now try and download data
last_month <- ymd(max_month) %m+% months(1)
while(last_month < floor_date(today(), unit = "month")) {
    message(last_month) 
    downloads_per_month(last_month)
    last_month <- last_month %m+% months(1)
}

#####################################
## re-write the complete tables
#####################################

files <- list.files(pattern = "bioc", path = "rdata/monthly/", full.names = TRUE)
tmp <- lapply(files, function(x) {
    counts <- readRDS(x) %>%
        mutate(year = substr(basename(x), 1, 4),
               month = month.abb[as.integer(substr(basename(x), 6, 7))]) %>%
        dplyr::select(pkg_name, year, month, count)
})
bioc_counts <- dplyr::bind_rows(tmp) %>%
    arrange(pkg_name) 
readr::write_tsv(bioc_counts, path = "tsv/bioc_counts.tsv")
readr::write_rds(bioc_counts, path = "rdata/bioc_counts.rds", compress = "gz")


files <- list.files(pattern = "all", path = "rdata/monthly", full.names = TRUE)
tmp <- lapply(files, function(x) {
    counts <- readRDS(x) %>%
        mutate(year = substr(basename(x), 1, 4),
               month = month.abb[as.integer(substr(basename(x), 6, 7))]) %>%
        dplyr::select(pkg_name, year, month, count)
})
all_counts <- dplyr::bind_rows(tmp) %>%
    arrange(pkg_name)
readr::write_tsv(all_counts, path = "tsv/all_counts.tsv")
readr::write_rds(all_counts, path = "rdata/all_counts.rds", compress = "gz")
