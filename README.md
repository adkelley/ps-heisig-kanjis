# README
## Log
1. 20201013 Dropped nodemon in favor of `spago --then`; Used `osa notify` to send notifications that ps was building
2. 20201014 Created `src/OSX` library for mac related terminal commands
3. 20201015 Created `src/Google` library for google authentication
4. 20201016 Validated args
5. 20201017 Error handling in .js, Data.Either.note
6. 20201018 Finished error handling, began optparse migration by implementing tutorial

## TODOS:
- [x] Finish error handling in google functions
- [] Migrate Params.purs to [purescript-optparse](https://pursuit.purescript.org/packages/purescript-optparse/3.0.0)
- [] Store token and check it's validity

## REFERENCES
[Google Sheets
API](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/batchGet)
