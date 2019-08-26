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

* We need a frontend for our serverless app
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
* Configure plugin - See directory part-4 serverless.yml
* Deploy everything
```
serverless deploy -v
```
* Visit url: `http://serverless-workshop-s3-bucket.s3-website.eu-central-1.amazonaws.com/`
* Change some text in index.html
* Redeploy on s3 files
```
sls s3sync
```

## Part 5

* Show weather data in user interface for Duesseldorf
* Delete hello function everywhere (serverless.yml and handler.rb)
* Create temperature function which outputs static value
* Allow cross-origin request through adding header in function output
```
  {
    statusCode: 200,
    body: JSON.generate({temperature: 10}),
    headers: {
      'Access-Control-Allow-Origin': '*',
    }
  }
```

## Part 6
* Add tracing to our functions
```
provider:
  name: aws
  runtime: ruby2.5

  stage: dev
  region: eu-central-1

  tracing:
    lambda: true
```
* Visit AWS [X-RAY](https://eu-central-1.console.aws.amazon.com/xray/home) dashboard
* Create new cloudwatch dashboard together - https://eu-central-1.console.aws.amazon.com/cloudwatch/home?region=eu-central-1#dashboards:

## Part 7
* Now we will add real data to the request and see latency rise.
* Add real weather api call. Sponsored through metaweather api.
* Get your location id first e.g. "646099" for Düsseldorf [Metaweather API Location search](https://www.metaweather.com/api/location/search/?query=d%C3%BCsseldorf)
* Api call to get data `https://www.metaweather.com/api/location/646099/`
* See code example in directory: `part 7`
* Add httparty to Gemfile
* Add a gem layer to our serverless function
```
layers:
  gemLayer:
    path: ruby

functions:
  temperature:
    handler: handler.temperature
    layers:
      - {Ref: GemLayerLambdaLayer}
    environment:
      GEM_PATH: /opt/2.5.0
```
* Install gems locally, compiled through docker on linux
```
docker run --rm -it -v $PWD:/var/gem_build -w /var/gem_build lambci/lambda:build-ruby2.5 bundle install --path=.
```
