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
enum ENUM_CUSTOM_PERF_CRITERIUM_METHOD
{
   NO_CUSTOM_METRIC,                            //No Custom Metric
   STANDARD_PROFIT_FACTOR,                      //Standard Profit Factor
   MODIFIED_PROFIT_FACTOR                       //Modified Profit Factor
};
enum ENUM_DIAGNOSTIC_LOGGING_LEVEL
{
   DIAG_LOGGING_NONE,                           //NONE
   DIAG_LOGGING_LOW,                            //LOW - Major Diagnostics Only
   DIAG_LOGGING_HIGH                            //HIGH - All Diagnostics (Warning - Use with caution)
};
input group "==== General ====";
static input long InpMagicnumber= 1336;         // magic number
input double InpVolume = 0.01;                  //lots / money / percent size
input LOT_MODE_ENUM InpLotMode=LOT_MODE_FIXED;// lot mode
input int InpStopLoss = 100;                    //stop loss
input int InpTakeProfit = 200;                  //take profit
input bool InpStopLossTrailing = true;          //Trailing stoploss?
input ENUM_TIMEFRAMES InpStopLossTrailingTimeframe = PERIOD_H1; //Trailing stoploss timeframe
input CLOSE_MODE InpCloseCond = NO_CLOSING;     //Close modes
input bool InpNewBarMode = true;                // execute every bar?

input group "==== AROON ====";
input ENUM_TIMEFRAMES InpAROONTimeframe = PERIOD_H1;  //Timeframe
input int InpAROONPeriod = 25;                        //Period (number of bars to count, 0=off)
input int InpAROONShift = 0;                          //Horizontal Shift;
input AROON_MODE InpAROONMode = COMPARE_LEVEL_MODE;   //AROON Mode
input int InpAROONFilterVar = 50;                     //Filter level/difference
input group "=== Custom Criteria ==="
input ENUM_CUSTOM_PERF_CRITERIUM_METHOD   InpCustomPerfCriterium    = MODIFIED_PROFIT_FACTOR;   //Custom Performance Criterium
input ENUM_DIAGNOSTIC_LOGGING_LEVEL       InpDiagnosticLoggingLevel = DIAG_LOGGING_LOW;         //Diagnostic Logging Level


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