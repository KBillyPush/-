shinyUI(
    fluidPage(
        tags$head(tags$link(rel = 'stylesheet', type = 'text/css', href = 'style.css')),
        tags$head(tags$link(rel = 'icon', type = 'image/png', href = 'Rlogo.png'),
                  tags$title('Unhack the vote')),
        navbarPageWithText('GeoMander Go!',
                           tabPanel('Efficiency Gaps',
                                    sidebarLayout(
                                        sidebarPanel('hi'),
                                        mainPanel(
                                            leafletOutput('map')
                                        )
                                    )
                           ), 
                           tabPanel('Get Involved!'),
                           text = HTML('<a href = "https://www.thursdaynetwork.org/" target = "_blank">Thursday Network</a>')
        )
    )
)