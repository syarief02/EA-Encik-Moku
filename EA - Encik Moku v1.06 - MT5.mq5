//+------------------------------------------------------------------+
//|                                      EA Encik Moku v1.06 MT5.mq5 |
//|                                 Copyright © 2022, Syarief Azman. |
//|                                          http://t.me/EABudakUbat |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, BuBat's Trading"
#property link      "https://t.me/EABudakUbat"
#property version   "1.06"
#property description "This is a single entry EA."
#property description "Recommended capital is 100 usd, choose trending pair."
#property description "The EA Trades based on Ichimoku Kinko Hyo, RSI, and Stoch."
#property description "It buy above kumo and sell below kumo."
#property description "MultiTimeFrame mode take 4 different timeframes into account before entering trades."
#property description " "
#property description "Ayuh bangkit darah pahlawan. Pantang undur sebelum MC. Agi idop, agi ngelaban! "
#property description "Join our Telegram channel : https://t.me/EAEncikMoku"
#property description "Facebook : https://m.me/EABudakUbat"
#property description "Tel: +60194961568 (Budak Ubat)"
#property icon        "\\Images\\bupurple.ico";

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>

#define Copyright "Copyright © 2022, BuBat's Trading"

//+------------------------------------------------------------------+
//| Name of the EA                                                   |
//+------------------------------------------------------------------+
input string EA_Name = "EA Encik Moku v1.06 MT5";
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

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input double Lots = 0.01;
input int    Takeprofit_Pips = 50;
input int    Stoploss_Pips = 50;
input bool   Close_On_Reversal = true;
string ExpertComment;

enum trdtype
  {
   AA = 0,   // No MTF  (Current TimeFrame only)
   BB = 1,   // Scalperz (H1, M15, M5, M1)
   CC = 2,   // Intradayz (H4, H1, M15, M5)
   DD = 3,   // Swingz     (D1, H4, H1, M15)
   EE = 4,   // Positionz (W1, D1, H4, H1)
  };

input trdtype MultiTimeFrame_Mode = CC;

enum compound
  {
   A = 0,   // Off                         (EntryLot = Lots)
   B = 1,   // Very High Risk (EntryLot = Lots / 50 * Equity)
   C = 2,   // High Risk           (EntryLot = Lots / 100 * Equity)
   D = 3,   // Medium Risk     (EntryLot = Lots / 1000 * Equity)
   E = 4,   // Low Risk             (EntryLot = Lots / 10000 * Equity)
   F = 5,   // Very Low Risk   (EntryLot = Lots / 100000 * Equity)
  };

input compound AutoCompounding_Mode = A;
input bool   ECN_Broker = false;

input string __Trailing_Function_Below__ = "__Trailing_Function_Below__";
input bool   TrailingStop_Enabled = false;
input int    TrailingStop_Pips = 25;
input int    TrailingGap_Pips = 7;
input int    NewTakeProfit_Pips = 0;

input string __Trading_Time_Function_Below__ = "__Trading_Time_Function_Below__";
input bool   Monday = true;
input bool   Tuesday = true;
input bool   Wednesday = true;
input bool   Thursday = true;
input bool   Friday = true;
input bool   Saturday = true;
input bool   Sunday = true;
input int    HoursFrom = 0;
input int    HoursTo = 24;

input string __Martingale_Function_Below__ = "__Martingale_Function_Below__";
input double LotMultiplierOnLoss = 2.25;
input double LotsMultiplierOnProfit = 1;
input double MaxLots = 999;
input bool   LotsResetOnProfit = true;
input bool   LotsResetOnLoss = false;

input string __Notification_Settings__ = "__Notification_Settings__";
input bool   Email_Notification = true;
input bool   Alert_Notification = false;
input bool   MT5_Messages = true;

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
int MagicNumber = 260328;
double PipValue = 1;
bool Terminated = false;
string TMode;
string CTF;
double EntryLots;
double MartingaleMultiplier;

double CurrentBuyLots;
double CurrentSellLots;

datetime BarTime6 = 0;
datetime BarTime48 = 0;

CTrade trade;
CPositionInfo posInfo;

// Ichimoku handles for 7 timeframes: W1, D1, H4, H1, M15, M5, M1
int h_ichimoku[7];
int h_stoch[7];
int h_rsi[7];

