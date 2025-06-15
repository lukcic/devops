# WAF

Web application firewall

Client --> CDN [ +WAF ] --> ALB --> EC2

WAF is regional service (ALB, Api Gateway, AppSync). Global region can be used if working with CLoudFront.  

Web ACLS - Web Access Lists

Web request body inspection - part of body must be examined to evaluate the rules on the request. Size 16-64KB. 16KB is default, larger are paid extra.

Rules

- regular rules
- rate limit rules

Rules

- AWS managed
  - paid rules, like bot protection,  account fraud prevention, account takeover protection; paths of registration must be provided, payload time (json, form)
  - free rules, like admin protection, IP reputation list, anonymous IP list (VPNs), known bad inputs (exploitations)
- custom rules

subrules - e.g. types of bots in bot control, automated browser in account fraud prevention

BOT control - uses reverse dns to check if bot is legit (e.g. Google).

Actions

- allow
- block
- count
- captcha
- challenge

Default Web ACL action for requests that not match any rules. WAF can work as whitelist with block all, or blacklist with allow all.

## WCU-  Web ACLs capacity unit

WAF has limits, more than 1500 WCUs is paid. Max value is 5000.

## Application integration

Scripts that can be added to the website code to challenge visitor by captcha or determine if it is a bot or real human.

## regex

Some parts do not need WAF checks (static files). Here should be filtered.

## Rule groups

Way for sharing rules between different Web ACLs.

