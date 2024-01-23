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
   
   currPoint=_Point;
   currDigits=_Digits;
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
   
   //count open positions
   if(!CountOpenPositions(cntBuy,cntSell)){return;}
   
   // Check for Buy Order
   if(!CheckOrder(true)){return;}
   // Check for Sell Order
   if(!CheckOrder(false)){return;}
   
   if(!CountOpenPositions(cntBuy,cntSell)){return;}
   //Close condition
   Close();
   
}

//+------------------------------------------------------------------+
