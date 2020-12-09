# A tool to aid recruiting.
#
# By David Selby
# david.selby@manchester.ac.uk
#
# 8 December 2020
#
# TODO: if some responses already exist, load that data and use it to populate
# fields in the form. Then, on save, have the option to overwrite existing data.

library(shiny)
library(purrr)

shinyServer(function(input, output, session) {
    
    # Data
    criteria_text <- transform(read.csv('criteria.csv'),
                               Essential = Essential == 'Yes')
    cncon <- file('candidate_names.txt', encoding = 'UTF-8')
    candidate_names <- readLines(cncon)
    close(cncon)
    
    output$candidate_selector <- renderUI(
        selectInput('candidate_select',
                    'Applicant',
                    candidate_names)
    )
    
    output$debugCriteria <- renderTable(criteria_text)
    
    # Form layout
    output$criteria_form <- renderUI({
        map(1:nrow(criteria_text), ~ {
            list(
                hr(),

                p(strong(paste(sep = '. ',
                               criteria_text$CritID[.x],
                               criteria_text$Description[.x])),
                  if (criteria_text$Essential[.x])
                      strong('*', style = 'color:red')
                ),
                radioButtons(
                    paste0('criteria_met', .x),
                    label = NULL,
                    choices = c('Not met' = 0,
                                'Partly met' = 1,
                                'Fully met' = 2),
                    inline = TRUE
                ),
                textAreaInput(paste0('criteria_comment', .x),
                              NULL,
                              width = '100%',
                              placeholder = 'Comment')
            )
        })
    })
    
    # Save form data
    responses_dir <- 'responses'
    fields_scores <- paste0('criteria_met', seq_len(nrow(criteria_text)))
    fields_comments <- paste0('criteria_comment', seq_len(nrow(criteria_text)))
    
    form_data <- reactive({
        data <- data.frame(
            candidate_name = input$candidate_select,
            criterion = criteria_text$CritID,
            essential = criteria_text$Essential,
            met = map_chr(fields_scores, ~ input[[.x]]),
            comment = map_chr(fields_comments, ~ input[[.x]]),
            shortlist = input$add_shortlist,
            timestamp = as.integer(Sys.time())
        )
        data
    })
    
    save_data <- function(data) {
        filename <- 'responses.csv'
        filepath <- file.path(responses_dir, filename)
        write.table(data, file = filepath,
                    append = file.exists(filepath),
                    row.names = FALSE, quote = TRUE, sep = ',',
                    col.names = !file.exists(filepath))
    }
    
    reset_form <- function() {
        updateCheckboxInput(session, 'add_shortlist', value = FALSE)
        map(fields_comments, ~ updateTextAreaInput(session, .x, value = ''))
        map(fields_scores, ~ updateRadioButtons(session, .x, selected = 0))
    }
    
    observeEvent(input$submit, {
        # Save the form data to disk
        save_data(form_data())
        
        # Go to top of page
        shinyjs::runjs('scroll(0, 0)')
        
        # Move selector to next candidate
        # Return to the first candidate if we've reached the end.
        next_candidate <- which(candidate_names == input$candidate_select) + 1
        updateSelectInput(
            session, 'candidate_select',
            selected = if (next_candidate <= length(candidate_names))
                candidate_names[next_candidate] else candidate_names[1]
        )
        
        # Reset all form fields
        reset_form()

    })

})
