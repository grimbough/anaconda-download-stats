source("download_functions.R")

for(year in c("2017", "2018", "2019")) {
    for(month in stringr::str_pad(1:12, 2, pad = "0")) {
        input <- paste0(year, month, "01")
        downloads_per_month(input)
    }
}
