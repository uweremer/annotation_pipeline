#install.packages("DBI")
library(DBI)
#install.packages("RPostgres")
library(RPostgres)

con <- dbConnect(Postgres(),dbname = 'next',  
                 host = IP,
                 port = 5432,
                 user = USER,
                 password = PASS,
                 options="-c search_path=open_discourse")

dbListTables(con)

dbListFields(con, "speeches")

#speeches <- dbReadTable(con, "speeches")

query <-  dbSendQuery(con, "SELECT * FROM speeches WHERE
                    speeches.last_name = 'merkel' ")
merkel_speeches <- dbFetch(query)
str(merkel_speeches)

merkel_speeches$date
