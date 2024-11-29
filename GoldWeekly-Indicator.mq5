// EA Name: GoldWeekly-Indicator
// Creator: Wise-Time

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 3

// Plot properties
#property indicator_label1 "SMMA1"
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2

#property indicator_label2 "SMMA2"
#property indicator_type2 DRAW_LINE
#property indicator_color2 clrOrange
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2

#property indicator_label3 "SMMA3"
#property indicator_type3 DRAW_LINE
#property indicator_color3 clrYellow
#property indicator_style3 STYLE_SOLID
#property indicator_width3 2

// Enum for Text Position
enum TextPosition
  {
   TOP_LEFT,
   TOP_MIDDLE,
   BOTTOM_LEFT
  };

// Enum for Font Size
enum FontSize
  {
   SMALL = 8,
   MEDIUM = 10,
   LARGE = 12
  };

// Input Parameters
input TextPosition textPosition = TOP_LEFT; // Default position
input FontSize fontSize = MEDIUM;           // Default font size

// SMMA Input Parameters
input int SMMA_Period1 = 250;  // Red SMMA period
input int SMMA_Period2 = 500;  // Orange SMMA period
input int SMMA_Period3 = 1000; // Yellow SMMA period

// Global Variables
int g_tickCounter = 0;

// Indicator Buffers
double SMMA_Buffer1[];
double SMMA_Buffer2[];
double SMMA_Buffer3[];

// Indicator Handles
int SMMA_Handle1;
int SMMA_Handle2;
int SMMA_Handle3;

// Function to get the corner based on text position
int GetCorner(TextPosition position)
{
   switch(position)
   {
      case TOP_LEFT:
         return 0; // CORNER_LEFT_UPPER
      case TOP_MIDDLE:
         return 0; // We'll adjust X distance
      case BOTTOM_LEFT:
         return 2; // CORNER_LEFT_LOWER
      default:
         return 0;
   }
}

// Function to get the X distance based on text position
int GetXDistance(TextPosition position)
{
   int chartWidth = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);

   switch(position)
   {
      case TOP_LEFT:
      case BOTTOM_LEFT:
         return 10;
      case TOP_MIDDLE:
         return (chartWidth / 2) - 100; // Adjust as needed
      default:
         return 10;
   }
}

// Initialization Function
int OnInit()
{
   // Set the indicator properties
   IndicatorSetString(INDICATOR_SHORTNAME, "GoldWeeklyText");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   // Set indicator buffers
   SetIndexBuffer(0, SMMA_Buffer1, INDICATOR_DATA);
   SetIndexBuffer(1, SMMA_Buffer2, INDICATOR_DATA);
   SetIndexBuffer(2, SMMA_Buffer3, INDICATOR_DATA);

   // Create indicator handles
   SMMA_Handle1 = iMA(NULL, PERIOD_CURRENT, SMMA_Period1, 0, MODE_SMMA, PRICE_CLOSE);
   if(SMMA_Handle1 == INVALID_HANDLE)
   {
      Print("Failed to create SMMA_Handle1: ", GetLastError());
      return INIT_FAILED;
   }

   SMMA_Handle2 = iMA(NULL, PERIOD_CURRENT, SMMA_Period2, 0, MODE_SMMA, PRICE_CLOSE);
   if(SMMA_Handle2 == INVALID_HANDLE)
   {
      Print("Failed to create SMMA_Handle2: ", GetLastError());
      return INIT_FAILED;
   }

   SMMA_Handle3 = iMA(NULL, PERIOD_CURRENT, SMMA_Period3, 0, MODE_SMMA, PRICE_CLOSE);
   if(SMMA_Handle3 == INVALID_HANDLE)
   {
      Print("Failed to create SMMA_Handle3: ", GetLastError());
      return INIT_FAILED;
   }

   return(INIT_SUCCEEDED);
}

// Deinitialization Function
void OnDeinit(const int reason)
{
   // Delete all text label objects
   for(int i = 0; i < 15; i++) // Adjusted maximum lines to 15
   {
      string objName = "GoldWeeklyTextLabel_" + IntegerToString(i);
      ObjectDelete(0, objName);
   }
}

// Calculation Function
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double   &Open[],
                const double   &High[],
                const double   &Low[],
                const double   &Close[],
                const long     &TickVolume[],
                const long     &Volume[],
                const int      &Spread[])
{
   // Increment tick counter
   g_tickCounter++;

   // Update the indicator no more than once per 10 ticks
   if(g_tickCounter >= 10)
   {
      // Reset tick counter
      g_tickCounter = 0;

      int to_copy = rates_total;

      // Copy SMMA values into indicator buffers
      if(CopyBuffer(SMMA_Handle1, 0, 0, to_copy, SMMA_Buffer1) <= 0)
      {
         Print("Error copying SMMA_Handle1: ", GetLastError());
         return 0;
      }

      if(CopyBuffer(SMMA_Handle2, 0, 0, to_copy, SMMA_Buffer2) <= 0)
      {
         Print("Error copying SMMA_Handle2: ", GetLastError());
         return 0;
      }

      if(CopyBuffer(SMMA_Handle3, 0, 0, to_copy, SMMA_Buffer3) <= 0)
      {
         Print("Error copying SMMA_Handle3: ", GetLastError());
         return 0;
      }

      // Display relevant information on the chart
      DisplayChartVariables(rates_total);
   }

   return(rates_total);
}

