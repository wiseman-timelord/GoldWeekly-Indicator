// EA Name: GoldWeekly-TextOnly
// Creator: Wise-Time

// Indicator Properties
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0

// Global Variables
datetime g_startOfWeek;

// Initialization Function
int OnInit()
{
   // Set the indicator properties
   IndicatorSetString(INDICATOR_SHORTNAME, "GoldWeeklyText");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   return(INIT_SUCCEEDED);
}

// Calculation Function
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   // Calculate the start of the current week
   datetime currentTime = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(currentTime, dt);
   dt.day_of_week = 0; // Set to Sunday (start of the week)
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;
   g_startOfWeek = StructToTime(dt);

   // Display relevant information on the chart
   DisplayChartVariables(rates_total);

   return(rates_total);
}

// Display Function
void DisplayChartVariables(int rates_total)
{
   // Calculate the end of the current week
   MqlDateTime dt;
   TimeToStruct(g_startOfWeek, dt);
   dt.day += 7; // Add 7 days to get the end of the week
   datetime endOfWeek = StructToTime(dt);

   string dateWeekEnd = "DATE WEEK END: " + TimeToString(endOfWeek, TIME_DATE);

   // Calculate the number of bars since the start of the week
   int startOfWeekIndex = iBarShift(NULL, 0, g_startOfWeek);
   int barsSinceWeekStart = rates_total - startOfWeekIndex;
   string barsCount = "BARS SINCE START: ";
   if (barsSinceWeekStart > 1000)
   {
      barsCount += "1000+";
   }
   else
   {
      barsCount += IntegerToString(barsSinceWeekStart);
   }

   string display =
      "-----------------------------------------------\n"
      " DATE WEEK START: " + TimeToString(g_startOfWeek, TIME_DATE) + "\n"
      + dateWeekEnd + "\n"
      + barsCount + "\n"
      "-----------------------------------------------";

   // Display the text on the chart
   Comment(display);
}