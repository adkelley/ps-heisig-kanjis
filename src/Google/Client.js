"use strict";

const {google} = require ('googleapis');
const keys = require('./api-keys.json');

exports._client = function(onError, onSuccess) {
   const jwtClient = new google.auth.JWT(
        keys.client_email, 
        null, 
        keys.private_key, 
        ['https://www.googleapis.com/auth/spreadsheets.readonly']
    );

   onSuccess(jwtClient);

   return function (cancelError, onCancelerError, onCancelerSuccess) {
       onCancelerSuccess();
   };
   
}
