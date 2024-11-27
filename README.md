# GoldWeekly-IndicatorMt5
Its an  Indicator for Mt5, that enables hopefully more effective trading, written with, GPT4o and DeepSeek2.5.

### Development
Current project workflow...
- Mk4 - Refinements and Rsi Window. You cannot have two windows for 2 indicators in a single indicator, it would have to be merged.
- Not done yet - rsi with colors indicating if the direction the rsi is going in is going in same direction as combined smma trend result. Rsi overlay on chart is tricky also, normally its in separate window at bottom of chart.
- Not done yet - Display Text with resize; resizeable text is more tricky than first expected. 


### Description
- Indicators to use in Metatrader 5, designed for trending market, to use as confirmation for trading strategy, to make likelyhoods more apparent. Manual trading with the indicator provided relies upon the trader's ability to recognize patterns in the market, therein,but these patterns often have unexpected twists, but the likelyhood of, recouperating losses and avoiding bad trades, can be improved through the use of indicators, at least thats how the theory goes.

### Features
The current detail of features is...
- GoldWeekly-TextDisplay - useful info such as, periods since week start max 1000, combined smma result, week date start/end.  
- GoldWeekly-3xSmma - 3 color smma trends, Red is Fast, Orange is Medium, Yellow is Slow, with default line thickness 2. 
- Any pair compatible - Not pair locked like early version, but still intended for gold.

### Preview
- The Project so far...

![indicator preview](media/preview.png)

## Instructions
With this indicator, the strategy for trading would rely upon recognizing patterns, then when you recognize a pattern, you must be confirming directions for optimal trading with indicator... 
- Smma denotes if rebound is likely possible.
- Rsi is like market pressure, when too far over one side, it will eventually go to other side.

### Warnings
- Trading with specified method, in theory is supposed to work, but you should combine with other methods you are experimenting with or knowing of; this indicator will not guarantee success.
