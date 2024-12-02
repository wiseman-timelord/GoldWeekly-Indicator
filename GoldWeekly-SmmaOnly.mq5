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
   switch(position)
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
   if(SMMA_Handle1 == INVALID_HANDLE) return INIT_FAILED;

   SMMA_Handle2 = iMA(NULL, PERIOD_CURRENT, SMMA_Period2, 0, MODE_SMMA, PRICE_CLOSE);
   if(SMMA_Handle2 == INVALID_HANDLE) return INIT_FAILED;

   SMMA_Handle3 = iMA(NULL, PERIOD_CURRENT, SMMA_Period3, 0, MODE_SMMA, PRICE_CLOSE);
   if(SMMA_Handle3 == INVALID_HANDLE) return INIT_FAILED;

   return(INIT_SUCCEEDED);
}

// Deinitialization Function
void OnDeinit(const int reason)
{
   // Delete all text label objects
   for(int i = 0; i < 10; i++) // Assuming a maximum of 10 lines
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
   g_tickCounter++;

   if(g_tickCounter >= 10)
   {
      g_tickCounter = 0;

      if(CopyBuffer(SMMA_Handle1, 0, 0, rates_total, SMMA_Buffer1) <= 0) return 0;
      if(CopyBuffer(SMMA_Handle2, 0, 0, rates_total, SMMA_Buffer2) <= 0) return 0;
      if(CopyBuffer(SMMA_Handle3, 0, 0, rates_total, SMMA_Buffer3) <= 0) return 0;

      DisplaySMMAStatus();
   }

   return(rates_total);
}

// Display SMMA Direction Status
void DisplaySMMAStatus()
{
   int upCount = 0, downCount = 0;

   // Determine the direction for each SMMA line
   if (SMMA_Buffer1[0] > SMMA_Buffer1[1]) upCount++;
   else downCount++;

   if (SMMA_Buffer2[0] > SMMA_Buffer2[1]) upCount++;
   else downCount++;

   if (SMMA_Buffer3[0] > SMMA_Buffer3[1]) upCount++;
   else downCount++;

   // Determine overall direction based on majority
   string direction = (upCount > downCount) ? "BULLISH" : "BEARISH";

   // Prepare multiline text
   string lines[] = {
      "GOLDWEEKLY-3XSMMA", // First line
      "MEDIUM SMMA: " + direction // Second line
   };

   // Update the display text
   for(int i = 0; i < ArraySize(lines); i++)
   {
      UpdateTextLabel(lines[i], i);
   }
}

// Function to create and update the text label
void UpdateTextLabel(string text, int lineIndex)
{
   string objName = "GoldWeeklySMMAStatus_" + IntegerToString(lineIndex);

   ObjectDelete(0, objName);

   if(!ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0)) return;

   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial");

   ObjectSetInteger(0, objName, OBJPROP_CORNER, GetCorner(textPosition));

   // Adjust position based on line index
   int xDist = GetXDistance(textPosition);
   int yDist = 10 + lineIndex * 15; // Adjust vertical spacing
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, xDist);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, yDist);

   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
}
