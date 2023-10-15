# Jak utworzyc nowy plik etherpad.zip

1. Potrzebny jest system Amazon Linux (obslugiwana wersje mozna sprawdzic pod adresem http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts.platforms.html#concepts.platforms.nodejs)
1. Pobierz ostania wersje aplikacji Etherpad dla systemow Linux/Mac ze strony http://etherpad.org/#download
1. Poleceniem cd przejdz do katalogu, w którym rozpakowales archiwum zip
1. Utworz plik `.ebextensions/custom.config` o nastepujacej zawartosci (upewnij sie, ze wersja NodeVersion jest dostepna w najnowszym srodowisku uslugi EB):
```
option_settings:
  aws:elasticbeanstalk:container:nodejs: 
    NodeCommand: "bin/run.sh"
    NodeVersion: "10.16.3"
```
1. Utworz plik `src/.npmrc` o nastepujacej zawartosci:
```
unsafe-perm = true
```
1. Skopiuj plik `settings.json.template` nadajac mu nazwe `settings.json` i zmien port na 8081
1. Wykonaj polecenie `zip -r etherpad.zip ./`
