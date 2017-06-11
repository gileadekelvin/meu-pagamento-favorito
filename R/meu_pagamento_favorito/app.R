library(shiny)
library(shinydashboard)
library(htmltools)
library(ggplot2)
library(highcharter)
        

## Leitura dos dados
source("script_data_diff.R")
##

ui <- dashboardPage(skin = "blue",
  dashboardHeader(title = "Meu pagamento favorito", titleWidth = 250),
  dashboardSidebar(width = 250,
    sidebarMenu( 
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Info", tabName = "info", icon = icon("info")), 
      menuItem("Comments", tabName = "disqus_here", icon = icon("comments"))
    )
  ),
    
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "dashboard", class = "active",
              fluidRow(
                column(width = 4,
                       box(width = 12, status = "warning", solidHeader = TRUE,
                           title = "Entradas",
                         selectInput("cidades", "Cidades",
                                     c("João Pessoa" = "095", "Campina Grande" = "050"),
                                     selected = "050"
                         ),
                         selectInput("funcao", "Áreas",
                                       c("Saúde" = "10", "Educação" = "12", "Habitação" = "16"),
                                     selected = "16"
                         ),
                         selectInput("passo", "Passo da Execução",
                                       c("Liquidação" = "liq", "Pagamento" = "pag"),
                                       selected = "pag"
                         )
                       ),
                       box(width = 12,
                           title = "Execução Orçamentária", status = "success",  solidHeader = TRUE,
                           div(style="text-align: justify;", "No processo de execução orçamentária da despesa pública a ordem correta é 
                              Empenho, liquidação, Pagamento. Para alguns casos é estranho que esses passos aconteçam no mesmo dia.")
                      )
                ),
                column(width = 8,
                       tabBox(width = 12,
                         selected = "Histograma",
                         tabPanel("Histograma", highchartOutput("histogram")),
                         tabPanel("Dispersão", highchartOutput("scatter"))
                         
                       )
                )
                
             
        )
      ),
      
      tabItem(tabName = "info",
              box(width = 4,
                  title = "Dados", status = "primary", solidHeader = TRUE,
                  "A fonte dos dados é o Sagres. Disponibilizado pelo TCE - Tribunal de Contas do Estado."
              ),
              box(width = 4,
                  title = "Sobre", status = "warning",  solidHeader = TRUE,
                  "Essa aplicação foi desenvolvida no Hackfest - Contra a corrupção 2017.", br()),
              box(width = 4,
                  title = "Equipe", status = "success",  solidHeader = TRUE,
                  "Team: Arthur Costa, Arthur Sena, Danilo Lacerda, Gileade Kelvin.", br())
              
      
      ),
      tabItem(tabName = "disqus_here",
              div(id="disqus_thread",
                  HTML(
                    "<script>
    (function() {  
        var d = document, s = d.createElement('script');
        s.src = 'https://meu-pagamento-favorito.disqus.com/embed.js';
        s.setAttribute('data-timestamp', +new Date());
        (d.head || d.body).appendChild(s);
    })();
</script>
<noscript>Please enable JavaScript to view the
<a href='https://disqus.com/?ref_noscript' rel='nofollow'>comments powered by Disqus.</a>
</noscript>"
                  )
              )
      )
    ),
    div(HTML('<script id="dsq-count-scr" src="//meu-pagamento-favorito.disqus.com/count.js" async></script>'))

  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  output$histogram <- renderHighchart({
    if(input$passo == "liq"){
      hchist(as.numeric(get.emp.liq(input$cidades, input$funcao)$mean.diffLiq)) %>%
      hc_add_theme(hc_theme_smpl()) %>%
      hc_tooltip(pointFormat = "Diferença: {bar.x} <br> Número de ocorrências: {bar.y}") %>%
      hc_legend(enabled = FALSE) %>%
      hc_title(text = "Diferença de datas entre o empenho e suas liquidações") %>%
      hc_xAxis(title = list(text = "Diferença entre as datas de empenho e liquidação" )) %>%
      hc_yAxis(title = list(text = "Número de ocorrências"))
    } else {
      hchist(as.numeric(get.emp.pag(input$cidades, input$funcao)$mean.diffPag)) %>%
        hc_add_theme(hc_theme_smpl())%>%
        hc_legend(enabled = FALSE) %>%
        hc_title(text = "Diferença de datas entre o empenho e seus pagamentos") %>%
        hc_xAxis(title = list(text = "Número de ocorrências")) %>%
        hc_yAxis(title = list(text = "Diferença entre as datas de empenho e pagamento"))
      
    }
  })
  
  output$scatter <- renderHighchart({
    ## Tentando scatterplot
    get.emp.pag(input$cidades, input$funcao) %>%
      filter(mean.diffPag == 0) %>%
      hchart("scatter", hcaes(y = vl_Empenho)) %>%
      hc_add_theme(hc_theme_smpl()) %>%
      hc_tooltip(pointFormat = "Credor: {point.no_Credor} <br> Valor do empenho: {point.y} <br> Unidade Gestora: {point.cd_UGestora}") %>% 
      hc_xAxis(title = list(text = "Empenhos")) %>%
      hc_yAxis(title = list(text = "Valor empenhado em Reais"))
  })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)

