export HADOOP_HEAPSIZE=1024 && hive -f initial_data.sql > ./data/initial_data.tsv && 
hive -f mobile_redirects.sql > ./data/mobile_redirects.tsv &&
hive -f diversity.sql > ./data/diversity.tsv && R CMD BATCH ./R/initial.R