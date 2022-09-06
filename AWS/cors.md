### CORS
Cross-Origin Resource Sharing

Origin = schema:
<protocol>://<host>:<port>

Same origin:
https://example.com/APP1 & https://example.com/APP2

Different origin:
https://WWW.example.com & https://OTHER.example.com

Browser-based security:
In your web app you can make request from other origin only if the other origin allows you to make this requests.

Correct CORS headers must be used, ex: Access-Control-Allow-Origin.

1. Web browser sends request to origin https://example.com
2. App code needs resources from another origin https://other.com
3. Browser sends “preflight request” to cross origin:
	* OPTIONS
	* Host: https://other.com
	* Origin: https://example.com
5. Cross origin sends the “preflight response” with response headers:
	* Access-Control-Allow-Origin: https://example.com
	* Access-Control-Allow-Methods: GET, PUT, DELETE
6. Browser received CORS headers, so now it can send request to Cross origin:
	* GET /
	* Host: https://other.com
	* Origin: https://example.com

###

### S3 CORS
```
Browser ———— GET index.html ————— > bucket-html (website enabled)
Browser <————————————————-—————  bucket-html (website enabled)

Browser ——— GET coffee.jpg ———> bucket-assets (website en, Cross origin)		ORIGIN: https://bucket-html.s3-website.eu-west-3.amazonaws.com
Browser <————————————————--  bucket-assets (website en, Cross origin)
    	Access-Control-Allow-Origin:
	http://bucket-html.s3-website.eu-west-3.amazonaws.com
```

S3 bucket options: Cross-origin resource sharing (CORS):
```
[
    {
        "AllowedHeaders": [
            "Authorization"
        ],
        "AllowedMethods": [
            "GET"
        ],
        "AllowedOrigins": [
            "<url of first bucket with http://...without slash at the end>",
			  "http://demo-s3-bucket-2022.s3-website-eu-west-1.amazonaws.com"
        ],
        "ExposeHeaders": [],
        "MaxAgeSeconds": 3000
    }
]
```