# 🛥 Santorini 🛥

This is a Santorini solver written in Elixir. It supports a simple set of cards for moving mechanics,
and will parse and encode JSON inputs and outputs. The solver will select a winning move if it sees one,
but otherwise will move and build randomly on the spaces available. 

I tried (😢) to follow a kind of...
"object oriented" (air quotes for emphasis) style of functional programming by boxing each
move set for each god into its own module. In the process, however, I think I introduced bugs on a scale of
2 bugs per method, 10 methods per card, and 8 cards total for somewhere around... 160 bugs! Excessive
code duplication was NOT the plan, but somehow it turned out like that. The JSON parsing, however,
works really well! I am hoping to squash some more bugs on this, consolidate a lot of duplicated code, and fix 
the "object tree" (more air quotes) such that the god cards implement a generic set of player methods. 
As a stretch goal, I would
also like to implement a look-ahead function that will generate a list of possible move paths that could occur
and then select the best move available, rather than moving randomly.

## Usage

An executable binary has been included: santorini. Usage is as the player protocol requires;
run santorini from the command line, and it begins to read some stdin until it reaches an EOF or is
terminated, either by winning and calling exit(), encountering an error, or receiving a signal.

The tests are a remnant from the first iteration of Santorini with no cards and need to be updated to work. 
But, if you still desire to run them:

``mix test``
