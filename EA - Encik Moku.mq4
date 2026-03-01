//+------------------------------------------------------------------+
//|                                                EA Encik Moku.mq4 |
//|                                 Copyright © 2022, Syarief Azman. |
//|                                          http://t.me/EABudakUbat |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, BuBat's Trading"
#property link      "https://t.me/EABudakUbat"
#property version   "1.06"
#property description   "This is a single entry EA."
#property description   "Recommended capital is 100 usd, choose trending pair."
#property description   "The EA Trades based on Ichimoku Kinko Hyo, RSI, and Stoch. "
#property description   "It buy above kumo and sell below kumo."
#property description   "MultiTimeFrame mode take 4 different timeframes into account before entering the trades."
#property description   " "
#property description   "Ayuh bangkit darah pahlawan. Pantang undur sebelum MC! "
#property description   "Join our Telegram channel : https://t.me/EAEncikMoku"
#property description   "Facebook : https://m.me/EABudakUbat"
#property description   "Tel: +60194961568 (Budak Ubat)"
#property icon        "\\Images\\bupurple.ico";  
#include <stdlib.mqh>
#include <WinUser32.mqh>



//+------------------------------------------------------------------+
//| Name of the EA                                                   |
//+------------------------------------------------------------------+
input string EA_Name = "EA Encik Moku v1.06";
string Owner = "BUDAK UBAT";
string Contact = "WHATSAPP/TELEGRAM : +60194961568";

//+------------------------------------------------------------------+
//| Authorization and Expiration date for the EA                     |
//+------------------------------------------------------------------+
datetime expDate = D'2026.03.28 23:55';

int allowedAccountNumbers[] =
  {
   51379350, 220757761, 10589171, 220757426, 241764167, 220756561, 220756639, 301419237, 16581411, 231104393, 220754569, 290921520, 220754551, 220754458, 220754351, 110030128, 220753629, 220753544, 3805175, 231104416, 231101347, 231103989, 231103990, 260802695, 220747326, 231102420, 231100797, 231101152, 46138418, 290894056, 231099736, 290891017, 290891018, 231098986, 231097084, 231098630, 31018538, 536221, 301419571, 301419462, 301419236, 220476053, 13301739, 301419002, 301418623, 31018009, 271757912, 301417622, 1235226, 41328586, 301415814, 13300444, 38039998, 91931537, 1235225, 301415091, 301414688, 49156221, 15120370, 4574565, 407676, 271758951, 271758209, 41029112, 230325793, 271757233, 271756669, 49154578, 4573169, 260801772, 260800857, 40855756, 40818759, 30472764, 4572375, 260799123, 4120301, 22779978, 20966306, 260796883, 4571803, 260796867, 20981220, 241579974
  };

string allowedAccountNames[] =
  {
   "Mohd Nizab Pawan",
   "Nazmi Zakaria",
   "Yusrezal Bin Ramdzan", "Yusrezal Ramdzan",
   "Syed Kamal Al-Yahya Bin Syed Mohd", "Bin Syed Mohd Syed Kamal Al-Yahya",
   "Jimmy Antonio Luciano Baez", "Jimmy Luciano",
   "Ahmad Husaini Bin Shahrul Azmi", "Ahmad Husaini Shahrul Azmi",
   "Zaliha Binti Hussin", "Zaliha Hussin",
   "Syarief Azman bin Rosli"
  };

string ExpiryAlert;
int MagicNumber = 260328;
double MartingaleMultiplier;

// exported variables
extern double Lots = 0.01;
extern int Takeprofit_Pips = 50;
extern int Stoploss_Pips = 50;
extern bool Close_On_Reversal = true;
string ExpertComment;

enum trdtype
{
    AA=0,     // No MTF  (Current TimeFrame only)
    BB=1,     // Scalperz (H1, M15, M5, M1)
    CC=2,     // Intradayz (H4, H1, M15, M5)
    DD=3,     // Swingz     (D1, H4, H1, M15)
    EE=4,     // Positionz (W1, D1, H4, H1)
    
};
//--- input parameters
input trdtype MultiTimeFrame_Mode= CC;

enum compound
{
    A=0,     // Off                         (EntryLot = Lots)
    B=1,     // Very High Risk (EntryLot = Lots ÷ 50 × Equity)
    C=2,     // High Risk           (EntryLot = Lots ÷ 100 × Equity)
    D=3,     // Medium Risk     (EntryLot = Lots ÷ 1 000 × Equity)
    E=4,     // Low Risk             (EntryLot = Lots ÷ 10 000 × Equity)
    F=5,     // Very Low Risk   (EntryLot = Lots ÷ 100 000 × Equity)
    
};
//--- input parameters
input compound AutoCompounding_Mode= A;

extern bool ECN_Broker = false;

extern string __Trailing_Function_Below__ = "__Trailing_Function_Below__";
extern bool TrailingStop = False ;
extern int TrailingStop_Pips = 25;
extern int TrailingGap_Pips = 7;
extern int NewTakeProfit_Pips = 0;
 
extern string __Trading_Time_Function_Below__ = "__Trading_Time_Function_Below__ "; 
extern bool Monday = true;
extern bool Tuesday = true;
extern bool Wednesday = true;
extern bool Thursday = true;
extern bool Friday = true;
extern bool Saturday = true;
extern bool Sunday = true;
extern int HoursFrom = 0;
extern int HoursTo = 24;

extern string __Martingale_Function_Below__ = "__Martingale_Function_Below__ "; 
extern double LotMultiplierOnLoss = 2.25;
extern double LotsMultiplierOnProfit = 1;
extern double MaxLots = 999;
extern bool LotsResetOnProfit = true;
extern bool LotsResetOnLoss = false;

extern string __Notification_Settings__ = "__Notification_Settings__"; 
extern bool Email_Notification = true;
extern bool Alert_Notification = false;
extern bool MT4_Messages = true;
 bool tmsrv = true;

