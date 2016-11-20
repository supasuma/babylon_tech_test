#!/usr/bin/env ruby

require "./lib/availability"
require "json"
require "time"

class MyApp

attr_reader :script_time

TIME_FORMAT = "%H:%M:%S"
TIME_REGEX = /^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0]$/

def initialize(script_time: nil)
  @script_time = ARGV.first || nil
  file = File.read('./availability_slots.json')
  data = JSON.parse(file)
  appointments  = data["availability_slots"]
end

def prompt_user
  if script_time == nil
    puts "What time would you like to book?"
    user_input = $stdin.gets
  else
    user_input = script_time
  end
  check_time_valid(user_input)
end

def check_time_valid(user_input)
  while !TIME_REGEX.match(user_input)
    puts "Invalid time format! Make sure you use ':' & select a time that is on the hour or at 10 minute intervals after."
    user_input = $stdin.gets
  end
  request = Time.parse(user_input).strftime(TIME_FORMAT)
  request_booking(request)
end

def request_booking(request)
  puts "Your booking is at:-"
  puts Availability.new(appointments).find_availability(request)

puts "Please confirm you would like this booking? please enter Y or N"
user_answer = $stdin.gets

if user_answer.upcase == "Y"
  data["availability_slots"] = appointments
  File.open("./availability_slots.json", "w") { |json_file| json_file.write(data.to_json) }
end

puts data
