### BIOS 611 - HW10

### Load packages 
library(tidyverse)
library(dplyr)
library(shiny)
library(ggplot2)
library(plotly)


### Load data 
covid <- read_csv("worldometer_coronavirus_summary_data.csv")
demographics <- read_csv("UNdata_Export_2017.csv")

# rename columns for ease of use 
colnames(demographics) <- c("country", "year", "area", "sex", "age", "record_type", "reliability", "source_year", "value", "value_footnotes")


### Tidy data 
# Sorting data by number of data points associated with a given country shows us 
# that there are a few singletons that don't appear to represent countries at all, 
# so remove those:
country_counts <- demographics %>% count(country) %>% filter(n > 1)
demographics <- demographics %>% filter(country %in% country_counts$country)

# Remove non-ASCII characters and translate to camel case (to match up with covid data): 
simplify_strings <- function(s){
    s %>% 
        str_to_title() %>%
        str_trim() %>%
        str_replace_all("-"," ") %>%
        str_replace_all(",","") %>% 
        str_replace("\\s*\\([^\\)]+\\)", "") %>% # remove anything in parentheses 
        iconv(to='ASCII//TRANSLIT') # remove accented characters 
}

demographics$country <- simplify_strings(demographics$country)

### Filtering 
demographics <- demographics %>% filter(area == "Total", sex == "Both Sexes", 
  reliability == "Final figure, complete", nchar(age) > 3) %>%
  distinct(country, age, .keep_all = TRUE) %>%
  select(country, age, value)

# Pivot wide so that each column is the population for a specific age group: 
demo_wide <- demographics %>% pivot_wider(id_cols = country, names_from = age, values_from = value)

# Remove "unknown" column and redundant columns:
demo_wide <- demo_wide %>% select(-Unknown, -'1 - 4', -'0 - 14', -'15 - 64', -'95 - 98', 
                                  -'65 +', -'75 +', -'80 +', -'85 +', -'90 +',-'95 +', 
                                  -'99 +', -'100 +')


### Calculate metrics 
# Proportion of total population for each country that is over 40, 50, 60, 70, 80 
demo_wide <- demo_wide %>% rowwise() %>% 
  mutate(over_40 = sum(c_across('40 - 44':'110 +'), na.rm = TRUE)/Total) %>%
  mutate(over_50 = sum(c_across('50 - 54':'110 +'), na.rm = TRUE)/Total) %>%
  mutate(over_60 = sum(c_across('60 - 64':'110 +'), na.rm = TRUE)/Total) %>%
  mutate(over_70 = sum(c_across('70 - 74':'110 +'), na.rm = TRUE)/Total) %>%
  mutate(over_80 = sum(c_across('80 - 84':'110 +'), na.rm = TRUE)/Total) %>%
  ungroup()


### Join country data with covid data 
# Do an inner join, so the resulting table has countries which we have both 
# demographic and covid data for. 
combined <- inner_join(demo_wide, covid, by = "country")

# Which countries from the demographics data set weren't included in the join? 
demo_wide$country[which(!(demo_wide$country %in% combined$country))]

# Rename countries in demographics data set that don't match up with country names 
# in COVID-19 data set (didn't bother looking the other way, because there are several 
# countries in the COVID-19 dataset for which we wont' have demographic data): 
demo_wide$country[which(demo_wide$country == "Czechia")] <- "Czech Republic"
demo_wide$country[which(demo_wide$country == "Faroe Islands")] <- "Faeroe Islands"
demo_wide$country[which(demo_wide$country == "North Macedonia")] <- "Macedonia"
demo_wide$country[which(demo_wide$country == "Republic Of Moldova")] <- "Moldova"
demo_wide$country[which(demo_wide$country == "Republic Of South Sudan")] <- "Sudan"
demo_wide$country[which(demo_wide$country == "United Kingdom Of Great Britain And Northern Ireland")] <- "UK"
demo_wide$country[which(demo_wide$country == "United States Of America")] <- "USA"

# Re-do the join: 
rm(combined)
combined <- inner_join(demo_wide, covid, by = "country")


### Launch shiny app 
shinyApp(
  ui = fluidPage(
    titlePanel("Country demographics vs. COVID-19 deaths by age"),
    
    sidebarLayout(
      sidebarPanel(
        varSelectInput(inputId="x_variable",
                       label="Variable (x):",
                       combined,
                       multiple=F),
        varSelectInput(inputId="y_variable",
                       label="Variable (y):",
                       combined,
                       multiple=F)
      ),
      mainPanel(
        plotlyOutput(outputId = "plot1")
      )
    )
  ),
  
  server = function(input, output) {
    output$plot1 <- renderPlotly({
      
      ggplot(combined, aes(!!input$x_variable, !!input$y_variable)) + geom_point()

    })
  },
  
  options=list(port=8080, host="0.0.0.0")
)

