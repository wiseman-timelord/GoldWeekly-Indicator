// EA Name: GoldWeekly-3xSmma
// Creator: Wise-Time

// Indicator Properties
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 3

// Input Parameters
input int smmaPeriod125 = 75; // SMMA Period for 125 (Red)
input int smmaPeriod250 = 150; // SMMA Period for 250 (Orange)
input int smmaPeriod500 = 300; // SMMA Period for 500 (Yellow)

// Global Variables
double g_smmaBufferRed[];
double g_smmaBufferOrange[];
double g_smmaBufferYellow[];

// Initialization Function
int OnInit()
{
   // Set the indicator properties
   IndicatorSetString(INDICATOR_SHORTNAME, "GoldWeeklyLimitedSmma");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   // Set the indicator buffers
   SetIndexBuffer(0, g_smmaBufferRed, INDICATOR_DATA);
   SetIndexBuffer(1, g_smmaBufferOrange, INDICATOR_DATA);
   SetIndexBuffer(2, g_smmaBufferYellow, INDICATOR_DATA);

   // Set the properties for each SMMA line
   PlotIndexSetString(0, PLOT_LABEL, "SMMA 125");
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrRed);

   PlotIndexSetString(1, PLOT_LABEL, "SMMA 250");
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, clrOrange);

   PlotIndexSetString(2, PLOT_LABEL, "SMMA 500");
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(2, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, clrYellow);

   return(INIT_SUCCEEDED);
}

// Calculation Function
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   // Calculate the SMMA for each period
   CalculateSMMA(g_smmaBufferRed, price, rates_total, smmaPeriod125, prev_calculated);
   CalculateSMMA(g_smmaBufferOrange, price, rates_total, smmaPeriod250, prev_calculated);
   CalculateSMMA(g_smmaBufferYellow, price, rates_total, smmaPeriod500, prev_calculated);

   return(rates_total);
}

// SMMA Calculation Function
void CalculateSMMA(double &smmaBuffer[], const double &price[], int rates_total, int period, int prev_calculated)
{
   if(prev_calculated == 0)
   {
      // Initialize SMMA buffer with empty values
      ArrayInitialize(smmaBuffer, EMPTY_VALUE);

      // Calculate the initial SMMA value (SMA)
      double sum = 0;
      for(int i = 0; i < period; i++)
      {
         sum += price[i];
      }
      smmaBuffer[period - 1] = sum / period;

      // Calculate subsequent SMMA values
      for(int i = period; i < rates_total; i++)
      {
         smmaBuffer[i] = (smmaBuffer[i - 1] * (period - 1) + price[i]) / period;
      }
   }
   else
   {
      // Update the latest SMMA value
      int lastBarIndex = rates_total - 1;
      smmaBuffer[lastBarIndex] = (smmaBuffer[lastBarIndex - 1] * (period - 1) + price[lastBarIndex]) / period;
   }
}