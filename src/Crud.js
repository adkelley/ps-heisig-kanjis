const {google} = require ('googleapis');

exports._gsBatchGet = function (client) {
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

        try {
          const data = await gsapi.spreadsheets.values.batchGet(opt);

          const result = new Object();
          result.kanji = data.data.valueRanges[0].values[0];
          result.indices = data.data.valueRanges[1].values[0];
          result.keywords = data.data.valueRanges[2].values[0];
          result.components = data.data.valueRanges[3].values[0];

          onSuccess(result);

        } catch (err) {
            onError(err);
            return;
        };

        return function (cancelError, onCancelerError, onCancelerSuccess) {
          onCancelerSuccess();
        };
    };
};

exports._gsUpdate = function (ud) {
    return async function (onError, onSuccess) {

        const gsapi = google.sheets({version: 'v4', auth: ud.client});
        // Column F: components
        const body = { values: [[ud.value]] };
        const opt = {
            spreadsheetId: '1woYl-4S7c37pyHQKFAplinGTc9TxQZN-gL8O61RfbSk',
            range: ud.range,
            valueInputOption: 'RAW',
            resource: body,
        };

        try {
            response = await gsapi.spreadsheets.values.update(opt);
            onSuccess(ud.value);
            
        } catch (err) {
            onError(err);
            return;
        }

        return function (cancelError, onCancelerError, onCancelerSuccess) {
            onCancelerSuccess();
        };
    }; 
};