ENUM_TIMEFRAMES TF_Array[7] = {PERIOD_W1, PERIOD_D1, PERIOD_H4, PERIOD_H1, PERIOD_M15, PERIOD_M5, PERIOD_M1};

//+------------------------------------------------------------------+
//| Ichimoku buffer helpers                                          |
//| Buffer 0 = Tenkan-sen, 1 = Kijun-sen, 2 = Senkou Span A,       |
//| 3 = Senkou Span B, 4 = Chikou Span                              |
//+------------------------------------------------------------------+
double GetIchimoku(int tfIdx, int buffer, int shift)
  {
   double val[];
   ArraySetAsSeries(val, true);
   if(CopyBuffer(h_ichimoku[tfIdx], buffer, shift, 1, val) <= 0)
      return 0;
   return val[0];
  }

double GetTenkan(int tfIdx, int shift)    { return GetIchimoku(tfIdx, 0, shift); }
double GetKijun(int tfIdx, int shift)     { return GetIchimoku(tfIdx, 1, shift); }
double GetSenkouA(int tfIdx, int shift)   { return GetIchimoku(tfIdx, 2, shift); }
double GetSenkouB(int tfIdx, int shift)   { return GetIchimoku(tfIdx, 3, shift); }

double GetStochMain(int tfIdx, int shift)
  {
   double val[];
   ArraySetAsSeries(val, true);
   if(CopyBuffer(h_stoch[tfIdx], 0, shift, 1, val) <= 0)
      return 0;
   return val[0];
  }

double GetStochSignal(int tfIdx, int shift)
  {
   double val[];
   ArraySetAsSeries(val, true);
   if(CopyBuffer(h_stoch[tfIdx], 1, shift, 1, val) <= 0)
      return 0;
   return val[0];
  }

double GetRSI(int tfIdx, int shift)
  {
   double val[];
   ArraySetAsSeries(val, true);
   if(CopyBuffer(h_rsi[tfIdx], 0, shift, 1, val) <= 0)
      return 0;
   return val[0];
  }

int TFIndex(ENUM_TIMEFRAMES tf)
  {
   for(int i = 0; i < 7; i++)
      if(TF_Array[i] == tf)
         return i;
   return 3; // default H1
  }

//+------------------------------------------------------------------+
//| Bullish check: Tenkan > Senkou A, Tenkan > Senkou B, Tenkan > Kijun |
//| + RSI < 70, Stoch main < 80 && main > signal                    |
//+------------------------------------------------------------------+
bool IsBullishTF(ENUM_TIMEFRAMES tf)
  {
   int idx = TFIndex(tf);
   double tenkan  = GetTenkan(idx, 0);
   double kijun   = GetKijun(idx, 0);
   double senkouA = GetSenkouA(idx, 0);
   double senkouB = GetSenkouB(idx, 0);
   double rsi     = GetRSI(idx, 0);
   double stochMain   = GetStochMain(idx, 0);
   double stochSignal = GetStochSignal(idx, 0);

   // Ichimoku: Tenkan above Kumo and above Kijun
   if(!(tenkan > senkouA && tenkan > senkouB && tenkan > kijun))
      return false;

   // RSI < 70
   if(rsi >= 70)
      return false;

   // Stochastic: main < 80 AND main > signal
   if(stochMain >= 80 || stochMain <= stochSignal)
      return false;

   return true;
  }

