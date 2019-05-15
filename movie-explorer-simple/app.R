library(ggvis)
library(tidyverse)
library(shiny)
library(DescTools)

# For dropdown menu


all_movies <- read_csv('movies_s.csv')

axis_vars <- c(
  "Tomato Meter" = "Meter",
  "Numeric Rating" = "Rating",
  "Number of reviews" = "Reviews",
  "Dollars at box office" = "BoxOffice",
  "Year" = "Year",
  "Length (minutes)" = "Runtime",
  "Title Length" = "TitleLength",
  "User Rating" = "userRating"
)


ui <- fluidPage(
  titlePanel("Movie explorer"),
  fluidRow(
    column(3,
      wellPanel(
        h4("Filter"),
        sliderInput("reviews", "Minimum number of reviews on Rotten Tomatoes",
          10, 300, 80, step = 10),
        selectInput("genre", "Genre (a movie can have multiple genres)",
          c("All", "Action", "Adventure", "Animation", "Biography", "Comedy",
            "Crime", "Documentary", "Drama", "Family", "Fantasy", "History",
            "Horror", "Music", "Musical", "Mystery", "Romance", "Sci-Fi",
            "Short", "Sport", "Thriller", "War", "Western")
        ),
        textInput("director", "Director name contains (e.g., Miyazaki)")##########,
        # textInput("cast", "Cast names contains (e.g. Tom Hanks)")
      ),
      wellPanel(
        selectInput("xvar", "X-axis variable", axis_vars, selected = "Meter"),
        selectInput("yvar", "Y-axis variable", axis_vars, selected = "Reviews"),
        tags$small(paste0(
          "Note: The Tomato Meter is the proportion of positive reviews",
          " (as judged by the Rotten Tomatoes staff), and the Numeric rating is",
          " a normalized 1-10 score of those reviews which have star ratings",
          " (for example, 3 out of 4 stars)."
        ))
      )
    ),
    column(9,
      ggvisOutput("plot1"),
      wellPanel(
        span("Number of movies selected:",
          textOutput("n_movies")
        )
      )
    )
  )
)


server <- function(input, output, session) {
  
  # Filter the movies, returning a data frame
  movies <- reactive({
    # Due to dplyr issue #318, we need temp variables for input values
    reviews <- input$reviews
    
    # Apply filters
    m <- all_movies %>%
      filter(
        Reviews >= reviews
      ) %>%
      arrange(Oscars)
    
    # Optional: filter by genre
    if (input$genre != "All") {
      m <- m %>% filter(Genre == input$genre)
    }
    
    # Optional: filter by director
    if (!is.null(input$director) && input$director != "") {
      director <- paste0("%", input$director, "%")
      m <- m %>% filter(Director %like% director)
    }
    m <- as.data.frame(m)
    
    # Add column which says whether the movie won any Oscars
    # Be a little careful in case we have a zero-row data frame
    m$has_oscar <- character(nrow(m))
    m$has_oscar[m$Oscars == 0] <- "No"
    m$has_oscar[m$Oscars >= 1] <- "Yes"
    m
  })
  
  # Function for generating tooltip text
  movie_tooltip <- function(x) {
    if (is.null(x)) return(NULL)
    if (is.null(x$ID)) return(NULL)
    
    # Pick out the movie with this ID
    all_movies <- isolate(movies())
    movie <- all_movies[all_movies$ID == x$ID, ]
    
    paste0("<b>", movie$Title, "</b><br>",
           movie$Year, "<br>",
           "$", format(movie$BoxOffice, big.mark = ",", scientific = FALSE)
    )
  }
  
  # A reactive expression with the ggvis plot
  vis <- reactive({
    # Lables for axes
    xvar_name <- names(axis_vars)[axis_vars == input$xvar]
    yvar_name <- names(axis_vars)[axis_vars == input$yvar]
    
    # Normally we could do something like props(x = ~BoxOffice, y = ~Reviews),
    # but since the inputs are strings, we need to do a little more work.
    xvar <- prop("x", as.symbol(input$xvar))
    yvar <- prop("y", as.symbol(input$yvar))
    
    movies %>%
      ggvis(x = xvar, y = yvar) %>%
      layer_points(size := 50, size.hover := 200,
                   fillOpacity := 0.2, fillOpacity.hover := 0.5,
                   stroke = ~has_oscar, key := ~ID) %>%
      add_tooltip(movie_tooltip, "hover") %>%
      add_axis("x", title = xvar_name) %>%
      add_axis("y", title = yvar_name) %>%
      add_legend("stroke", title = "Won Oscar", values = c("Yes", "No")) %>%
      scale_nominal("stroke", domain = c("Yes", "No"),
                    range = c("orange", "#aaa")) %>%
      set_options(width = 500, height = 500)
  })
  
  vis %>% bind_shiny("plot1")
  
  output$n_movies <- renderText({ nrow(movies()) })
}

  

shinyApp(ui, server)
