###################################
# Server functions
# 
# thertrader@gmail.com - June 2014
###################################

library(knitr)
library(PerformanceAnalytics)
library(xtable)
library(xts)

shinyServer(function(input, output) {
  
  getData <- function(inputPath=inputPath,inputFile=inputFile,keepColumns=keepColumns){
    data <- read.csv(paste(inputPath,inputFile,sep=""),sep=",")
    keepColumns <- keepColumns
    dataDaily <- data[,keepColumns]
    colnames(dataDaily) <- c("date","rtn")
    days <- as.Date(dataDaily[,"date"],"%m/%d/%Y")
    dailyRtn <- as.numeric(substring(dataDaily[,"rtn"],1,nchar(as.character(dataDaily[,"rtn"]))-1)) ##
    return(list(date=days,rtn=dailyRtn))
  }
  
  data <- reactive({
    ### ETF
    if (input$strategy == "ETF"){
      dt <- getData(inputPath="./",
                    inputFile="mocRtnFile.csv",
                    keepColumns=c("date","rtn"))
    }
    ### EQUITY BOND ALLOCATION  
    if (input$strategy == "Equity Bond Allocation"){
      dt <- getData(inputPath="./",
                    inputFile="mocRtnFile.csv",
                    keepColumns=c("date","rtn"))
    }
    ### EQUITY INDEX  
    if (input$strategy == "Equity Index"){
      dt <- getData(inputPath="./",
                    inputFile="mocRtnFile.csv",
                    keepColumns=c("date","rtn"))
    }
    ### FX PRICE ACTION  
    if (input$strategy == "FX Price Action"){
      dt <- getData(inputPath="./",
                    inputFile="mocRtnFile.csv",
                    keepColumns=c("date","rtn"))
    }
    ### PORTFOLIO  
    if (input$strategy == "Portfolio"){
      dt <- getData(inputPath="./",
                    inputFile="mocRtnFile.csv",
                    keepColumns=c("date","rtn"))
    }
    return(dt)
  })
  
  output$plot1 <- renderPlot({
    data <- data()
    posStart <- min(which(as.Date(data$date,format="%Y-%m-%d") >= as.Date(input$startDate,format="%Y-%m-%d")))
    posEnd <- max(which(as.Date(data$date,format="%Y-%m-%d") <= as.Date(input$endDate,format="%Y-%m-%d")))
    
    if (posStart >= posEnd)
      stop("EndingDate must be > StartingDate")
    
    if (posStart < posEnd){
      x <- data$date[posStart:posEnd]
      y <- data$rtn[posStart:posEnd]
      
      drawdowns <- data.frame(y=y/100)
      rownames(drawdowns) <- x
      
      drawdowns <- table.Drawdowns(DJ.roc[,1])
      drawdowns.dates <- cbind(format(drawdowns$From),format(drawdowns$To))
      drawdowns.dates[is.na(drawdowns.dates)] <- format(index(DJ.roc)[NROW(DJ.roc)])
      
      xDD <- as.vector(findDrawdowns(drawdowns))
      
      par(mfrow=c(2,1),cex=0.9,mex=0.4)
      
      plot(x,cumsum(y),
           type="l",
           main=" Equity Curve (%)",
           xlab="",
           ylab="",
           col="royal blue",
           lwd=1.5)
      grid(col="dark grey")
      
      plot(x,100*xDD$to,
           type="l",
           xlab="",
           ylab="",
           main="DrawDowns (%)",
           col="royal blue",
           lwd=1.5)
      grid(col="dark grey")  
    }
  })
  
  output$plot2 <- renderPlot({
    # data <- dt
    # input <- NULL
    # input$startDate <- "2000-01-01"
    # input$endDate <- "2014-01-01"
    data <- data()
    posStart <- min(which(as.Date(data$date,format="%Y-%m-%d") >= as.Date(input$startDate,format="%Y-%m-%d")))
    posEnd <- max(which(as.Date(data$date,format="%Y-%m-%d") <= as.Date(input$endDate,format="%Y-%m-%d")))
    
    x <- data$date[posStart:posEnd]
    y <- data$rtn[posStart:posEnd]
    
    par(mfrow=c(2,1),cex=0.9,mex=0.6)
    
    chart.VaRSensitivity(xts(y,order.by=x),
                         methods = c("HistoricalVaR", "GaussianVaR"),
                         colorset = bluefocus, 
                         lwd = 2,
                         xlab="",
                         ylab="",
                         main="Risk Confidence Sensitivity")  
    
    aa <- c(min(rollapply(y,5,sum)),
            min(rollapply(y,10,sum)),
            min(rollapply(y,20,sum)),
            min(rollapply(y,60,sum)),
            min(rollapply(y,120,sum)))
    
    bp <- barplot(aa,
                  border = NA,
                  col=c("light grey","sky blue 3","dark blue","royal blue","light blue"),
                  ylim=range(floor(min(aa)) - 1,0),
                  main="Worst 5,10,20,60,120 days return (%)")
    abline(h=0)
    
    text(bp,
         aa,
         labels=as.character(round(aa,2)),
         pos=1) 
    
  })
  
  output$tablePerformance <- renderTable({  
    data <- data()
    posStart <- min(which(as.Date(data$date,format="%Y-%m-%d") >= as.Date(input$startDate,format="%Y-%m-%d")))
    posEnd <- max(which(as.Date(data$date,format="%Y-%m-%d") <= as.Date(input$endDate,format="%Y-%m-%d")))
    x <- data$date[posStart:posEnd]
    y <- data$rtn[posStart:posEnd]
    
    drawdowns <- data.frame(y=y/100)
    rownames(drawdowns) <- x
    
    dailyDD <- as.vector(findDrawdowns(drawdowns))
    
    nbDays <- length(x)
    nbYears <- nbDays/252
    totalReturn <- sum(y)
    annualizedReturn <- round(totalReturn/nbYears,2)
    annualizedVolatility <- round(sd(y)*sqrt(252),2)
    sharpeRatio <- round(annualizedReturn/annualizedVolatility,2)
    profitFactor <- round(sum(y[y > 0])/abs(sum(y[y < 0])),2)
    
    rtnTable <- rbind(paste(annualizedReturn,"%",sep=""),paste(annualizedVolatility,"%",sep=""),sharpeRatio,profitFactor)
    rownames(rtnTable) <- c("Ann.Return","Ann.Volatility","Sharpe Ratio","Profit Factor")
    colnames(rtnTable) <- c("Performance")
    
    rtnTable                                 
  })
  
  output$tableRisk <- renderTable({  
    data <- data()
    posStart <- min(which(as.Date(data$date,format="%Y-%m-%d") >= as.Date(input$startDate,format="%Y-%m-%d")))
    posEnd <- max(which(as.Date(data$date,format="%Y-%m-%d") <= as.Date(input$endDate,format="%Y-%m-%d")))
    x <- data$date[posStart:posEnd]
    y <- data$rtn[posStart:posEnd]
    
    drawdowns <- data.frame(y=y/100)
    rownames(drawdowns) <- x
    
    dailyDD <- as.vector(findDrawdowns(drawdowns))[[1]]
    
    maxDD <- 100*round(min(dailyDD),3)
    recoveryTime <- round(min(which(dailyDD[match(min(dailyDD),dailyDD):length(dailyDD)] == 0)),0)
    painIndex <- round(PainIndex(y),2)
    timeInMarket <- 100*round(length(which(y != 0))/length(y),2)
    
    riskTable <- rbind(paste(maxDD,"%",sep=""),paste(recoveryTime," days",sep=""),painIndex,paste(timeInMarket,"%",sep=""))
    rownames(riskTable) <- c("Max.DD","Recovery Time","Pain Index","% Time Invested")
    colnames(riskTable) <- c("Risk")
    
    riskTable                                 
  })
  
  output$tableDaily <- renderTable({  
    data <- data()
    posStart <- min(which(as.Date(data$date,format="%Y-%m-%d") >= as.Date(input$startDate,format="%Y-%m-%d")))
    posEnd <- max(which(as.Date(data$date,format="%Y-%m-%d") <= as.Date(input$endDate,format="%Y-%m-%d")))
    x <- data$date[posStart:posEnd]
    y <- data$rtn[posStart:posEnd]
    
    avRtn <- round(mean(y,na.rm=TRUE),2)
    avRtnPos <- round(mean(y[y >0],na.rm=TRUE),2)
    avRtnNeg <- round(mean(y[y <0],na.rm=TRUE),2)
    hitRatio <- 100*round(length(which(y > 0))/length(which(y != 0)),2)
    worstDay <- round(min(y),2)
    bestDay <- round(max(y),2)
    
    dailyTable <- rbind(paste(avRtn,"%",sep=""),paste(avRtnPos,"%",sep=""),paste(avRtnNeg,"%",sep=""),paste(hitRatio,"%",sep=""),paste(worstDay,"%",sep=""),paste(bestDay,"%",sep=""))
    rownames(dailyTable) <- c("Av. Rtn","Av. Rtn > 0","Av. Rtn < 0","Hit Ratio","Worst Day","Best Day")
    colnames(dailyTable) <- c("Daily")
    
    dailyTable                                 
  })
  
  output$tableMonthly <- renderTable({  
    data <- data()
    posStart <- min(which(as.Date(data$date,format="%Y-%m-%d") >= as.Date(input$startDate,format="%Y-%m-%d")))
    posEnd <- max(which(as.Date(data$date,format="%Y-%m-%d") <= as.Date(input$endDate,format="%Y-%m-%d")))
    x <- data$date[posStart:posEnd]
    y <- data$rtn[posStart:posEnd]
    
    months <- sort(unique(substring(x,1,7)))
    monthlyRtn <- aggregate(y,by=list(substring(x,1,7)),sum)[,2]
    
    monthlyHitRate <- 100*round(length(which(monthlyRtn > 0))/length(monthlyRtn),2)
    monthlyRtnAverage <- round(mean(monthlyRtn),2) 
    monthlyRtnPositive <- round(mean(monthlyRtn[which(monthlyRtn > 0)]),2) 
    monthlyRtnNegative <- round(mean(monthlyRtn[which(monthlyRtn < 0)]) ,2)
    worstMonth <- round(min(monthlyRtn),2)
    bestMonth <- round(max(monthlyRtn),2)
    
    monthlyTable <- rbind(paste(monthlyRtnAverage,"%",sep=""),paste(monthlyRtnPositive,"%",sep=""),paste(monthlyRtnNegative,"%",sep=""),paste(monthlyHitRate,"%",sep=""),paste(worstMonth,"%",sep=""),paste(bestMonth,"%",sep=""))
    rownames(monthlyTable) <- c("Av. Rtn","Av. Rtn > 0","Av. Rtn < 0","Hit Ratio","Worst Month","Best Month")
    colnames(monthlyTable) <- c("Monthly")
    
    monthlyTable                                 
  })
  #   session$onSessionEnded(function() {
  #     stopApp()
  #     q("n")
  #   })
}) 

