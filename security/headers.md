### HTTP Strict-Transport-Security

Header forces use of HTTPS transmission. In case of certificate error it disallows user to enter the site.
First request may use HTTP without TLS. 

Server should automatically redirect HTTP to HTTPS with 307 (internal redirect code).

Params:
* max-age (required) - how long browser will remember setting (in seconds)
* includeSubDomains - the rule is also related to subdomains. Should be used with `Set-cookie: Secure` to protect cookies.  
* preload - if site is added to the `HSTS Pre-loaded list` managed by Google (https://hstspreload.org) all traffic will be transferred via HTTPS (with first request also). This is not part of official HTTP specification. Supported by all modern browsers.

### Referrer-Policy

Case: Internal (hidden) system has comments feature. If comment includes link to external service and user will click it, external server will receive request with url of hidden app in `Referer` header (name of header has a mistake) - it may be classified by information leak.

Params:
* no-referrer-when-downgrade (default) - in no policy, send referrer inly if the same protocol and do not send referrer while moving to less secure communication (HTTPS-HTTP)
* no-referrer - `Referer` header will not be send
* origin - send only origin, without full path
* origin-when-cross-origin - full path will be sent only if request is sent from the same origin, in other cases only origin will be send
* same-origin - full path will be sent only if request is sent from the same origin, in other cases no `Referer` header will be send
* strict-origin - only origin will be send in case of the same protocol, in case of change to less secure protocol (Https->Http) no `Referer` header will be send
* strict-origin-when-cross-origin - full path only if the same origin, in other cases the same behavior like `strict-origin`
* unsafe-url - send full path always, even if protocol downgrade

### X-Content-Type-Options

Browser will read `Content-Type` header and it will not try to interpret file using own mechanism (disabling MIME sniffing). 

Params:
* nosniff 

### Permissions-Policy (aka Feature-Policy)

Enable/disable/edit some features of browsers API like camera, microphone, auto-play, full-screen, etc. Works for given site and for content loaded by `iFrame`.

Example:
```
Permissions-Policy: geolocation 'none'; camera 'none'
```

### X-Frame-Options

Sets if give site can be loaded inside frame (<iframe>, <frame>, <embed>, <object>). Protects against Click-jacking attacks - ex. clicking in hidden FB's like.

Params:
* deny - block embedding site inside frames
* sameorigin - allow embedding only inside own origin
* allow-from URI - only specified origins can embed site

The same result can be achieved using `Content-Security-Policy` directive called `frame-ancestors`. 


