# README
## Log
1. 20201013 Dropped nodemon in favor of `spago --then`; Used `osa notify` to send notifications that ps was building
2. 20201014 Created `src/OSX` library for mac related terminal commands
3. 20201015 Created `src/Google` library for google authentication
4. 20201016 Validated args

## TODOS:
* Migrate Params.purs to [purescript-optparse](https://pursuit.purescript.org/packages/purescript-optparse/3.0.0)
* Decide to support both Alfred and terminal.  If terminal, then have a flag
  that says you're using the terminal since this is a rare case
