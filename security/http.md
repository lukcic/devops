## iframe

```html
<iframe> height='800px' width='100%' src='https://localadmin.pl' </iframe>
```

```html
<script>
  document.body.innerHTML = `
        <iframe> 
            height='800px' 
            width='100%' 
            src='https://localadmin.pl' 
        </iframe>`;
</script>
```

## SQL injection

Use `Prepare statement` which prepares query model first and then execute it using named placeholders (?). Data from client are parsed and prevent
adding another command in data field.

## CORS

Fetch by default doesn't include session cookies. To use it parameter `credentials: include` must be set. If it is set,
then CORS with `Access-Control-Allow-Origin: *` won't work. CORS host must be set literally in header (no wildcard).
Second header `Access0Control-Allow-Credentials: true` must also be set.
