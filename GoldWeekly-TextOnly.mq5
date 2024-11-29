// EA Name: GoldWeekly-TextOnly
// Creator: Wise-Time

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0

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
input FontSize fontSize = MEDIUM; // Default font size

// Global Variables
datetime g_startOfWeek;

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

   // No need to create the label here; we'll create/update it in OnCalculate

   return(INIT_SUCCEEDED);
}

// Deinitialization Function
void OnDeinit(const int reason)
{
   // Delete all text label objects
   for(int i = 0; i < 10; i++) // Assuming a maximum of 10 lines
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
   // Calculate the start of the current week
   datetime    currentTime = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(currentTime, dt);
   dt.day_of_week = 0; // Set to Sunday (start of the week)
   dt.hour        = 0;
   dt.min         = 0;
   dt.sec         = 0;
   g_startOfWeek  = StructToTime(dt);

   // Display relevant information on the chart
   DisplayChartVariables(rates_total);

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

   string bidStr       = "BID PRICE: " + DoubleToString(bidPrice, _Digits);
   string askStr       = "ASK PRICE: " + DoubleToString(askPrice, _Digits);
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

   string display =
      "GOLDWEEKLY-TEXT\n"
      + daysUntilWeekendStr + "\n"
      + barsCount + "\n"
      + symbolName + "\n"
      + bidStr + "\n"
      + askStr + "\n"
      + spreadStr + "\n"
      + dailyHighStr + "\n"
      + dailyLowStr;

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