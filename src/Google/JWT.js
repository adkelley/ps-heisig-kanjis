"use strict";

const {google} = require ('googleapis');
const keys = require('./api-keys.json');

exports._jwt = function(onError, onSuccess) {
   const jwt = new google.auth.JWT(
        keys.client_email, 
        null, 
        keys.private_key, 
        ['https://www.googleapis.com/auth/spreadsheets.readonly']
    );

   onSuccess(jwt);

   return function (cancelError, onCancelerError, onCancelerSuccess) {
       onCancelerSuccess();
   };
   
}
