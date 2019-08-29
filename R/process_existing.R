source("R/download_functions.R")

for(year in c("2017", "2018", "2019")) {
    for(month in stringr::str_pad(1:12, 2, pad = "0")) {
        input <- paste(year, month, "01", sep = "-")
        if(ymd(input) < lubridate::today() %m-% months(1))
        downloads_per_month(input)
    }
}

bioc_files <- list.files(pattern = "bioc", path = "rdata/monthly/", full.names = TRUE)
bioc_counts <- compileCompleteTable(monthly_files = bioc_files) %>%
    rename(Package = pkg_name, Year = year, Month = month, Nb_of_downloads = counts)
readr::write_tsv(bioc_counts, path = "tsv/bioc_counts.tsv")
readr::write_rds(bioc_counts, path = "rdata/bioc_counts.rds", compress = "gz")


all_files <- list.files(pattern = "all", path = "rdata/monthly", full.names = TRUE)
all_counts <- compileCompleteTable(monthly_files = all_files)
readr::write_tsv(all_counts, path = "tsv/all_counts.tsv")
readr::write_rds(all_counts, path = "rdata/all_counts.rds", compress = "gz")
