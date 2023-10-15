# Node TODO dla platformy AWS

![Node TODO dla platformy AWS](./nodetodo.png?raw=true "Node TODO dla platformy AWS")

Zainstaluj zaleznosci ...

```
npm install
```

... i uruchom aplikacje nodetodo

```
node index.js --help
```

## uzycie

### uzytkownik

#### dodawanie

```
node index.js user-add <uid> <email> <phone>

node index.js user-add michael michael@widdix.de 0123456789
```

#### usuwanie

```
node index.js user-rm <uid>

node index.js user-rm michael
```

#### lista

```
node index.js user-ls
```

#### wyswietlanie

```
node index.js user <uid>

node index.js user michael
```

### zadanie

#### dodawanie

```
node index.js task-add <uid> <description> [<category>] [--dueat=<yyyymmdd>] 

node index.js task-add michael "zaplanuj obiad" --dueat=20150522
```

####  usuwanie

```
node index.js task-rm <uid> <tid>

node index.js task-rm michael 1432187491647
```

#### lista

```
node index.js task-ls <uid> [<category>] [--overdue|--due|--withoutdue|--futuredue|--dueafter=<yyyymmdd>|--duebefore=<yyyymmdd>] [--limit=<limit>] [--next=<id>]

node index.js task-ls michael
```

#### oznacz jako zrobione

```
node index.js task-done <uid> <tid>

node index.js task-done michael 1432187491647
```

## schemat

W celu utworzenia tabel w bazie DynamoDB mozna uzyc szablonu CloudFormation `tables.yaml` lub interfejsu CLI:

### uzytkownik

```
aws dynamodb create-table --table-name todo-user --attribute-definitions AttributeName=uid,AttributeType=S --key-schema AttributeName=uid,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

#### klucz podstawowy

* HASH: uid

#### atrybuty

* uid: string
* email: string
* phone: string

### zadanie

```
aws dynamodb create-table --table-name todo-task --attribute-definitions AttributeName=uid,AttributeType=S AttributeName=tid,AttributeType=N --key-schema AttributeName=uid,KeyType=HASH AttributeName=tid,KeyType=RANGE --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

aws dynamodb update-table --table-name todo-task --attribute-definitions AttributeName=uid,AttributeType=S AttributeName=tid,AttributeType=N AttributeName=category,AttributeType=S --global-secondary-index-updates '[{"Create": {"IndexName": "category-index", "KeySchema": [{"AttributeName": "category", "KeyType": "HASH"}, {"AttributeName": "tid", "KeyType": "RANGE"}], "Projection": {"ProjectionType": "ALL"}, "ProvisionedThroughput": {"ReadCapacityUnits": 5, "WriteCapacityUnits": 5}}}]'
```

#### klucz podstawowy

* HASH: uid
* RANGE: tid

#### atrybuty

* uid: string
* tid: number (time stamp)
* category: string (optional)
* description: string
* due: number (yyyymmdd)
* created: number (yyyymmdd)
* completed: number (yyyymmdd)

## demo

```
$ node index.js user-add michael michael@widdix.de +4971537507824
$ node index.js task-add michael "zarezerwuj bilet na lot konferencje AWS re:Invent"
$ node index.js task-add michael "przejrzyj rozdzial 10."
$ node index.js task-ls michael
$ node index.js task-done michael <tid>
```
