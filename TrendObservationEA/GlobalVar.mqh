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