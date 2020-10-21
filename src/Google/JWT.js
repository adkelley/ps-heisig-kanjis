"use strict";

const {google} = require ('googleapis');

exports._jwt = function(onError, onSuccess) {
   try {
       const keys = require('./api-keys.json');
       const jwt = new google.auth.JWT(
            keys.client_email, 
            null, 
            keys.private_key, 
            ['https://www.googleapis.com/auth/spreadsheets.readonly']
        );
        // TODO: 1) See if a jwt token already exists; 2) check whether it has 
        // expired; 3) if expired get a new one; else use existing
        //console.log(jwt);
        onSuccess(jwt);
   } catch (err) {
       onError(err);
       return;
   }

   return function (cancelError, onCancelerError, onCancelerSuccess) {
       onCancelerSuccess();
   };
   
}
