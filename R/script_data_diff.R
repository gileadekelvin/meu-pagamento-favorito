library(RMySQL)
library(dplyr)

## liquidacoes e empenhos

get.emp.liq <- function(cidade, cd_funcao){
  mydb = dbConnect(MySQL(), user='hackfest', password='H@ckfest', dbname="sagres", host='150.165.85.32', port = 22030)
  #dbListTables(mydb)
  
  emp.liq <- dbSendQuery(mydb, paste("select e.nu_Empenho, l.cd_UGestora, e.dt_Ano, e.cd_UnidOrcamentaria, e.cd_Credor, e.no_Credor, 
                         datediff(l.dt_Liquidacao, e.dt_Empenho)  from empenhos e, liquidacao l 
                         where CAST(e.cd_Ugestora as CHAR(50)) like '%", cidade,"' and e.cd_funcao = ", cd_funcao," and l.nu_Empenho = e.nu_Empenho and 
                         l.cd_UGestora = e.cd_UGestora and l.dt_Ano = e.dt_Ano and l.cd_UnidOrcamentaria = e.cd_UnidOrcamentaria", sep = ""))
  
  data.emp.liq <- fetch(emp.liq, n=-1)
  
  data.emp.liq <- data.emp.liq %>%
    rename("diffLiq" = `datediff(l.dt_Liquidacao, e.dt_Empenho)`)
  
  diff.emp.liq <- data.emp.liq %>%
    group_by(nu_Empenho, cd_UGestora, cd_UnidOrcamentaria, dt_Ano, cd_Credor, no_Credor) %>%
    summarise(mean.diffLiq = mean(diffLiq))
  
  return(diff.emp.liq)
}

## pagamentos e empenhos

get.emp.pag <- function(cidade, cd_funcao){
  mydb = dbConnect(MySQL(), user='hackfest', password='H@ckfest', dbname="sagres", host='150.165.85.32', port = 22030)
  
  emp.pag <- dbSendQuery(mydb, paste("select e.nu_Empenho, p.cd_UGestora, e.dt_Ano, e.cd_UnidOrcamentaria, e.cd_Credor, e.no_Credor, 
                         datediff(p.dt_Pagamento, e.dt_Empenho)  from empenhos e, pagamentos p 
                         where CAST(e.cd_Ugestora as CHAR(50)) like '%", cidade,"' and e.cd_funcao = ", cd_funcao," and  
                         p.nu_Empenho = e.nu_Empenho and p.cd_UGestora = e.cd_UGestora and p.dt_Ano = e.dt_Ano and 
                         p.cd_UnidOrcamentaria = e.cd_UnidOrcamentaria", sep = ""))
  
  data.emp.pag <- fetch(emp.pag, n=-1)
  
  data.emp.pag <- data.emp.pag %>%
    rename("diffPag" = `datediff(p.dt_Pagamento, e.dt_Empenho)`)
  
  diff.emp.pag <- data.emp.pag %>%
    group_by(nu_Empenho, cd_UGestora, cd_UnidOrcamentaria, dt_Ano, cd_Credor) %>%
    summarise(mean.diffPag = mean(diffPag))
  
  return(diff.emp.pag)
}



