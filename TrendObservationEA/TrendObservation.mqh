//+------------------------------------------------------------------+
//| Trend Observation                                                |
//+------------------------------------------------------------------+
#include "GlobalVar.mqh"
#include "InpConfig.mqh"

void TrendObservation(){
   // AROON BEGIN ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   if(InpAROONPeriod!=0){
      switch(InpAROONMode){
         case COMPARE_UP_DOWN_MODE:                                                       // ======== COMPARE_UP_DOWN_MODE ======== //
            if(AROON_Up[0]-AROON_Down[0]>InpAROONFilterVar){                              // Up trend:         Up - Down > input    //
               if(curr_state!=UP_TREND){new_state=true;}                                  // Down trend:       Down - Up > input    //
               curr_state=UP_TREND;                                                       // Not trending:                          //
               return;                                                                    //    + From Up:     Up -> Not Trending   //
            }                                                                             //    + From Down:   Down -> Not Trending //
            else if(AROON_Down[0]-AROON_Up[0]>InpAROONFilterVar){                         ////////////////////////////////////////////
               if(curr_state!=DOWN_TREND){new_state=true;}
               curr_state=DOWN_TREND;
               return;
            }else{
               if(curr_state==UP_TREND){
                  if(InpCloseCond==CLOSE_WHEN_NEW_STATE){new_state=true;}
                  curr_state=NOT_TRENDING_FROM_UP;
                  return;
               }
               if(curr_state==DOWN_TREND){
                  if(InpCloseCond==CLOSE_WHEN_NEW_STATE){new_state=true;}
                  curr_state=NOT_TRENDING_FROM_DOWN;
                  return;
               }
            }
            break;
         case COMPARE_LEVEL_MODE:                                                         // ============= COMPARE_LEVEL_MODE ============= //
            if(AROON_Up[0]>=InpAROONFilterVar&&AROON_Down[0]<InpAROONFilterVar){          // Up trend:         Up >= input && Down < input  //
               if(curr_state!=UP_TREND){new_state=true;}                                  // Down trend:       Up < input && Down >= input  //
               curr_state=UP_TREND;                                                       // Not trending:                                  //
               return;                                                                    //    + From Up:     Up -> Not Trending           //
            }                                                                             //    + From Down:   Down -> Not Trending         //
            else if(AROON_Up[0]<InpAROONFilterVar&&AROON_Down[0]>=InpAROONFilterVar){     ////////////////////////////////////////////////////
               if(curr_state!=DOWN_TREND){new_state=true;}
               curr_state=DOWN_TREND;
               return;
            }else{
               if(curr_state==UP_TREND){
                  if(InpCloseCond==CLOSE_WHEN_NEW_STATE){new_state=true;}
                  curr_state=NOT_TRENDING_FROM_UP;
                  return;
               }
               if(curr_state==DOWN_TREND){
                  if(InpCloseCond==CLOSE_WHEN_NEW_STATE){new_state=true;}
                  curr_state=NOT_TRENDING_FROM_DOWN;
                  return;
               }
            }
            break;
      }
   }
   // AROON END //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}