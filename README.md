# GoldWeekly-Indicator
Status: Incomplete

### Development
Project back on because `"In MetaTrader 5, Custom Indicators are designed to display data for only one type of indicator, as each indicator operates as an independent entity. However, when you use an Expert Advisor (EA), you gain much more flexibility"`. Current project details (needs update)...
1. Convert to Expert Advisor.
2. Halted/Abandoned; 1) cant have multiple different types of indicators in 1 indicator as intended, and 2) GPT4o and DeepSeek2.5 are unable to draw Rsi on main chart, 3) going round in circles and dont have the time/patience.
3. GoldWeekly-Rsi - the rsi, for now just use normal Rsi Built-in.
4. Not done - rsi as overlay on main chart. cant be done with, gpt4o and deepseek2.5, or with additional research. The idea was to have Rsi with colors indicating if the direction the rsi is going in is going in same direction as combined smma trend result.
5. Not done - Display Text with resize; resizeable text is more tricky than first expected, it requires text objects, which, gpt and deepseek2.5, dont get right. 
6. Not done - Re-visit the display text, and add other useful non-indicator based information.

### Description
- A set of Indicators to use in Metatrader 5, designed for trending market, to use as confirmation for trading strategy, to make likelyhoods more apparent. Manual trading with the indicator provided relies upon the trader's ability to recognize patterns in the market, therein,but these patterns often have unexpected twists, but the likelyhood of, recouperating losses and avoiding bad trades, can be improved through the use of indicators, at least thats how the theory goes.

### Preview
- Indicator (Limited)...

![indicator preview](media/preview.png)

### Features
The current detail of features is... 
- GoldWeekly-Indicator - As shown above, with the, Display Text and the 3 Smma; Indicators are limited to 1 type of Indicator. 

## Instructions
With this combination indicators, the strategy for trading would rely upon recognizing patterns, then when you recognize a pattern, you must be confirming directions for optimal trading with indicators. 
- Smma - denotes if rebound is likely possible.
- Text - Good to know stuff, for piece of mind..
- Rsi (built-in Mt5) - is like market pressure, when too far over one side, it will likely go to direction of other side at some point after.
- Lines (built-in Mt5) - Ensure to draw on the chart to clarify patterns.

### Warnings
- Trading with specified method, in theory is supposed to work, but you should combine with other methods you are experimenting with or knowing of; this indicator will not guarantee success.
