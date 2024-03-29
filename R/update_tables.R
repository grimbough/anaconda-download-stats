source("R/download_functions.R")

if(!dir.exists("rdata/monthly")) {
    dir.create("rdata/monthly")
}

current_all <- readr::read_rds("rdata/all_counts.rds")

last_month <- recreateMonthlyTables(complete_table = current_all)
next_month <- ymd(last_month) %m+% months(1)
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
readr::write_tsv(bioc_counts, file = "tsv/bioc_counts.tsv")
readr::write_rds(bioc_counts, file = "rdata/bioc_counts.rds", compress = "gz")

message("Writing complete tables")
all_files <- list.files(pattern = "all", path = "rdata/monthly", full.names = TRUE)
all_counts <- compileCompleteTable(monthly_files = all_files)
readr::write_tsv(all_counts, file = "tsv/all_counts.tsv")
readr::write_rds(all_counts, file = "rdata/all_counts.rds", compress = "gz")
