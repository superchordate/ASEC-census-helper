require(easyr)
begin()

for(file in list.files('raw-data/asec-clean-2019-2023', full.names = TRUE, pattern = 'RDS$')){
    idt = readRDS(file)
    w(idt, gsub('RDS', 'csv', file))
}

