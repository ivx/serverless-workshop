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
