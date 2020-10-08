source("R/download_functions.R")

if(!dir.exists("rdata/monthly")) {
    dir.create("rdata/monthly")
}

next_month <- ymd('2017-01-01') 
while(next_month < floor_date(today(), unit = "month")) {
    message(next_month) 
    downloads_per_month(next_month)
    next_month <- next_month %m+% months(1)
}

#####################################
## re-write the complete tables
#####################################

message("Writing bioc tables")
bioc_files <- list.files(pattern = "bioc", path = "rdata/monthly/", full.names = TRUE)
bioc_counts <- compileCompleteTable(monthly_files = bioc_files) %>%
    rename(Package = pkg_name, Year = year, Month = month, Nb_of_downloads = counts)
readr::write_tsv(bioc_counts, path = "tsv/bioc_counts.tsv")
readr::write_rds(bioc_counts, path = "rdata/bioc_counts.rds", compress = "gz")

message("Writing complete tables")
all_files <- list.files(pattern = "all", path = "rdata/monthly", full.names = TRUE)
all_counts <- compileCompleteTable(monthly_files = all_files)
readr::write_tsv(all_counts, path = "tsv/all_counts.tsv")
readr::write_rds(all_counts, path = "rdata/all_counts.rds", compress = "gz")
