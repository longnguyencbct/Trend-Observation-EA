#include "InpConfig.mqh"
#include "GlobalVar.mqh"
//+------------------------------------------------------------------+
//| OnTick Helper functions                                          |
//+------------------------------------------------------------------+

bool AROON_OnTick(){
   //Get AROON Indicator values
   if(InpAROONPeriod!=0){
      int values=CopyBuffer(AROON_handle,0,0,1,AROON_Up)
                +CopyBuffer(AROON_handle,1,0,1,AROON_Down);
                
      if(values!=2){
         Print("Failed to get AROON  indicator values, value:",values);
         Print(GetLastError());
         return false;
      }
      string curr_state_str;
      switch(curr_state){
         case UP_TREND:
            curr_state_str="Up Trend";
            break;
         case DOWN_TREND:
            curr_state_str="Down Trend";
            break;
         case NOT_TRENDING_FROM_UP:
            curr_state_str="Not Trending from Up";
            break;
         case NOT_TRENDING_FROM_DOWN:
            curr_state_str="Not Trending from Down";
            break;
      }
      
      Comment("\nAROON:"+
              "\n Up[0]: "+string(AROON_Up[0])+
              "\n Down[0]: "+string(AROON_Down[0])+
              "\n Market State: "+curr_state_str);
      return true;
   }
   return true;
}

bool CheckOrder(bool buy_sell){
   if(buy_sell){//buy
      // conditions to open a buy position
      if(Trigger(true)&&Filter(true)){
         Print("Open buy");
         openTimeBuy=iTime(currSymbol,MainTimeframe,0);
         double sl = InpStopLoss==0?0:currentTick.bid-InpStopLoss*currPoint;
         double tp = InpTakeProfit==0?0:currentTick.bid+InpTakeProfit*currPoint;
         if(!NormalizePrice(sl,sl)){return false;}
         if(!NormalizePrice(tp,tp)){return false;}
         
         //calculate lots
         double lots;
         if(!CalculateLots(currentTick.bid-sl,lots)){return false;}
         
         trade.PositionOpen(currSymbol,ORDER_TYPE_BUY,lots,currentTick.ask,sl,tp,"Bollinger bands EA");  
      }
      return true;
   }else{//sell
      // conditions to open a sell position
      if(Trigger(false)&&Filter(false)){
         Print("Open sell");
         openTimeSell=iTime(currSymbol,MainTimeframe,0);
         double sl = InpStopLoss==0?0:currentTick.ask+InpStopLoss*currPoint;
         double tp = InpTakeProfit==0?0:currentTick.ask-InpTakeProfit*currPoint;
         if(!NormalizePrice(sl,sl)){return false;}
         if(!NormalizePrice(tp,tp)){return false;}
         
         //calculate lots
         double lots;
         if(!CalculateLots(sl-currentTick.ask,lots)){return false;}
         
         trade.PositionOpen(currSymbol,ORDER_TYPE_SELL,lots,currentTick.bid,sl,tp,"Bollinger bands EA");  
      }
      return true;
   }
}