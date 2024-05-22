# SOP - Same Origin Policy
Javascript code on given page cannot fetch data from different origin. 

CORS disables SOP (weaken SOP policy). Webserver can use CORS headers to allow another website to send request to itself. 

For websites that uses Cookie authentication setting up non-restrictive CORS (with allowing credentials) is dangerous missconfiguration. Setting up `Allow-credentials` tells the browser that it can add session cookies to the requests - request will be authenticated as the current user.  App with token based authentication are safe (browser will not send authentication token).

Open api shouldn't have set CORS headers. 