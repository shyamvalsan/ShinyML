
# Define UI for data upload app ----
ui <- fluidPage(
  # App title ----
  titlePanel("ShinyML - machine learning anywhere, anytime!"),
  
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
      helpText("Choose label before you click train - for large files this might take some time."),
      tags$hr(),
      downloadButton("downloadModel", "Download Model"),
      helpText("Download will be available once training is completed.")
     ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      h3("Results"),
      HTML('<br/>'),
      h4(textOutput("text_acc")),
      h4(textOutput("text_kap")),
      HTML('<br/>'),
      h4("Confusion Matrix"),
      dataTableOutput("table"),
      h4("Test Loss vs Train Loss"),
      plotOutput("plot")
     
    )
  ),
  
  conditionalPanel(
    condition = "input.do_train % 2 == 0",
    column(4),
    column(4,
    h3("Instructions"),
    HTML('<strong>1. Prepare your csv file for training.</strong>'),HTML('</br>'),
    "    - The file MUST be less than 300MB in size",HTML('</br>'),
    "    - The file MUST contain headers for every column",HTML('</br>'),
    "    - The file MUST contain only numeric data, please transform strings to numeric values",HTML('</br>'),HTML('</br>'),
    HTML('<strong>2. Upload your csv file and wait till the options to select label and model appear.</strong>'),HTML('</br>'),
    "    - This might take some time even after the upload progress bar hits 100% for large files",HTML('</br>'),HTML('</br>'),
    HTML('<strong>3. Select the label you are trying to predict.</strong>'),HTML('</br>'),
    "    - This works for classification OR regression",HTML('</br>'),HTML('</br>'),
    HTML('<strong>4. Select the model you want to use.</strong>'),HTML('</br>'),
    "    - As of now, XGBoost is the only available choice. More models will be added in the future",HTML('</br>'),HTML('</br>'),
    HTML('<strong>5. Click Train to train the model on your data.</strong>'),HTML('</br>'),
    "    - This might take up to a few minutes for a large dataset",HTML('</br>'),
    "    - The input csv is split into train (75%) and test (25%) to measure the model performance",HTML('</br>'),HTML('</br>'),
    HTML('<strong>6. Observe the results.</strong>'),HTML('</br>'),
    "    - Accuracy and Kappa scores are printed",HTML('</br>'),
    "    - The confusion matrix is also printed, showing the false positives and negatives for each class",HTML('</br>'),
    "    - For binary classification, there will only be two classes",HTML('</br>'),
    "    - The test loss vs train loss plot helps you understand if overfitting or underfitting is taking place",HTML('</br>'),
    "    - Test loss is the green line, train loss is the red line",HTML('</br>'),HTML('</br>'),
    "    - Lower the test loss, better the model",HTML('</br>'),HTML('</br>'),
    HTML('<strong>7. Download the model.</strong>'),HTML('</br>'),
    "    - Click the download model button to download a binary of your trained model",HTML('</br>'),
    "    - This model file can be read by XGBoost running on C++/Python/R to make predictions",HTML('</br>'),HTML('</br>'),HTML('</br>'),
    HTML('<strong>TO DO LIST</strong>'),HTML('</br>'),HTML('</br>'),
    "    - Make the UI prettier, fix the layout, move the help to a cleaner visible section",HTML('</br>'),
    "    - Add support for BayesNet, RandomForest",HTML('</br>'),
    "    - Add support for BayesNet, RandomForest",HTML('</br>'),
    "    - Add progress indicator for model training, right now it doesn't look like it's doing anything",HTML('</br>'),
    "    - Add more performance indicators and clean up the confusion matrix display",HTML('</br>'),
    "    - Add controls to tune hyperparameters",HTML('</br>'),
    "    - To add a TO DO to the list, contact svalsan@sandvine.com'",HTML('</br>'),HTML('</br>')
  )
  )
)

