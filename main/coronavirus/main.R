suppressWarnings(library(leaflet))
suppressWarnings(library(htmlwidgets))
suppressWarnings(library(beepr))
suppressWarnings(library(rio))
suppressWarnings(library(tidyverse))
suppressWarnings(library(zoo))

setwd("C:/Users/Wenyao/Desktop/R/R/output/coronavirus")
set.seed(350)

#===== load data =====
coronavirus_raw <- import("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv")

# format data
coronavirus <- coronavirus_raw %>% 
  mutate(
    id = if_else(
      `Province/State` == "",
      `Country/Region`,
      paste0(`Province/State`, " @ ", `Country/Region`)
    ),
    display_name = if_else(
      `Province/State` == "",
      `Country/Region`,
      `Province/State`
    )
  ) %>% 
  select(-`Province/State`, -`Country/Region`) %>% 
  gather(date, cases, -id, -Lat, -Long, -display_name) %>% 
  mutate(
    date = as.Date(date, format = "%m/%d/%y"),
    
    # smooth scale for better visualization effect
    p_norm = pnorm(cases, mean = mean(cases), sd = sd(cases)),
    size = 10 + (p_norm - min(p_norm)) / (max(p_norm) - min(p_norm)) * 90
  )


#===== plot on map =====
# initialize
output <- leaflet(
  options = leafletOptions(minZoom = 3, maxZoom = 6)
) %>% 
  addTiles() %>% 
  setView(lng = 100, lat = 35, zoom = 4) %>% 
  setMaxBounds(lng1 = -180, lat1 = -90, lng2 = 180, lat2 = 90)

# plot group by date
all_dates <- unique(coronavirus$date)
for(a_date in all_dates){
  print(as.Date(a_date))
  output <- output %>%
    addCircleMarkers(
      data = coronavirus %>% 
        filter(date == as.Date(a_date)) %>% 
        filter(cases != 0),
      lng = ~Long, 
      lat = ~Lat,
      radius = ~size,
      stroke = FALSE, 
      color = "red",
      fillOpacity = 0.4,
      label = ~paste0(display_name, ": ", cases, " cases confirmed"),
      labelOptions = labelOptions(noHide = FALSE, textsize = "20px"),
      group = as.character(as.Date(a_date))
    )
  
  # hide everything except the first date's data (initially)
  if(a_date != all_dates[1]){
    output <- output %>% 
      hideGroup(as.character(as.Date(a_date)))
  }
}

# add control panel
output <- output %>% 
  addLayersControl(
    overlayGroups = as.character(all_dates),
    options = layersControlOptions(collapsed = TRUE)
  ) 

# let the animation autoplay on load
source("../../main/coronavirus/js_code.R", echo = TRUE)
output <- output %>% 
  onRender(
    jsCode = js_code
  )


#===== save =====
saveWidget(output, file = "map.html")

# play sound when finished
beep(sound = 2)