const AWS = require('aws-sdk');
const uuid = require('uuid/v4');
const config = require('./config.json');
const sqs = new AWS.SQS({
  region: 'us-east-1'
});

if (process.argv.length !== 3) {
  console.log('Brak adresu URL');
  process.exit(1);
}

const id = uuid();
const body = {
  id: id,
  url: process.argv[2]
};

sqs.sendMessage({
  MessageBody: JSON.stringify(body),
  QueueUrl: config.QueueUrl
}, (err) => {
  if (err) {
    console.log('blad', err);
  } else {
    console.log('Obraz PNG bedzie wkrotce dostepny pod adresem http://' + config.Bucket + '.s3-website-us-east-1.amazonaws.com/' + id + '.png');
  }
});
