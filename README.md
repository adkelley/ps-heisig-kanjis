# README
## Log
- 20201013 Dropped nodemon in favor of `spago --then`; Used `osa notify` to send notifications that ps was building
- 20201014 Created `src/OSX` library for mac related terminal commands
- 20201015 Created `src/Google` library for google authentication
- 20201016 Validated args
- 20201017 Error handling in .js, Data.Either.note
- 20201018 Finished error handling, began optparse migration by implementing tutorial
- 20201019 Continued working on optparse migration 
- 20201020 WIP: optparse migration.  Breakthrough! Limited the scope of the launchAff to just the functions that are performed in the AFF context was a good solution. 
- 20201021 Finished optparse migration; limited scope of launchAff_ ; concluded there's no advantage storing the JWT

## TODOS:
- [x] Finish error handling in google functions
- [x] Determine if I can further limit the scope of the AFF context
- [x] Migrate Params.purs to [purescript-optparse](https://pursuit.purescript.org/packages/purescript-optparse/3.0.0)
- [x] Store token and check it's validity

## REFERENCES
[Google Sheets
API](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/batchGet)
