#include <StdLibErr.mqh>
#include <Math\Stat\Stat.mqh>            //Required for MathStandardDeviation()
//+------------------------------------------------------------------+
//| Custom Criteria functions                                        |
//+------------------------------------------------------------------+

// Modified Profit Factor
int ModifiedProfitFactor(double& dCustomPerformanceMetric)
{
   HistorySelect(0, TimeCurrent());   
   int numDeals = HistoryDealsTotal();  
   double sumProfit = 0.0;
   double sumLosses = 0.0;
   int numTrades = 0;
   
   //OUTPUT DIAGNOSTIC DEAL DATA
   int outputFileHandle = INVALID_HANDLE;
   if(InpDiagnosticLoggingLevel >= 1)
   {
      string outputFileName = "DEAL_DIAGNOSTIC_INFO\\deal_log.csv";
      outputFileHandle = FileOpen(outputFileName, FILE_WRITE|FILE_CSV, "\t");
      FileWrite(outputFileHandle, "LIST OF DEALS IS BACKTEST");   
      FileWrite(outputFileHandle, "TICKET", "DEAL_ORDER", "DEAL_POSITION_ID", "DEAL_SYMBOL", "DEAL_TYPE", 
                                    "DEAL_ENTRY", "DEAL_REASON", "DEAL_TIME", "DEAL_VOLUME", "DEAL_PRICE", 
                                    "DEAL_COMMISSION", "DEAL_SWAP", "DEAL_PROFIT", "DEAL_MAGIC", "DEAL_COMMENT");
   }
   
   //LOOP THROUGH DEALS IN DATETIME ORDER 
   int positionCount = 0;
   double positionNetProfit[];
   double positionVolume[];
   
   for(int dealID = 0; dealID < numDeals; dealID++) 
   { 
      //GET THIS DEAL'S TICKET NUMBER 
      ulong dealTicket = HistoryDealGetTicket(dealID); 
      
      if(HistoryDealGetInteger(dealTicket, DEAL_ENTRY) == DEAL_ENTRY_OUT)
      {
         positionCount++;
         ArrayResize(positionNetProfit, positionCount);
         ArrayResize(positionVolume, positionCount);
         
         positionNetProfit[positionCount - 1] = HistoryDealGetDouble(dealTicket, DEAL_PROFIT) +
                                                HistoryDealGetDouble(dealTicket, DEAL_SWAP) + 
                                                (2 * HistoryDealGetDouble(dealTicket, DEAL_COMMISSION));  //*2 BASED ON ENTRY AND EXIT COMMISSION MODEL     
         
         positionVolume[positionCount - 1] = HistoryDealGetDouble(dealTicket, DEAL_VOLUME);
      }
      
      //######################
      //OUTPUT DEAL PROPERTIES
      //###################### 
      
      if(InpDiagnosticLoggingLevel >= 1)
      {
         FileWrite(outputFileHandle, IntegerToString(dealTicket), 
                                     IntegerToString(HistoryDealGetInteger(dealTicket, DEAL_ORDER)),
                                     IntegerToString(HistoryDealGetInteger(dealTicket, DEAL_POSITION_ID)),
                                     HistoryDealGetString(dealTicket, DEAL_SYMBOL),
                                     EnumToString((ENUM_DEAL_TYPE)HistoryDealGetInteger(dealTicket, DEAL_TYPE)),
                                     EnumToString((ENUM_DEAL_ENTRY)HistoryDealGetInteger(dealTicket, DEAL_ENTRY)),
                                     EnumToString((ENUM_DEAL_REASON)HistoryDealGetInteger(dealTicket, DEAL_REASON)),
                                     TimeToString((datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME), TIME_DATE|TIME_SECONDS),
                                     DoubleToString(HistoryDealGetDouble(dealTicket, DEAL_VOLUME), 2),
                                     DoubleToString(HistoryDealGetDouble(dealTicket, DEAL_PRICE), 5),
                                     DoubleToString(HistoryDealGetDouble(dealTicket, DEAL_COMMISSION), 2),
                                     DoubleToString(HistoryDealGetDouble(dealTicket, DEAL_SWAP), 2),
                                     DoubleToString(HistoryDealGetDouble(dealTicket, DEAL_PROFIT), 2),
                                     IntegerToString(HistoryDealGetInteger(dealTicket, DEAL_MAGIC)),
                                     HistoryDealGetString(dealTicket, DEAL_COMMENT)
                                     );
      }
                                     
   } 
   
   //###################################
   //1. CALCULATE STANDARD PROFIT FACTOR
   //###################################
   
   double sumOfProfit = 0;
   double sumOfLosses = 0;
   
   for(int positionNum = 1; positionNum <= positionCount; positionNum++)
   {
      if(positionNetProfit[positionNum - 1] > 0)
         sumOfProfit += positionNetProfit[positionNum - 1];
      else
         sumOfLosses += positionNetProfit[positionNum - 1];
   }
   
   double standardProfitFactor = NULL;
   
   if(sumOfLosses != 0)
      standardProfitFactor = MathAbs(sumOfProfit / sumOfLosses);
   
   //WRITE OUT INTERMEDITE DIAGNOSTIC DATA
   if(InpDiagnosticLoggingLevel >= 1)
      FileWrite(outputFileHandle, "\nPROFIT FACTOR (STANDARD CALCULATION)", standardProfitFactor);
   
   //###################################
   //2. CALCULATE RELATIVE PROFIT FACTOR (INTERMEDIATE STEP)
   //################################### 
   
   sumOfProfit = 0;
   sumOfLosses = 0;   
   
   for(int positionNum = 1; positionNum <= positionCount; positionNum++)
   {
      positionNetProfit[positionNum - 1] /= positionVolume[positionNum - 1];
      
      if(positionNetProfit[positionNum - 1] > 0)
         sumOfProfit += positionNetProfit[positionNum - 1];
      else
         sumOfLosses += positionNetProfit[positionNum - 1];
   }                          
   
   double relativeProfitFactor = NULL;
   
   if(sumOfLosses != 0)
      relativeProfitFactor = MathAbs(sumOfProfit / sumOfLosses);
      
   //WRITE OUT INTERMEDITE DIAGNOSTIC DATA
   if(InpDiagnosticLoggingLevel >= 1)
      FileWrite(outputFileHandle, "\nPROFIT FACTOR (MODIFIED CALCULATION)", relativeProfitFactor);
   
   //#########################
   //3. EXCLUDE EXTREME TRADES
   //#########################
   
   double MeanRelNetProfit = MathMean(positionNetProfit);
   double StdDevRelNetProfit = MathStandardDeviation(positionNetProfit);
   
   double stdDevExcludeMultiple = 4.0; //Exclude trades that have values in excess of 4SD from the mean
   int numExcludedTrades = 0;
   sumOfProfit = 0;
   sumOfLosses = 0;
   
   for(int positionNum = 1; positionNum <= positionCount; positionNum++)
   {
      if(positionNetProfit[positionNum - 1] < MeanRelNetProfit-(stdDevExcludeMultiple*StdDevRelNetProfit)  ||  
         positionNetProfit[positionNum - 1] > MeanRelNetProfit+(stdDevExcludeMultiple*StdDevRelNetProfit))
      {
         numExcludedTrades++;
      }
      else
      {
         if(positionNetProfit[positionNum - 1] > 0)
            sumOfProfit += positionNetProfit[positionNum - 1];
         else
            sumOfLosses += positionNetProfit[positionNum - 1];
      }
   }
   
   dCustomPerformanceMetric = NULL;
   
   if(sumOfLosses != 0)
      dCustomPerformanceMetric = MathAbs(sumOfProfit / sumOfLosses);
      
   //WRITE OUT FINAL DIAGNOSTIC DATA
   if(InpDiagnosticLoggingLevel >= 1)
   {
      FileWrite(outputFileHandle, "\nEXCLUDING EXTREME (NEWS AFFECTED) TRADES:");
      FileWrite(outputFileHandle, "TOTAL TRADES BEFORE EXCLUSIONS", positionCount);
      FileWrite(outputFileHandle, "MEAN RELATIVE NET PROFIT", MeanRelNetProfit);
      FileWrite(outputFileHandle, "STD DEV RELATIVE NET PROFIT", StdDevRelNetProfit);
      FileWrite(outputFileHandle, "NUM TRADES EXCLUDED (> " + DoubleToString(stdDevExcludeMultiple, 1) + " SD)", numExcludedTrades, DoubleToString(((double)numExcludedTrades/positionCount)*100.0) + "%");
      FileWrite(outputFileHandle, "MODIFIED PROFIT FACTOR", dCustomPerformanceMetric);
      
      FileClose(outputFileHandle);
   }
   
   return positionCount;
}  
   