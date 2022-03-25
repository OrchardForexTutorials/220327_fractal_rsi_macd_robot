/*

   Fractal RSI
   Expert

   Copyright 2022, Orchard Forex
   https://www.orchardforex.com

*/

/**=
 *
 * Disclaimer and Licence
 *
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * All trading involves risk. You should have received the risk warnings
 * and terms of use in the README.MD file distributed with this software.
 * See the README.MD file for more information and before using this software.
 *
 **/

/*
 * Strategy
 *
 * wait for a consolidation of bollinger indicated by
 *    narrowing to inside a specified range
 *    for a minimum specified period
 * Trade on candle close outside the specified range
 *	tp/sl 1:1 from entry at distance of squeeze range
 *
 */

#include "Framework.mqh"

class CExpert : public CExpertBase {

private:
protected:
// Definitions for compatibility
#ifdef __MQL4__
   #define UPPER_LINE MODE_UPPER
   #define LOWER_LINE MODE_LOWER
#endif

   CIndicatorRSI     *mRSI;
   CIndicatorFractal *mFractal;
   double             mRSIBuyLevel;
   double             mRSISellLevel;
   double             mTPSLRatio;

   double             mBuyPrice;
   double             mBuySL;
   double             mSellPrice;
   double             mSellSL;

   void               Loop();
   void               OpenTrade( ENUM_ORDER_TYPE type, double sl );

public:
   CExpert( CIndicatorRSI *rsi, CIndicatorFractal *fractal,      //
            double buyLevel, double sellLevel, double tpslRatio, //
            double volume, string tradeComment, int magic );
   ~CExpert();
};

//
CExpert::CExpert( CIndicatorRSI *rsi, CIndicatorFractal *fractal,      //
                  double buyLevel, double sellLevel, double tpslRatio, //
                  double volume, string tradeComment, int magic )
   : CExpertBase( volume, tradeComment, magic ) {

   mRSI          = rsi;
   mFractal      = fractal;

   mRSIBuyLevel  = buyLevel;
   mRSISellLevel = sellLevel;

   mBuyPrice     = 0;
   mSellPrice    = 0;

   mTPSLRatio    = tpslRatio;

   mInitResult   = INIT_SUCCEEDED;
}

//
CExpert::~CExpert() {

   delete mRSI;
   delete mFractal;
}

//
void CExpert::Loop() {

   if ( !mNewBar ) return; // Only trades on open of a new bar

   double rsi        = mRSI.GetData( 0, 1 );
   double fractalHi  = mFractal.GetData( UPPER_LINE, 3 ); // fractal will be 3 bars back
   double fractalLo  = mFractal.GetData( LOWER_LINE, 3 );
   double closePrice = iClose( mSymbol, mTimeframe, 1 ); // last bar close price

   if ( fractalHi != EMPTY_VALUE ) {
      mBuyPrice = fractalHi;
      mBuySL    = iLow( mSymbol, mTimeframe, 3 );
   }
   if ( fractalLo != EMPTY_VALUE ) {
      mSellPrice = fractalLo;
      mSellSL    = iHigh( mSymbol, mTimeframe, 3 );
   }

   if ( mBuyPrice > 0 && closePrice > mBuyPrice && rsi > mRSIBuyLevel ) {
      OpenTrade( ORDER_TYPE_BUY, mBuyPrice - mBuySL );
      mBuyPrice = 0;
   }
   else if ( mSellPrice > 0 && closePrice < mSellPrice && rsi < mRSISellLevel ) {
      OpenTrade( ORDER_TYPE_SELL, mSellPrice - mSellSL );
      mSellPrice = 0;
   }

   return;
}

void CExpert::OpenTrade( ENUM_ORDER_TYPE type, double sl ) {

   double price   = ( type == ORDER_TYPE_BUY ) ? SymbolInfoDouble( mSymbol, SYMBOL_ASK )
                                               : SymbolInfoDouble( mSymbol, SYMBOL_BID );
   price          = NormalizeDouble( price, Digits() );
   double slPrice = NormalizeDouble( price - sl, Digits() );
   double tpPrice =
      NormalizeDouble( price + ( sl * mTPSLRatio ), Digits() ); //	Same for both buy and sell
   Trade.PositionOpen( mSymbol, type, mOrderSize, price, slPrice, tpPrice, mTradeComment );
}

//
