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
  
  model <- eventReactive(input$do_train, {
    req(input$file1) 
    req(input$label)
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
    globalModel <<- xgbModel
    test_pred <- predict(xgbModel, newdata = test)
    cMatrix <<- confusionMatrix(test_pred, test_label)
    acc <- cMatrix$overall[1]
    kap <- cMatrix$overall[2]
    tab <- as.matrix(cMatrix$table)
    
    eval_log <- xgbModel$evaluation_log
    x  <- eval_log$iter
    y1 <- eval_log$train_merror
    y2 <- eval_log$test_merror
    df <- data.frame(x,y1,y2)
    require(ggplot2)
    
    ggplot(df, aes(x)) +                    # basic graphical object
      geom_line(aes(y=y1), colour="red") +  # first layer
      geom_line(aes(y=y2), colour="green")  # second layer
    g <- ggplot(df, aes(x))
    g <- g + geom_line(aes(y=y1), colour="red")
    g <- g + geom_line(aes(y=y2), colour="green")
    g <- g + ylab("Y") + xlab("X")
    
    list(acc = acc, kap = kap, tab = tab, plot = g)
  })
  
  output$text <- renderText({
    out <- paste0("Accuracy: ", model()$acc,"\n","Kappa: ", model()$kap)
    print(out)
    out
  })

  output$table <- renderTable({
    model()$tab
  })
  
  output$plot <- renderPlot({
    model()$plot
  })
  
  output$downloadModel <- downloadHandler(
  #  if (globalModel == "") {
  #    
  #  }
    filename = function() {
      paste(input$file1, ".model", sep = "")
    },
    content = function(file) {
      #write.csv(datasetInput(), file, row.names = FALSE)
      xgb.save(globalModel, file)
    }
  )
  
}