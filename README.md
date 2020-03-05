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

## Part 1 - Get your first app running
* Each folder in this git repository shows a working end state
* Create a new directory and initialize a serverless app
```
serverless create --template aws-ruby
```

* Delete all comments in serverless.yml to see all your config at one glance

* Deploy our new app
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

* Redeploy only the lambda function code
```
serverless deploy -f hello
```

* Verify cloudformation template in aws interface
* Show logs
```
serverless logs -f hello
```
* Let's talk about cost savings by increasing memory

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
* Get url of your functions
```
serverless info
```
* Let's talk about api gateway

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
```
* Add plugin to serverless.yml
```
service: serverless-workshop-part-1

plugins:
  - serverless-s3-sync

provider:
```
* Configure plugin - See directory part-4 serverless.yml
* Change bucket name in serverless.yml, otherwise you will get an error during deployment
S3 Bucket names must be unique over all regions and accounts
```
  siteName: serverless-workshop-trivago-ADD_SOME_IDENTIFIER
```

* Create a `static` directory and add a index.html in the directory
```
<html>
  <head>
  </head>
  <body>
    <h1>Hello DUS</h1>
  </body>
</html>
```

* Deploy everything
```
serverless deploy -v
```

* Visit url: `http://YOUR_BUCKET_NAME.s3-website.eu-central-1.amazonaws.com/`
* Change some text in index.html
* Redeploy only s3 files
```
sls s3sync
```
* Let's talk about cloudfront / s3 combination. Different possibilities e.g. netlify.

## Part 5 - Allow connection from frontend to backend via HEADER manipulation

* Show weather data in user interface for Duesseldorf
* Delete hello function everywhere (serverless.yml and handler.rb)
* Create temperature function which outputs static value. See handler.rb in part-5 directory for help.
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

* If you get problems during this step. For example do not have docker installed. Just rename directory ruby-layer to ruby. This is a ready directory to use.

* Deploy everything
```
serverless deploy
```

## Part 8 - Lets fix response times through dynamodb
* That are some bad response times. Lets fix this through DynamoDB.
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
