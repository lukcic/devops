# Content Security Policy

Main goal of CSP is protection against XSS (Cross-Site-Scripting). It works like an instruction for browser which elements of website should be loaded and which one should not. 


CSP adjusts elements like:
* images
* scripts
* fonts
* audio/video objects
* API fetches

## Usage
CSP can be deployed using `Content-Security-Policy` HTTP header:

The most simple example:
```
Content-Security-Policy: default-src https://example.com
```
or directly in HTML code as a part of <meta> section:
```
<meta http-equiv="Content-Security-Policy" content="default-src https://example.com">
``` 
Not all directives works with `<meta>`, so HTTP header method should be preferred.


In this case browser will allow loading external elements only from [](https://example.com) which means, if HTML code will include any external references like: `<img src="https://not-example.com">` or `<script src="https://another-domain.com"></script>` they will be blocked and browser's console will throw an error.  

Additionally browser will block any inline scripts defined directly in HTML code. This means all scripts must be loaded from internal files hosted in the same domain: `<script src=https://example.com/app.js></script>`

## Syntax

```
directive-name value1 value2 'keyword' ; directive-name2 [...]
```

* full directives are separated by `;`
* elements inside directive are separated by [space]
* values:
** protocol name only, ex. `https`
** domain name only like `example.com` without defining protocol 
** domain name with protocol, ex. `https://example.com`
** domain name with wildcard, ex. `https://*.example.com` for subdomains, not include APEX!
** path to catalog, ex `https://example.com/scripts/` - trailing `/` gives information that resource is a catalog
** path to the file, ex. `https://example.com/script.js`
** same domain, like: `'self'` - must include apostrophe
** keyword `'none'`, which means external resource type will not be loaded

### Syntax examples

* `default-src 'self'` - all resources on the site will be loaded only from this domain which HTML file is currently opened
* `default-src https://example.com https://*.anotherexample.com` - all resources on the siete will be loaded only from domain `https:example.com` or from any subdomain of `https://*.anotherexample.com`, but not from `https://anotherexample.com` itself
* `default-src 'self' https://example.com/script.js` - resources from own domain are allowed and only `script.js` file from `https://example.com`
* `default-src 'none'` - none of external resources are allowed