//+------------------------------------------------------------------+
//| Bearish check: Tenkan < Senkou A, Tenkan < Senkou B, Tenkan < Kijun |
//| + RSI > 30, Stoch main > 20 && main < signal                    |
//+------------------------------------------------------------------+
bool IsBearishTF(ENUM_TIMEFRAMES tf)
  {
   int idx = TFIndex(tf);
   double tenkan  = GetTenkan(idx, 0);
   double kijun   = GetKijun(idx, 0);
   double senkouA = GetSenkouA(idx, 0);
   double senkouB = GetSenkouB(idx, 0);
   double rsi     = GetRSI(idx, 0);
   double stochMain   = GetStochMain(idx, 0);
   double stochSignal = GetStochSignal(idx, 0);

   if(!(tenkan < senkouA && tenkan < senkouB && tenkan < kijun))
      return false;

   if(rsi <= 30)
      return false;

   if(stochMain <= 20 || stochMain >= stochSignal)
      return false;

   return true;
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ExpertComment = EA_Name;
   ExpiryAlert = EA_Name + " IS EXPIRED. "
                 "\nAccount " + IntegerToString((int)AccountInfoInteger(ACCOUNT_LOGIN)) + " is Unauthorized. "
                 "\nUse Demo account to access Trials Mode. "
                 "\nPLEASE CONTACT " + Owner + " FOR MORE INFO. "
                 "\n" + Contact;
   MartingaleMultiplier = LotMultiplierOnLoss;

   CurrentBuyLots = Lots;
   CurrentSellLots = Lots;

   PipValue = 1;
   if(_Digits == 3 || _Digits == 5)
      PipValue = 10;

   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(4);

   for(int i = 0; i < 7; i++)
     {
      h_ichimoku[i] = iIchimoku(_Symbol, TF_Array[i], 9, 26, 52);
      h_stoch[i]    = iStochastic(_Symbol, TF_Array[i], 5, 3, 3, MODE_SMA, STO_LOWHIGH);
      h_rsi[i]      = iRSI(_Symbol, TF_Array[i], 14, PRICE_CLOSE);

      if(h_ichimoku[i] == INVALID_HANDLE || h_stoch[i] == INVALID_HANDLE || h_rsi[i] == INVALID_HANDLE)
        {
         Print("Failed to create indicator handle for TF index ", i);
         return(INIT_FAILED);
        }
     }

   RunAuthorization();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int i = 0; i < 7; i++)
     {
      if(h_ichimoku[i] != INVALID_HANDLE)
         IndicatorRelease(h_ichimoku[i]);
      if(h_stoch[i] != INVALID_HANDLE)
         IndicatorRelease(h_stoch[i]);
      if(h_rsi[i] != INVALID_HANDLE)
         IndicatorRelease(h_rsi[i]);
     }
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   ChartCommentDisplay();

   if(Bars(_Symbol, PERIOD_CURRENT) < 10)
     {
      Comment("Not enough bars");
      return;
     }

   if(Terminated)
     {
      Comment("EA Terminated.");
      return;
     }

   OnEveryTick();
  }

//+------------------------------------------------------------------+
//| Main trading logic per tick                                      |
//+------------------------------------------------------------------+
void OnEveryTick()
  {
   ENUM_TIMEFRAMES currentPeriod = (ENUM_TIMEFRAMES)Period();
   switch(currentPeriod)
     {
      case PERIOD_M1:  CTF = "M1";  break;
      case PERIOD_M5:  CTF = "M5";  break;
      case PERIOD_M15: CTF = "M15"; break;
      case PERIOD_M30: CTF = "M30"; break;
      case PERIOD_H1:  CTF = "H1";  break;
      case PERIOD_H4:  CTF = "H4";  break;
      case PERIOD_D1:  CTF = "D1";  break;
      case PERIOD_W1:  CTF = "W1";  break;
      case PERIOD_MN1: CTF = "MN";  break;
      default:         CTF = "??";  break;
     }

   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   switch(AutoCompounding_Mode)
     {
      case A: EntryLots = Lots; break;
      case B: EntryLots = NormalizeDouble(Lots / 50.0 * equity, 2); break;
      case C: EntryLots = NormalizeDouble(Lots / 100.0 * equity, 2); break;
      case D: EntryLots = NormalizeDouble(Lots / 1000.0 * equity, 2); break;
      case E: EntryLots = NormalizeDouble(Lots / 10000.0 * equity, 2); break;
      case F: EntryLots = NormalizeDouble(Lots / 100000.0 * equity, 2); break;
     }

   switch(MultiTimeFrame_Mode)
     {
      case AA: TMode = "No MTF (" + CTF + ")"; break;
      case BB: TMode = "Scalperz (H1>M15>M5>M1)"; break;
      case CC: TMode = "Intradayz (H4>H1>M15>M5)"; break;
      case DD: TMode = "Swingz (D1>H4>H1>M15)"; break;
      case EE: TMode = "Positionz (W1>D1>H4>H1)"; break;
     }

   ExpiryCheck();

   MqlDateTime dt;
   TimeLocal(dt);
   int dow = dt.day_of_week;
   bool dayAllowed = false;
   if((Monday && dow == 1) || (Tuesday && dow == 2) || (Wednesday && dow == 3) ||
      (Thursday && dow == 4) || (Friday && dow == 5) || (Saturday && dow == 6) || (Sunday && dow == 0))
      dayAllowed = true;

   if(!dayAllowed) return;

   int hour0 = dt.hour;
   bool hourAllowed = false;
   if(HoursFrom < HoursTo)
      hourAllowed = (hour0 >= HoursFrom && hour0 < HoursTo);
   else if(HoursFrom > HoursTo)
      hourAllowed = (hour0 < HoursTo || hour0 >= HoursFrom);
   else
      hourAllowed = true;

   if(!hourAllowed) return;

   CheckBuySignal();
   CheckSellSignal();

   if(TrailingStop_Enabled)
      DoTrailingStop();
  }

