const {google} = require ('googleapis');
const keys = require('./api-keys.json');
const RTK = require('./lib/rtk.js');
// test this comment

const client = new google.auth.JWT(
	keys.client_email, 
	null, 
	keys.private_key, 
	['https://www.googleapis.com/auth/spreadsheets.readonly']
);

client.authorize(function(err, tokens) {
	if (err) {
		console.log(err);
		return;
	} else {
		console.log('Connected');
		gsrun(client);
	}
});


/*
** Given an RTK search string (e.g, kanji or kanji jukugo), return a string containing
** the result or all the results making up that kanji or jukugo,
** respectively. results are a keyword(s) or index(es)
**
** @jukugo string (e.g., kanji jukugo)
** @sep1   character separator for search string
** @dict1  dictionary1 (i.e., kanjis or RTK indices)
** @dict2  dictionary2 (i.e., kanjis or RTK indices)
** @sep2   character separator for results
*/
//const traverse = (jukugo, dict1, dict2, sep2) =>
//	jukugo.map(key => dict2[dict1.indexOf(key)])
//	        .join(sep2);
//
//
//const groupFrame = (jukugo, kanjis, indices) =>
//	jukugo.map(key => `${kanjis[indices.indexOf(key)]}[${key}]`)
//            .join('  ');

const intersection = (set1, set2) =>
    new Set([...set1].filter(x => set2.has(x)));

const isSubset = (set1, set2) =>
    [...set1].length === [...intersection(set1, set2)].length;

const stringToSet = (component) =>
   new Set(component.split(';')
                    .map(x => x.trimStart()));

function primitives(primNames, components, kanjis, indices) {
    const set1 = new Set(primNames);
    const results = [];
    components.forEach((c, i) => {
      let set2 = stringToSet(c);
      if (isSubset(set1, set2)) {
        results.push(`${kanjis[i]}[${indices[i]}]`);
      }
    });

    return results.join(' ');
}

function pbcopy(data) {
	const proc = require('child_process').spawn('pbcopy');
	proc.stdin.write(data);
	proc.stdin.end();
}

async function gsrun(cl) {
	const gsapi = google.sheets({version: 'v4', auth: cl});
	// Column A: kanjis, Column C: Index Column E: keywords (6th edition)
    // Column F: components
	const opt = {
		spreadsheetId: '1woYl-4S7c37pyHQKFAplinGTc9TxQZN-gL8O61RfbSk',
		ranges: [ 'Heisig!A2:A3001'
                , 'Heisig!C2:C3001'
                , 'Heisig!E2:E3001'
                , 'Heisig!F2:F3001'
                ],
		majorDimension: 'COLUMNS'
	};
	const data = await gsapi.spreadsheets.values.batchGet(opt);
	const kanji = data.data.valueRanges[0].values[0];
	const indices = data.data.valueRanges[1].values[0];
	const keywords = data.data.valueRanges[2].values[0];
	const components = data.data.valueRanges[3].values[0];

	const option  = process.argv[2];

	/*
	 * Options: 
	 *   kw given a jukugo, return the RTK keywords
	 *   ix given a jukugo, return the RTK indices
     *   jukugo given a list of comma separated keywords, return jukugo
	 *   frames given a set of space separated RTK indices, return the Kanjis
     *   -c given a set of space separated component names, return the Kanjis
     *   that contain those components
	*/


    let result = ""
	switch (option) {
		case 'keywords': {
            const jukugo = process.argv[3].split('');
            const errorMsg = "Usage: keywords jukugo"
			result = RTK.query_rtk(jukugo)(kanji)(keywords)(', ')(errorMsg);
			break;
		}
		case 'indices': {
            const jukugo = process.argv[3].split('');
            const errorMsg = "Usage: indices jukugo" 
            result = RTK.query_rtk(jukugo)(kanji)(indices)(', ')(errorMsg)
			break;
		}
		case 'jukugo': {
            const query = process.argv.slice(3);
            const errorMsg = "Usage: jukugo keywords"
            result = RTK.query_rtk(query)(keywords)(kanji)('')(errorMsg)
			break;
		}
		case 'frames': {
            const query = process.argv.slice(3);
            const errMsg = "Usage: frames indices"
            result = RTK.frames(query)(indices)(kanji)(' ')(errMsg)
			break;
		}
		case 'prims': {
            const query = process.argv.slice(3);
            result = RTK.prims(query)(components)(kanji)
            console.log(result)
			break;
		}
		default: {
			result = 'Error: invalid option';
		}
	}
    pbcopy(result);
}
