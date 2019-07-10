# Author: Mathieu Depetris <mathieu.depetris@ird.fr>
#         Laurent Floc'h <laurent.floch@ird.fr>
# Creation date: 05/04/2018
# Description: Script for monthly extraction of catch and effort data.
# Required: packages devtools and furdeb 
# Updates: 10/07/2019

# Setup ----
library(devtools)
install_github("https://github.com/OB7-IRD/furdeb.git")
library(furdeb)
# The first time for initiat the configuration file
#config_env <- configuration_file()
config_env <- configuration_file(new_configtype = F,
                                 path_configtype = "D:\\IRD\\5-Projets_&_themes\\3-ADD\\1-Monthly_datacall_dpma\\1-Data\\configfile_datacall_mensuels_dpma.csv")

# Year selection ----
year <- as.numeric(format(Sys.Date(), "%Y"))

if (interactive()) {
  cat(paste("The year used in the queries is ",
            year,
            "\nDo you want to use this year?",
            "\n(yes,no)",
            sep = ""))
  year_answer <- readline()
  while (!(year_answer %in% c("yes", "no"))) {
    cat(paste("Be careful! Your answer is not correct",
              "\nThe year used in the queries is ",
              year,
              "\nDo you want to use this year?",
              "\n(yes,no)",
              sep=""))
    year_answer <- readline()
  }
  if (year_answer == "no") {
    cat("Select the year used in the queries\n")
    year <- as.numeric(readline())
    #Year verification
    while(nchar(year) != 4) {
      cat("Be careful! The year seem incorrect\nPlease correct it")
      cat("Select the year used in the queries\n")
      year <- as.numeric(readline())
    }
  }
  rm(year_answer)
}

# Database connection ----
#You have to connect the VPN of IRD before run this command
t3_connection <- db_connection(config_env[["t3plus_user"]],
                               config_env[["t3plus_password"]],
                               config_env[["t3plus_dbname"]],
                               config_env[["t3plus_host"]],
                               config_env[["t3plus_port"]])

# Loading data ----
# Format1_note_93_15
format1_note_93_15_sqlQry <- paste(readLines(con = file.path(config_env[["queries_loc"]], 
                                                             "format1_note_93_15.sql", 
                                                             fsep = "\\")), 
                                   collapse="\n")
format1_note_93_15_sqlQry <- sub("put_year_here", 
                                 year, 
                                 format1_note_93_15_sqlQry)
format1_note_93_15 <- RPostgreSQL::dbGetQuery(t3_connection, 
                                              format1_note_93_15_sqlQry)
# Format2_rapport_acdr
format2_rapport_acdr_sqlQry <- paste(readLines(con = file.path(config_env[["queries_loc"]], 
                                                               "format2_rapport_acdr.sql", 
                                                               fsep = "\\"), 
                                               encoding = "UTF-8"), 
                                     collapse="\n")
format2_rapport_acdr_sqlQry <- sub("put_year_here", 
                                   year, 
                                   format2_rapport_acdr_sqlQry)
format2_rapport_acdr <- RPostgreSQL::dbGetQuery(t3_connection, 
                                                format2_rapport_acdr_sqlQry)
for (i in 1:dim(format2_rapport_acdr)[2]) {
  Encoding(colnames(format2_rapport_acdr)[i]) <- "UTF-8"
  if (i == dim(format2_rapport_acdr)[2]) 
    {rm(i)}
}
# Query_orthongel
query_orthongel_sqlQry <- paste(readLines(con = file.path(config_env[["queries_loc"]], 
                                                          "query_orthongel.sql", 
                                                          fsep = "\\")), 
                                collapse = "\n")
query_orthongel_sqlQry <- sub("put_year_here", 
                              year, 
                              query_orthongel_sqlQry)
query_orthongel <- RPostgreSQL::dbGetQuery(t3_connection, 
                                           query_orthongel_sqlQry)
Encoding(query_orthongel$`fishing zone declared`) <- "UTF-8"

# Exporting data ----
#Creation of specific directory
if (!dir.exists(file.path(config_env[["output_loc"]], 
                          paste(format(Sys.time(), '%Y_%m_%d_'), "export", 
                                sep = ""), 
                          fsep = "\\"))) {
  dir.create(file.path(config_env[["output_loc"]], 
                       paste(format(Sys.time(), '%Y_%m_%d_'), "export", 
                             sep = ""), 
                       fsep = "\\"))
}

if (min(format1_note_93_15[, "Time_period"]) == max(format1_note_93_15[, "Time_period"])) {
  name_format1_note_93_15 <- paste("\\France",
                                   year,
                                   iconv(format(as.Date(paste(min(format1_note_93_15[, "Time_period"]), "01", 
                                                              sep = "-")), 
                                                "%B"), 
                                         to = "ASCII//TRANSLIT"),
                                   "format1_note_93_15.csv", sep="_")
} else {
  name_format1_note_93_15 <- paste("\\France",
                                   year,
                                   iconv(format(as.Date(paste(min(format1_note_93_15[, "Time_period"]), "01", 
                                                              sep = "-")), 
                                                "%B"), 
                                         to = "ASCII//TRANSLIT"),
                                   iconv(format(as.Date(paste(max(format1_note_93_15[, "Time_period"]), "01", 
                                                              sep = "-")), 
                                                "%B"), 
                                         to = "ASCII//TRANSLIT"),
                                "format1_note_93_15.csv", sep="_")
}
write.table(format1_note_93_15,
            file = paste(file.path(config_env[["output_loc"]], 
                                   paste(format(Sys.time(), '%Y_%m_%d_'), "export", 
                                         sep = ""), 
                                   fsep = "\\"), 
                       name_format1_note_93_15,
                       sep = ""),
            sep = ";",
            dec = ".",
            row.names = FALSE,
            col.names = TRUE,
            append = FALSE)

