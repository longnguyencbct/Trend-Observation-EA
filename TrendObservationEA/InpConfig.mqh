//+------------------------------------------------------------------+
//| Input Configuration functions                                    |
//+------------------------------------------------------------------+
enum LOT_MODE_ENUM{
   LOT_MODE_FIXED,// fixed lots
   LOT_MODE_MONEY,// lots based on money
   LOT_MODE_PCT_ACCOUNT// lots based on % account
};
enum AROON_MODE{
   COMPARE_LEVEL_MODE,        //compare using level
   COMPARE_UP_DOWN_MODE       //compare up and down
};
enum CLOSE_MODE{
   NO_CLOSING,                // no closing condition
   CLOSE_WHEN_NEW_STATE,      // close when new state
   CLOSE_WHEN_NEW_DIRECTION   // close when new direction
};
input group "==== General ====";
static input long InpMagicnumber= 1336;         // magic number
input double InpVolume = 0.01;                  //lots / money / percent size
input LOT_MODE_ENUM InpLotMode=LOT_MODE_FIXED;// lot mode
input int InpStopLoss = 100;                    //stop loss
input int InpTakeProfit = 200;                  //take profit
input CLOSE_MODE InpCloseCond = NO_CLOSING;     //Close modes
input bool InpNewBarMode = true;                // execute every bar?

input group "==== AROON ====";
input ENUM_TIMEFRAMES InpAROONTimeframe = PERIOD_H1;  //Timeframe
input int InpAROONPeriod = 25;                        //Period (number of bars to count, 0=off)
input int InpAROONShift = 0;                          //Horizontal Shift;
input AROON_MODE InpAROONMode = COMPARE_LEVEL_MODE;   //AROON Mode
input int InpAROONFilterVar = 50;                     //Filter level/difference


bool CheckInputs(){
   if(InpMagicnumber<=0){
      Alert("Wrong input: Magicnumber <= 0");
      return(false);
   }
   if(InpVolume<=0){
      Alert("Wrong input: Lots size <= 0");
      return(false);
   }
   if(InpStopLoss<0){
      Alert("Wrong input: Stop loss < 0");
      return(false);
   }
   if(InpTakeProfit<0){
      Alert("Wrong input: Take profit < 0");
      return(false);
   }
   if(InpAROONPeriod<0){
      Alert("Wrong input: AROON Period < 0");
      return(false);
   }
   if(InpAROONShift<0){
      Alert("Wrong input: AROON Shift < 0");
      return(false);
   }
   if(InpAROONFilterVar<0){
      Alert("Wrong input: AROON Filter level < 0");
      return(false);
   }
   return true;
}