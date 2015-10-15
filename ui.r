library(shiny)
library(visNetwork)
require(markdown)
library(DT)

shinyUI(
    
    navbarPage("Supplementary Material",
                   tabPanel("Home", 
                            fluidRow(
                                column(10, offset=1,
                                       includeMarkdown("introduction.md"))
                                )
                        ),
                    tabPanel("JSD Examples", 
                             withMathJax(),
                             fluidRow(
                                 column(8, offset=1,
                                        includeMarkdown("jsd_examples.md")
                                        )),
                             fluidRow(
                                 column(3,
                                        radioButtons("dist", "Value of JSD:",
                                                     c("Low" = "low",
                                                       "Middle" = "middle",
                                                       "High" = "high")),
                                        textOutput('jsd')
                                 )
                                 ,
                                 column(7,
                                        plotOutput('gp_jsd')
                             
                             ))),
               
                   tabPanel("JSD Distributions", 
                            fluidRow(
                                column(8, offset=2,
                                       div("The JSD measures in our data are visualized in two ways. The first shows the distribution of mean JSD scores 
                                           across journals, while the second visualizes the raw scores. 
                                           The plot below visualizes the aggregated distribution across the different databases."),
                                       br(),
                                       div("Below, you can select from four different types: mean of JSD in science journals (SCI), social science journals (SOCSCI), or related cognitive science journals (Other cognitive).
                                           The mean JSD of the journal Cognitive Science (CogSci) is portrayed by the dashed vertical line."),
                                       br()
                                )),
                            
                            fluidRow(
                                column(2,
                                       checkboxGroupInput("variable", "Select type of journal:",
                                                          c("SCI" = "SCI",
                                                            "SOCSCI" = "SOCSCI",
                                                            "Other Cognitive"="COGNITIVE"),
                                                          selected = c("SOCSCI","SCI")
                                       )
                                ),
                                column(7,
                                       plotOutput("gp_agg")        )
                            ),
                            br(),
                            hr(),
                            br(),
                            fluidRow(
                                column(8, offset=2,
                                       div("Instead of aggregating the JSD measures across journals, the plot below shows the raw JSD in the databases."),
                                       br(),
                                       div("You can select from four different types: collaborations in science journals (SCI), social science journals (SOCSCI), in the journal Cognitive Science (CogSci), or related cognitive science journals (Other cognitive)."),
                                       br()
                                       )),
                            fluidRow(
                                column(2,
                                       checkboxGroupInput("variable2", "Select type of journal:",
                                                          c( "SCI" = "SCI",
                                                            "SOCSCI" = "SOCSCI",
                                                            "CogSci" = "COGSCI",
                                                            "Other Cognitive" = "similar"),
                                                          selected = c("SOCSCI","SCI", "COGSCI")
                                       )
                                ),
                                column(8, 
                                       plotOutput("gp_all"))
                            ),
                            tags$style(type='text/css', '#variable { width:100%; margin-top:50px;}'), 
                            tags$style(type='text/css', '#variable2 { width:100%; margin-top:50px;}')
                            
                   ),
               tabPanel("Journal Rankings", 
                        fluidRow(
                            column(10, offset=1,
                                   includeMarkdown("rankings.md")
                            )),   
                        fluidRow(
                            column(10, offset=1,
                                   DT::dataTableOutput("mytable")
                            ))),
               tabPanel("CogSci Author Network", 
                        
                        fluidRow(
                            column(10, offset=1,
                                   includeMarkdown("network.md")
                                   )),         
                        fluidRow(
                            column(10, offset=1,
                                   visNetworkOutput("network", height="600px")
                            ))
                        )
))