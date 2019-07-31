source("download_functions.R")

for(year in c("2017", "2018", "2019")) {
    for(month in stringr::str_pad(1:12, 2, pad = "0")) {
        input <- paste0(year, month, "01")
        downloads_per_month(input)
    }
}

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