//--- hidden variables
 int TrailingStop58 = TrailingStop_Pips;
 int NewTakeProfit58 = NewTakeProfit_Pips;
 int TrailingGap58 = TrailingGap_Pips;

 bool Monday21 = Monday;
 bool Tuesday21 = Tuesday;
 bool Wednesday21 = Wednesday;
 bool Thursday21 = Thursday;
 bool Friday21 = Friday;
 bool Saturday21 = Saturday;
 bool Sunday21 = Sunday;
 int HoursFrom22 = HoursFrom;
 int HoursTo22 = HoursTo;

 double BuyLots34 = Lots;
 int BuyStoploss34 = Stoploss_Pips;
 int BuyTakeprofit34 = Takeprofit_Pips;
 double MaxBuyLots34 = MaxLots;
 double LotsBuyChOnLoss34 = 0;
 double LotsBuyChOnProfit34 = 0;
 double LotsBuyMpOnLoss34 = LotMultiplierOnLoss;
 double LotsBuyMpOnProfit34 = LotsMultiplierOnProfit;
 bool LotsResetOnProfit34 = LotsResetOnProfit;
 bool LotsResetOnLoss34 = LotsResetOnLoss;

 double SellLots47 = Lots;
 int SellStoploss47 = Stoploss_Pips;
 int SellTakeprofit47 = Takeprofit_Pips;
 double MaxSellLots47 = MaxLots;
 double LotsSellChOnLoss47 = 0;
 double LotsSellChOnProfit47 = 0;
 double LotsSellMpOnLoss47 = LotMultiplierOnLoss;
 double LotsSellMpOnProfit47 = LotsMultiplierOnProfit;
 bool LotsResetOnProfit47 = LotsResetOnProfit;
 bool LotsResetOnLoss47 = LotsResetOnLoss;


// local variables
double PipValue=1;    // this variable is here to support 5-digit brokers
bool Terminated = false;
string LF = "\n";  // use this in custom or utility blocks where you need line feeds
int NDigits = 4;   // used mostly for NormalizeDouble in Flex type blocks
int ObjCount = 0;  // count of all objects created on the chart, allows creation of objects with unique names
int current = 0;   // current bar index, used by Cross Up, Cross Down and many other blocks
int varylots[101]; // used by Buy Order Varying, Sell Order Varying and similar




double CurrentBuyLots34 = 1;
bool FirstBuyLotsMgm34 = true;
double CurrentSellLots47 = 1;
bool FirstSellLotsMgm47 = true;

datetime BarTime6 = 0;
datetime BarTime48 = 0;

double EntryLots ;
string TMode;
string CTF;

int init()
{
    ExpertComment = EA_Name;
    ExpiryAlert = EA_Name + " IS EXPIRED. "
                 "\nAccount " + IntegerToString(AccountNumber()) + " is Unauthorized. "
                 "\nUse Demo account to access Trials Mode. "
                 "\nPLEASE CONTACT " + Owner + " FOR MORE INFO. "
                 "\n" + Contact;
    MartingaleMultiplier = LotMultiplierOnLoss;

    NDigits = Digits;
    
    if (false) ObjectsDeleteAll();
    
    CurrentBuyLots34 = BuyLots34;
    CurrentSellLots47 = SellLots47;
    
    Comment("");
    RunAuthorization();
    return (0);
}

// Expert start
int start()
{
    if (Bars < 10)
    {
        Comment("Not enough bars");
        return (0);
    }
    if (Terminated == true)
    {
        Comment("EA Terminated.");
        return (0);
    }
    
    OnEveryTick20();
    return (0);
}

void OnEveryTick20()
{

//--- Trading Mode
if (Period()==1) {CTF = "M1";}
   if (Period()==5) {CTF = "M5";}
   if (Period()==15) {CTF = "M15";}
   if (Period()==30) {CTF = "M30";}
   if (Period()==60) {CTF = "H1";}
   if (Period()==240) {CTF = "H4";}
   if (Period()==1440) {CTF = "Daily";}
   if (Period()==10080) {CTF = "Weekly";}
   if (Period()==43200) {CTF = "Monthly";}

if (MultiTimeFrame_Mode==AA){ TMode = CTF ;}
   if (MultiTimeFrame_Mode==BB){ TMode = "Scalperz (M1,M5,M15,H1)" ;}
   if (MultiTimeFrame_Mode==CC){ TMode = "Intradayz (M5,M15,H1,H4)" ;}
   if (MultiTimeFrame_Mode==DD){ TMode = "Swingz (M15,H1,H4,D1)" ;}
   if (MultiTimeFrame_Mode==EE){ TMode = "Positionz (H1,H4,D1,W1)" ;}

//--- Auto Compound
if (AutoCompounding_Mode==A){ EntryLots = Lots ;}
   if (AutoCompounding_Mode==B){ EntryLots = ((Lots/50)*AccountEquity()) ;}
   if (AutoCompounding_Mode==C){ EntryLots = ((Lots/100)*AccountEquity()) ;}
   if (AutoCompounding_Mode==D){ EntryLots = ((Lots/1000)*AccountEquity()) ;}
   if (AutoCompounding_Mode==E){ EntryLots = ((Lots/10000)*AccountEquity()) ;}
   if (AutoCompounding_Mode==F){ EntryLots = ((Lots/100000)*AccountEquity()) ;}

  SellLots47 = EntryLots;
  BuyLots34 = EntryLots;
   
  TrailingStop58 = TrailingStop_Pips;
  NewTakeProfit58 = NewTakeProfit_Pips;
  TrailingGap58 = TrailingGap_Pips;

  Monday21 = Monday;
  Tuesday21 = Tuesday;
  Wednesday21 = Wednesday;
  Thursday21 = Thursday;
  Friday21 = Friday;
  Saturday21 = Saturday;
  Sunday21 = Sunday;
  HoursFrom22 = HoursFrom;
  HoursTo22 = HoursTo;

  BuyStoploss34 = Stoploss_Pips;
  BuyTakeprofit34 = Takeprofit_Pips;
  MaxBuyLots34 = MaxLots;
  LotsBuyChOnLoss34 = 0;
  LotsBuyChOnProfit34 = 0;
  LotsBuyMpOnLoss34 = LotMultiplierOnLoss;
  LotsBuyMpOnProfit34 = LotsMultiplierOnProfit;
  LotsResetOnProfit34 = LotsResetOnProfit;
  LotsResetOnLoss34 = LotsResetOnLoss;

  SellStoploss47 = Stoploss_Pips;
  SellTakeprofit47 = Takeprofit_Pips;
  MaxSellLots47 = MaxLots;
  LotsSellChOnLoss47 = 0;
  LotsSellChOnProfit47 = 0;
  LotsSellMpOnLoss47 = LotMultiplierOnLoss;
  LotsSellMpOnProfit47 = LotsMultiplierOnProfit;
  LotsResetOnProfit47 = LotsResetOnProfit;
  LotsResetOnLoss47 = LotsResetOnLoss;
  
  {
    ChartComment();
    
}

    PipValue = 1;
    if (NDigits == 3 || NDigits == 5) PipValue = 10;
    
    CustomIf59();
    ExpiryCheck();
    WeekdayFilter21();
    
}

