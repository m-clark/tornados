library(readr)
tornados = read_csv('data/All_tornadoes1950_2015.csv', col_names=F, col_types=cols(X6='t', X14='n', X15='n'))
colnames(tornados) = c('Number','Year','Month', 'Day', 'Date','Time', 'Timezone', 'State',
                       'StateFips','StateNumber', 'Fscale','Injuries','Fatalities',
                       'PropertyLoss','CropLoss','StartLat','StartLon','EndLat','EndLon',
                       'LengthinMiles','WidthinYards','NumberStatesAffected','StateNumber2',
                       'SegmentNumber','County1Fips','County2Fips','County3Fips','County4Fips','Wind')

summary(tornados)
str(tornados)
tornados


# Note, there are many, many issues with this data
for(i in c('StartLat','StartLon','EndLat','EndLon')){
  tornados[tornados[,i]==0,i] = NA
}


library(leaflet)
library(dplyr)
library(wesanderson)
# fscaleColor = colorFactor(as.character(wes_palette(name='Cavalcanti', type='discrete', n=6)), factor(tornados$Fscale))
# fscaleColor = colorFactor(rainbow(6), factor(tornados$Fscale))
fscaleColor = colorFactor(RColorBrewer::brewer.pal(6, 'Reds'), factor(tornados$Fscale))

leaflet(filter(tornados, !is.na(StartLon))) %>%  # because leaflet doesn't know how to deal with NAs
  addTiles() %>%
  addCircles(~StartLon, ~StartLat, radius=1, color=~fscaleColor(Fscale), fillOpacity=.05)


library(ggplot2); library(GGally)

library(plotly)


# geo styling

g <- list(
  scope = 'usa',
  projection = list(type = 'albers usa'),
  showland = TRUE,
  landcolor = toRGB("gray99"),
  subunitcolor = toRGB("gray85"),
  countrycolor = toRGB("gray85"),
  countrywidth = 0.25,
  subunitwidth = 0.25
)


# geocode place names at some point?
# reverse_geocode_coords(tornados$StartLat, tornados$StartLon)

m <- list(colorbar = list(title = "F Scale"),  opacity = 0.05,
          symbol = 'dot', size=tornados$Size, colors='Reds')

# note that rstudio will not display this, but saving as webpage will
tornado_plot = plot_ly(tornados, lat = StartLat, lon = StartLon,
                       hoverinfo='none', colors='Reds',
                       type = 'scattergeo', locationmode = 'USA-states', mode = 'markers',
                       marker = m) %>%
  layout(title = 'Tornados 1950-2015', geo = g)


save(tornados, tornado_plot, file='data/tornados.RData')
