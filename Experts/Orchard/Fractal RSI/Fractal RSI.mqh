/*
 * Fractal RSI.mqh
 *
 * Copyright 2022, Orchard Forex
 * https://orchardforex.com
 *
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

#define APP_COPYRIGHT "Copyright 2022, Orchard Forex"
#define APP_LINK      "https://orchardforex.com"
#define APP_VERSION   "1.00"
#define APP_DESCRIPTION                                                                            \
   "A trend following expert based on\n"                                                           \
   "break of a fractal level\n"                                                                    \
   "following the RSI trend"
#define APP_COMMENT "Fractal RSI"
#define APP_MAGIC   222222

#include "Framework.mqh"

//	Inputs

//	RSI specification
input int                InpRSIPeriod       = 10;          //	RSI period
input ENUM_APPLIED_PRICE InpRSIAppliedPrice = PRICE_CLOSE; // RSI applied price
input double             InpRSIBuyLevel     = 50;          // Buy above level
input double             InpRSISellLevel    = 50;          // Sell below level
input double             InpTPSLRatio       = 1.5;         // TPSL ratio

//	Default inputs
//	I have these in a separate file because I use them all the time
#include <Orchard/Shared/Default Inputs.mqh>

//	The expert does all the work
#include "Expert.mqh"
CExpert *Expert;

//
int      OnInit() {

   Expert =
      new CExpert( new CIndicatorRSI( InpRSIPeriod, InpRSIAppliedPrice ), // RSI
                        new CIndicatorFractal(),                               // Fractal
                        InpRSIBuyLevel, InpRSISellLevel, InpTPSLRatio, // Various params and TP/SL ratio
                        InpVolume, InpTradeComment, InpMagic           //	Common
           );

   return ( Expert.OnInit() );
}

//
void OnDeinit( const int reason ) {
   delete Expert;
}

//
void OnTick() {
   Expert.OnTick();
}

//
