//+------------------------------------------------------------------+
//|                                           TrendObservationEA.mq5 |
//|           clongnguynvn@gmail.com or long.nguyencbct@hcmut.edu.vn |
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include "InpConfig.mqh"
#include "GlobalVar.mqh"
#include "Helper.mqh"
#include "OnTickHelper.mqh"
#include "TriggerFilterClose.mqh"
#include "TrendObservation.mqh"
#include "CustomCriteria.mqh"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   if(!CheckInputs()){return INIT_PARAMETERS_INCORRECT;}
   trade.SetExpertMagicNumber(InpMagicnumber);
   
   currSymbol=_Symbol;
   currPoint=_Point;
   currDigits=_Digits;
   
   // Init AROON
   if(InpAROONPeriod>0){
      //set Main Timeframe
      MainTimeframe=InpAROONTimeframe;
      
      AROON_handle=iCustom(currSymbol,MainTimeframe,"Custom\\aroon",InpAROONPeriod,InpAROONShift);
      
      if(AROON_handle==INVALID_HANDLE){
         Alert("Failed to create AROON indicatior handle");
         return INIT_FAILED;
      }
      
      ArraySetAsSeries(AROON_Up,true);
      ArraySetAsSeries(AROON_Down,true);
   }
   
   if(!InitCustomCriteria()){return INIT_PARAMETERS_INCORRECT;}
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //release AROON indicator handle
   if(InpAROONPeriod>0){
      if(AROON_handle!=INVALID_HANDLE){IndicatorRelease(AROON_handle);}
   }
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   UpdateHistoryArray();
   
   currPoint=_Point;
   currDigits=_Digits;
   UpdateStopLoss();
   
   //check if current tick is a bar open tick
   if(!IsNewBar()){return;}
   
   
   PreviousTickAsk=currentTick.ask;
   PreviousTickBid=currentTick.bid;
   //Get current tick
   if(!SymbolInfoTick(currSymbol,currentTick)){Print("Failed to get tick"); return;}
   
   // Get AROON indicator values
   if(!AROON_OnTick()){return;}
   
   // Trend Observation
   TrendObservation();
   //Close condition
   Close();
   //count open positions
   if(!CountOpenPositions(cntBuy,cntSell)){return;}
   // Check for Buy Order
   if(!CheckOrder(true)){return;}
   // Check for Sell Order
   if(!CheckOrder(false)){return;}
   
   prev_cntBuy=cntBuy;
   prev_cntSell=cntSell;
   if(!CountOpenPositions(cntBuy,cntSell)){return;}
   // new order check
   if(cntBuy-prev_cntBuy==1||cntSell-prev_cntSell==1){
      if(InpAROONOneTrade){one_trade_check=false;}
   }
}
double OnTester()  
{
   double customPerformanceMetric;  
   
   if(InpCustomPerfCriterium == STANDARD_PROFIT_FACTOR)
   {
      customPerformanceMetric = TesterStatistics(STAT_PROFIT_FACTOR);
   }
   else if(InpCustomPerfCriterium == MODIFIED_PROFIT_FACTOR)
   {
      int numTrades = ModifiedProfitFactor(customPerformanceMetric);
      
      //IF NUMBER OF TRADES < 250 THEN NO STATISTICAL SIGNIFICANCE, SO DISREGARD RESULTS (PROBABLE THAT GOOD 
      //RESULTS CAUSED BY RANDOM CHANCE / LUCK, THAT WOULD NOT BE REPEATABLE IN FUTURE PERFORMANCE)
      if(numTrades < 250)
         customPerformanceMetric = 0.0;
   } 
   else if(InpCustomPerfCriterium == CAGR_OVER_MEAN_DD)
   {
      int numTrades = CagrOverMeanDD(customPerformanceMetric);
      
      //IF NUMBER OF TRADES < 250 THEN NO STATISTICAL SIGNIFICANCE, SO DISREGARD RESULTS (PROBABLE THAT GOOD 
      //RESULTS CAUSED BY RANDOM CHANCE / LUCK, THAT WOULD NOT BE REPEATABLE IN FUTURE PERFORMANCE).
      //IF THE TRADING SYSTEM USUALLY GENERATES A NUMBER OF TRADES GREATLY IN EXCESS OF THIS THEN ADVISABLE TO INCREASE THIS THRESHOLD VALUE
      if(numTrades < 250)
         customPerformanceMetric = 0.0;
   }
   else if(InpCustomPerfCriterium == NO_CUSTOM_METRIC)
   {
      customPerformanceMetric = 0.0;
   }
   else
   {
      Print("Error: Custom Performance Criterium requested (", EnumToString(InpCustomPerfCriterium), ") not implemented in OnTester()");
      customPerformanceMetric = 0.0;
   }
   
   Print("Custom Perfromance Metric = ", DoubleToString(customPerformanceMetric, 3));
   
   return customPerformanceMetric;
}
//+------------------------------------------------------------------+
