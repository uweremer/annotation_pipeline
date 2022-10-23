#install.packages("DBI")
library(DBI)
#install.packages("RPostgres")
library(RPostgres)

con <- dbConnect(Postgres(),dbname = 'next',  
                 host = '193.196.39.254',
                 port = 5432,
                 user = 'postgres',
                 password = 'postgres',
                 options="-c search_path=open_discourse")

dbListTables(con)

dbListFields(con, "speeches")

#speeches <- dbReadTable(con, "speeches")

query <-  dbSendQuery(con, "SELECT * FROM speeches WHERE
                    speeches.last_name = 'merkel' ")
merkel_speeches <- dbFetch(query)
str(merkel_speeches)

merkel_speeches$date
