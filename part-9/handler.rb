#!/bin/ruby
require 'json'
require 'httparty'
require 'aws-sdk-dynamodb'

DYNAMO_DB = Aws::DynamoDB::Client.new(region: 'eu-central-1')

def temperature(event:, context:)
  db_query = {
    table_name: 'weather',
    expression_attribute_values: {
      ':id' => 1
    },
    key_condition_expression: 'locationId = :id',
    projection_expression: 'temperature',
  }

  resp = DYNAMO_DB.query(db_query)

  temp = resp['items'].first['temperature'].to_f.round(1)

  {
    statusCode: 200,
    body: JSON.generate({temperature: temp}),
    headers: {
      'Access-Control-Allow-Origin': '*',
    }
  }
end

def updateTemperature(event:, context:)
  url = 'https://www.metaweather.com/api/location/646099/'
  resp = HTTParty.get(url).parsed_response
  temp = resp['consolidated_weather'].first['the_temp'].round(1)

  resp = DYNAMO_DB.update_item({
    table_name: 'weather',
    key: {
      locationId: 1
    },
    update_expression: 'set temperature = :t',
    expression_attribute_values: {':t' => temp }
  })
  puts resp.inspect
end
