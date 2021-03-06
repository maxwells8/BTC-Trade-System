//+------------------------------------------------------------------+
//|                                                    BTC-Trade.mq5 |
//+------------------------------------------------------------------+
/* ------------------------------------------------------------------+
    交易周期M1
    
    只用官方的库
    
    需要改成信号模式
---------------------------------------------------------------------*/
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Indicators\Trend.mqh>
#include <Indicators\Oscilators.mqh>

CExpert              m_expert;
CTrade               m_trade;
CSymbolInfo          m_symbol;
CPositionInfo        m_position;

CiMA                 m_ma1;
CiMA                 m_ma2;
CiMA                 m_ma3;
CiMA                 m_ma4;
CiMA                 m_ma5;

CiWPR                m_wpr;

input string ___1___ = "";//-------------------------------------------
input int    Magic        = 111;
input string iComment     = "";
input bool   UseMM        = false;
input double LotFix       = 0.1;
input double Percentage   = 1.0; //Percentage(0-DBL_MAX)
input int    StopLoss     = 300; //StopLoss(10*Point)
input int    TakeProfit   = 20;  //TakeProfit(10*Point)

input string ___2___ = "";//-------------------------------------------
input int    StartHour    = 0;
input int    StartMinute  = 0;
input int    EndHour      = 23;
input int    EndMinute    = 59;
input int    TimeOffset   = 0;

string OpenOrderComment;
double iPoint;
int    kTimeOffset;

int K = 10;

int MagicNumber;

int SignalState = 0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);
   
   m_expert.Init(_Symbol,PERIOD_CURRENT,true,Magic);
   
  
   m_ma1.Create(_Symbol,PERIOD_M1,100,0,MODE_EMA,PRICE_CLOSE);
   m_ma2.Create(_Symbol,PERIOD_M1,200,0,MODE_EMA,PRICE_CLOSE);
   m_ma3.Create(_Symbol,PERIOD_M1,300,0,MODE_EMA,PRICE_CLOSE);
   m_ma4.Create(_Symbol,PERIOD_M1,400,0,MODE_EMA,PRICE_CLOSE);
   m_ma5.Create(_Symbol,PERIOD_M1,500,0,MODE_EMA,PRICE_CLOSE);
   
   m_wpr.Create(_Symbol,PERIOD_M15,14);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   m_ma1.Refresh();
   m_ma2.Refresh();
   m_ma3.Refresh();
   m_ma4.Refresh();
   m_ma5.Refresh();
   m_wpr.Refresh();

   int total = PositionsTotal();
//开仓
   if(total<=0)
     {
      if(!CloseBuyEntry() && BuyEntry())
        {
         m_trade.Buy(0.1,_Symbol,SymbolInfoDouble(_Symbol,SYMBOL_ASK),0,0,OpenOrderComment);
        }

      if(!CloseSellEntry() && SellEntry())
        {
         m_trade.Sell(0.1,_Symbol,SymbolInfoDouble(_Symbol,SYMBOL_BID),0,0,OpenOrderComment);
        }
     }
   else // 平仓
     {
      if(CloseBuyEntry())
        {
         if(m_position.PositionType()==POSITION_TYPE_BUY)
           {
            m_trade.PositionClose(_Symbol,1);
           }
        }

      if(CloseSellEntry())
        {
         if(m_position.PositionType()==POSITION_TYPE_SELL)
           {
            m_trade.PositionClose(_Symbol,1);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---

  }
//+------------------------------------------------------------------+
//|                            买入 入口                             |
//+------------------------------------------------------------------+
bool BuyEntry()
  {
   bool result=false;
   if(BuySignal1())
     {
      OpenOrderComment="buy-1 "+iComment;
      result=true;
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                           卖出 入口                              |
//+------------------------------------------------------------------+
bool SellEntry()
  {
   bool result=false;

   if(SellSignal1())
     {
      OpenOrderComment="sell-1 "+iComment;
      result=true;
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                          买入 平仓 入口                         |
//+------------------------------------------------------------------+
bool CloseBuyEntry()
  {
   bool result=false;
   m_position.Select(_Symbol);
   double position_price_open =  PositionGetDouble(POSITION_PRICE_OPEN);
   if(CloseBuySignal1(position_price_open))
     {
      OpenOrderComment="close-buy-1 "+iComment;
      result=true;
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                          卖出 平仓 入口                          |
//+------------------------------------------------------------------+
bool CloseSellEntry()
  {
   bool result=false;

   m_position.Select(_Symbol);
   double position_price_open =  PositionGetDouble(POSITION_PRICE_OPEN);
   if(CloseSellSignal1(position_price_open))
     {
      OpenOrderComment="close-sell-1 "+iComment;
      result=true;
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BuySignal1()
  {
   int trend = 0;
   if(m_ma1.Main(0) > m_ma2.Main(0) &&
      m_ma2.Main(0) > m_ma3.Main(0) &&
      m_ma3.Main(0) > m_ma4.Main(0) &&
      m_ma4.Main(0) > m_ma5.Main(0)
    )
   {
      trend = 1;
   }
   if(trend == 1)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SellSignal1()
  {
   int trend = 0;
   if(m_ma1.Main(0) < m_ma2.Main(0) &&
      m_ma2.Main(0) < m_ma3.Main(0) &&
      m_ma3.Main(0) < m_ma4.Main(0) &&
      m_ma4.Main(0) < m_ma5.Main(0)
    )
   {
      trend = -1;
   }
   if(trend == -1)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CloseBuySignal1(double OrderPrice)
  {
   if(0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CloseSellSignal1(double OrderPrice)
  {
   if(0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ProfitFilterSignal1()
  {
   m_position.Select(_Symbol);
   if(m_position.Profit()+m_position.Commission()+m_position.Swap()>0)
      return true;
   else
      return false;
  }
// -------------------------------END----------------------------------
