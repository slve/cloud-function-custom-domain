const functions = require('firebase-functions');

exports.slve = functions.https.onRequest(async (req, res) => {
  res.status(202).send('OK');
});