//+------------------------------------------------------------------+
void ExpiryCheck()
  {
   if(TimeCurrent() > expDate)
     {
      if(!IsDemo() && !isAuthorized())
        {
         Alert(ExpiryAlert);
         ExpertRemove();
         Comment("\n" + ExpiryAlert);
        }
     }
  }

bool IsDemo()
  {
   return (AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO);
  }

//+------------------------------------------------------------------+
//| Check buy signal based on MTF mode                               |
//+------------------------------------------------------------------+
void CheckBuySignal()
  {
   bool buySignal = false;

   switch(MultiTimeFrame_Mode)
     {
      case EE:
         buySignal = IsBullishTF(PERIOD_W1) && IsBullishTF(PERIOD_D1) &&
                     IsBullishTF(PERIOD_H4) && IsBullishTF(PERIOD_H1);
         break;
      case DD:
         buySignal = IsBullishTF(PERIOD_D1) && IsBullishTF(PERIOD_H4) &&
                     IsBullishTF(PERIOD_H1) && IsBullishTF(PERIOD_M15);
         break;
      case CC:
         buySignal = IsBullishTF(PERIOD_H4) && IsBullishTF(PERIOD_H1) &&
                     IsBullishTF(PERIOD_M15) && IsBullishTF(PERIOD_M5);
         break;
      case BB:
         buySignal = IsBullishTF(PERIOD_H1) && IsBullishTF(PERIOD_M15) &&
                     IsBullishTF(PERIOD_M5) && IsBullishTF(PERIOD_M1);
         break;
      case AA:
        {
         ENUM_TIMEFRAMES curTF = (ENUM_TIMEFRAMES)Period();
         if(IsBullishTF(curTF))
           {
            datetime barTimes[];
            ArraySetAsSeries(barTimes, true);
            if(CopyTime(_Symbol, PERIOD_CURRENT, 0, 1, barTimes) > 0)
              {
               if(BarTime6 < barTimes[0])
                 {
                  BarTime6 = barTimes[0];
                  buySignal = true;
                 }
              }
           }
        }
      break;
     }

   if(buySignal)
     {
      if(!BuyExists())
        {
         if(Close_On_Reversal)
            CloseSellPositions();
         BuyOrderWithMgm();
        }
     }
  }

//+------------------------------------------------------------------+
//| Check sell signal based on MTF mode                              |
//+------------------------------------------------------------------+
void CheckSellSignal()
  {
   bool sellSignal = false;

   switch(MultiTimeFrame_Mode)
     {
      case EE:
         sellSignal = IsBearishTF(PERIOD_W1) && IsBearishTF(PERIOD_D1) &&
                      IsBearishTF(PERIOD_H4) && IsBearishTF(PERIOD_H1);
         break;
      case DD:
         sellSignal = IsBearishTF(PERIOD_D1) && IsBearishTF(PERIOD_H4) &&
                      IsBearishTF(PERIOD_H1) && IsBearishTF(PERIOD_M15);
         break;
      case CC:
         sellSignal = IsBearishTF(PERIOD_H4) && IsBearishTF(PERIOD_H1) &&
                      IsBearishTF(PERIOD_M15) && IsBearishTF(PERIOD_M5);
         break;
      case BB:
         sellSignal = IsBearishTF(PERIOD_H1) && IsBearishTF(PERIOD_M15) &&
                      IsBearishTF(PERIOD_M5) && IsBearishTF(PERIOD_M1);
         break;
      case AA:
        {
         ENUM_TIMEFRAMES curTF = (ENUM_TIMEFRAMES)Period();
         if(IsBearishTF(curTF))
           {
            datetime barTimes[];
            ArraySetAsSeries(barTimes, true);
            if(CopyTime(_Symbol, PERIOD_CURRENT, 0, 1, barTimes) > 0)
              {
               if(BarTime48 < barTimes[0])
                 {
                  BarTime48 = barTimes[0];
                  sellSignal = true;
                 }
              }
           }
        }
      break;
     }

   if(sellSignal)
     {
      if(!SellExists())
        {
         if(Close_On_Reversal)
            CloseBuyPositions();
         SellOrderWithMgm();
        }
     }
  }

