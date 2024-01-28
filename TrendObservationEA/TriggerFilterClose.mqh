#include "InpConfig.mqh"
#include "GlobalVar.mqh"
//+------------------------------------------------------------------+
//| Trigger function                                                 |
//+------------------------------------------------------------------+
bool Trigger(bool buy_sell){
   return AROON_Trigger(buy_sell)&&InpAROONPeriod!=0;
}
bool AROON_Trigger(bool buy_sell){
   if(buy_sell){//buy
      return   cntBuy==0&&
               curr_state==UP_TREND&&
               one_trade_check;
   }else{//sell
      return   cntSell==0&&
               curr_state==DOWN_TREND&&
               one_trade_check;
   }
}
//+------------------------------------------------------------------+
//| Filter function                                                  |
//+------------------------------------------------------------------+
bool Filter(bool buy_sell){
   return true;
}

//+------------------------------------------------------------------+
//| Close function                                                   |
//+------------------------------------------------------------------+
void Close(){
   //check for close when there is a new state or new direction
   if(new_state){
      if(InpCloseCond!=NO_CLOSING){
         ClosePositions(0);
      }
      new_state=false;
   }
}