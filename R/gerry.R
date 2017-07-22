setwd('C:/Users/Charlie/Documents/Side Projects/-/')

unzip('dataverse_files.zip')
unzip('dataverse_files (1).zip')
unzip('dataverse_files (2).zip')


files <- list.files()[grepl('.tab', list.files())]

map(files, function(x) {
    assign(sub('\\.tab', '', x), read.table(x, sep="\t", header=TRUE, stringsAsFactors = F), envir = .GlobalEnv)
})

head(CT_2012)

unique(CT_2012$cd)

unique(NH_2012$cd)

tots <- map_df(ls()[grepl('_20', ls())], function(x) {
    tmp <- get(x)
    
    if (is.null(tmp$cd)) {
        tibble()
    } else {
        select(tmp, cd, g2012_USP_rv, g2012_USP_dv, g2012_USP_tv) %>% 
            mutate(state = substr(x, 1, 2)) %>% 
            group_by(state, cd) %>% 
            summarise_at(vars(contains('g2012_USP|')), funs(sum(., na.rm = T))) %>% 
            ungroup %>% 
            rename(D = g2012_USP_dv, R = g2012_USP_rv) %>% 
            mutate(total_votes = D + R,
                   d_win = D > R,
                   d_wasted_votes = ifelse(d_win, D - (floor(total_votes/2) + 1), D),
                   r_wasted_votes = ifelse(!d_win, R - (floor(total_votes/2) + 1), R),
                   net_wasted_votes = r_wasted_votes - d_wasted_votes)
    }
})


write.csv(tots, 'district_votes_2012.csv', row.names = F)

efficiencies <- tots %>% 
    group_by(state) %>%
    summarise(D = sum(D, na.rm = T),
              R = sum(R, na.rm = T),
              d_wasted_votes = sum(d_wasted_votes, na.rm = T),
              r_wasted_votes = sum(r_wasted_votes, na.rm = T),
              total_votes = sum(total_votes, na.rm = T),
              efficiency = (sum(d_wasted_votes, na.rm = T) - sum(r_wasted_votes, na.rm = T)) / sum(total_votes, na.rm = T) * -1) %>% 
    mutate(name = state.name[match(state, state.abb)],
           net_wasted_votes = d_wasted_votes)
# write.csv(efficiencies, 'efficiencies_1.csv', row.names = F)

states <- geojsonio::geojson_read('http://eric.clst.org/wupl/Stuff/gz_2010_us_040_00_5m.json', what = 'sp')

save(states, file = 'states.RData')

states$efficiency <- efficiencies$efficiency[match(states$NAME, efficiencies$name)]

pal <- colorNumeric("RdBu", NULL)
leaflet(states) %>% 
    addPolygons(fillColor = ~pal(efficiency), fillOpacity = 1, smoothFactor = .3,
                opacity = 1, weight = 1, color = '#444444',
                label = ~paste0(NAME, ': ', round(efficiency, 3)),
                highlightOptions = highlightOptions(color = "white", weight = 2, bringToFront = TRUE))
