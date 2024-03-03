## Change file ownership in bulk

```sh
icacls C:\Windows\CSC\v2.0.6\namespace\qnap /T /grant lukcic:F
takeown /F C:\Windows\CSC\v2.0.6\namespace\qnap /R /D Y
```
