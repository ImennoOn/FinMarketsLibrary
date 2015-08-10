###################################
# UI functions
# 
# thertrader@gmail.com - June 2014
###################################

theDates <- seq(as.Date("2012-01-01"),as.Date("2014-12-30"),by="months")

shinyUI(
  fluidPage(
    headerPanel(""),
    
    sidebarPanel(
      selectInput("strategy", 
                  "Strategy:", 
                  choices = c("ETF","Equity Bond Allocation","Equity Index","FX Price Action","Portfolio"),
                  selected = "ETF"),
      
      selectInput("startDate", 
                  "Start:", 
                  choices = theDates),
      
      selectInput("endDate", 
                  "End:", 
                  choices = theDates,
                  selected = theDates[length(theDates)]), 
      
      div(HTML("<br>This app was created by <a href='http://thertrader.com' target='_blank'>the R Trader</a>.
               <br>Powered by <a href='http://shiny.rstudio.com/' target='_blank'>Shiny</a>"))
      ),
    
    mainPanel(  
      tabsetPanel(
        ## OVERVIEW
        tabPanel("Overview", plotOutput("plot1",height = 550, width = 550)),
        
        ## TRADING STATISTICS
        tabPanel("Trading Statistics",
                 fixedRow(
                   column(8,
                          fixedRow(column(4,tableOutput("tablePerformance")),
                                   column(4,tableOutput("tableRisk"))),
                          fixedRow(column(4,tableOutput("tableDaily")),
                                   column(4,tableOutput("tableMonthly"))))
                 )
        ),
        ## RISK
        tabPanel("Risk",plotOutput("plot2",height = 550, width = 550)),
        
        ## HOW TO
        tabPanel("How To",
                 HTML("<p> This Shiny application is designed to help analysing trading strategies. It is an ongoing project that I improve when time allows. Feel free to get in touch should you have any suggestion.</p>
                      
                      <b>How to use the App as it is?</b>
                      <p>The App uses as input 3 csv files one for each strategy. Each has at least two columns: date and daily return. There is an example of such a file in the <a href='https://gist.github.com/thertrader/8e777452b8e0e10320ee' target='_blank'>Github</a> repository. The code is essentially made of 3 files.</p>
                      <li><i>ui.R</i>:  controls the layout and appearance of the app</li>
                      <li><i>server.R</i>: contains the instructions needed to build the app. You can load as much strategies as you want as long as the corresponding csv file has the right format (see below).</li>
                      <li><i>shinyStrategyGeneral.R</i>: loads the required packages and launches the app</li>
                      <p>put ui.R and server.R file in a separate directory</p>
                      <p>In the server.R file change the inputPath, inputFile and keepColumns parameters to match your setting. The first two are self explanatory the third one is a list of column names within the csv file. Keep only date and daily return.</p>
                      
                      <b>How to add a trading strategy?</b>
                      <li>Create the corresponding csv file</li>
                      <li>Create a new input in the data reactive function (within the server.R file)</li>
                      <li>Add an extra element to the choice parameter in the first selectInput in the sidebarPanel (within the ui.R file). The element's name should match the name of the new input above.</li>

<p></p>
<b>How to remove a trading strategy?</b>
<li>Remove the input in the data reactive function corresponding to the strategy you want to remove (within the server.R file)</li>
<li>Remove the element in the choice parameter in the first selectInput in the sidebarPanel corresponding to the strategy you want to remove (within the ui.R file).</li>
                    "))
      )  
  )
))