void CustomIf59()
{
    if (TrailingStop == True)
    {
        TrailingStop58();
        
    }
}

void TrailingStop58()
{
    for (int i=OrdersTotal()-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
            double takeprofit = OrderTakeProfit();
            
            if (OrderType() == OP_BUY && Ask - OrderOpenPrice() > TrailingStop58*PipValue*Point)
            {
                if (OrderStopLoss() < Ask-(TrailingStop58+TrailingGap58)*PipValue*Point)
                {
                    if (NewTakeProfit58 != 0) takeprofit = Ask+(NewTakeProfit58 + TrailingStop58)*PipValue*Point;
                    bool ret1 = OrderModify(OrderTicket(), OrderOpenPrice(), Ask-TrailingStop58*PipValue*Point, takeprofit, OrderExpiration(), White);
                    if (ret1 == false)
                    Print("OrderModify() error - ", ErrorDescription(GetLastError()));
                }
            }
            if (OrderType() == OP_SELL && OrderOpenPrice() - Bid > TrailingStop58*PipValue*Point)
            {
                if (OrderStopLoss() > Bid+(TrailingStop58+TrailingGap58)*PipValue*Point)
                {
                    if (NewTakeProfit58 != 0) takeprofit = Bid-(NewTakeProfit58 + TrailingStop58)*PipValue*Point;
                    bool ret2 = OrderModify(OrderTicket(), OrderOpenPrice(), Bid+TrailingStop58*PipValue*Point, takeprofit, OrderExpiration(), White);
                    if (ret2 == false)
                    Print("OrderModify() error - ", ErrorDescription(GetLastError()));
                }
            }
        }
    }
    else
    Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
    
}

void ExpiryCheck()
{
    if(TimeCurrent() > expDate)
    {
        if(!IsDemo() && !isAuthorized())
        {
            Alert(ExpiryAlert);
            ExpertRemove();
            Comment("\n" + ExpiryAlert);
            return;
        }
    }
}

void WeekdayFilter21()
{
    if ((Monday21 && DayOfWeek() == 1) || (Tuesday21 && DayOfWeek() == 2) || (Wednesday21 && DayOfWeek() == 3) ||
    (Thursday21 && DayOfWeek() == 4) || (Friday21 && DayOfWeek() == 5) || (Saturday21 && DayOfWeek() == 6) || (Sunday21 && DayOfWeek() == 0))
    {
        HoursFilter22();
        
    }
}

void HoursFilter22()
{
    int datetime800 = TimeLocal();
    int hour0 = TimeHour(datetime800);
    
    if ((HoursFrom22 < HoursTo22 && hour0 >= HoursFrom22 && hour0 < HoursTo22) ||
    (HoursFrom22 > HoursTo22 && (hour0 < HoursTo22 || hour0 >= HoursFrom22)))
    {
        CustomIf11();
        CustomIf12();
        CustomIf13();
        CustomIf9();
        CustomIf10();
        
    }
}

void CustomIf11()
{
    if (MultiTimeFrame_Mode==CC)
    {
        TechnicalAnalysis3x130();
        TechnicalAnalysis3x131();
        
    }
}

