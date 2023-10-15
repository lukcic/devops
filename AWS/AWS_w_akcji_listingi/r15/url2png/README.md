# URL2PNG

![URL2PNG](./url2png.png?raw=true "URL2PNG")

Zainstaluj zaleznosci ...

```
$ npm install
```

... utworz kubelek S3

```
$ aws s3 mb s3://url2png
```

... uaktywnij w nim hosting internetowy

```
$ aws s3 website s3://url2png --index-document index.html --error-document error.html
```

... i za pomoca interfejsu CLI platformy AWS utworz w usludze SQS kolejke komunikatow

```
$ aws sqs create-queue --queue-name url2png
{
	"QueueUrl": "https://queue.amazonaws.com/878533158213/url2png"
}
```

... poddaj edycji plik config.json, nadaj wartosci wlasciwosciom QueueUrl i Bucket

... i uruchom proces roboczy URL2PNG

```
$ node worker.js
```

... otworz inny terminal i uruchom proces URL2PNG

```
$ node index.js "http://aws.amazon.com/"
Obraz PNG bedzie wkrotce dostepny pod adresem http://aws-in-action-url2png.s3-website-us-east-1.amazonaws.com/6dbe4a05-82b3-4cbd-bd2b-65bbc8a51539.png
```

... poczekaj i otworz obraz