if (min(format2_rapport_acdr$mois) == max(format2_rapport_acdr$mois)) {
  min_format2_rapport_acdr <- ifelse(nchar(min(format2_rapport_acdr$mois)) == 1, 
                                     paste("0", min(format2_rapport_acdr$mois), 
                                           sep = ""), 
                                     min(format2_rapport_acdr$mois))
  name_format2_rapport_acdr <- paste("\\France",
                                     year,
                                     iconv(format(as.Date(paste(year, min_format2_rapport_acdr, 
                                                                "01", 
                                                                sep = "-"), 
                                                          "%Y-%m-%d"), 
                                                  "%B"), 
                                           to = "ASCII//TRANSLIT"),
                                     "format2_rapport_acdr.csv", 
                                  sep = "_")
  rm(min_format2_rapport_acdr)
} else {
  min_format2_rapport_acdr <- ifelse(nchar(min(format2_rapport_acdr$mois))==1, 
                                     paste("0", min(format2_rapport_acdr$mois), sep=""), 
                                     min(format2_rapport_acdr$mois))
  max_format2_rapport_acdr <- ifelse(nchar(max(format2_rapport_acdr$mois))==1, 
                                     paste("0", max(format2_rapport_acdr$mois), sep=""), 
                                     max(format2_rapport_acdr$mois))
  name_format2_rapport_acdr <- paste("\\France",
                                     year,
                                     iconv(format(as.Date(paste(year, min_format2_rapport_acdr, "01", 
                                                                sep = "-"), 
                                                          "%Y-%m-%d"), 
                                                  "%B"), 
                                           to = "ASCII//TRANSLIT"),
                                     iconv(format(as.Date(paste(year, max_format2_rapport_acdr, "01", 
                                                                sep = "-"), 
                                                          "%Y-%m-%d"), 
                                                  "%B"), 
                                           to = "ASCII//TRANSLIT"),
                                  "format2_rapport_acdr.csv", 
                                  sep = "_")
  rm(min_format2_rapport_acdr, max_format2_rapport_acdr)
}
write.table(format2_rapport_acdr,
            file = paste(file.path(config_env[["output_loc"]], 
                                 paste(format(Sys.time(), '%Y_%m_%d_'), "export", 
                                       sep = ""), 
                                 fsep = "\\"), 
                       name_format2_rapport_acdr,
                       sep = ""),
            sep = ";",
            dec = ".",
            row.names = FALSE,
            col.names = TRUE,
            append=FALSE)

if (min(query_orthongel$activity_month) == max(query_orthongel$activity_month)) {
  min_query_orthongel <- ifelse(nchar(min(query_orthongel$activity_month)) == 1, 
                                paste("0", min(query_orthongel$activity_month), sep = ""), 
                                min(query_orthongel$activity_month))
  name_query_orthongel <- paste("\\France",
                                year,
                                iconv(format(as.Date(paste(year, min_query_orthongel, "01", 
                                                           sep = "-"), 
                                                     "%Y-%m-%d"), 
                                             "%B"), 
                                      to = "ASCII//TRANSLIT"),
                                "query_orthongel.csv", 
                                sep = "_")
  rm(min_query_orthongel)
} else {
  min_query_orthongel <- ifelse(nchar(min(query_orthongel$activity_month)) == 1, 
                                paste("0", min(query_orthongel$activity_month), sep = ""), 
                                min(query_orthongel$activity_month))
  max_query_orthongel <- ifelse(nchar(max(query_orthongel$activity_month)) == 1, 
                                paste("0", max(query_orthongel$activity_month), sep = ""), 
                                max(query_orthongel$activity_month))
  name_query_orthongel <- paste("\\France",
                                year,
                                iconv(format(as.Date(paste(year, min_query_orthongel, "01", 
                                                           sep = "-"), 
                                                     "%Y-%m-%d"), 
                                             "%B"), 
                                      to = "ASCII//TRANSLIT"),
                                iconv(format(as.Date(paste(year, max_query_orthongel, "01", 
                                                           sep = "-"), 
                                                     "%Y-%m-%d"), 
                                             "%B"), 
                                      to = "ASCII//TRANSLIT"),
                                "query_orthongel.csv", 
                                sep = "_")
  rm(min_query_orthongel, max_query_orthongel)
}
write.table(query_orthongel,
            file <- paste(file.path(config_env[["output_loc"]], 
                                    paste(format(Sys.time(), '%Y_%m_%d_'), "export", 
                                          sep = ""), 
                                    fsep = "\\"), 
                          name_query_orthongel, 
                          sep = ""),
            sep = ";",
            dec = ".",
            row.names = FALSE,
            col.names = TRUE,
            append = FALSE)
