# https://mastering-shiny.org/action-dynamic.html

library(shiny)

shinyUI(fluidPage(
    titlePanel('Speedy Shiny Shortlister'),
    uiOutput('candidate_selector'),
    checkboxInput('add_shortlist', 'Add to shortlist?'),
    uiOutput('criteria_form'),
    shinyjs::useShinyjs(),
    actionButton('submit', 'Save to file', class = 'btn-primary'),
    hr(),
    conditionalPanel('false', # debugging
                     h3('Debugging'),
                     h4('Criteria text'),
                     tableOutput('debugCriteria'))
))
