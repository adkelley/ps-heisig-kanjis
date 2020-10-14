const {google} = require ('googleapis');
const keys = require('./api-keys.json');
const fs = require("fs");


exports._pbcopy = function pbcopy(data) {
    return async function (onError, onSuccess) {
        const { spawn } = require('child_process');
        const pbcopy = spawn('pbcopy');
        //const proc = require('child_process').spawn('pbcopy');
        //await proc.stdin.write(data);
        //proc.stdin.end();
        await pbcopy.stdin.write(data);
        pbcopy.stdin.end();

        onSuccess();

        return function (cancelError, onCancelerError, onCancelerSuccess) {
            onCancelerSuccess();
        };
    }
}


exports._gsRun = function (client) {
    return async function (onError, onSuccess) {

        const gsapi = google.sheets({version: 'v4', auth: client});
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

        const result = new Object();
        result.kanji = data.data.valueRanges[0].values[0];
        result.indices = data.data.valueRanges[1].values[0];
        result.keywords = data.data.valueRanges[2].values[0];
        result.components = data.data.valueRanges[3].values[0];

        onSuccess(result)

        return function (cancelError, onCancelerError, onCancelerSuccess) {
            onCancelerSuccess();
        };
    }
}


// type JWT =
//   { access_token :: String
//   , token_type :: String
//   , expiry_date :: Int
//   , id_token :: String
//   , refresh_token :: String
// }
//
exports._authorizeClient = async function (onError, onSuccess) {
    const client = new google.auth.JWT(
        keys.client_email, 
        null, 
        keys.private_key, 
        ['https://www.googleapis.com/auth/spreadsheets.readonly']
    );

    await client.authorize((err, res) => {
        if (err) {
            onError(err);
            return;
        }

        onSuccess(client);

    });

    return function (cancelError, onCancelerError, onCancelerSuccess) {
        onCancelerSuccess();
    };
};
