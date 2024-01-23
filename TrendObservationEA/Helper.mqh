#include "InpConfig.mqh"
#include "GlobalVar.mqh"
//+------------------------------------------------------------------+
//| Helper functions                                                 |
//+------------------------------------------------------------------+

//check if we hace a bar open tick
bool IsNewBar(){
   if(!InpNewBarMode){return true;}
   static datetime previousTime=0;
   datetime currentTime=iTime(currSymbol,MainTimeframe,0);
   if(previousTime!=currentTime){
      previousTime=currentTime;
      return true;
   }
   return false;
}
bool IsNewTrailSLBar(){
   if(!InpNewBarMode){return true;}
   static datetime previousTime=0;
   datetime currentTime=iTime(currSymbol,InpStopLossTrailingTimeframe,0);
   if(previousTime!=currentTime){
      previousTime=currentTime;
      return true;
   }
   return false;
}

bool CountOpenPositions(int &countBuy,int &countSell){
   countBuy = 0;
   countSell =0;
   int total= PositionsTotal();
   for(int i=total-1;i>=0;i--){
      ulong positionTicket=PositionGetTicket(i);
      if(positionTicket<=0){Print("Failed to get ticket"); return false;}
      if(!PositionSelectByTicket(positionTicket)){Print("Failed to select position"); return false;}
      long magic;
      if(!PositionGetInteger(POSITION_MAGIC,magic)){Print("Failed to get magic"); return false;}
      if(magic==InpMagicnumber){
         long type;
         if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get type"); return false;}
         if(type==POSITION_TYPE_BUY){countBuy++;}
         if(type==POSITION_TYPE_SELL){countSell++;}
      }
   }
   return true;
}

bool NormalizePrice(double price,double &normalizedPrice){
   double tickSize=0;
   if(!SymbolInfoDouble(currSymbol,SYMBOL_TRADE_TICK_SIZE,tickSize)){
      Print("Failed to get tick size");
      return false;
   }
   normalizedPrice=NormalizeDouble(MathRound(price/tickSize)*tickSize,currDigits);
   return true;
}

bool ClosePositions(int all_buy_sell){
   int total= PositionsTotal();
   for(int i=total-1;i>=0;i--){
      ulong positionTicket=PositionGetTicket(i);
      if(positionTicket<=0){Print("Failed to get ticket"); return false;}
      if(!PositionSelectByTicket(positionTicket)){Print("Failed to select position"); return false;}
      long magic;
      if(!PositionGetInteger(POSITION_MAGIC,magic)){Print("Failed to get magic"); return false;}
      if(magic==InpMagicnumber){
         long type;
         if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get type"); return false;}
         if(all_buy_sell==1&&type==POSITION_TYPE_SELL){continue;}
         if(all_buy_sell==2&&type==POSITION_TYPE_BUY){continue;}
         trade.PositionClose(positionTicket);
         if(trade.ResultRetcode()!=TRADE_RETCODE_DONE){
            Print("Failed to close position ticket:",(string)positionTicket,
                  "result:",(string)trade.ResultRetcode()+":",trade.ResultRetcodeDescription());
            return false;
         }
      }
   }
   return true;
}

//Calculate lots
bool CalculateLots(double slDistance, double &lots){
   lots=0.0;
   if(InpLotMode==LOT_MODE_FIXED){
      lots=InpVolume;
   }
   else{
      double tickSize=SymbolInfoDouble(currSymbol,SYMBOL_TRADE_TICK_SIZE);
      double tickValue=SymbolInfoDouble(currSymbol,SYMBOL_TRADE_TICK_VALUE);
      double volumeStep=SymbolInfoDouble(currSymbol,SYMBOL_VOLUME_STEP);
      
      double riskMoney = InpLotMode==LOT_MODE_MONEY?InpVolume:AccountInfoDouble(ACCOUNT_EQUITY)*InpVolume*0.01;
      double moneyVolumeStep=(slDistance/tickSize)*tickValue*volumeStep;
      
      lots=MathFloor(riskMoney/moneyVolumeStep)*volumeStep;
   }
   //check calculated lots
   if(!CheckLots(lots)){return false;}
   
   return true;
}

//check lots for min, max and step
bool CheckLots(double &lots){
   
   double min = SymbolInfoDouble(currSymbol,SYMBOL_VOLUME_MIN);
   double max = SymbolInfoDouble(currSymbol,SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(currSymbol,SYMBOL_VOLUME_STEP);
   
   if(lots<min){
      Print("Lot size will be set to the minimum allowable volume");
      lots=min;
      return true;
   }
   if(lots>max){
      Print("Lot size greater than and will be set to the maximum allowable volume. lots:",lots,", max:",max);
      lots=max;
      return true;
   }
   lots=(int)MathFloor(lots/step)*step;
   return  true;
}

// update stop loss
void UpdateStopLoss(){
   //return if no SL or fixed stop loss
   if(InpStopLoss==0||!InpStopLossTrailing){return;}
   if(!IsNewTrailSLBar()){return;}
   //loop through open positions
   int total= PositionsTotal();
   for(int i=total-1;i>=0;i--){
      ulong ticket=PositionGetTicket(i);
      if(ticket<=0){Print("Failed to get position ticket"); return;}
      if(!PositionSelectByTicket(ticket)){Print("Failed to select position by ticket"); return;}
      ulong magic;
      if(!PositionGetInteger(POSITION_MAGIC,magic)){Print("Failed to get magic"); return;}
      if(magic==InpMagicnumber){
         //get type
         long type;
         if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get position type");return;}
         //get current sl and tp
         double currSL,currTP;
         if(!PositionGetDouble(POSITION_SL,currSL)){Print("Failed to get position stop loss");return;}
         if(!PositionGetDouble(POSITION_TP,currTP)){Print("Failed to get position take profit");return;}
         //calculate stop loss
         double currPrice=type==POSITION_TYPE_BUY?currentTick.bid:currentTick.ask;
         double prevPrice=type==POSITION_TYPE_BUY?PreviousTickBid:PreviousTickAsk;
         int n           =type==POSITION_TYPE_BUY?1:-1;
         double newSL = NormalizeDouble(currSL+(currPrice-prevPrice)*n,currDigits);
         
         //check if new stop loss is closer to current price than existing stop loss
         if((newSL*n)<(currSL*n)||NormalizeDouble(MathAbs(newSL-currSL),currDigits)<currPoint){
            //Print("No new stop loss needed");
            continue;
         }
         //check for stop level
         long level = SymbolInfoInteger(currSymbol,SYMBOL_TRADE_STOPS_LEVEL);
         if(level!=0&&MathAbs(currPrice-newSL)<=level*currPoint){
            //Print("New stop loss inside stop level");
            continue;
         }
         
         // modify position with new stop loss
         if(!trade.PositionModify(ticket,newSL,currTP)){
            Print("Failed to modify position, ticket:",(string)ticket,", currSL:",(string)currSL,
            ", newSL:",(string)newSL,", currTP:",(string)currTP);
            return;
         }
      }
   }
}