// Display Function
void DisplayChartVariables(int rates_total)
{
   // First, check if the symbol is a gold pair
   string symbol      = Symbol();
   string symbolUpper = symbol;
   StringToUpper(symbolUpper);

   if(StringFind(symbolUpper, "XAU") != -1 || StringFind(symbolUpper, "GOLD") != -1)
     {
      // It's a gold pair
     }
   else
     {
      // Not a gold pair
      Comment("THIS EA WORKS ONLY ON GOLD PAIRS.");
      return;
     }

   // Calculate the start of the current day
   MqlDateTime dt;
   datetime currentTime = TimeCurrent();
   TimeToStruct(currentTime, dt);
   dt.hour = 0;
   dt.min  = 0;
   dt.sec  = 0;
   datetime startOfDay = StructToTime(dt);

   // Calculate the number of bars since the start of the day
   int startOfDayIndex = iBarShift(symbol, PERIOD_CURRENT, startOfDay);
   int barsSinceDayStart = rates_total - startOfDayIndex;
   string barsCount = "BARS TODAY: ";
   if(barsSinceDayStart > 1000)
     {
      barsCount += "1000+";
     }
   else
     {
      barsCount += IntegerToString(barsSinceDayStart);
     }

   // Get symbol name in capitals
   string symbolName = "SYMBOL: " + symbolUpper;

   // Get statistical information
   double bidPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
   double askPrice = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double point    = SymbolInfoDouble(symbol, SYMBOL_POINT);
   double spread   = (askPrice - bidPrice) / point;

   // Initialize variables for daily high and low
   double dailyHigh      = 0.0;
   double dailyLow       = 0.0;
   double dailyHighArray[];
   double dailyLowArray[];

   // Copy the daily high
   if(CopyHigh(symbol, PERIOD_D1, 0, 1, dailyHighArray) > 0)
      dailyHigh = dailyHighArray[0];
   else
      dailyHigh = 0.0;

   // Copy the daily low
   if(CopyLow(symbol, PERIOD_D1, 0, 1, dailyLowArray) > 0)
      dailyLow = dailyLowArray[0];
   else
      dailyLow = 0.0;

   string spreadStr    = "SPREAD: " + DoubleToString(spread, 1) + " POINTS";
   string dailyHighStr = "DAILY HIGH: " + DoubleToString(dailyHigh, _Digits);
   string dailyLowStr  = "DAILY LOW: " + DoubleToString(dailyLow, _Digits);

   // Calculate days until weekend
   MqlDateTime currentDt;
   TimeToStruct(currentTime, currentDt);
   int daysUntilWeekend = 5 - currentDt.day_of_week; // 5 is Friday
   if (daysUntilWeekend < 0)
      daysUntilWeekend = 0;
   if (currentDt.day_of_week == 5) // Friday
      daysUntilWeekend = 1;
   if (currentDt.day_of_week == 6 || currentDt.day_of_week == 0) // Saturday or Sunday
      daysUntilWeekend = 0;
   string daysUntilWeekendStr = "TRADE DAYS LEFT: " + IntegerToString(daysUntilWeekend);

   // Determine Mean SMMA direction
   string meanSMMAStatus = "MEAN SMMA: ";
   
   // Count the number of SMMA lines going up or down
   int upCount = 0;
   int downCount = 0;

   if (SMMA_Buffer1[0] > SMMA_Buffer1[1]) upCount++; else if (SMMA_Buffer1[0] < SMMA_Buffer1[1]) downCount++;
   if (SMMA_Buffer2[0] > SMMA_Buffer2[1]) upCount++; else if (SMMA_Buffer2[0] < SMMA_Buffer2[1]) downCount++;
   if (SMMA_Buffer3[0] > SMMA_Buffer3[1]) upCount++; else if (SMMA_Buffer3[0] < SMMA_Buffer3[1]) downCount++;

   // Determine the majority direction
   if (upCount > downCount)
      meanSMMAStatus += "BEAR";
   else if (downCount > upCount)
      meanSMMAStatus += "BULL";
   else
   {
      // If upCount and downCount are equal, determine the direction based on the majority of the SMMA lines
      if (SMMA_Buffer1[0] > SMMA_Buffer1[1] || SMMA_Buffer2[0] > SMMA_Buffer2[1] || SMMA_Buffer3[0] > SMMA_Buffer3[1])
         meanSMMAStatus += "BEAR";
      else
         meanSMMAStatus += "BULL";
   }

   string display =
      "GLDWKLY-INDICATOR\n"
      + symbolName + "\n"
      + daysUntilWeekendStr + "\n"
      + barsCount + "\n"
      + spreadStr + "\n"
      + dailyHighStr + "\n"
      + dailyLowStr + "\n"
      + meanSMMAStatus;

   // Split the display text into lines
   string lines[];
   int lineCount = StringSplit(display, '\n', lines);

   // Update the text labels on the chart
   for(int i = 0; i < lineCount; i++)
   {
      UpdateTextLabel(lines[i], i);
   }
}

// Function to create and update the text label
void UpdateTextLabel(string text, int lineIndex)
{
   string objName = "GoldWeeklyTextLabel_" + IntegerToString(lineIndex);

   // Remove existing object if it exists
   ObjectDelete(0, objName);

   // Create the label object
   if(!ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0))
   {
      Print("Failed to create label object");
      return;
   }

   // Set label properties
   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial");

   // Set the corner of the label
   ObjectSetInteger(0, objName, OBJPROP_CORNER, GetCorner(textPosition));

   // Set x and y distances from the corner
   int xDist = GetXDistance(textPosition);
   int yDist = 10 + lineIndex * 15; // Adjust vertical spacing as needed
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, xDist);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, yDist);

   // Bring the label to the foreground
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
}