
Missing security headers doesn't necessarily create a vulnerability, app context must be understood first. Functionality of the app will help judge if there is a significant risk. Sometimes there is an intended feature why we don't want it.   

Some headers will weaken security if added, like CORS (disables SOP). Mostly they will strenghten security if added, like X-Frame-Options, CSP, HSTS, HTTPOnly Cookie.


### HTTP Strict-Transport-Security

Header forces use of HTTPS transmission. In case of certificate error it disallows user to enter the site.
First request may use HTTP without TLS if there's no HTTPS redirect on server side. If webpage is accessed via HTTP browser ignores HSTS header, because in that case attacker is able to modify headers using MITM attack. Remedy can be `preload` parameter. Most modern browsers have feature to avoid HTTP requests.

Additionally server should automatically redirect HTTP to HTTPS with 307 (internal redirect code).

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

Indicate if browser can be allowed to render the page inside iframe (<iframe>, <frame>, <embed>, <object>). Protects against Click-jacking attacks - ex. clicking in hidden FB's like. Make sense only if page has functionality which can be impacted by clickjacking (site handles critical users actions). Doesn't make sense if rendering page inside iframe is desired (ex. embedding youtube video on the page).

Params:
* deny - block embedding site inside frames
* sameorigin - allow embedding only inside own origin
* allow-from URI - only specified origins can embed site

The same result can be achieved using `Content-Security-Policy` directive called `frame-ancestors`. 

### Set-Cookie

Be aware that existing XSS cannot steal protected cookies using JS, but it's able to send request which will be authenticated with cookie. Next thing is only session cookies should be protected, typical information stored as cookies usually shouldn't. 

Params:
* Secure - browser will send cookies only with encrypted transmission (HTTPS). 
* HTTPONLY - browser will not allow JS scripts to access cookies

### X-XSS-Protection
Tell browser to not run data from outside.

Params:
* 0 - disables XSS filtering
* 1 - enables XSS filtering (default for most browsers), if attack is detected the browser will sanitize the page (remove the unsafe parts)
* 1; mode-block - enables XSS filtering, if attack is detected the browser will prevent the page from rendering


