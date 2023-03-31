//getAndStoreToken.js
'use strict';
require('dotenv').config();
const fs = require('fs');
const readline = require('readline');
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});
const { promisify } = require('util');

const { google } = require('googleapis');
const { OAuth2Client } = require('google-auth-library');


const mongoose = require('mongoose')
const EmailToken = require('./models/emailToken')

// Promisify with promise
const readFileAsync = promisify(fs.readFile);

const SCOPES = [
  'https://www.googleapis.com/auth/gmail.send',
];

const main = async () => {
  const content = await readFileAsync(__dirname + '/client_secret.json');
  const credentials = JSON.parse(content); //credential//authentication
  const clientSecret = credentials.installed.client_secret;
  const clientId = credentials.installed.client_id;
  const redirectUrl = credentials.installed.redirect_uris[0];
  const oauth2Client = new OAuth2Client(clientId, clientSecret, redirectUrl);

  //get new token
  const authUrl = oauth2Client.generateAuthUrl({
    access_type: 'offline',
    scope: SCOPES
  });

  console.log('Authorize this app by visiting this url: ', authUrl);
  rl.question('Enter the email you authorized with: ', (email) => {
    rl.question('Enter the code from that page here: ', (code) => {

      oauth2Client.getToken(code, async (err, token) => {
        if (err) {
          console.log('Error while trying to retrieve access token', err);
          return;
        }

        oauth2Client.credentials = token;

        try {
          await mongoose.connect(process.env.DB_URI)
          const found = await EmailToken.findOne({ email: email }).exec()
          if (!found) {
            const email_token = new EmailToken({
              email: email,
              token: token
            })
            await email_token.save()
          } else {
            await found.updateOne({ token: token })
          }
        } catch (err) {
          throw err;
        }

        console.log('Token stored in database!');
        rl.close();
        process.stdin.destroy();
        process.exit(0)
      });
    });
  })
};

main();