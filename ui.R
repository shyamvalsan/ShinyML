
# Define UI for data upload app ----
ui <- fluidPage(
  # App title ----
  titlePanel("ShinyML"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Select a file ----
      fileInput("file1", "Choose CSV File",
                multiple = TRUE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")),
      
      # Horizontal line ----
      tags$hr(),
      
      # Label selector
      uiOutput("choose_label"),
      uiOutput("models"),
      # Input: Checkbox if file has header ----
      #checkboxInput("header", "Header", TRUE),
     
      # Horizontal line ----
      tags$hr(),
      actionButton("do_train", "Train"),
      tags$hr(),
      downloadButton("downloadModel", "Download Model"),
      helpText("Download will be available once training is completed.")
     ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      textOutput("text"),
      tableOutput("table"),
      plotOutput("plot")
     
    )
    
  )
)

