options(shiny.maxRequestSize=30*1024^2)
server <- function(input, output) {
  
  values <- reactiveValues()
  
  selectedLabel <- reactive({
    req(input$file1)
    file1 <<- read.csv(input$file1$datapath, header = input$header, sep = ",", quote = '"')
    attributes=names(file1)
    names(attributes)=attributes
    selectInput("label", "Select Label:",attributes)
  })
  
  output$choose_label <- renderUI({ selectedLabel() })
  
  output$models <- renderUI({
    req(input$file1)
    selectInput("model", "Select Model:", choices = "XGBoost")
  })
  
  output$contents <- renderPrint({
    req(input$file1) 
    req(input$label)
    #file1 <- read.csv(input$file1$datapath, header = input$header, sep = ",", quote = '"')    
    #return(head(file1))
    data <- file1[complete.cases(file1),]
    data_label <- as.numeric(data[,input$label])  
    sample_size <- floor(0.75 * nrow(data))
    set.seed(123)
    train_ind <- sample(seq_len(nrow(data)), size = sample_size)
    
    train <- data[train_ind, ]
    test <- data[-train_ind, ]
    
    datafull <- as(as.matrix(data[ , -which(names(data) %in% input$label)]), "dgCMatrix")
    
    train_label <- as.numeric(train[,input$label])
    train <- as(as.matrix(train[ , -which(names(train) %in% c(input$label))]), "dgCMatrix")
    test_label <- as.numeric(test[,input$label])
    test <- as(as.matrix(test[ , -which(names(test) %in% input$label)]), "dgCMatrix")
    
    dtrain <- xgb.DMatrix(data = train, label=train_label)
    dtest <- xgb.DMatrix(data = test, label=test_label)    
    watchlist <- list(train=dtrain, test=dtest)
    
    xgbModel <- xgb.train(data = dtrain, max.depth = 10, eta = 0.2, nthread = 2, num_class = 7, nround = 8, watchlist=watchlist, objective = "multi:softmax")
    test_pred <- predict(xgbModel, newdata = test)
    cMatrix <<- confusionMatrix(test_pred, test_label)
    
    return(cMatrix$overall)
  })
  
  newEntry <- observe({ # use observe pattern
    
    req(input$file1)
    #file1 <- read.csv(input$file1$datapath, header = input$header, sep = ",", quote = '"')        
    #isolate(values$df <- input$label)
    data <- file1[complete.cases(file1),]
    data_label <- as.numeric(data[,input$label])  
    
  })
  output$out <- renderText(paste0("Label: ",input$label))
  
  output$contents1 <- renderTable({
    req(input$file1)
    req(input$label)
    return(cMatrix$table)
  })
}