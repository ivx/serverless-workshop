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

* Update the cli if you already have it installed
```
npm update -g serverless  
```

* Create AWS account
* Log into your account
* Visit IAM Portal and click Users [IAM Users](https://console.aws.amazon.com/iam/home?region=eu-west-1#/users)
* Add user `serverless-cli` and allow `programmatic acccess`
![Add User](/img/add-user.png)
* For simplicity attach existing policy `AdministratorAccess`
![Add user permissions](/img/add-user-permissions.png)
* Keep browser window with credentials open
![Add user credentials](/img/add-user-credentials.png)
* Configure aws credentials in serverless framework in your terminal
```
serverless config credentials --provider aws --key AKIAIOSFODNN7EXAMPLE --secret wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```
* Close credentials browser window
* During the course we will work with a s3 bucket which must be unique through all aws regions / accounts.
```
  siteName: :SERVERLESS-WORKSHOP-S3-BUCKET-PLACEHOLDER:
```
* There is a script which is able to exchange the bucket name easily
```
./rename-bucket serverless-workshop-devops-gathering-thomas-peitz
```

## Pre Info
* Each folder in this git repository shows a working end state.
* You can do all stuff alone at home if it is to fast for you.
* The learnings after each stage are more important than the actual coding of yourself.

## Part 1 - Get your first function running
* Create a new directory and initialize a serverless app
* We will use ruby as language. In  most parts the language is totally unimportant,
feel free to spice up your experience by using a different language.
```
mkdir my-own-code;cd my-own-code
serverless create --template aws-ruby
```

* Delete all comments in serverless.yml to see all your config at one glance
![Serverless simple config](/img/serverless-simple-config.png)

* Deploy your new app
```
serverless deploy -v 
```

* Test function locally
```
serverless invoke -f hello
```

* Let it greet yourself. Change code in handler.rb to greet yourself
```
def hello(event:, context:)
  { statusCode: 200, body: JSON.generate('Hello CHANGE_TO_YOUR_USERNAME :)') }
end
```

* Redeploy only the lambda function
```
serverless deploy -f hello
```

* Verify speed difference between deploying code / deploying whole cloudformation template
* Find and verify cloudformation template in aws interface and check which resources were created
![Cloudformation Resources](/img/cloudformation-resources.png)
* Show logs
```
serverless logs -f hello
```
* Let's talk about the potential of cost savings by increasing memory
* Delete your stack and recreate afterwards
```
serverless remove
serverless deploy
```

## Part 2 - Add a http endpoint via api gateway

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
serverless deploy
```

* We just spawned our first api gateway together
* Verify api gateway in aws interace
![API Gateway](/img/api-gateway.png)
* Get url of your functions
```
serverless info
```
* Discuss possibilites of api gateway

## Part 3 - Let our function greet others via GET Parameter

* We want to greet other persons as well. So lets add a GET Parameter to the function
```
params = event['queryStringParameters']
{ statusCode: 200, body: JSON.generate("Hello @InVision #{params['name']}") }
```

* You can add error handling if you want
For example event['queryStringParameters'] can be `nil` if no params are attached to your request

* Try out get parameter
```
curl https://your-api-id.execute-api.eu-central-1.amazonaws.com/dev/hello?name=greta
```

## Part 4 - Add a frontend on s3

* We need a frontend for our serverless app
* To deploy static sites with serverless framework, we need a plugin
```
serverless plugin install -n serverless-s3-sync
# or
cd part4;npm install
```
* Add plugin to serverless.yml
```
service: serverless-workshop-part-1

plugins:
  - serverless-s3-sync

provider:
```
* Configure plugin - See directory part-4 serverless.yml for details.
* We add a new root element to the serverless.yml - Resources.
* Check out [aws resources possibilities](https://serverless.com/framework/docs/providers/aws/guide/resources/).

* Create a `static` directory and add a index.html in the directory
```
<html>
  <head>
  </head>
  <body>
    <h1>Hello World</h1>
  </body>
</html>
```

* Deploy everything
```
serverless deploy -v
```

* Get [cloudformation outputs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/outputs-section-structure.html) to get website url
```
sls info -v
```
* Change some text in index.html
* Redeploy only s3 files
```
sls s3sync
```
* Let's talk about cloudfront / s3 combination. Different possibilities e.g. netlify.

## Part 5 - Allow connection from frontend to backend via HEADER manipulation

* Show weather data in user interface for Duesseldorf
* Delete hello function everywhere (serverless.yml and handler.rb)
* Create temperature function which outputs static value
```
def temperature(event:, context:)
  {
    statusCode: 200,
    body: JSON.generate({temperature: 10})
  }
end
```
* Create event handler which listens on /temperature on api gateway
```
functions:
  temperature:
    handler: handler.temperature
    events:
    - http:
        path: temperature
        method: get
```
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
* Update static/indxex.html with your api gateway address
* Deploy all via `serverless deploy`

## Part 6 - Add monitoring to our functions through Cloudwatch / XRay
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
* Let's talk about costs of monitoring and how important it is

## Part 7 - Use a http lib in lambda layer
* Now we will add real data to the request and see latency rise
* Add real weather api call. Sponsored through metaweather api.
* Get your location id first e.g. "646099" for Düsseldorf [Metaweather API Location search](https://www.metaweather.com/api/location/search/?query=d%C3%BCsseldorf)
* Api call to get data `https://www.metaweather.com/api/location/646099/`
```
#!/bin/ruby
require 'json'
require 'httparty'

def temperature(event:, context:)
  url = 'https://www.metaweather.com/api/location/646099/'
  resp = HTTParty.get(url).parsed_response
  temp = resp['consolidated_weather'].first['the_temp'].round(1)

  {
    statusCode: 200,
    body: JSON.generate({temperature: temp}),
    headers: {
      'Access-Control-Allow-Origin': '*',
    }
  }
end
```
* Add httparty to Gemfile
```
source 'https://rubygems.org'

gem 'httparty'
```
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
# If you get problems during the next step. Just rename directory ruby-layer to ruby. This is a ready directory to use.
docker run --rm -it -v $PWD:/var/gem_build -w /var/gem_build lambci/lambda:build-ruby2.7 bundle install --path=.
```

* Deploy everything
```
serverless deploy
```

## Part 8 - Lets fix response times through dynamodb
* We would do a lot of api requests if people would reload page more frequently. Lets fix this through using DynamoDB for caching.
* Add table in serverless.yml
```
    WeatherTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: weather
        AttributeDefinitions:
          - AttributeName: locationId
            AttributeType: N
        KeySchema:
          - AttributeName: locationId
            KeyType: HASH
        ProvisionedThroughput:
          ReadCapacityUnits: 1
          WriteCapacityUnits: 1
```

* Allow tables to be accessed by code
```
  tracing:
    lambda: true

  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:PutItem
        - dynamodb:Query
        - dynamodb:Scan
        - dynamodb:UpdateItem
        - dynamodb:GetItem
      Resource:
        Fn::GetAtt:
          - WeatherTable
          - Arn
```

* Fill table with one value manually through AWS Cli
* Add dynamodb gem into Gemfile
```
gem 'aws-sdk-dynamodb'
```

* Require it in code
```
require 'aws-sdk-dynamodb'
DYNAMO_DB = Aws::DynamoDB::Client.new(region: 'eu-central-1')
```

* Install locally gems
```
bundle --no-deployment 
```

* Update gem layer
```
docker run --rm -it -v $PWD:/var/gem_build -w /var/gem_build lambci/lambda:build-ruby2.5 bundle install --path=.
serverless deploy
```

* Refactor method to use dynamodb table instead of directly using api to retrieve temperature. See part-8 handler.rb.
* Let's talk about cost / scaling of dynamodb.

## Part 9 - Update dynamodb template automatically
* In the next part we will update the value in the database automatically
* We will add a new function with the following event type:
```
    events:
      - schedule: rate(1 minute)
```
* Then we will add some code to update the value in the dynamodb table
* Let's talk about use cases of schedules. Static vs dynamic content

## BONUS - Finish our app with some SQS messaging
* In our last step we will add SQS to our serverless application. In our mind we want to ensure
that if we query more locations, we use our weather api effectively. In most cases APIs allow to get several values at
onces. For our API this is not the case but we will still use this pattern in the example. We will always
get two locations at once and we will ensure that we are not running two api requests at once.
* First we add a new gem `aws-sdk-sqs` to our project and require it in the code.
* We need a SQS Queue to be able to send messages into SQS. We will create it in serverless.yml
* We will add a new function, called generateList which will set to scheduled at every minute.
* Then we create a function which generates a list, and inserts messages into SQS.
* Our old updateTemperature method will be rewritten to be triggered by SQS.
* Through reservedConcurrency we ensure that no more than x api requests are send concurrently.
* Through delay in sqs we show a different possibility to care for api limits. 
* And we introduce local payloads for local testing.
* Let's talk about SQS pricing, how lambda binds to SQS and the costs when you do not have a Dead Letter Queue.

# You are bored?
## Read about costs
* Read about serverless costs https://medium.com/@amiram_26122/the-hidden-costs-of-serverless-6ced7844780b
* Try tuning your lambda costs via tool https://github.com/alexcasalboni/aws-lambda-power-tuning