//+------------------------------------------------------------------+
bool BuyExists()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(posInfo.SelectByIndex(i))
         if(posInfo.Symbol() == _Symbol && posInfo.Magic() == MagicNumber && posInfo.PositionType() == POSITION_TYPE_BUY)
            return true;
   return false;
  }

bool SellExists()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(posInfo.SelectByIndex(i))
         if(posInfo.Symbol() == _Symbol && posInfo.Magic() == MagicNumber && posInfo.PositionType() == POSITION_TYPE_SELL)
            return true;
   return false;
  }

int CountBuy()
  {
   int k = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(posInfo.SelectByIndex(i))
         if(posInfo.Symbol() == _Symbol && posInfo.Magic() == MagicNumber && posInfo.PositionType() == POSITION_TYPE_BUY)
            k++;
   return k;
  }

int CountSell()
  {
   int k = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(posInfo.SelectByIndex(i))
         if(posInfo.Symbol() == _Symbol && posInfo.Magic() == MagicNumber && posInfo.PositionType() == POSITION_TYPE_SELL)
            k++;
   return k;
  }

void CloseSellPositions()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(posInfo.SelectByIndex(i))
         if(posInfo.Symbol() == _Symbol && posInfo.Magic() == MagicNumber && posInfo.PositionType() == POSITION_TYPE_SELL)
            trade.PositionClose(posInfo.Ticket());
  }

void CloseBuyPositions()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(posInfo.SelectByIndex(i))
         if(posInfo.Symbol() == _Symbol && posInfo.Magic() == MagicNumber && posInfo.PositionType() == POSITION_TYPE_BUY)
            trade.PositionClose(posInfo.Ticket());
  }

//+------------------------------------------------------------------+
//| Martingale: get last deal profit                                 |
//+------------------------------------------------------------------+
double GetLastDealProfit(double &lastLots)
  {
   lastLots = Lots;
   double profit = 0;
   datetime lastTime = 0;

   HistorySelect(0, TimeCurrent());
   int total = HistoryDealsTotal();

   for(int i = total - 1; i >= 0; i--)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0) continue;
      if(HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol) continue;
      if(HistoryDealGetInteger(ticket, DEAL_MAGIC) != MagicNumber) continue;

      long dealEntry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
      if(dealEntry != DEAL_ENTRY_OUT && dealEntry != DEAL_ENTRY_INOUT) continue;

      datetime dealTime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
      if(dealTime > lastTime)
        {
         lastTime = dealTime;
         profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         lastLots = HistoryDealGetDouble(ticket, DEAL_VOLUME);
        }
     }
   return profit;
  }

