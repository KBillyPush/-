library(shiny)
library(tidyverse)
library(leaflet)

setwd('C:/Users/Charlie/Documents/Side Projects/-/R/app/')

load('states.RData')
votes <- read.csv('district_votes_2012.csv', stringsAsFactors = F)

efficiencies <- votes %>% 
    group_by(state) %>%
    summarise(D = sum(D, na.rm = T),
              R = sum(R, na.rm = T),
              d_wasted_votes = sum(d_wasted_votes, na.rm = T),
              r_wasted_votes = sum(r_wasted_votes, na.rm = T),
              total_votes = sum(total_votes, na.rm = T),
              efficiency = (sum(d_wasted_votes, na.rm = T) - sum(r_wasted_votes, na.rm = T)) / sum(total_votes, na.rm = T) * -1) %>% 
    mutate(name = state.name[match(state, state.abb)],
           net_wasted_votes = d_wasted_votes)

states$efficiency <- efficiencies$efficiency[match(states$NAME, efficiencies$name)]

pal <- colorNumeric("RdBu", NULL)

navbarPageWithText <- function(..., text) {
    navbar <- navbarPage(...)
    textEl <- tags$p(class = "navbar-text", text)
    navbar[[3]][[1]]$children[[1]] <- htmltools::tagAppendChild(
        navbar[[3]][[1]]$children[[1]], textEl)
    navbar
}
