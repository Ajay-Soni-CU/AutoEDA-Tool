library(shiny)
library(ggplot2)

#################################################################################
summary_fn<-function(data,selected_features){
  data<-data[selected_features]
  summary_data<-data.frame(
    Feature=colnames(data),
    Min=sapply(data,function(x) if(is.numeric(x)) summary(x)[1] else NA),
    Median=sapply(data,function(x) if(is.numeric(x)) summary(x)[3] else NA),
    Mean=sapply(data,function(x) if(is.numeric(x)) mean(x,na.rm=TRUE) else NA),
    Max=sapply(data,function(x) if(is.numeric(x)) summary(x)[6] else NA),
    StdDev=sapply(data,function(x) if(is.numeric(x)) sd(x,na.rm=TRUE) else NA),
    Variance=sapply(data,function(x) if(is.numeric(x)) var(x,na.rm=TRUE) else NA),
    MissingValues=sapply(data,function(x) sum(is.na(x)))
  )
  return(summary_data)
}

outlier_fn<-function(data,feature){
  ggplot(data,aes(x="",y=.data[[feature]]))+
    geom_boxplot(
      outlier.colour="red",
      outlier.shape=16,
      outlier.size=2,
      fill="skyblue",
      color="black")+
    labs(
      title=paste("Outlier Detection for",feature),
      x="Feature",y="Values"
    )+
    theme_minimal(base_size=14)
}

total_outlier<-function(data,feature){
  values<-data[[feature]]
  
  Q1<-quantile(values,0.25,na.rm=TRUE)
  Q3<-quantile(values,0.75,na.rm=TRUE)
  IQR<-Q3-Q1
  
  lower_bound<-Q1-1.5*IQR
  upper_bound<-Q3+1.5*IQR
  
  outliers<-sum(values<lower_bound|values>upper_bound,na.rm=TRUE)
  
  return(outliers)
}

dist_fn<-function(data,feature){
  ggplot(data,aes(x=.data[[feature]]))+
    geom_density(alpha=0.5,fill="blue",color="black")+
    labs(
      title=paste("Density Plot of",feature),
      x=feature,
      y="Density"
    )
}

data_fn<-function(data){
  result<-data.frame(
    Feature=colnames(data),
    Data_Type=sapply(data,class),
    row.names=NULL
  )
  return(result)
}

correlation_fn<-function(data,feature1,feature2){
  cor_value<-cor(data[[feature1]],data[[feature2]],use="complete.obs")
  return(data.frame(Feature1=feature1,Feature2=feature2,Correlation=cor_value))
}

#################################################################################

