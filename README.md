Speed Shiny Shortlister
-----------------------

David Selby  
david.selby@manchester.ac.uk  
December 2020

-----------------------

Before running the Shiny app, make sure to add all your candidate names to the `candidate_names.txt` file - one per line.

You can run a Shiny app by opening either the `server.R` or `ui.R` files in RStudio and clicking "Run App".
Alternatively (if you don't use RStudio), in the R command line, enter the code:
```r
shiny::runApp('/path/to/shortlister')
```

If adapting this to a different job role, please also edit the file `criteria.csv` with the descriptions (and number) of essential job criteria.

Probably, I will add more functionality to this at some point in the future (but don't count on it). No warranty is provided.

