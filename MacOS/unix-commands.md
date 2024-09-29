MacOS Commands

## Listening for open ports

```sh
`sudo lsof -i -P | grep LISTEN
```

Run app in background
`open -j /opt/homebrew/bin/syncthing`

## Chrome with security disabled

```sh
open -n -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args \ --user-data-dir="/tmp/chrome_dev_test" --disable-web-security
```

## Flush DNS

```sh
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
```