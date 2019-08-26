require 'json'

def hello(event:, context:)
  { statusCode: 200, body: JSON.generate('Hello friends :)') }
end