void TechnicalAnalysis3x130()
{
    if ((iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x127();
        
    }
}

void TechnicalAnalysis3x127()
{
    if ((70 > iRSI(NULL, PERIOD_H4,14,PRICE_CLOSE,current)) && (80 > iStochastic(NULL, PERIOD_H4,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_H4,5,3,3,MODE_SMA,0,MODE_MAIN,current) > iStochastic(NULL, PERIOD_H4,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x117();
        
    }
}

void TechnicalAnalysis3x117()
{
    if ((iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x111();
        
    }
}

void TechnicalAnalysis3x111()
{
    if ((70 > iRSI(NULL, PERIOD_H1,14,PRICE_CLOSE,current)) && (80 > iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,current) > iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x120();
        
    }
}

void TechnicalAnalysis3x120()
{
    if ((iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x112();
        
    }
}

void TechnicalAnalysis3x112()
{
    if ((70 > iRSI(NULL, PERIOD_M15,14,PRICE_CLOSE,current)) && (80 > iStochastic(NULL, PERIOD_M15,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_M15,5,3,3,MODE_SMA,0,MODE_MAIN,current) > iStochastic(NULL, PERIOD_M15,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x84();
        
    }
}

void TechnicalAnalysis3x84()
{
    if ((iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x82();
        
    }
}

void TechnicalAnalysis3x82()
{
    if ((70 > iRSI(NULL, PERIOD_M5,14,PRICE_CLOSE,current)) && (80 > iStochastic(NULL, PERIOD_M5,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_M5,5,3,3,MODE_SMA,0,MODE_MAIN,current) > iStochastic(NULL, PERIOD_M5,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        IfOrderDoesNotExist33();
        
    }
}

void IfOrderDoesNotExist33()
{
    bool exists = false;
    for (int i=OrdersTotal()-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
            exists = true;
        }
    }
    else
    {
        Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
    }
    
    if (exists == false)
    {
        CustomIf39();
        SendEmail37();
        CustomIf38();
        
    }
}

void CustomIf39()
{
    if (Close_On_Reversal == true)
    {
        CloseOrder40();
        
    }
}

void CloseOrder40()
{
    int orderstotal = OrdersTotal();
    int orders = 0;
    int ordticket[90][2];
    for (int i = 0; i < orderstotal; i++)
    {
        bool sel = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderType() != OP_SELL || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
        {
            continue;
        }
        ordticket[orders][0] = OrderOpenTime();
        ordticket[orders][1] = OrderTicket();
        orders++;
    }
    if (orders > 1)
    {
        ArrayResize(ordticket,orders);
        ArraySort(ordticket);
    }
    for (i = 0; i < orders; i++)
    {
        if (OrderSelect(ordticket[i][1], SELECT_BY_TICKET) == true)
        {
            bool ret = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 4, Red);
            if (ret == false)
            Print("OrderClose() error - ", ErrorDescription(GetLastError()));
        }
    }
    BuyOrderLotsMgm34();
    
}

void BuyOrderLotsMgm34()
{
    double profit = 0;
    datetime lastCloseTime = 0;
    int cnt = OrdersHistoryTotal();
    for (int i=0; i < cnt; i++)
    {
        if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && lastCloseTime < OrderCloseTime())
        {
            lastCloseTime = OrderCloseTime();
            profit = OrderProfit();
            CurrentBuyLots34 = OrderLots();     // take lots from the last order
        }
    }
    
    if (profit > 0)     // had profit
    {
        CurrentBuyLots34 = CurrentBuyLots34 * LotsBuyMpOnProfit34 + LotsBuyChOnProfit34;
        if (LotsResetOnProfit34)
        CurrentBuyLots34 = BuyLots34;
    }
    else if (profit < 0)    // had loss
    {
        CurrentBuyLots34 = CurrentBuyLots34 * LotsBuyMpOnLoss34 + LotsBuyChOnLoss34;
        if (LotsResetOnLoss34) CurrentBuyLots34 = BuyLots34;
    }
    if (CurrentBuyLots34 > MaxBuyLots34)
    {
        CurrentBuyLots34 = MaxBuyLots34;
    }
    double lotvalue = CurrentBuyLots34;
    
    if (lotvalue < MarketInfo(Symbol(), MODE_MINLOT))    // make sure lot is not smaller than allowed value
    {
        lotvalue = MarketInfo(Symbol(), MODE_MINLOT);
    }
    if (lotvalue > MarketInfo(Symbol(), MODE_MAXLOT))    // make sure lot is not greater than allowed value
    {
        lotvalue = MarketInfo(Symbol(), MODE_MAXLOT);
    }
    double SL = Ask - BuyStoploss34*PipValue*Point;
    if (BuyStoploss34 == 0) SL = 0;
    double TP = Ask + BuyTakeprofit34*PipValue*Point;
    if (BuyTakeprofit34 == 0) TP = 0;
    FirstBuyLotsMgm34 = false;
    int ticket = -1;
    if (false)
    ticket = OrderSend(Symbol(), OP_BUY, lotvalue, Ask, 4, 0, 0, ExpertComment, MagicNumber, 0, Blue);
    else
    ticket = OrderSend(Symbol(), OP_BUY, lotvalue, Ask, 4, SL, TP, ExpertComment, MagicNumber, 0, Blue);
    if (ticket > -1)
    {
        if (false)
        {
            bool sel = OrderSelect(ticket, SELECT_BY_TICKET);
            bool ret = OrderModify(OrderTicket(), OrderOpenPrice(), SL, TP, 0, Blue);
            if (ret == false)
            Print("OrderModify() error - ", ErrorDescription(GetLastError()));
        }
            
    }
    else
    {
        Print("OrderSend() error - ", ErrorDescription(GetLastError()));
    }
}

void SendEmail37()
{
    double SL = Ask - BuyStoploss34*PipValue*Point; 
    double TP = Ask + BuyTakeprofit34*PipValue*Point;
    
  if (Email_Notification == true)
  {
    SendMail(ExpertComment, Symbol() + ". Buy Signal." + " \nPrice: " + Ask + ". \nTP: " + TP + ". \nSL: " + SL + ". \nMultiTimeFrame Mode: " + TMode );
  }  
  if (Alert_Notification == true)
  {
    Alert(ExpertComment, ". " + Symbol() + ". Buy Signal." + " Price: " + Ask + ". TP: " + TP + ". SL: " + SL + ". \nMultiTimeFrame Mode: " + TMode);
  }
  if (MT4_Messages == true) 
  {
    SendNotification(ExpertComment + ". \n" + Symbol() + ". Buy Signal." + " \nPrice: " + Bid + ". \nTP: " + TP + ". \nSL: " + SL + ". \nMultiTimeFrame Mode: " + TMode);
  }  
  if (tmsrv == true) 
  {
    tms_send(ExpertComment + ". \n" + Symbol() + ". Buy Signal." + " \nPrice: " + Bid + ". \nTP: " + TP + ". \nSL: " + SL + ". \nMultiTimeFrame Mode: " + TMode);
  }  
    
}

void CustomIf38()
{
    if (Close_On_Reversal == false)
    {
        BuyOrderLotsMgm34();
        
    }
}

void TechnicalAnalysis3x131()
{
    if ((iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x132();
        
    }
}

void TechnicalAnalysis3x132()
{
    if ((30 < iRSI(NULL, PERIOD_H4,14,PRICE_CLOSE,current)) && (20 < iStochastic(NULL, PERIOD_H4,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_H4,5,3,3,MODE_SMA,0,MODE_MAIN,current) < iStochastic(NULL, PERIOD_H4,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x118();
        
    }
}

void TechnicalAnalysis3x118()
{
    if ((iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x119();
        
    }
}

void TechnicalAnalysis3x119()
{
    if ((30 < iRSI(NULL, PERIOD_H1,14,PRICE_CLOSE,current)) && (20 < iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,current) < iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x121();
        
    }
}

void TechnicalAnalysis3x121()
{
    if ((iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x113();
        
    }
}

void TechnicalAnalysis3x113()
{
    if ((30 < iRSI(NULL, PERIOD_M15,14,PRICE_CLOSE,current)) && (20 < iStochastic(NULL, PERIOD_M15,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_M15,5,3,3,MODE_SMA,0,MODE_MAIN,current) < iStochastic(NULL, PERIOD_M15,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x83();
        
    }
}

void TechnicalAnalysis3x83()
{
    if ((iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x81();
        
    }
}

void TechnicalAnalysis3x81()
{
    if ((30 < iRSI(NULL, PERIOD_M5,14,PRICE_CLOSE,current)) && (20 < iStochastic(NULL, PERIOD_M5,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_M5,5,3,3,MODE_SMA,0,MODE_MAIN,current) < iStochastic(NULL, PERIOD_M5,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        IfOrderDoesNotExist46();
        
    }
}

void IfOrderDoesNotExist46()
{
    bool exists = false;
    for (int i=OrdersTotal()-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
            exists = true;
        }
    }
    else
    {
        Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
    }
    
    if (exists == false)
    {
        CustomIf36();
        SendEmail38();
        CustomIf35();
        
    }
}

void SendEmail38()
{
    double SL = Bid + SellStoploss47*PipValue*Point; 
    double TP = Bid - SellTakeprofit47*PipValue*Point;
    
  if (Email_Notification == true)
  {
    SendMail(ExpertComment, Symbol() + ". Sell Signal." + " \nPrice: " + Bid + ". \nTP: " + TP + ". \nSL: " + SL + ". \nMultiTimeFrame Mode: " + TMode);
  }
  if (Alert_Notification == true)
  {
    Alert(ExpertComment, ". " + Symbol() + ". Sell Signal." + " Price: " + Bid + ". TP: " + TP + ". SL: " + SL + ". \nMultiTimeFrame Mode: " + TMode);
  }
    if (MT4_Messages == true) 
  {
    SendNotification(ExpertComment + ". \n" + Symbol() + ". Sell Signal." + " \nPrice: " + Bid + ". \nTP: " + TP + ". \nSL: " + SL + ". \nMultiTimeFrame Mode: " + TMode);
  }  
   if (tmsrv == true)
  {
    tms_send(ExpertComment + ". \n" + Symbol() + ". Sell Signal." + " \nPrice: " + Bid + ". \nTP: " + TP + ". \nSL: " + SL + ". \nMultiTimeFrame Mode: " + TMode);
  }  
}

void CustomIf36()
{
    if (Close_On_Reversal == true)
    {
        CloseOrder41();
        
    }
}

void CloseOrder41()
{
    int orderstotal = OrdersTotal();
    int orders = 0;
    int ordticket[90][2];
    for (int i = 0; i < orderstotal; i++)
    {
        bool sel = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderType() != OP_BUY || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
        {
            continue;
        }
        ordticket[orders][0] = OrderOpenTime();
        ordticket[orders][1] = OrderTicket();
        orders++;
    }
    if (orders > 1)
    {
        ArrayResize(ordticket,orders);
        ArraySort(ordticket);
    }
    for (i = 0; i < orders; i++)
    {
        if (OrderSelect(ordticket[i][1], SELECT_BY_TICKET) == true)
        {
            bool ret = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 4, Red);
            if (ret == false)
            Print("OrderClose() error - ", ErrorDescription(GetLastError()));
        }
    }
    SellOrderLotsMgm47();
    
}

void SellOrderLotsMgm47()
{
    double profit = 0;
    datetime lastCloseTime = 0;
    int cnt = OrdersHistoryTotal();
    for (int i=0; i < cnt; i++)
    {
        if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && lastCloseTime < OrderCloseTime())
        {
            lastCloseTime = OrderCloseTime();
            profit = OrderProfit();
            CurrentSellLots47 = OrderLots();
        }
    }
    
    if (profit > 0)     // had profit
    {
        CurrentSellLots47 = CurrentSellLots47 * LotsSellMpOnProfit47 + LotsSellChOnProfit47;
        if (LotsResetOnProfit47)
        CurrentSellLots47 = SellLots47;
    }
    else if (profit < 0)    // had loss
    {
        CurrentSellLots47 = CurrentSellLots47 * LotsSellMpOnLoss47 + LotsSellChOnLoss47;
        if (LotsResetOnLoss47) CurrentSellLots47 = SellLots47;
    }
    if (CurrentSellLots47 > MaxSellLots47)
    {
        CurrentSellLots47 = MaxSellLots47;
    }
    double lotvalue = CurrentSellLots47;
    
    if (lotvalue < MarketInfo(Symbol(), MODE_MINLOT))    // make sure lot is not smaller than allowed value
    {
        lotvalue = MarketInfo(Symbol(), MODE_MINLOT);
    }
    if (lotvalue > MarketInfo(Symbol(), MODE_MAXLOT))    // make sure lot is not greater than allowed value
    {
        lotvalue = MarketInfo(Symbol(), MODE_MAXLOT);
    }
    
    double SL = Bid + SellStoploss47*PipValue*Point;
    if (SellStoploss47 == 0) SL = 0;
    double TP = Bid - SellTakeprofit47*PipValue*Point;
    if (SellTakeprofit47 == 0) TP = 0;
    FirstSellLotsMgm47 = false;
    int ticket = -1;
    if (false)
    ticket = OrderSend(Symbol(), OP_SELL, lotvalue, Bid, 4, 0, 0, ExpertComment, MagicNumber, 0, Red);
    else
    ticket = OrderSend(Symbol(), OP_SELL, lotvalue, Bid, 4, SL, TP, ExpertComment, MagicNumber, 0, Red);
    if (ticket > -1)
    {
        if (false)
        {
            bool sel = OrderSelect(ticket, SELECT_BY_TICKET);
            bool ret = OrderModify(OrderTicket(), OrderOpenPrice(), SL, TP, 0, Red);
            if (ret == false)
            Print("OrderModify() error - ", ErrorDescription(GetLastError()));
        }
            
    }
    else
    {
        Print("OrderSend() error - ", ErrorDescription(GetLastError()));
    }
}

void CustomIf35()
{
    if (Close_On_Reversal == false)
    {
        SellOrderLotsMgm47();
        
    }
}

void CustomIf12()
{
    if (MultiTimeFrame_Mode==DD)
    {
        TechnicalAnalysis3x156();
        TechnicalAnalysis3x155();
        
    }
}

void TechnicalAnalysis3x156()
{
    if ((iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x154();
        
    }
}

void TechnicalAnalysis3x154()
{
    if ((70 > iRSI(NULL, PERIOD_D1,14,PRICE_CLOSE,current)) && (80 > iStochastic(NULL, PERIOD_D1,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_D1,5,3,3,MODE_SMA,0,MODE_MAIN,current) > iStochastic(NULL, PERIOD_D1,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x142();
        
    }
}

void TechnicalAnalysis3x142()
{
    if ((iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x138();
        
    }
}

void TechnicalAnalysis3x138()
{
    if ((70 > iRSI(NULL, PERIOD_H4,14,PRICE_CLOSE,current)) && (80 > iStochastic(NULL, PERIOD_H4,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_H4,5,3,3,MODE_SMA,0,MODE_MAIN,current) > iStochastic(NULL, PERIOD_H4,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x139();
        
    }
}

void TechnicalAnalysis3x139()
{
    if ((iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x137();
        
    }
}

void TechnicalAnalysis3x137()
{
    if ((70 > iRSI(NULL, PERIOD_H1,14,PRICE_CLOSE,current)) && (80 > iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,current) > iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x73();
        
    }
}

void TechnicalAnalysis3x73()
{
    if ((iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x76();
        
    }
}

void TechnicalAnalysis3x76()
{
    if ((70 > iRSI(NULL, PERIOD_M15,14,PRICE_CLOSE,current)) && (80 > iStochastic(NULL, PERIOD_M15,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_M15,5,3,3,MODE_SMA,0,MODE_MAIN,current) > iStochastic(NULL, PERIOD_M15,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        IfOrderDoesNotExist33();
        
    }
}

void TechnicalAnalysis3x155()
{
    if ((iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x153();
        
    }
}

void TechnicalAnalysis3x153()
{
    if ((30 < iRSI(NULL, PERIOD_D1,14,PRICE_CLOSE,current)) && (20 < iStochastic(NULL, PERIOD_D1,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_D1,5,3,3,MODE_SMA,0,MODE_MAIN,current) < iStochastic(NULL, PERIOD_D1,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x143();
        
    }
}

void TechnicalAnalysis3x143()
{
    if ((iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x144();
        
    }
}

void TechnicalAnalysis3x144()
{
    if ((30 < iRSI(NULL, PERIOD_H4,14,PRICE_CLOSE,current)) && (20 < iStochastic(NULL, PERIOD_H4,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_H4,5,3,3,MODE_SMA,0,MODE_MAIN,current) < iStochastic(NULL, PERIOD_H4,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x140();
        
    }
}

void TechnicalAnalysis3x140()
{
    if ((iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x141();
        
    }
}

void TechnicalAnalysis3x141()
{
    if ((30 < iRSI(NULL, PERIOD_H1,14,PRICE_CLOSE,current)) && (20 < iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,current) < iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x78();
        
    }
}

void TechnicalAnalysis3x78()
{
    if ((iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x77();
        
    }
}

void TechnicalAnalysis3x77()
{
    if ((30 < iRSI(NULL, PERIOD_M15,14,PRICE_CLOSE,current)) && (20 < iStochastic(NULL, PERIOD_M15,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_M15,5,3,3,MODE_SMA,0,MODE_MAIN,current) < iStochastic(NULL, PERIOD_M15,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        IfOrderDoesNotExist46();
        
    }
}

void CustomIf13()
{
    if (MultiTimeFrame_Mode==EE)
    {
        TechnicalAnalysis3x150();
        TechnicalAnalysis3x149();
        
    }
}

void TechnicalAnalysis3x150()
{
    if ((iIchimoku(NULL, PERIOD_W1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_W1,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_W1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_W1,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_W1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_W1,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x148();
        
    }
}

void TechnicalAnalysis3x148()
{
    if ((70 > iRSI(NULL, PERIOD_W1,14,PRICE_CLOSE,current)) && (80 > iStochastic(NULL, PERIOD_W1,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_W1,5,3,3,MODE_SMA,0,MODE_MAIN,current) > iStochastic(NULL, PERIOD_W1,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x124();
        
    }
}

void TechnicalAnalysis3x124()
{
    if ((iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x114();
        
    }
}

void TechnicalAnalysis3x114()
{
    if ((70 > iRSI(NULL, PERIOD_D1,14,PRICE_CLOSE,current)) && (80 > iStochastic(NULL, PERIOD_D1,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_D1,5,3,3,MODE_SMA,0,MODE_MAIN,current) > iStochastic(NULL, PERIOD_D1,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x87();
        
    }
}

void TechnicalAnalysis3x87()
{
    if ((iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x90();
        
    }
}

void TechnicalAnalysis3x90()
{
    if ((70 > iRSI(NULL, PERIOD_H4,14,PRICE_CLOSE,current)) && (80 > iStochastic(NULL, PERIOD_H4,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_H4,5,3,3,MODE_SMA,0,MODE_MAIN,current) > iStochastic(NULL, PERIOD_H4,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x63();
        
    }
}

void TechnicalAnalysis3x63()
{
    if ((iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x66();
        
    }
}

void TechnicalAnalysis3x66()
{
    if ((70 > iRSI(NULL, PERIOD_H1,14,PRICE_CLOSE,current)) && (80 > iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,current) > iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        IfOrderDoesNotExist33();
        
    }
}

void TechnicalAnalysis3x149()
{
    if ((iIchimoku(NULL, PERIOD_W1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_W1,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_W1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_W1,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_W1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_W1,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x147();
        
    }
}

void TechnicalAnalysis3x147()
{
    if ((30 < iRSI(NULL, PERIOD_W1,14,PRICE_CLOSE,current)) && (20 < iStochastic(NULL, PERIOD_W1,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_W1,5,3,3,MODE_SMA,0,MODE_MAIN,current) < iStochastic(NULL, PERIOD_W1,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x125();
        
    }
}

void TechnicalAnalysis3x125()
{
    if ((iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_D1,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x126();
        
    }
}

void TechnicalAnalysis3x126()
{
    if ((30 < iRSI(NULL, PERIOD_D1,14,PRICE_CLOSE,current)) && (20 < iStochastic(NULL, PERIOD_D1,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_D1,5,3,3,MODE_SMA,0,MODE_MAIN,current) < iStochastic(NULL, PERIOD_D1,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x88();
        
    }
}

void TechnicalAnalysis3x88()
{
    if ((iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H4,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x89();
        
    }
}

void TechnicalAnalysis3x89()
{
    if ((30 < iRSI(NULL, PERIOD_H4,14,PRICE_CLOSE,current)) && (20 < iStochastic(NULL, PERIOD_H4,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_H4,5,3,3,MODE_SMA,0,MODE_MAIN,current) < iStochastic(NULL, PERIOD_H4,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x64();
        
    }
}

void TechnicalAnalysis3x64()
{
    if ((iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x65();
        
    }
}

void TechnicalAnalysis3x65()
{
    if ((30 < iRSI(NULL, PERIOD_H1,14,PRICE_CLOSE,current)) && (20 < iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,current) < iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        IfOrderDoesNotExist46();
        
    }
}

void CustomIf9()
{
    if (MultiTimeFrame_Mode==BB)
    {
        TechnicalAnalysis3x105();
        TechnicalAnalysis3x106();
        
    }
}

void TechnicalAnalysis3x105()
{
    if ((iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x108();
        
    }
}

void TechnicalAnalysis3x108()
{
    if ((70 > iRSI(NULL, PERIOD_H1,14,PRICE_CLOSE,current)) && (80 > iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,current) > iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x91();
        
    }
}

void TechnicalAnalysis3x91()
{
    if ((iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x94();
        
    }
}

void TechnicalAnalysis3x94()
{
    if ((70 > iRSI(NULL, PERIOD_M15,14,PRICE_CLOSE,current)) && (80 > iStochastic(NULL, PERIOD_M15,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_M15,5,3,3,MODE_SMA,0,MODE_MAIN,current) > iStochastic(NULL, PERIOD_M15,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x102();
        
    }
}

void TechnicalAnalysis3x102()
{
    if ((iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x100();
        
    }
}

void TechnicalAnalysis3x100()
{
    if ((70 > iRSI(NULL, PERIOD_M5,14,PRICE_CLOSE,current)) && (80 > iStochastic(NULL, PERIOD_M5,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_M5,5,3,3,MODE_SMA,0,MODE_MAIN,current) > iStochastic(NULL, PERIOD_M5,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x69();
        
    }
}

void TechnicalAnalysis3x69()
{
    if ((iIchimoku(NULL, PERIOD_M1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_M1,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_M1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_M1,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_M1,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_M1,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x71();
        
    }
}

void TechnicalAnalysis3x71()
{
    if ((70 > iRSI(NULL, PERIOD_M1,14,PRICE_CLOSE,current)) && (80 > iStochastic(NULL, PERIOD_M1,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_M1,5,3,3,MODE_SMA,0,MODE_MAIN,current) > iStochastic(NULL, PERIOD_M1,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        IfOrderDoesNotExist33();
        
    }
}

void TechnicalAnalysis3x106()
{
    if ((iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_H1,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x107();
        
    }
}

void TechnicalAnalysis3x107()
{
    if ((30 < iRSI(NULL, PERIOD_H1,14,PRICE_CLOSE,current)) && (20 < iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,current) < iStochastic(NULL, PERIOD_H1,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x96();
        
    }
}

void TechnicalAnalysis3x96()
{
    if ((iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_M15,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x95();
        
    }
}

void TechnicalAnalysis3x95()
{
    if ((30 < iRSI(NULL, PERIOD_M15,14,PRICE_CLOSE,current)) && (20 < iStochastic(NULL, PERIOD_M15,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_M15,5,3,3,MODE_SMA,0,MODE_MAIN,current) < iStochastic(NULL, PERIOD_M15,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x101();
        
    }
}

void TechnicalAnalysis3x101()
{
    if ((iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_M5,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x99();
        
    }
}

void TechnicalAnalysis3x99()
{
    if ((30 < iRSI(NULL, PERIOD_M5,14,PRICE_CLOSE,current)) && (20 < iStochastic(NULL, PERIOD_M5,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_M5,5,3,3,MODE_SMA,0,MODE_MAIN,current) < iStochastic(NULL, PERIOD_M5,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        TechnicalAnalysis3x70();
        
    }
}

void TechnicalAnalysis3x70()
{
    if ((iIchimoku(NULL, PERIOD_M1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_M1,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_M1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_M1,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_M1,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_M1,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x72();
        
    }
}

void TechnicalAnalysis3x72()
{
    if ((30 < iRSI(NULL, PERIOD_M1,14,PRICE_CLOSE,current)) && (20 < iStochastic(NULL, PERIOD_M1,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_M1,5,3,3,MODE_SMA,0,MODE_MAIN,current) < iStochastic(NULL, PERIOD_M1,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        IfOrderDoesNotExist46();
        
    }
}

void CustomIf10()
{
    if (MultiTimeFrame_Mode==AA)
    {
        TechnicalAnalysis3x52();
        TechnicalAnalysis3x53();
        
    }
}

void TechnicalAnalysis3x52()
{
    if ((iIchimoku(NULL, PERIOD_CURRENT,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_CURRENT,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_CURRENT,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_CURRENT,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_CURRENT,9,26,52,MODE_TENKANSEN,current) > iIchimoku(NULL, PERIOD_CURRENT,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x50();
        
    }
}

void TechnicalAnalysis3x50()
{
    if ((70 > iRSI(NULL, PERIOD_CURRENT,14,PRICE_CLOSE,current)) && (80 > iStochastic(NULL, PERIOD_CURRENT,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_CURRENT,5,3,3,MODE_SMA,0,MODE_MAIN,current) > iStochastic(NULL, PERIOD_CURRENT,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        OncePerBar6();
        
    }
}

void OncePerBar6()
{
    
    if (BarTime6 < Time[0])
    {
        // we have a new bar opened
        BarTime6 = Time[0]; // keep the new bar open time
        IfOrderDoesNotExist33();
        
    }
}

void TechnicalAnalysis3x53()
{
    if ((iIchimoku(NULL, PERIOD_CURRENT,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_CURRENT,9,26,52,MODE_SENKOUSPANA,current)) && (iIchimoku(NULL, PERIOD_CURRENT,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_CURRENT,9,26,52,MODE_SENKOUSPANB,current)) && (iIchimoku(NULL, PERIOD_CURRENT,9,26,52,MODE_TENKANSEN,current) < iIchimoku(NULL, PERIOD_CURRENT,9,26,52,MODE_KIJUNSEN,current)))
    {
        TechnicalAnalysis3x60();
        
    }
}

void TechnicalAnalysis3x60()
{
    if ((30 < iRSI(NULL, PERIOD_CURRENT,14,PRICE_CLOSE,current)) && (20 < iStochastic(NULL, PERIOD_CURRENT,5,3,3,MODE_SMA,0,MODE_MAIN,current)) && (iStochastic(NULL, PERIOD_CURRENT,5,3,3,MODE_SMA,0,MODE_MAIN,current) < iStochastic(NULL, PERIOD_CURRENT,5,3,3,MODE_SMA,0,MODE_SIGNAL,current)))
    {
        OncePerBar48();
        
    }
}

void OncePerBar48()
{
    
    if (BarTime48 < Time[0])
    {
        // we have a new bar opened
        BarTime48 = Time[0]; // keep the new bar open time
        IfOrderDoesNotExist46();
        
    }
}



int deinit()
{
    if (false) ObjectsDeleteAll();
    
    
    
    
    return (0);
}


datetime _tms_last_time_messaged;
extern bool tms_send(string message, string token="-1001763778949:9f05a430"){  
   const string url = "https://tmsrv.pw/send/v1";   
   
   string response,headers; 
   int result;
   char post[],res[]; 
   
   if(IsTesting() || IsOptimization()) return true;
   if(_tms_last_time_messaged == Time[0]) return false; // do not send twice at the same candle;  

   string spost = StringFormat("message=%s&token=%s&code=MQL",message,token);
   

   ArrayResize(post,StringToCharArray(spost,post,0,WHOLE_ARRAY,CP_UTF8)-1);

   result = WebRequest("POST",url,"",NULL,3000,post,ArraySize(post),res,headers);
   _tms_last_time_messaged = Time[0];
       
   if(result==-1) {
         if(GetLastError() == 4060) {
            printf("tms_send() | Add the address %s in the list of allowed URLs on tab 'Expert Advisors'",url);
         } else {
            printf("tms_send() | webrequest filed - error № %i", GetLastError());
         }
         return false;
   } else { 
      response = CharArrayToString(res,0,WHOLE_ARRAY);
     
      if(StringFind(response,"\"ok\":true")==-1) {

         printf("tms_send() return an error - %s",response);
         return false;
      }
   }
  
  Sleep(1000); //to prevent sending more than 1 message per seccond
  return true;
}
//+------------------------------------------------------------------+
//| The comment that will appear on chart                            |
//+------------------------------------------------------------------+
void ChartComment()
{
   datetime Today = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day()));
   string Date = TimeToStr(TimeCurrent(), TIME_DATE + TIME_MINUTES + TIME_SECONDS);
   string expDateStr = TimeToStr(expDate, TIME_DATE + TIME_MINUTES + TIME_SECONDS);

   if(isAuthorized() || IsDemo())
   {
      Comment(
         "\n Copyright © 2022, BuBat's Trading",
         "\n ", Date, "\n",
         "\n ", AuthMessage(), "\n",
         "\n ", EA_Name,
         "\n Starting Lot: ", Lots,
         "\n Layer Multiplier: ", MartingaleMultiplier,
         "\n Equity: $", NormalizeDouble(AccountInfoDouble(ACCOUNT_EQUITY), 2),
         "\n Buy: ", CountBuy(), " | Sell: ", CountSell(),
         "\n");
   }
   else if(!isAuthorized() && !IsDemo() && (TimeCurrent() < expDate))
   {
      Comment(
         "\n Copyright © 2022, BuBat's Trading",
         "\n ", Date, "\n",
         "\n ", AuthMessage(), "\n",
         "\n ", EA_Name,
         "\n Starting Lot: ", Lots,
         "\n Layer Multiplier: ", MartingaleMultiplier,
         "\n Equity: $", NormalizeDouble(AccountInfoDouble(ACCOUNT_EQUITY), 2),
         "\n Buy: ", CountBuy(), " | Sell: ", CountSell(),
         "\n\n ExpireDate: ", expDateStr,
         "\n");
   }
   else
   {
      Alert(ExpiryAlert);
      ExpertRemove();
      Comment("\n" + ExpiryAlert);
   }
}
//+------------------------------------------------------------------+
//| Authorization                                                    |
//+------------------------------------------------------------------+
bool isAuthorized()
{
   int accountNumber = AccountNumber();
   string accountName = AccountName();
   bool isAllowed = false;

   for(int i = ArraySize(allowedAccountNumbers) - 1; i >= 0; i--)
   {
      if(accountNumber == allowedAccountNumbers[i])
      {
         isAllowed = true;
         break;
      }
   }

   if(!isAllowed)
   {
      for(int i = ArraySize(allowedAccountNames) - 1; i >= 0; i--)
      {
         if(accountName == allowedAccountNames[i])
         {
            isAllowed = true;
            break;
         }
      }
   }

   return isAllowed;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RunAuthorization()
{
   if(IsDemo())
   {
      Print("Demo account detected, skipping authorization");
      return (INIT_SUCCEEDED);
   }
   if(TimeCurrent() > expDate)
   {
      if(isAuthorized())
      {
         return (INIT_SUCCEEDED);
      }
      else
      {
         Alert(ExpiryAlert);
         ExpertRemove();
         Comment("\n" + ExpiryAlert);
         return (INIT_FAILED);
      }
   }
   else
      return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string AuthMessage()
{
   if(IsDemo())
   {
      return("Demo account detected.\n Account Authorized.\n Account Number: " + IntegerToString(AccountNumber()) + "\n Account Name: " + AccountName());
   }
   else if((TimeCurrent() < expDate) && (isAuthorized() == false))
   {
      return("Account " + IntegerToString(AccountNumber()) + " is Unauthorized, EA will expire soon.\n Trials Mode Activated.");
   }
   else if(RunAuthorization() == (INIT_SUCCEEDED) && IsDemo() == false)
   {
      return("Account Authorized.\n Account Number: " + IntegerToString(AccountNumber()) + "\n Account Name: " + AccountName());
   }
   else
      return(ExpiryAlert);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountSell()
{
   RefreshRates();
   int k = 0;
   int index = OrdersTotal() - 1;
   while(index >= 0 && OrderSelect(index, SELECT_BY_POS, MODE_TRADES) == true)
   {
      if(OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber)
      {
         if(OrderType() == OP_SELL)
            k++;
      }
      index--;
   }
   return k;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountBuy()
{
   RefreshRates();
   int k = 0;
   int index = OrdersTotal() - 1;
   while(index >= 0 && OrderSelect(index, SELECT_BY_POS, MODE_TRADES) == true)
   {
      if(OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber)
      {
         if(OrderType() == OP_BUY)
            k++;
      }
      index--;
   }
   return k;
}
//+------------------------------------------------------------------+
