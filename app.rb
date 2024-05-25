require "sinatra"
require "sinatra/reloader"
require "http"
require "sinatra/cookies"

get("/") do
  erb(:welcome)
end

get("/umbrella") do
  erb(:umbrella_form)
end

post("/process_umbrella") do

  #Get location information
  @user_location = params.fetch("user_location")

  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=Merchandise%20Mart%20" + @user_location + "&key=" + ENV.fetch("GMAPS_KEY")

  @raw_response = HTTP.post(gmaps_url).to_s

  @parsed_response = JSON.parse(@raw_response)

  @loc_hash = @parsed_response.dig("results", 0, "geometry", "location")

  @latitude = @loc_hash.fetch("lat")
  @longitude = @loc_hash.fetch("lng")  
  
  #store information into cookies
  cookies["last_location"] = @user_location
  cookies["last_lat"] = @latitude
  cookies["last_lng"] = @longitude

  #get weather information
  #fetch weather API key
  pirate_weather_api_key = ENV.fetch("PIRATE_WEATHER_KEY")

  pirate_weather_url = "https://api.pirateweather.net/forecast/" + pirate_weather_api_key + "/#{@latitude},#{@longitude}"

  #pp pirate_weather_url
  weather_url = HTTP.get(pirate_weather_url)
  ##pp weather_url

  weather_json = JSON.parse(weather_url.to_s)

  @current = weather_json["currently"]

  @message = do_I_need_an_umbrella(weather_json) #parse json data using the function below

  erb(:umbrella_results)
end

def do_I_need_an_umbrella(weather_json)
  """Determine if an umbrella is needed

     Input:
       weather_json
    Output:
       a string stating if an umbrella is needed
  """

  # Some locations around the world do not come with minutely data.
  minutely_hash = weather_json.fetch("minutely", false)

  if minutely_hash
    #get weather information in the next hour
    @next_hour_summary = minutely_hash["summary"]
  end

  hourly_hash = weather_json["hourly"]

  hourly_data_array = hourly_hash["data"]

  next_twelve_hours = hourly_data_array[1..12]

  precip_prob_threshold = -1

  any_precipitation = false

  lst_precipitation = []

  next_twelve_hours.each do |hour_hash|
    precip_prob = hour_hash.fetch("precipProbability")

    if precip_prob > precip_prob_threshold
      any_precipitation = true

      precip_time = Time.at(hour_hash.fetch("time"))

      seconds_from_now = precip_time - Time.now

      hours_from_now = seconds_from_now / 60 / 60

      #append data to array
      lst_precipitation.append([hours_from_now.round, precip_prob * 100.round])

      #puts "In #{hours_from_now.round} hours, there is a #{(precip_prob * 100).round}% chance of precipitation."
    end
  end

  if @next_hour_summary.downcase == 'rain'
    return "You might want to take an umbrella!"
  else
    return "You probably won't need an umbrella."
  end  

end


get("/message") do
  erb(:message_form)
end

post("/process_single_message") do
  """Respond to a message via ChatGPT
  """

  #get user message
  @the_message = params.fetch("the_message")

  #query chatgpt via a function
  @parsed_message = ask_chatgpt(@the_message)

  erb(:message_results)
end

def ask_chatgpt(query)
  """query chatgpt with a single message

     Input: ask_chatgpt
     Output: parsed string
  """

  gpt_api_key = "MY_GPT2_KEY"  

  #send query
  request_headers_hash = {
  "Authorization" => "Bearer #{ENV.fetch(gpt_api_key)}",
  "content-type" => "application/json"
  }

  request_body_hash = {
    "model" => "gpt-3.5-turbo",
    "messages" => [
      {
        "role" => "user",
        "content" => query
      }
    ]
  }

  #load response as json
  request_body_json = JSON.generate(request_body_hash)

  raw_response = HTTP.headers(request_headers_hash).post(
    "https://api.openai.com/v1/chat/completions",
    :body => request_body_json
  ).to_s


  #parse response
  parsed_message = JSON.parse(raw_response)["choices"][0]["message"]["content"]

  return parsed_message
end

#----------Chat feature
#global variable needed for the chat feature to retain the historical queries
strings=[]
conversation_history=[]

get("/chat") do

  #erase history and start over
  strings=[] #reset array
  conversation_history=[] #reset history

  erb(:chat_form)
end

post("/add_message_to_chat") do

  #get user message
  @user_message = params.fetch("user_message")

  #query chatgpt via a function

  @parsed_response = chat_with_assistant(@user_message, conversation_history)
  #updateconversation history
  conversation_history = @parsed_response[1] 

  #join user message with chatgpt response and pass to @pass_strings variable
  strings.append([@user_message, @parsed_response])
  @pass_strings = strings

  erb(:chat_results)

end

post("/clear_chat") do
  strings=[] #reset array
  conversation_history=[] #reset history

  erb(:chat_form) #return to chat form 
end

def chat_with_assistant(query, conversation_history = [])

  # Fetch the GPT API key from environment variables
  gpt_api_key = "MY_GPT2_KEY"  

  # Define request headers
  request_headers_hash = {
  "Authorization" => "Bearer #{ENV.fetch(gpt_api_key)}",
  "content-type" => "application/json"
  }

  # Construct the request body with conversation history
  request_body_hash = {
    "model" => "gpt-3.5-turbo",
    "messages" => conversation_history + [
      {
        "role" => "assistant",
        "content" => query
      }
    ]
  }

  # Convert request body to JSON
  request_body_json = JSON.generate(request_body_hash)

  # Send POST request to OpenAI API
  raw_response = HTTP.headers(request_headers_hash).post(
    "https://api.openai.com/v1/chat/completions",
    body: request_body_json
  ).to_s

  # Parse the response
  parsed_response = JSON.parse(raw_response)

  # Extract the response message
  response_message = parsed_response["choices"][0]["message"]["content"]

  # Update conversation history with the current message - required for chatgpt to carry on a conversation
  updated_conversation_history = request_body_hash["messages"]
  
  [response_message, updated_conversation_history] #response_message
end

get ("/zebra") do
  #test cookies
  
  cookies["color"]="purple"
  cookies["sport"]="tennis"
end
