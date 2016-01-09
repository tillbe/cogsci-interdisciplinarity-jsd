library(shiny)
library(dplyr)
library(ggplot2)
# library(cowplot)
library(visNetwork)
library(DT)
library(tidyr)

# Reading in JSD data -----------------------------------------------------

xdata = read.csv("avg_data2.csv")
levels(xdata$database)[1]="COGSCI"
xdata$database = factor(xdata$database, levels=c("SCI", "SOCSCI", "COGSCI"))

ydata = read.csv("raw_data2.csv")
levels(ydata$database)[1] = "COGSCI"
ydata$database = factor(ydata$database, levels=c("SCI", "SOCSCI", "COGSCI", "competitor"))


# Reading in network data -------------------------------------------------

edges = read.csv("edges.csv")
nodes = read.csv("nodes.csv")
names(edges) = c("from", "to", "value")
names(nodes)[1]= "id"
names(nodes)[2] = "label"
nodes$id = nodes$id+1
edges$from = edges$from+1
edges$to = edges$to +1
# nodes$title = paste0("JSD:", round(sqrt(nodes$size)/10,3))
# edges$title = paste0("JSD:", round(sqrt(edges$value)/10,3))
nodes$title = paste0("JSD:", round(nodes$size,3))
edges$title = paste0("JSD:", round(edges$value,3))

nodes$size = (nodes$size) * 10
edges$value = (edges$value^2) * 10
nodes = nodes %>% arrange(label)
names(nodes)[3] = "value"

dists = read.csv('jsd_dists.csv')
jsds = data.frame(type=c('low', 'middle', 'high'), jsd=c(0.1032118, 0.4014161, 0.6931472))

shinyServer(function(input, output) {


# Data Table Rankings -----------------------------------------------------
    
    
    output$mytable = DT::renderDataTable(
        xdata %>% mutate(database = as.character(database),
                         competitor = as.character(competitor),
                         journal = as.character(journal)) %>% 
            mutate(database = ifelse(database == "COGSCI", "SOCSCI", database),
                   competitor = ifelse(issn == "1551-6709", "Yes", competitor),
                   journal = ifelse(issn == "1551-6709", "COGNITIVE SCIENCE", journal)) %>%
            filter(database %in% c("SCI", "SOCSCI")) %>% 
            arrange(desc(avgJSD)) %>% 
            mutate(avgJSD = round(as.numeric(avgJSD), 4)) %>%
            select(journal, issn, database, competitor, avgJSD) %>%
            mutate(database=as.factor(database),
                   competitor=as.factor(competitor),
                   issn=as.character(issn)),
        colnames=c("Journal","ISSN", "Database", "Cognitive Journal","Avg. JSD"),
        filter = "top",
        style = "bootstrap",
        options = list(pageLength=10))


# JSD examples ------------------------------------------------------------


    getJSDdist = reactive({
        dists %>% filter(type == input$dist)
    })


    output$jsd <- renderText({ 
            paste0("The JSD for this collaboration is ",round(jsds %>% filter(type == input$dist) %>% .$jsd,3), ".")
    })

    output$gp_jsd = renderPlot({
        ggplot(getJSDdist(), aes(x=i, y=value, fill=author)) + 
            geom_bar(stat="identity",position="dodge") + 
            scale_y_continuous("# of Publications in journal\n", expand=c(0,0)) +
            scale_fill_brewer("", palette="Set2", labels=c("Author A", "Author B")) +
            theme_classic(base_size=20) + 
            xlab("Journals")
        
    })

# Plot Aggregated JSD -----------------------------------------------------
    
    selectAgg = reactive({
        col = c()
        if('SCI' %in% input$variable){
            col = c(col, 0.7)
        }else{
            col = c(col, 0)
        }
        if('SOCSCI' %in% input$variable){
            col = c(col, 0.7)
        }else{
            col = c(col, 0)
        }
        if('COGNITIVE' %in% input$variable){
            col = c(col, 0.7)
        }else{
            col = c(col, 0)
        }
        col
    })
    
    cogsci = reactive({
        # gets mean JSD of CogSci
        ydata %>% filter(database == "COGSCI") %>%
            summarise(avg = mean(jsd)) %>% .$avg
    })
    
    
    plotFunc = function(){
        avg_cog = cogsci()
        tmp = xdata %>% filter(database %in% c("SCI", "SOCSCI"))
        tmp2 = xdata %>% filter(competitor=="Yes")
        tmp2$database="cognitive"
        tmp = droplevels(rbind(tmp, tmp2))
        
        tmp$database = factor(tmp$database, levels=c("SCI", "SOCSCI", "cognitive"))
        
        
        gp = ggplot2::ggplot(tmp, aes(x=avgJSD)) +
            geom_density(aes(fill=database, color=NULL, alpha=database), size=0) +
            scale_y_continuous(expand=c(0,0), limits=c(0,12)) +
            xlim(0.1,0.6) +
            ggtitle("Distribution of average journal JSD across databases\n") +
            geom_vline(xintercept=avg_cog, linetype="dashed", col="grey40", size=2)+
            scale_fill_discrete(name="Type of journal\n", labels=c("SCI", "SOCSCI", "Other cognitive"))+
            guides(alpha=FALSE) +
            theme_classic() 
        return(gp)
    }
    
    output$gp_agg = renderPlot({
        plotFunc() + scale_alpha_manual(values=selectAgg())
    })
    

# Plot Raw JSD distributions ----------------------------------------------
    ydataInput <- reactive({
        col = c()
        if('SCI' %in% input$variable2){
            col = c(col, 0.7)
        }else{
            col = c(col, 0)
        }       
        if('SOCSCI' %in% input$variable2){
            col = c(col, 0.7)
        }else{
            col = c(col, 0)
        }
        if('COGSCI' %in% input$variable2){
            col = c(col, 0.7)
        }else{
            col = c(col, 0)
        }
        if('similar' %in% input$variable2){
            col = c(col, 0.7)
        }else{
            col = c(col, 0)
        }
        c(col, 0.7)
    })
    
    plotAll = function(){
        gp = ggplot2::ggplot(ydata, aes(x=jsd)) +
            geom_density(aes(fill=database, alpha=database), size=0) +
            scale_y_continuous(expand=c(0,0)) + 
            scale_x_continuous(limits=c(0,1))+
            ggtitle("Distribution of all JSDs across databases\n")+
            scale_fill_discrete(name="Type of journal\n", labels=c("SCI", "SOCSCI","CogSci", "Other cognitive"))+
            guides(alpha=FALSE) + 
            theme_classic()
        return(gp)
    }
    
    output$gp_all = renderPlot({
        plotAll() + scale_alpha_manual(values=ydataInput())
    })
    
    
    

# Network ---------------------------------------------------------------


    output$network = renderVisNetwork({
        visNetwork(nodes, edges) %>% 
            visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
            visNodes(font=list(size=22))
        })
})