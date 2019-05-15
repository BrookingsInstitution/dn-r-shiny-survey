library(tidyverse)
library(shiny)
library(igraph)
library(visNetwork)
library(leaflet)

#PATH <- dirname(sys.frame(1)$ofile) 
#setwd(PATH)


dayColors <- c("red","blue","orange","green","purple","cyan","pink")
graphColors <- c("lightblue","seagreen","gold","tomato","thistle",
                 "dodgerblue","dimgray","chartreuse","sienna","mediumpurple",
                 "darkturquoise","deeppink","firebrick","darkolivegreen","lightcoral")

famousNames <- c("Stark","Targaryen","Lannister","Baratheon","Greyjoy","Tyrell","Frey","Martell","Snow","Clegane")
nameChoices <- 1:length(famousNames)
names(nameChoices) <- famousNames

gotnodes <- read_csv("gotnodes.csv")
gotedges <- read_csv("gotedges.csv")
gotnodes <- mutate(gotnodes,title=Label)
gotedges <- mutate(gotedges,value=weight,title=paste(Source,"-",Target,":",weight))






r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()


ui <- fluidPage(
  fluidRow(h1('Game of Thrones Co-Occurence Network')),
  fluidRow(
    column(2,
           checkboxGroupInput('nameSelect',"Restrict Names",choices=nameChoices),
           sliderInput("slider","Restrict Frequency",0,100,0,step=1)
    ),
    column(10,
           visNetworkOutput("network",height=800)
    )
  )
)

server <- function(input, output, session) {
  
  getGraphDataReactive <- reactive({
    nodes <- gotnodes
    edges <- gotedges
    
    # print(gotnodes)
    if(!is.null(input$nameSelect)){
      nodes <- filter(nodes,Group %in% input$nameSelect)
      edges <- filter(edges,to %in% nodes$id, from%in% nodes$id)
    }
    if(input$slider!=0){
      nodes <- filter(nodes,freq>input$slider)
      #print(dim(nodes))
      edges <- filter(edges,to %in% nodes$id, from%in% nodes$id)
    }
    
    return(list("nodes"=nodes,"edges"=edges))
  })
  
  output$test <- renderText(3 %in% input$nameSelect)
  
  output$network <- renderVisNetwork({
    nodesVis <- getGraphDataReactive()$nodes
    edgesVis <- getGraphDataReactive()$edges
    
    nodesVis$color.background <- graphColors[nodesVis$Group]
    
    visNetwork(nodesVis, edgesVis, height = "1000px",width="100%") %>%
      visIgraphLayout(layout = "layout_with_fr")
  })
  
}



shinyApp(ui, server)
