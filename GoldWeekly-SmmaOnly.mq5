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
input TextPosition textPosition = TOP_MIDDLE; // Default position in the middle
input FontSize fontSize = LARGE;             // Default font size is large

// SMMA Input Parameters
input int SMMA_Period1 = 250;  // Red SMMA period
input int SMMA_Period2 = 500;  // Orange SMMA period
input int SMMA_Period3 = 1000; // Yellow SMMA period

// Global Variables for SMMA Values and Combined Direction
double GlobalSMMA1_Current, GlobalSMMA1_Previous;
double GlobalSMMA2_Current, GlobalSMMA2_Previous;
double GlobalSMMA3_Current, GlobalSMMA3_Previous;

string GlobalSMMA1_Direction, GlobalSMMA2_Direction, GlobalSMMA3_Direction;
string GlobalSMMA_Combined;

// Indicator Buffers
double SMMA_Buffer1[];
double SMMA_Buffer2[];
double SMMA_Buffer3[];

// Indicator Handles
int SMMA_Handle1;
int SMMA_Handle2;
int SMMA_Handle3;

// Tick Counter
int g_tickCounter = 0;

// Function to get the corner based on text position
int GetCorner(TextPosition position)
{
   switch (position)
   {
      case TOP_LEFT: return 0;
      case TOP_MIDDLE: return 0;
      case BOTTOM_LEFT: return 2;
      default: return 0;
   }
}

// Function to get the X distance based on text position
int GetXDistance(TextPosition position)
{
   int chartWidth = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   switch (position)
   {
      case TOP_LEFT:
      case BOTTOM_LEFT: return 10;
      case TOP_MIDDLE: return (chartWidth / 2) - 100;
      default: return 10;
   }
}

// Initialization Function
int OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME, "GoldWeeklySMMA");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   SetIndexBuffer(0, SMMA_Buffer1, INDICATOR_DATA);
   SetIndexBuffer(1, SMMA_Buffer2, INDICATOR_DATA);
   SetIndexBuffer(2, SMMA_Buffer3, INDICATOR_DATA);

   SMMA_Handle1 = iMA(NULL, PERIOD_CURRENT, SMMA_Period1, 0, MODE_SMMA, PRICE_CLOSE);
   if (SMMA_Handle1 == INVALID_HANDLE) return INIT_FAILED;

   SMMA_Handle2 = iMA(NULL, PERIOD_CURRENT, SMMA_Period2, 0, MODE_SMMA, PRICE_CLOSE);
   if (SMMA_Handle2 == INVALID_HANDLE) return INIT_FAILED;

   SMMA_Handle3 = iMA(NULL, PERIOD_CURRENT, SMMA_Period3, 0, MODE_SMMA, PRICE_CLOSE);
   if (SMMA_Handle3 == INVALID_HANDLE) return INIT_FAILED;

   InitializeGlobals();
   DisplaySMMAStatus();

   return(INIT_SUCCEEDED);
}

// Initialize Global Variables
void InitializeGlobals()
{
   if (CopyBuffer(SMMA_Handle1, 0, 0, 2, SMMA_Buffer1) > 0)
   {
      GlobalSMMA1_Current = SMMA_Buffer1[0];
      GlobalSMMA1_Previous = SMMA_Buffer1[1];
   }

   if (CopyBuffer(SMMA_Handle2, 0, 0, 2, SMMA_Buffer2) > 0)
   {
      GlobalSMMA2_Current = SMMA_Buffer2[0];
      GlobalSMMA2_Previous = SMMA_Buffer2[1];
   }

   if (CopyBuffer(SMMA_Handle3, 0, 0, 2, SMMA_Buffer3) > 0)
   {
      GlobalSMMA3_Current = SMMA_Buffer3[0];
      GlobalSMMA3_Previous = SMMA_Buffer3[1];
   }

   UpdateDirections();
}

// Update SMMA Directions
void UpdateDirections()
{
   GlobalSMMA1_Direction = (GlobalSMMA1_Current > GlobalSMMA1_Previous) ? "BULLISH" : "BULLISH";
   GlobalSMMA2_Direction = (GlobalSMMA2_Current > GlobalSMMA2_Previous) ? "BULLISH" : "BULLISH";
   GlobalSMMA3_Direction = (GlobalSMMA3_Current > GlobalSMMA3_Previous) ? "BULLISH" : "BULLISH";

   int bullishCount = 0;
   if (GlobalSMMA1_Direction == "BULLISH") bullishCount++;
   if (GlobalSMMA2_Direction == "BULLISH") bullishCount++;
   if (GlobalSMMA3_Direction == "BULLISH") bullishCount++;

   GlobalSMMA_Combined = (bullishCount >= 2) ? "BULLISH" : "BEARISH";
}

// Update Global Variables
void UpdateGlobals()
{
   GlobalSMMA1_Previous = GlobalSMMA1_Current;
   GlobalSMMA2_Previous = GlobalSMMA2_Current;
   GlobalSMMA3_Previous = GlobalSMMA3_Current;

   GlobalSMMA1_Current = SMMA_Buffer1[0];
   GlobalSMMA2_Current = SMMA_Buffer2[0];
   GlobalSMMA3_Current = SMMA_Buffer3[0];

   UpdateDirections();
}

// Deinitialization Function
void OnDeinit(const int reason)
{
   for (int i = 0; i < 10; i++)
   {
      string objName = "GoldWeeklySMMAStatus_" + IntegerToString(i);
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
   if (rates_total <= 1) return 0;

   if (CopyBuffer(SMMA_Handle1, 0, 0, rates_total, SMMA_Buffer1) <= 0) return 0;
   if (CopyBuffer(SMMA_Handle2, 0, 0, rates_total, SMMA_Buffer2) <= 0) return 0;
   if (CopyBuffer(SMMA_Handle3, 0, 0, rates_total, SMMA_Buffer3) <= 0) return 0;

   if (prev_calculated < rates_total - 1)
   {
      UpdateGlobals();
      DisplaySMMAStatus();
   }

   return rates_total;
}

// Display SMMA Status
void DisplaySMMAStatus()
{
   string lines[] = {
      "GOLDWEEKLY-3XSMMA",
      "SMMA RED: " + GlobalSMMA1_Direction,
      "SMMA ORA: " + GlobalSMMA2_Direction,
      "SMMA YEL: " + GlobalSMMA3_Direction,
      "SMMA ALL: " + GlobalSMMA_Combined
   };

   for (int i = 0; i < ArraySize(lines); i++)
   {
      UpdateTextLabel(lines[i], i);
   }
}

// Update Text Label
void UpdateTextLabel(string text, int lineIndex)
{
   string objName = "GoldWeeklySMMAStatus_" + IntegerToString(lineIndex);
   ObjectDelete(0, objName);

   if (!ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0))
   {
      Print("Failed to create object: ", objName);
      return;
   }

   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, objName, OBJPROP_CORNER, GetCorner(textPosition));
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, GetXDistance(textPosition));
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, 10 + (lineIndex * 15));
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
}
