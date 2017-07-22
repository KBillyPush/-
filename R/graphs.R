install.packages('UScensus2010')
library(UScensus2010)
library(scales)
library(rvest)
library(readxl)

edu <- read_excel('dobis.xlsx')


url <- 'http://www.governing.com/topics/urban/gov-majority-minority-populations-in-states.html'

pop <- url %>% 
    read_html %>% 
    html_nodes(xpath = '//*[@id="inputdata"]') %>% 
    html_table %>% 
    as.data.frame(stringsAsFactors = F) %>% 
    mutate_at(vars(-State), parse_number)

pop <- url %>% 
    read_html %>% 
    html_nodes(xpath = '/html/body/div[2]/div/div/section/div/div[2]/div[2]/div[1]/div[1]/div/div[11]/div/div/div/div/table') %>% 
    html_table %>% 
    as.data.frame(stringsAsFactors = F) %>% 
    mutate_at(vars(-State), parse_number)

names(pop) <- c('state', 'minority_share', 'white', 'hispanic', 'black', 'asian')

efficiencies %>% 
    left_join(edu, by = c('name' = 'state')) %>% 
    mutate(party = ifelse(efficiency < 0, 'Districting benefits Republicans', 'Districting benefits Democrats'),
           tooltip = name) %>%
    hchart(hcaes(x = pct_grads_10, y = efficiency, group = party), type = 'scatter') %>% 
    hc_tooltip(formatter = JS(paste0("function() {return this.point.tooltip;}")), useHTML = T) %>% 
    hc_colors(c('blue', 'red')) %>% 
    hc_title(text = 'Party efficiency gap is correlated with education') %>% 
    hc_yAxis(title = list(text = 'Effeciency Gap, 2012 Presidential Election')) %>% 
    hc_xAxis(title = list(text = 'Percentage of Adults aged 25-34 with a Postsecondary Degree, 2010')) %>% 
    hc_credits(
        enabled = TRUE,
        text = "Sources: Deparment of Education and Harvard Dataverse",
        href = "https://www.ed.gov/news/press-releases/new-state-state-college-attainment-numbers-show-progress-toward-2020-goal") %>% 
    hc_add_theme(hc_theme_538()) %>% 
    saveWidget(file = 'graph.html')