//+------------------------------------------------------------------+
void BuyOrderWithMgm()
  {
   SendBuyNotification();

   double lastLots = Lots;
   double profit = GetLastDealProfit(lastLots);
   CurrentBuyLots = lastLots;

   if(profit > 0)
     {
      CurrentBuyLots = CurrentBuyLots * LotsMultiplierOnProfit;
      if(LotsResetOnProfit) CurrentBuyLots = Lots;
     }
   else
      if(profit < 0)
        {
         CurrentBuyLots = CurrentBuyLots * LotMultiplierOnLoss;
         if(LotsResetOnLoss) CurrentBuyLots = Lots;
        }

   if(CurrentBuyLots > MaxLots) CurrentBuyLots = MaxLots;

   double lotvalue = NormalizeDouble(CurrentBuyLots, 2);
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(lotvalue < minLot) lotvalue = minLot;
   if(lotvalue > maxLot) lotvalue = maxLot;

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double SL = ask - Stoploss_Pips * PipValue * _Point;
   if(Stoploss_Pips == 0) SL = 0;
   double TP = ask + Takeprofit_Pips * PipValue * _Point;
   if(Takeprofit_Pips == 0) TP = 0;
   SL = NormalizeDouble(SL, _Digits);
   TP = NormalizeDouble(TP, _Digits);

   if(ECN_Broker)
     {
      if(trade.Buy(lotvalue, _Symbol, ask, 0, 0, ExpertComment))
        {
         ulong posTicket = trade.ResultOrder();
         if(posTicket > 0 && (SL != 0 || TP != 0))
           { Sleep(500); trade.PositionModify(posTicket, SL, TP); }
        }
      else Print("Buy error: ", trade.ResultRetcodeDescription());
     }
   else
     {
      if(!trade.Buy(lotvalue, _Symbol, ask, SL, TP, ExpertComment))
         Print("Buy error: ", trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
void SellOrderWithMgm()
  {
   SendSellNotification();

   double lastLots = Lots;
   double profit = GetLastDealProfit(lastLots);
   CurrentSellLots = lastLots;

   if(profit > 0)
     {
      CurrentSellLots = CurrentSellLots * LotsMultiplierOnProfit;
      if(LotsResetOnProfit) CurrentSellLots = Lots;
     }
   else
      if(profit < 0)
        {
         CurrentSellLots = CurrentSellLots * LotMultiplierOnLoss;
         if(LotsResetOnLoss) CurrentSellLots = Lots;
        }

   if(CurrentSellLots > MaxLots) CurrentSellLots = MaxLots;

   double lotvalue = NormalizeDouble(CurrentSellLots, 2);
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(lotvalue < minLot) lotvalue = minLot;
   if(lotvalue > maxLot) lotvalue = maxLot;

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double SL = bid + Stoploss_Pips * PipValue * _Point;
   if(Stoploss_Pips == 0) SL = 0;
   double TP = bid - Takeprofit_Pips * PipValue * _Point;
   if(Takeprofit_Pips == 0) TP = 0;
   SL = NormalizeDouble(SL, _Digits);
   TP = NormalizeDouble(TP, _Digits);

   if(ECN_Broker)
     {
      if(trade.Sell(lotvalue, _Symbol, bid, 0, 0, ExpertComment))
        {
         ulong posTicket = trade.ResultOrder();
         if(posTicket > 0 && (SL != 0 || TP != 0))
           { Sleep(500); trade.PositionModify(posTicket, SL, TP); }
        }
      else Print("Sell error: ", trade.ResultRetcodeDescription());
     }
   else
     {
      if(!trade.Sell(lotvalue, _Symbol, bid, SL, TP, ExpertComment))
         Print("Sell error: ", trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
void SendBuyNotification()
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double SL = ask - Stoploss_Pips * PipValue * _Point;
   double TP = ask + Takeprofit_Pips * PipValue * _Point;
   string msg = ExpertComment + ". " + _Symbol + ". Buy Signal. Price: " + DoubleToString(ask, _Digits)
                + ". TP: " + DoubleToString(TP, _Digits) + ". SL: " + DoubleToString(SL, _Digits)
                + ". MTF Mode: " + TMode;
   if(Email_Notification) SendMail(ExpertComment, msg);
   if(Alert_Notification) Alert(msg);
   if(MT5_Messages) SendNotification(msg);
  }

void SendSellNotification()
  {
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double SL = bid + Stoploss_Pips * PipValue * _Point;
   double TP = bid - Takeprofit_Pips * PipValue * _Point;
   string msg = ExpertComment + ". " + _Symbol + ". Sell Signal. Price: " + DoubleToString(bid, _Digits)
                + ". TP: " + DoubleToString(TP, _Digits) + ". SL: " + DoubleToString(SL, _Digits)
                + ". MTF Mode: " + TMode;
   if(Email_Notification) SendMail(ExpertComment, msg);
   if(Alert_Notification) Alert(msg);
   if(MT5_Messages) SendNotification(msg);
  }

//+------------------------------------------------------------------+
//| Trailing Stop                                                    |
//+------------------------------------------------------------------+
void DoTrailingStop()
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!posInfo.SelectByIndex(i)) continue;
      if(posInfo.Symbol() != _Symbol || posInfo.Magic() != MagicNumber) continue;

      double openPrice = posInfo.PriceOpen();
      double sl = posInfo.StopLoss();
      double tp = posInfo.TakeProfit();

      if(posInfo.PositionType() == POSITION_TYPE_BUY)
        {
         if(ask - openPrice > TrailingStop_Pips * PipValue * _Point)
           {
            double newSL = ask - TrailingStop_Pips * PipValue * _Point;
            if(sl < newSL - TrailingGap_Pips * PipValue * _Point)
              {
               double newTP = tp;
               if(NewTakeProfit_Pips != 0)
                  newTP = ask + (NewTakeProfit_Pips + TrailingStop_Pips) * PipValue * _Point;
               trade.PositionModify(posInfo.Ticket(), NormalizeDouble(newSL, _Digits), NormalizeDouble(newTP, _Digits));
              }
           }
        }
      else
         if(posInfo.PositionType() == POSITION_TYPE_SELL)
           {
            if(openPrice - bid > TrailingStop_Pips * PipValue * _Point)
              {
               double newSL = bid + TrailingStop_Pips * PipValue * _Point;
               if(sl > newSL + TrailingGap_Pips * PipValue * _Point || sl == 0)
                 {
                  double newTP = tp;
                  if(NewTakeProfit_Pips != 0)
                     newTP = bid - (NewTakeProfit_Pips + TrailingStop_Pips) * PipValue * _Point;
                  trade.PositionModify(posInfo.Ticket(), NormalizeDouble(newSL, _Digits), NormalizeDouble(newTP, _Digits));
                 }
              }
           }
     }
  }

//+------------------------------------------------------------------+
//| Chart Comment Display                                            |
//+------------------------------------------------------------------+
void ChartCommentDisplay()
  {
   string Date = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
   string expStr = TimeToString(expDate, TIME_DATE | TIME_MINUTES | TIME_SECONDS);

   if(isAuthorized() || IsDemo())
     {
      Comment("\n ", Copyright, "\n ", Date, "\n", "\n ", AuthMessage(), "\n",
              "\n ", EA_Name, "\n Starting Lot: ", Lots,
              "\n Layer Multiplier: ", MartingaleMultiplier,
              "\n Equity: $", NormalizeDouble(AccountInfoDouble(ACCOUNT_EQUITY), 2),
              "\n Buy: ", CountBuy(), " | Sell: ", CountSell(), "\n");
     }
   else
      if(!isAuthorized() && !IsDemo() && (TimeCurrent() < expDate))
        {
         Comment("\n ", Copyright, "\n ", Date, "\n", "\n ", AuthMessage(), "\n",
                 "\n ", EA_Name, "\n Starting Lot: ", Lots,
                 "\n Layer Multiplier: ", MartingaleMultiplier,
                 "\n Equity: $", NormalizeDouble(AccountInfoDouble(ACCOUNT_EQUITY), 2),
                 "\n Buy: ", CountBuy(), " | Sell: ", CountSell(),
                 "\n\n ExpireDate: ", expStr, "\n");
        }
      else
        {
         Alert(ExpiryAlert);
         ExpertRemove();
         Comment("\n" + ExpiryAlert);
        }
  }

//+------------------------------------------------------------------+
bool isAuthorized()
  {
   long accountNumber = AccountInfoInteger(ACCOUNT_LOGIN);
   string accountName = AccountInfoString(ACCOUNT_NAME);

   for(int i = 0; i < ArraySize(allowedAccountNumbers); i++)
      if((int)accountNumber == allowedAccountNumbers[i])
         return true;

   for(int i = 0; i < ArraySize(allowedAccountNames); i++)
      if(accountName == allowedAccountNames[i])
         return true;

   return false;
  }

int RunAuthorization()
  {
   if(IsDemo()) { Print("Demo account detected, skipping authorization"); return(INIT_SUCCEEDED); }
   if(TimeCurrent() > expDate)
     {
      if(isAuthorized()) return(INIT_SUCCEEDED);
      else { Alert(ExpiryAlert); ExpertRemove(); Comment("\n" + ExpiryAlert); return(INIT_FAILED); }
     }
   return(INIT_SUCCEEDED);
  }

string AuthMessage()
  {
   long accNum = AccountInfoInteger(ACCOUNT_LOGIN);
   string accName = AccountInfoString(ACCOUNT_NAME);
   if(IsDemo())
      return("Demo account detected.\n Account Authorized.\n Account Number: " + IntegerToString(accNum) + "\n Account Name: " + accName);
   else
      if((TimeCurrent() < expDate) && !isAuthorized())
         return("Account " + IntegerToString(accNum) + " is Unauthorized, EA will expire soon.\n Trials Mode Activated.");
      else
         if(isAuthorized())
            return("Account Authorized.\n Account Number: " + IntegerToString(accNum) + "\n Account Name: " + accName);
         else
            return(ExpiryAlert);
  }
//+------------------------------------------------------------------+
