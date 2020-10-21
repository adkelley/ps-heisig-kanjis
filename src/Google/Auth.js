"use strict";

// type JWT =
//   { access_token :: String
//   , token_type :: String
//   , expiry_date :: Int
//   , id_token :: String
//   , refresh_token :: String
// }
//
exports._auth = function (jwtClient) {
    return async function (onError, onSuccess) {
        await jwtClient.authorize((err, res) => {
            if (err) {
                onError(err);
                return;
            }

            onSuccess(jwtClient);

        });

        return function (cancelError, onCancelerError, onCancelerSuccess) {
            onCancelerSuccess();
        };
    };
}
