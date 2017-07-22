shinyServer(function(input, output, session) {
    
    output$map <- renderLeaflet({
        leaflet(states) %>% 
            setView(-98.58, 39.82, 4) %>% 
            addPolygons(fillColor = ~pal(efficiency), fillOpacity = 1, smoothFactor = .3,
                        opacity = 1, weight = 1, color = '#444444',
                        label = ~paste0(NAME, ': ', round(efficiency, 3)),
                        highlightOptions = highlightOptions(color = "white", weight = 2, bringToFront = TRUE))
    })
    
})