ui<-fluidPage(
  tags$head(
    tags$style(
      HTML("
        :root {
          --primary: #2c3e50;
          --secondary: #3498db;
          --success: #27ae60;
          --danger: #e74c3c;
          --warning: #f39c12;
          --light: #ecf0f1;
          --dark: #2c3e50;
        }
        
        body {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          min-height: 100vh;
        }
        
        .main-container {
          background: white;
          border-radius: 15px;
          box-shadow: 0 10px 30px rgba(0,0,0,0.2);
          margin: 20px auto;
          padding: 0;
          overflow: hidden;
          max-width: 1400px;
        }
        
        .title-panel {
          background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
          color: white;
          padding: 25px;
          text-align: center;
          margin-bottom: 0;
        }
        
        .title-panel h1 {
          font-weight: 700;
          font-size: 2.5em;
          margin: 0;
          text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        
        .title-panel h4 {
          font-weight: 300;
          margin: 5px 0 0 0;
          opacity: 0.9;
        }
        
        .sidebar {
          background: var(--light);
          padding: 25px;
          border-right: 3px solid var(--secondary);
          height: 100%;
          min-height: 90vh;
        }
        
        .main-content {
          padding: 25px;
          background: white;
          min-height: 90vh;
        }
        
        .section {
          background: white;
          border-radius: 10px;
          padding: 20px;
          margin-bottom: 25px;
          box-shadow: 0 4px 6px rgba(0,0,0,0.1);
          border-left: 4px solid var(--secondary);
        }
        
        .section h3 {
          color: var(--primary);
          border-bottom: 2px solid var(--light);
          padding-bottom: 10px;
          margin-top: 0;
        }
        
        .btn-custom {
          width: 100%;
          padding: 12px;
          font-weight: 600;
          border: none;
          border-radius: 8px;
          transition: all 0.3s ease;
          margin: 5px 0;
        }
        
        .btn-start {
          background: linear-gradient(135deg, var(--success) 0%, #2ecc71 100%);
          color: white;
        }
        
        .btn-start:hover {
          transform: translateY(-2px);
          box-shadow: 0 5px 15px rgba(39, 174, 96, 0.4);
        }
        
        .btn-reload {
          background: linear-gradient(135deg, var(--warning) 0%, #f1c40f 100%);
          color: white;
        }
        
        .btn-reload:hover {
          transform: translateY(-2px);
          box-shadow: 0 5px 15px rgba(243, 156, 18, 0.4);
        }
        
        .checkbox-group {
          background: white;
          padding: 15px;
          border-radius: 8px;
          border: 2px solid var(--light);
        }
        
        .checkbox-group label {
          font-weight: 500;
          color: var(--dark);
          margin: 8px 0;
        }
        
        .file-input {
          background: white;
          padding: 15px;
          border-radius: 8px;
          border: 2px dashed var(--secondary);
          text-align: center;
        }
        
        .feature-card {
          background: var(--light);
          padding: 15px;
          border-radius: 8px;
          margin: 10px 0;
          border-left: 4px solid var(--secondary);
        }
        
        .result-box {
          background: #f8f9fa;
          padding: 15px;
          border-radius: 8px;
          border: 1px solid #dee2e6;
          margin: 10px 0;
        }
        
        .plot-container {
          background: white;
          padding: 15px;
          border-radius: 8px;
          border: 2px solid var(--light);
          margin: 15px 0;
        }
        
        .footer {
          text-align: center;
          padding: 20px;
          background: var(--primary);
          color: white;
          margin-top: 30px;
          border-radius: 0 0 10px 10px;
        }
        
        .footer h4 {
          margin: 0;
          font-weight: 300;
        }
        
        .feature-selector {
          background: white;
          border: 2px solid var(--light);
          border-radius: 8px;
          padding: 10px;
          margin: 10px 0;
        }
      ")
    )
  ),
  
  div(class="main-container",
      div(class="title-panel",
          h1("Auto EDA Tool"),
          h4("Comprehensive Exploratory Data Analysis Made Simple")
      ),
      
      fluidRow(
        column(4, class="sidebar",
               div(class="file-input",
                   h4("📁 Upload Your Data", style="color: var(--primary);"),
                   fileInput("CSV", "Choose CSV File:", 
                             accept = c(".csv"), 
                             buttonLabel = "Browse...",
                             placeholder = "No file selected")
               ),
               
               br(),
               
               div(class="checkbox-group",
                   h4("🔧 EDA Tasks", style="color: var(--primary);"),
                   checkboxGroupInput(
                     inputId="eda_options",
                     label=NULL,
                     choices=c(
                       "Plotting (Necessary)" = "Plotting (Necessary)",
                       "Summarizing Data" = "Summarizing Data",
                       "Identifying Outliers" = "Identifying Outliers",
                       "Data Types" = "Data Types",
                       "Correlation Analysis" = "Correlation Analysis",
                       "Data Distributions" = "Data Distributions"
                     ),
                     selected = "Plotting (Necessary)"
                   )
               ),
               
               br(),
               
               div(class="action-buttons",
                   actionButton("start", "🚀 START ANALYSIS", class="btn-custom btn-start"),
                   br(),
                   actionButton("reload", "🔄 RELOAD ANALYSIS", class="btn-custom btn-reload")
               )
        ),
        
        column(8, class="main-content",
               uiOutput("dynamic_content"),
               
               div(class="footer",
                   h4("R Programming Project Made by Ajay")
               )
        )
      )
  )
)

server<-function(input,output,session){
  
  output$dynamic_content <- renderUI({
    if(is.null(input$CSV)) {
      return(
        div(class="section",
            h3("Welcome to Auto EDA Tool"),
            p("Please upload a CSV file to begin your exploratory data analysis."),
            p("This tool will help you:"),
            tags$ul(
              tags$li("Explore data distributions and patterns"),
              tags$li("Identify outliers and anomalies"),
              tags$li("Understand data types and correlations"),
              tags$li("Generate comprehensive summaries")
            ),
            br(),
            p("📊 Select your desired EDA tasks from the sidebar and click 'START ANALYSIS' when ready.")
        )
      )
    }
  })
  
  observeEvent(input$start,{
    req(input$CSV)
    data<-read.csv(input$CSV$datapath)
    
    output$dynamic_content <- renderUI({
      tagList(
        # Plotting Section
        if("Plotting (Necessary)" %in% input$eda_options) {
          div(class="section",
              h3("📊 Data Visualization"),
              div(class="feature-selector",
                  fluidRow(
                    column(6,
                           selectInput(
                             inputId="feature1",
                             label="Select feature for histogram:",
                             choices=colnames(data),
                             selected=colnames(data)[1]
                           )
                    ),
                    column(6,
                           selectInput(
                             inputId="feature2_x",
                             label="X-axis feature for scatter plot:",
                             choices=colnames(data),
                             selected=colnames(data)[1]
                           ),
                           selectInput(
                             inputId="feature2_y",
                             label="Y-axis feature for scatter plot:",
                             choices=colnames(data),
                             selected=colnames(data)[2]
                           )
                    )
                  ),
                  actionButton("plot", "Generate Plots", class="btn-custom", 
                               style="background: var(--secondary); color: white;")
              ),
              uiOutput("plot_ui")
          )
        },
        
        # Summary Section
        if("Summarizing Data" %in% input$eda_options) {
          div(class="section",
              h3("📈 Data Summary"),
              div(class="feature-selector",
                  selectInput("selected_features","Select features to summarize:",
                              choices=colnames(data),
                              multiple=TRUE,
                              selected=colnames(data)[1:min(3, ncol(data))]),
                  actionButton("summarize", "Generate Summary", class="btn-custom",
                               style="background: var(--success); color: white;")
              ),
              div(class="result-box",
                  tableOutput("summary_show")
              )
          )
        },
        
        # Outlier Section
        if("Identifying Outliers" %in% input$eda_options) {
          div(class="section",
              h3("🔍 Outlier Detection"),
              div(class="feature-selector",
                  selectInput("outlier_feature","Select feature for outlier analysis:",
                              choices=colnames(data)),
                  actionButton("detect_outliers", "Detect Outliers", class="btn-custom",
                               style="background: var(--danger); color: white;")
              ),
              uiOutput("outlier_count")
          )
        },
        
        # Data Types Section
        if("Data Types" %in% input$eda_options) {
          div(class="section",
              h3("🔤 Data Types"),
              div(class="result-box",
                  tableOutput("table")
              )
          )
        },
        
        # Correlation Section
        if("Correlation Analysis" %in% input$eda_options) {
          div(class="section",
              h3("📐 Correlation Analysis"),
              div(class="feature-selector",
                  fluidRow(
                    column(6,
                           selectInput(
                             inputId="feature_corr1",
                             label="First feature:",
                             choices=colnames(data),
                             selected=colnames(data)[1]
                           )
                    ),
                    column(6,
                           selectInput(
                             inputId="feature_corr2",
                             label="Second feature:",
                             choices=colnames(data),
                             selected=colnames(data)[2]
                           )
                    )
                  ),
                  actionButton("calc_correlation", "Calculate Correlation", class="btn-custom",
                               style="background: var(--warning); color: white;")
              ),
              div(class="result-box",
                  tableOutput("correlation_result")
              )
          )
        },
        
        # Distribution Section
        if("Data Distributions" %in% input$eda_options) {
          div(class="section",
              h3("📶 Data Distributions"),
              div(class="feature-selector",
                  selectInput("distribution_feature","Select feature for distribution analysis:",
                              choices=colnames(data)),
                  actionButton("distribution_btn", "Show Distribution", class="btn-custom",
                               style="background: var(--secondary); color: white;")
              ),
              div(class="plot-container",
                  plotOutput("dist_plot")
              )
          )
        }
      )
    })
    
    # Plotting Logic
    if("Plotting (Necessary)" %in% input$eda_options) {
      observeEvent(input$plot,{
        output$plot_ui<-renderUI({
          tagList(
            fluidRow(
              column(6, 
                     div(class="plot-container",
                         h4(paste("Histogram of", input$feature1)),
                         plotOutput("hist_plot")
                     )
              ),
              column(6,
                     div(class="plot-container", 
                         h4(paste("Scatter Plot:", input$feature2_x, "vs", input$feature2_y)),
                         plotOutput("scatter_plot")
                     )
              )
            )
          )
        })
        
        output$hist_plot<-renderPlot({
          hist(data[[input$feature1]],
               main="",
               xlab=input$feature1,
               col="skyblue", border="white",
               breaks=20)
        })
        
        output$scatter_plot<-renderPlot({
          plot(data[[input$feature2_x]], data[[input$feature2_y]],
               main="",
               xlab=input$feature2_x,
               ylab=input$feature2_y,
               pch=19, col="darkgreen")
        })
      })
    }
    
    # Summary Logic
    if("Summarizing Data" %in% input$eda_options) {
      observeEvent(input$summarize,{
        output$summary_show<-renderTable({
          summary_fn(data, input$selected_features)
        })
      })
    }
    
    # Outlier Logic
    if("Identifying Outliers" %in% input$eda_options) {
      observeEvent(input$detect_outliers,{
        output$outlier_count<-renderUI({
          outliers<-total_outlier(data, input$outlier_feature)
          tagList(
            div(class="result-box",
                h4("Outlier Summary"),
                p(paste("Total outliers in", input$outlier_feature, ":", outliers)),
                plotOutput("outlier_plot")
            )
          )
        })
        
        output$outlier_plot<-renderPlot({
          outlier_fn(data, input$outlier_feature)
        })
      })
    }
    
    # Data Types Logic
    if("Data Types" %in% input$eda_options) {
      output$table<-renderTable({
        data_fn(data)
      })
    }
    
    # Correlation Logic
    if("Correlation Analysis" %in% input$eda_options) {
      observeEvent(input$calc_correlation,{
        output$correlation_result<-renderTable({
          correlation_fn(data, input$feature_corr1, input$feature_corr2)
        })
      })
    }
    
    # Distribution Logic
    if("Data Distributions" %in% input$eda_options) {
      observeEvent(input$distribution_btn,{
        output$dist_plot<-renderPlot({
          dist_fn(data, input$distribution_feature)
        })
      })
    }
  })
  
  observeEvent(input$reload, {
    session$reload()
  })
  
}

shinyApp(ui, server)
