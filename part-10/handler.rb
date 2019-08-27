#!/bin/ruby
require 'json'
require 'httparty'
require 'aws-sdk-dynamodb'
require 'aws-sdk-sqs'

DYNAMO_DB = Aws::DynamoDB::Client.new(region: 'eu-central-1')
SQS = Aws::SQS::Client.new(region: 'eu-central-1')

def temperature(event:, context:)
  db_query = {
    table_name: 'weatherTable',
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
  puts event.inspect
  #url = 'https://www.metaweather.com/api/location/646099/'
  #resp = HTTParty.get(url).parsed_response
  #temp = resp['consolidated_weather'].first['the_temp'].round(1)

  #resp = DYNAMO_DB.update_item({
  #  table_name: 'weatherTable',
  #  key: {
  #    locationId: 1
  #  },
  #  update_expression: 'set temperature = :t',
  #  expression_attribute_values: {':t' => temp }
  #})
  #puts resp.inspect
end

def generateList(even:, context:)
  locationList = [646099,667931,638242,656958,2487956,766273]
  delay = 0

  locations.each do |l|
    SQS.send_message(queue_url: ENV['SQS_URL'], message_body: sqs_message.to_json, delay_seconds: delay)
    delay += 10
  end
end
