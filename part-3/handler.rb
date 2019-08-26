require 'json'

def hello(event:, context:)
  puts event.inspect

  if event['queryStringParameters']
    params = event['queryStringParameters']
    if params['name']
      { statusCode: 200, body: JSON.generate("Hello @InVision #{params['name']}") }
    else
      { statusCode: 404, body: JSON.generate('Could not retrieve name parameter.') }
    end
  else
    { statusCode: 404, body: JSON.generate('Could not find any query string parameters.') }
  end
end
