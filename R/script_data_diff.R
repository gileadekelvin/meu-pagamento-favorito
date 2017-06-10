library(RMySQL)
library(dplyr)
library(ggplot2)

## liquidacoes e empenhos

mydb = dbConnect(MySQL(), user='hackfest', password='H@ckfest', dbname="sagres", host='150.165.85.32', port = 22030)
#dbListTables(mydb)

a <- dbSendQuery(mydb, "select e.cd_Credor, e.nu_Empenho, l.cd_UGestora, e.dt_Ano, e.cd_UnidOrcamentaria, datediff(l.dt_Liquidacao, e.dt_Empenho)  from empenhos e, liquidacao l where CAST(e.cd_Ugestora as CHAR(50)) like '%050' and  l.nu_Empenho = e.nu_Empenho and l.cd_UGestora = e.cd_UGestora and l.dt_Ano = e.dt_Ano and l.cd_UnidOrcamentaria = e.cd_UnidOrcamentaria")

data.emp.liq <- fetch(a, n=-1)

data.emp.liq <- data.emp.liq %>%
  rename("diffLiq" = `datediff(l.dt_Liquidacao, e.dt_Empenho)`)

diff.emp.liq <- data.emp.liq %>%
  group_by(nu_Empenho, cd_UGestora, cd_UnidOrcamentaria, dt_Ano, cd_Credor) %>%
  summarise(mean.diffLiq = mean(diffLiq))

## pagamentos e empenhos

mydb = dbConnect(MySQL(), user='hackfest', password='H@ckfest', dbname="sagres", host='150.165.85.32', port = 22030)

emp.pag <- dbSendQuery(mydb, "select e.cd_Credor, e.nu_Empenho, p.cd_UGestora, e.dt_Ano, e.cd_UnidOrcamentaria, datediff(p.dt_Pagamento, e.dt_Empenho)  from empenhos e, pagamentos p where CAST(e.cd_Ugestora as CHAR(50)) like '%050' and  p.nu_Empenho = e.nu_Empenho and p.cd_UGestora = e.cd_UGestora and p.dt_Ano = e.dt_Ano and p.cd_UnidOrcamentaria = e.cd_UnidOrcamentaria")

data.emp.pag <- fetch(emp.pag, n=-1)

data.emp.pag <- data.emp.pag %>%
  rename("diffPag" = `datediff(p.dt_Pagamento, e.dt_Empenho)`)

diff.emp.pag <- data.emp.pag %>%
  group_by(nu_Empenho, cd_UGestora, cd_UnidOrcamentaria, dt_Ano, cd_Credor) %>%
  summarise(mean.diffPag = mean(diffPag))

tabela <- diff.emp.liq %>%
  left_join(diff.emp.pag, by = c("nu_Empenho", "cd_UGestora", "dt_Ano", "cd_UnidOrcamentaria", "cd_Credor"))

tabela <- tabela %>%
  mutate(diferenca = mean.diffPag - mean.diffLiq)

