//+------------------------------------------------------------------+
//| Trend Observation                                                |
//+------------------------------------------------------------------+
#include "GlobalVar.mqh"
#include "InpConfig.mqh"

void TrendObservation(){
   prev_state = curr_state;
   // AROON BEGIN ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   if(InpAROONPeriod!=0){
      switch(InpAROONMode){
         case COMPARE_UP_DOWN_MODE:                                                                                                       // ======== COMPARE_UP_DOWN_MODE ======== //
            if(AROON_Up[0]-AROON_Down[0]>InpAROONDiffVar){                                                                                // Up trend:         Up - Down > diff     //
               Check_new_state_Variable(true);                                                                                            // Down trend:       Down - Up > diff     //
               curr_state=UP_TREND;                                                                                                       // Not trending:                          //
               return;                                                                                                                    //    + From Up:     Up -> Not Trending   //
            }                                                                                                                             //    + From Down:   Down -> Not Trending //
            else if(AROON_Down[0]-AROON_Up[0]>InpAROONDiffVar){                                                                           ////////////////////////////////////////////
               Check_new_state_Variable(false);
               curr_state=DOWN_TREND;
               return;
            }else{
               if(curr_state==UP_TREND){
                  if(InpCloseCond==CLOSE_WHEN_NEW_STATE){new_state=true; one_trade_check=true;}
                  curr_state=NOT_TRENDING_FROM_UP;
                  return;
               }
               if(curr_state==DOWN_TREND){
                  if(InpCloseCond==CLOSE_WHEN_NEW_STATE){new_state=true; one_trade_check=true;}
                  curr_state=NOT_TRENDING_FROM_DOWN;
                  return;
               }
            }
            break;
         case COMPARE_LEVEL_MODE:                                                                                                      // ============= COMPARE_LEVEL_MODE ============= //
            if(AROON_Up[0]>=InpAROONLevelVar&&AROON_Down[0]<InpAROONLevelVar){                                                         // Up trend:         Up >= level && Down < level  //
               Check_new_state_Variable(true);                                                                                         // Down trend:       Up < level && Down >= level  //
               curr_state=UP_TREND;                                                                                                    // Not trending:                                  //
               return;                                                                                                                 //    + From Up:     Up -> Not Trending           //
            }                                                                                                                          //    + From Down:   Down -> Not Trending         //
            else if(AROON_Up[0]<InpAROONLevelVar&&AROON_Down[0]>=InpAROONLevelVar){                                                    ////////////////////////////////////////////////////
               Check_new_state_Variable(false);
               curr_state=DOWN_TREND;
               return;
            }else{
               if(curr_state==UP_TREND){
                  if(InpCloseCond==CLOSE_WHEN_NEW_STATE){new_state=true; one_trade_check=true;}
                  curr_state=NOT_TRENDING_FROM_UP;
                  return;
               }
               if(curr_state==DOWN_TREND){
                  if(InpCloseCond==CLOSE_WHEN_NEW_STATE){new_state=true; one_trade_check=true;}
                  curr_state=NOT_TRENDING_FROM_DOWN;
                  return;
               }
            }
            break;
         case COMPARE_BOTH_MODE:                                                                                                       // ======================= COMPARE_BOTH_MODE ======================== //               
            if(AROON_Up[0]>=InpAROONLevelVar&&AROON_Down[0]<InpAROONLevelVar&&AROON_Up[0]-AROON_Down[0]>InpAROONDiffVar){              // Up trend:         Up >= level && Down < level && Up - Down > diff  //
               Check_new_state_Variable(true);                                                                                         // Down trend:       Up < level && Down >= level && Down - Up > diff  //
               curr_state=UP_TREND;                                                                                                    // Not trending:                                                      //
               return;                                                                                                                 //    + From Up:     Up -> Not Trending                               //
            }                                                                                                                          //    + From Down:   Down -> Not Trending                             //
            else if(AROON_Up[0]<InpAROONLevelVar&&AROON_Down[0]>=InpAROONLevelVar&&AROON_Down[0]-AROON_Up[0]>InpAROONDiffVar){         ////////////////////////////////////////////////////////////////////////
               Check_new_state_Variable(false);
               curr_state=DOWN_TREND;
               return;
            }else{
               if(curr_state==UP_TREND){
                  if(InpCloseCond==CLOSE_WHEN_NEW_STATE){new_state=true; one_trade_check=true;}
                  curr_state=NOT_TRENDING_FROM_UP;
                  return;
               }
               if(curr_state==DOWN_TREND){
                  if(InpCloseCond==CLOSE_WHEN_NEW_STATE){new_state=true; one_trade_check=true;}
                  curr_state=NOT_TRENDING_FROM_DOWN;
                  return;
               }
            }
            break;
      }
   }
   // AROON END //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}

void Check_new_state_Variable(bool up_down){
   if(up_down){//up trend
      switch(InpCloseCond) {
         case CLOSE_WHEN_NEW_STATE:
            if(curr_state!=UP_TREND){new_state=true; one_trade_check=true;} 
            break;
         case CLOSE_WHEN_NEW_DIRECTION:
            if(curr_state==DOWN_TREND||curr_state==NOT_TRENDING_FROM_DOWN){new_state=true; one_trade_check=true;} 
            break;
         default:
            break;
      }
   }else{// down trend
      switch(InpCloseCond) {
         case CLOSE_WHEN_NEW_STATE:
            if(curr_state!=DOWN_TREND){new_state=true; one_trade_check=true;} 
            break;
         case CLOSE_WHEN_NEW_DIRECTION:
            if(curr_state==UP_TREND||curr_state==NOT_TRENDING_FROM_UP){new_state=true; one_trade_check=true;} 
            break;
         default:
            break;
      }
   }
}
