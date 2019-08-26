# serverless-workshop

## Prerequisites
* Install nodejs
```
# If you have brew installed:
brew install node
# Alternative:
https://nodejs.org/dist/v10.16.3/node-v10.16.3.pkg
https://nodejs.org/dist/v10.16.3/node-v10.16.3-x86.msi
```

* Install serverless framework
```
npm install -g serverless
```

* Configure aws credentials in serverless framework
```
serverless config credentials --provider aws --key AKIAIOSFODNN7EXAMPLE --secret wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

## Deploy first version and test it

* Create a new directory and initialize a serverless app
 serverless create --template aws-ruby

* Deploy our new app
```
serverless deploy -v 
```

* Test function locally
```
serverless invoke -f hello
```

* Let it greet yourself. Change code in handler.rb to greet yourself.

```
serverless deploy -f hello
```

## Part 2

* We want to reach our application through HTTP Get on /hello
```
functions:
  hello:
    handler: handler.hello
    events:
    - http:
        path: hello
        method: get
```
* Redeploy whole stack
```
serverless deploy -f hello
```

* We just spawned our first api gateway together

## Part 3

* We want to greet other persons as well. So lets add a GET Parameter to the function.
```
params = event['queryStringParameters']
{ statusCode: 200, body: JSON.generate("Hello @InVision #{params['name']}") }
```

* You can add error handling if you want as event['queryStringParameters'] can be `nil` if not params are send.

## Part 4

* Let us start a real project now. A small weather application.
* We need a frontend first
* To deploy static sites with serverless framework, we need a plugin.
```
serverless plugin install -n serverless-s3-sync
```
* Add plugin to serverless.yml
```
service: serverless-workshop-part-1

plugins:
  - serverless-s3-sync

provider:
```
* Configure plugin - See directory part-4
