"use strict";

exports._pbpaste = function (onError, onSuccess) {
        const { spawn } = require('child_process');
        const pbpaste = spawn('pbpaste');

        pbpaste.stdout.on('data', data => {
           console.log(data.toString());
           onSuccess();
        });

        pbpaste.stderr.on('data', data => {
           onError(data);
        });

        return function (cancelError, onCancelerError, onCancelerSuccess) {
            onCancelerSuccess();
        };
}

exports._pbcopy = function pbcopy(data) {
    return async function (onError, onSuccess) {
        const { spawn } = require('child_process');
        const pbcopy = spawn('pbcopy');

        await pbcopy.stdin.write(data);
        pbcopy.stdin.end();

        onSuccess();

        return function (cancelError, onCancelerError, onCancelerSuccess) {
            onCancelerSuccess();
        };
    }
}
