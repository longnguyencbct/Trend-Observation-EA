//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+

enum MARKET_STATE{
   UP_TREND,
   DOWN_TREND,
   NOT_TRENDING_FROM_UP,
   NOT_TRENDING_FROM_DOWN
};
// Trend Observation variables
MARKET_STATE prev_state;
MARKET_STATE curr_state;
bool new_state=false;
bool one_trade_check=true;

//AROON Indicator variables
int AROON_handle;
double AROON_Up[];
double AROON_Down[];

// Custom Criteria variables
int      PreviousHourlyTasksRun  = -1;          //Set to -1 so that hourly tasks run immediately
double   EquityHistoryArray[];                  //Used to store equity at intermittent time intervals when using the Strategy Tester in order to calculate CAGR/MeanDD perf metric
datetime BackTestFirstDate;                     //Used in the CAGR/MeanDD Calc
datetime BackTestFinalDate;                     //Used in the CAGR/MeanDD Calc



// Ordinary Variables
MqlTick currentTick;
CTrade trade;
ENUM_TIMEFRAMES MainTimeframe;
string currSymbol;
double currPoint;
int currDigits;

datetime openTimeBuy=0;
datetime openTimeSell=0;
double PreviousTickAsk;
double PreviousTickBid;
int cntBuy, cntSell;
int prev_cntBuy, prev_cntSell;