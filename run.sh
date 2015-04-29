export HADOOP_HEAPSIZE=1024 &&
hive -f initial_data.sql > ./data/initial_data.tsv &&
hive -f retrieve_benchmark.sql > ./data/benchmark_data.tsv &&
R CMD BATCH ./R/initial.R