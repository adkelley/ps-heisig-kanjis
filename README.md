# README
## Usage
Given a set of space separated indices, return the group frame.
```
$ node index.js -f '1966;1964;1965;2821;2687'
# 編[1966] 偏[1964] 遍[1965] 騙[2821] 篇[2687]
```

Given a kanji compound, return the RTK keywords
```
$ node index.js -k 中学
＃in, study
```


Given a kanji compound, return the RTK indices
```
$ node index.js -i 中学
# 39, 346
```
Given a primitive(s), return the kanji containing the primative(s)
```
$ node index.js -p 中
# 忠[35] 沖[36] 仲[37] 串[623] 遣[1590] 潰[1636] 患[1755] 遺[1806] 貴[1850] 虫[2069]

```

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

## INSTALLATION:
Sticking to psc 0.13.8 until optparse migrates to 0.14.0 package set.  Once that's done then modify `package.json` to bump to psc `^0.13.8`.

`$ npm i`
`$ npm run build`

## REFERENCES
[Google Sheets
API](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/batchGet)
