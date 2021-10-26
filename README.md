Country age vs COVID-19 deaths per capita 
=========================================

This data science projects performs some basic analysis comparing country age demographics to COVID-19 death rates. 

Country population by age data was downloaded from [UNdata](http://data.un.org/Data.aspx?d=POP&f=tableCode%3A22) for the year 2017 and COVID-19 data was downloaded from [Kaggle](https://www.kaggle.com/josephassaker/covid19-global-dataset). 

To run this code, build the docker container like this:

```
docker build . -t covid 
```

And then start and RStudio server like this: 

```
docker run -p 8080:8080 -p 8787:8787 -e PASSWORD=pw123 -v $(pwd):/home/rstudio/project -t covid
```

And visit http://localhost:8787 in your browser, log in in with user `rstudio` and password `pw123`. Navigate to the Terminal tab, and run:

```
cd project/
Rscript bios611_shiny.R
```

And once the terminal says `Listening on http://0.0.0.0:8080`, navigate to `http://localhost:8080` to view the interactive visualization. Here you can select any age group (such as "over_80", the proportion of the population over 80 years old) and any covid metric (such as "total_deaths_per_1m_population") to view the relationship between age and death rate. 