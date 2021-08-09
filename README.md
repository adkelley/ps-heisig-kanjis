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
Given a primitive(s), search and return the kanji containing the primative(s)
Note the primitives must be separated by ';'
```
$ node index.js -p "middle;heart"
# 忠[35] 沖[36] 仲[37] 串[623] 遣[1590] 潰[1636] 患[1755] 遺[1806] 貴[1850] 虫[2069]

```

Given an rtk index and a primative(s), update the RTK spreadsheet with a formatted version
that matches Heisig's in his books. Note the index and primatives are separated by ';', for 
primitives with spaces use underscores
```
node index.js -u '46;part_of_the_body;glue'
# part of the body ... glue
```

## INSTALLATION:
Sticking to psc 0.13.8 until optparse migrates to 0.14.0 package set.  Once that's done then modify `package.json` to bump to psc `^0.13.8`.

`$ npm i`
`$ npm run build`

## REFERENCES
[Google Sheets
API](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/batchGet)
