options(shiny.maxRequestSize=30*1024^2)

# Define server logic to read selected file ----
server <- function(input, output) {
  
  output$labels <- renderUI({
    
    req(input$file1)
    
    df <- read.csv(input$file1$datapath,
                   header = input$header,
                   sep = ",",
                   quote = '"')
    attributes=names(df)
    names(attributes)=attributes
    selectInput("Label", "Select Label:",attributes)
    
  })
  
  output$contents <- renderTable({
    
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, head of that data file by default,
    # or all rows if selected, will be shown.
    
    req(input$file1)
    
    df <- read.csv(input$file1$datapath,
                   header = input$header,
                   sep = ",",
                   quote = '"')
    
    #if(input$disp == "head") {
      return(head(df))
    #}
    #else {
    #  return(df)
    #}
    
    data <- data_raw[complete.cases(df),]
    data_label <- as.numeric(data$Label)
    
    sample_size <- floor(0.75 * nrow(data))
    set.seed(123)
    train_ind <- sample(seq_len(nrow(data)), size = sample_size)
    
    train <- data[train_ind, ]
    test <- data[-train_ind, ]
    
    datafull <- as(as.matrix(data[ , -which(names(data) %in% c("App"))]), "dgCMatrix")
    
    train_label <- as.numeric(train$App)
    train <- as(as.matrix(train[ , -which(names(train) %in% c("App"))]), "dgCMatrix")
    test_label <- as.numeric(test$App)
    test <- as(as.matrix(test[ , -which(names(test) %in% c("App"))]), "dgCMatrix")
    
    dtrain <- xgb.DMatrix(data = train, label=train_label)
    dtest <- xgb.DMatrix(data = test, label=test_label)
    
    watchlist <- list(train=dtrain, test=dtest)
    
  })
  
}
