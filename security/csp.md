# Content Security Policy

CSP allows the web app developer to strictly define where additional resources that the web application uses can come from. Main goal of CSP is protection against XSS (Cross-Site-Scripting), but it should be last defense line which means app shouldn't have bugs allowing for XSS (all data coming from users should be validated). It works like an instruction for browser which elements of website should be loaded and which one should not. CSP doesn't fix the XSS vulnerability, it just blocks exploitation.

Defense-in-depth, second layer of protection.
Grade control on what web application can request, embed and execute.
Reduction of application privileges.
Reporting mode for detecting exploitation.

CSP adjusts elements like:

- images
- scripts
- fonts
- audio/video objects
- API fetches
- others

## Usage

CSP can be deployed using `Content-Security-Policy HTTP header`.

The most simple example:

```javascript
Content-Security-Policy: default-src https://example.com
```

or directly in HTML code as a part of `<meta>` section:

```html
<meta http-equiv="Content-Security-Policy" content="default-src https://example.com">
```

Not all directives works with `<meta>` and if vulnerability occurs before `<meta>` element then CSP will not work, so HTTP header method should be preferred.

In above case browser will allow loading external elements only from [](https://example.com) domain which means, if HTML code will include any external references like: `<img src="https://not-example.com">` or `<script src="https://another-domain.com"></script>` they will be blocked and browser's console will throw an error.

Browser will also block any `inline scripts` defined directly in HTML code. All scripts must be loaded from internal files hosted in the same domain: `<script src=https://example.com/app.js></script>`

### Reporting

When starting to work with CSP, it is recommended to use `report-only mode` to assess the state of the application
before changing the policy. To do this, instead of sending the `Content-Security-Policy header`, the
`Content-Security-Policy-Report-Only header` should be set.

`Content-Security-Policy-Report-Only` header can be used to inform administrator about policy violations, but without
blocking elements by the browser - `report-uri` directive:

```csp
Content-Security-Policy: default-src https://example.com; report-uri /api/csp-report;
```

Example report:

```json
{
  "document-uri": "https://tyrolit-frsvv16mr-tyrolit-website.vercel.app/en",
  "referrer": "",
  "violated-directive": "frame-src",
  "effective-directive": "frame-src",
  "original-policy": "report-uri /api/csp-report; default-src 'self' https://vercel.live https://vercel.com; connect-src https://vercel.live https://*.piwik.pro wss://*.pusher.com 'self'; script-src 'self' 'unsafe-eval' https://*.piwik.pro https://vercel.live https://www.gstatic.com https://*.vimeocdn.com https://player.vimeo.com 'nonce-OTJhODhmYjctM2E1MS00ZGVkLWI1ZDEtNjQyNmY3NWUwMGUz'; style-src 'self' https://vercel.live 'unsafe-inline'; img-src 'self' data: https://a.storyblok.com https://vercel.com https://*.vimeocdn.com; font-src https://vercel.live https://vercel.com 'self'; media-src https://player.vimeo.com https://*.akamaized.net https://*.vimeocdn.com 'self'; frame-src https://vercel.live; frame-ancestors https://app.storyblok.com; object-src 'self'; base-uri 'self'; form-action 'self';",
  "disposition": "report",
  "blocked-uri": "https://player.vimeo.com",
  "line-number": 9,
  "column-number": 278777,
  "source-file": "https://tyrolit-frsvv16mr-tyrolit-website.vercel.app/en",
  "status-code": 200,
  "script-sample": ""
}
```

```json
{
  "document-uri": "about",
  "referrer": "",
  "violated-directive": "connect-src",
  "effective-directive": "connect-src",
  "original-policy": "report-uri /api/csp-report; default-src 'self' https://vercel.live https://vercel.com; connect-src https://vercel.live https://*.piwik.pro wss://*.pusher.com 'self'; script-src 'self' 'unsafe-eval' https://*.piwik.pro https://vercel.live https://www.gstatic.com https://*.vimeocdn.com https://player.vimeo.com 'nonce-MTZjMTAxZDgtMDFhOC00N2RmLWJmZTItZGI0MjZkNTU5NzJm'; style-src 'self' https://vercel.live 'unsafe-inline'; img-src 'self' data: https://a.storyblok.com https://vercel.com https://*.vimeocdn.com; font-src https://vercel.live https://vercel.com 'self'; media-src https://player.vimeo.com https://*.akamaized.net https://*.vimeocdn.com 'self'; frame-src https://vercel.live; frame-ancestors https://app.storyblok.com; object-src 'self'; base-uri 'self'; form-action 'self';",
  "disposition": "report",
  "blocked-uri": "https://sockjs-us3.pusher.com/pusher/app/7d55ac978a3647512f45/606/j2fna66h/xhr?protocol=7&client=js&version=7.0.6&t=1732776463828&n=518",
  "line-number": 2,
  "column-number": 51016,
  "source-file": "https://vercel.live/_next-live/feedback/3708.63815dd6ab17d418121f.js",
  "status-code": 0,
  "script-sample": ""
}
```

`violated-directive` - the CSP directive in the original policy that was violated\
`effected-directive` - the effective directive that blocked the resource, after processing fallback logic from the CSP
policy (`default-src`)

#### Reporting solutions

`https://report-uri.com/`

## Syntax

```csp
directive-name value1 value2 'keyword'; directive-name2 [...]
```

* full directives are separated by `;`
* elements inside directive are separated by [space]
* values:
  * protocol name only, ex. `https`
  * domain name only like `example.com` without defining protocol
  * domain name with protocol, ex. `https://example.com`
  * domain name with wildcard, ex. `https://*.example.com` for subdomains, APEX is not included!
  * path to catalog, ex `https://example.com/scripts/` - trailing `/` gives information that resource is a catalog
  * path to the file, ex. `https://example.com/script.js`
  * same domain, like: `'self'` - must include apostrophe!
  * keyword `'none'`, which means external resource type will not be loaded

### Syntax examples

- `default-src 'self'` - resources on the site can be loaded only from own domain
- `default-src https://example.com https://*.anotherexample.com` - resources on the site can be loaded only from domain
  `https://example.com` or subdomains of `https://*.anotherexample.com`, but not from `https://anotherexample.com` itself
- `default-src 'self' https://example.com/script.js` - resources from own domain are allowed and only `script.js` file from `https://example.com`
- `default-src 'none'` - none of external resources are allowed

### Directives

- `default-src` - default directive which covers all individual directives, it is used if particular directive isn't set, should be first on the list
- `frame-src`, `child-src` - Web Workers API origins, `<iframe>` and `<frame>` sources. Allows you to specify where iframes in your webpage may be loaded from
- `connect-src` - origins for JavaScript APIs: Fetch API, XMLHTTPRequest, WebSocket, EventSource, Navigator.sendBeacon()
- `font-src` - fonts sources
- `img-src` - image sources
- `style-src` - external CSS styles sources
- `manifest-src` - manifest file sources
- `media-src` - audio/video files sources
- `object-src` - setting up origins allowed to load `<object>`, `<embed>` and `<applet>`. Usually these tags were used for loading unsafe technologies like Flash or Java, this directive should always be set as 'none'
- `script-src` - specifies the locations from which a script can be executed from
- `script-src-elem` - controls the location from which execution of script requests and blocks can occur
- `worker-src` - Web Workers API origins
- `base-uri` - whitelist for tag's `<base href=...>` value, which allows to define a base url against which all
  relative addresses will be recalculated. It can be used to bypass CSP if attacker can inject `<base>` tag with value of own origin just before `<script>` with proper nonce value. It should be always set with value of 'none' or 'self'.
- `block-all-mixed-content` - blocks any external resources served without HTTPS, browser support for it is limited :(
- `upgrade-insecure-requests` - upgrade all HTTP requests to HTTPS
- `form-action` - defines possible values of `<form action=...>` attribute, attacker can inject own `<form action=` value which override proper value
- `frame-ancestors` - it's the equivalent of `X-Frame-Options` header. Defines which origins can load your web-app inside `<iframe>` tag. `none` === `DENY`, `self` === `SAMEORIGIN`. In case of nested iframes, all origins must be whitelisted.
- `plugin-types` - definition of allowed plugin types like `application/x-shockwave-flash` used in `<object>` or `<applet>` tags
- `sandbox` - it is an equivalent of iframe's `sandbox` attribute. Allows to use additional restrictions in iframes like blocking alerts windows, accessing cookies or accessing localStorage by target web-app.

## script-src

`script-src` has extended keywords list:

- `none` - if website doesn't use JS at all
- `self` - only if there's no need to load external scripts
- `unsafe-inline` - allows for execution JS scripts defined as part of the site
  - between `<script>` tags
  - inside `on[event]` HTML attribute, for example `onclick=”someFunc()”`
  
  Use of this directive neutralizes main
  profit of deploying CSP. Shouldn't be used at all.
- `unsafe-eval` -  allows for execution of code passed to built-in JavaScript functions like:
  - `eval()` - executes code passed to it's argument as a string
  - `setTimeout()` and `setInterval()` - both executes string passed as the first argument as a JS code
  - `Function()` constructor, which based on string passed as an argument,  returns JS function

  Should be used only when necessary, for example is required for some JS frameworks, which use `eval` to
  execute code from HTML templates.

### Hashes

Should be used with web apps which use few external scripts with unchangeable code that cannot be moved to JS files. Allowed hashing algorithms: SHA256, SHA384, SHA512. Hashed value must be base64 encoded later.

1. Generating hash

```sh
echo -n 'someJSCode()' | openssl dgst -sha256 -binary | openssl base64
# dfpDHU1n...eoI=

```

2. Setting up header

```javascript
Content-Security-Policy: script-src 'dfpDHU1n...eoI='
```

3. Adding code to HTML

```html
<script>someJSCode()</script>
```

### Nonces

Nonce is an arbitrary number that can be used just once in an communication.
Adding it will ensure that script tag in the page is only executed if the nonce value matches the nonce in the CSP
header, which is a fresh random nonce generated for every response. That way, it could not be guessable by the attacker.
Using nonces you don't have to come up with the whitelist on the first place and you don't have to maintain it. It
resolves JSONP and Angular vulnerabilities (there's no whitelist). To avoid brute-force attack nonce value should be at
least 128 bits (16B). Should be used if web-app includes multiple of HTML defined scripts that cannot be moved into
files or if web-app uses scripts loaded from multiple external origins and whitelisting it may be problematic.

Most widgets or elements you load dynamically source other JS files (load other JS modules). If you have full control of the library you could manually propagate nonce to the dynamically created script. External scripts like Google Maps doesn't have this feature. It will provide static script to use, so you can't use nonces with external scripts.

```js
default-scr 'self';
script-src 'self' 'nonce-ihUB6ng5VRUny79rhit8tn8rtO';
report-uri /csp_violation_logger;
```

```html
<script nonce="ihUB6ng5VRUny79rhit8tn8rtO" src="//example.com/script.js"
```

All mentioned methods can be mixed if it is needed:

```js
Content-Security-Policy: script-scr https://example.com 'dfpDHU1n...eoI=' 'nonce-ihUB6ng5VRUny79rhit8tn8rtO'
```

### `strict-dynamic` source expression

Problems:

1. Some apps load multiple external scripts, so `script-src` directive can be long and hard to maintain.
2. Some apps load script dynamically based on ex. client browser or device features. In that case all external scripts origins should be whitelisted or external scripts should be extended with nonce value.

Solution - `strict-dynamic` value. It adds trust propagation mechanism, which means that we trust inline script with nonce value which can load external script (parser-inserted) from non-whitelisted origin. Because `<script>` tag is trusted, external script loaded by it will also be trusted:

```js
Content-Security-Policy: script-src 'nonce-ihUB6ng5VRUny79rhit8tn8rtO' 'strict-dynamic'
```

```html
<script 'nonce-ihUB6ng5VRUny79rhit8tn8rtO'>
	var sc = document.createElement('script');
	sc.src = 'https://example.com/script.js';
	document.body.appendChild(sc);
</script>
```

`strict-dynamic` drops existing whitelists and `unsafe-inline` keyword!

`strict-dynamic` aims to make CSP simpler to deploy for existing applications which have a high degrees of confidence in
the scripts their load directly, but low confidence in the possibility to provide a secure whitelist.

To maintain backward compatibility with older browsers (before 2016) `script-src` should include whitelisted domains and `unsafe-inline` keyword.

```pwsh
Content-Security-Policy: script-src https://example.com 'nonce-ihUB6ng5VRUny79rhit8tn8rtO' 'unsafe-inline' 'strict-dynamic'
```

## Evaluator

Tool for validating CSP policies. It can rate given policy and shows tips how to restrict it better.

https://csp-evaluator.withgoogle.com/

## Common mistakes

- `unsafe-inline` in `script-src` and no nonce - allows adding `<script>` tags
- URL schemes (https: )or wildcards in `script-src` and no `strict-dynamic` - can add inline script but can source script from wherever
- missing `object-src` or `default-src` directive - scripts are restricted, but attacker can could just inject a object tag and allow script access
- allow 'self' + hosting user-provided content on the same origin - if app is hosted in big domain with other apps or if you host user provided data on your domain or if you have some weird error messages that allow you to echo back strings right on your same domain all of this can potentially be used to completely bypass the CSP

Example:

```html
<script src="/user_upload/evil_cat.jpg.js">
```

## Bypassing CSP

### Whitelisted `JSONP-like` endpoint

`JSON with Padding` (JSONP) is a method for sending JSON data without worrying about
cross-domain issues. JSONP does not use the XMLHttpRequest object, it uses `<script>` tag instead to wrap JSON content.
JSONP has parameter usually called `callback` which takes function name. Mentioned function uses JSON as an argument,
but very often the value is not validated. CSP checks if domain is whitelisted and run script which includes malicious
payload.

Policy:

```js
script-src 'self' https://whitelisted.com
object-scr 'none'
```

Bypass:

```html
<script src="https://whitelisted.com/jsonp-endpoint?callback=alert(1);"></script>
```

```js
alert(1);({
  'key1': 1,
  'key2': 2
});
```

JSONP still exists in most APIs because a lot of them still allow a call back something for passing data across domains.

Examples:

- `https://ajax.googleapis.com`
- `https://google-analytics.com`

Both have JSONP-like endpoints, so if our CSP allows for these domains, XSS is possible.

### Whitelisting CDNs

Allowing for example https://cdnjs.cloudflare.com and sourcing vulnerable version of Angular.js from it. When Angular is loaded he can do whatever Angular can do ex. inject a source angular expression. Angular adds an abstraction layer on top of JavaScript. Whatever is doing inside Angular doesn't care CSP anymore. Bypass can be combined with other frameworks like Prototype.js.

Example:

```js
script-src 'self' https://cdnjs.cloudflare.com
```

```html
  <body>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prototype/1.7.2/prototype.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.0.1/angular.js"></script>
    <div ng-app ng-csp>
      {{$window.alert('xss')}}
    </div>
  </body>
```

Details:

https://blog.huli.tw/2022/09/01/en/angularjs-csp-bypass-cdnjs/

### Path relaxation due to `open redirect`

`Open redirect` application endpoint allows a user to control a redirect or forward to another URL. If the app does not validate untrusted user input, an attacker could supply a URL that redirects an unsuspecting victim from a legitimate domain to an attacker’s phishing site.

Example policy:

```js
script-src https://whitelisted.com/totally/secure.js https://some.website.with.openredirect.com
object-src 'none'
```

The following URLs redirect to bright.global:

```js
https://www.google.com/amp/s/bright.global/
https://www.youtube.com/redirect?q=bright.global
```

### More examples

https://book.hacktricks.xyz/pentesting-web/content-security-policy-csp-bypass

## Summary

1. CSP deployment should be started with `report-only` mode.
2. Analyze, if deployment can be done without using dangerous directives like `unsafe-inline`.
3. Check all external origins used by application, if possible resources should be moved to the servers that we can
   control.

