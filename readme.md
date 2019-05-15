## Shiny for R: Survey and Introduction
### Brookings Data Network
### 5/15/2019

The root directory of this repository contains the overview presentation `.Rmd` file in two forms, one with embedded versions of the example applications, and a `no_embed` version without embedded Shiny content. The `no_embed` version can be viewed by opening its html file with the browser, but the version with embedded apps must be run from Rstudio to initiate an R session to drive the apps.

The subdirectories `movie-explorer-simple`, `trivia-map`, and `got-network` each contain an example shiny app. You can run these by opening any of the `app.R` files in Rstudio then clicking the "Run App" button or using the shortcut "ctrl+shift+s" in the editor window.

I've also deployed the demo apps to my own shinyapps account for now:

- [Movie Explorer, simplified](https://rwgp.shinyapps.io/movie-explorer-simple/) (reduced version of Rstudio [movie explorer](https://shiny.rstudio.com/gallery/movie-explorer.html))
- [Trivia Venue Map](https://rwgp.shinyapps.io/shiny_map/)
- [GoT Co-occurrence Network](https://rwgp.shinyapps.io/got-network/)


#### Data Files:

The data for the apps are located both in the root directory, and in their respective app directories. This is because embedded shiny apps have as their working directory the directory of the parent `.Rmd` file, whereas apps run from Rstudio (or deployed on shinyapps.io) take their own location as working directory. 