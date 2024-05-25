# sinatra-omnicalc-3

This app starts out blank. We'll work towards building [this target](https://omnicalc-3.matchthetarget.com/) together. You can find the login username and password on canvas in the Sinatra Omnicalc 3 assignment.

Here is the link to the <a href="https://omnicalc-3.matchthetarget.com/">target</a>.

Activities:

• First, update the layout.erb form to add the various links, as shown below. <b>Remember</b> to include the command `<%= yield %>`; otherwise, the html contents of the rest of the erb files won't be displayed. Furthermore, the parameters cannot be passed between the html pages.

```
<!DOCTYPE html>
<html>
  <head>
    <title>Target: Omnicalc 3</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    
    <style>
      .navbar {
        display: flex;
        justify-content: space-around;
      }
    </style>

  </head>

  <body>
    <div class="navbar">
      <div>
        <a href="/umbrella">
          Umbrella
        </a>
      </div>

      <div>
        <a href="/message">
          Single AI message
        </a>
      </div>

      <div>
        <a href="/chat">
          AI Chat
        </a>
      </div>
    </div>

    <%= yield %>

  </body>
</html>
```

○ Every time you create a form, you will have to create two routes and not just one. The first route defines the form and the second route defines the page that displays the output of the form.  

1. Add a route to app.rb:

```
get("/umbrella") do
  erb(:umbrella_form)
end
```

Create a new file called umbrella_form.erb containing the following:

```
<h1>Should I take an umbrella?</h1>

<form action="/process_umbrella" method="post">
  <label for="location_field">Where are you located?</label>
  <input id="location_field" type="text" name="user_location">

  <button>Submit</button>
</form>
```

2. Correspondingly, create a second route within app.rb that processes the form, as shown below. You can pass the variable from the form via the variable @user_location.  

```
get("/process_umbrella") do
  @user_location = params.fetch("user_location")
  erb(:umbrella_results)
end
```

To probe what variables are available to be passed to the results page, you may add <%=params%> within umbrella_results.html. To pass the parameter, you must fetch the variable and assign it to a variable that is preceeded with @, e.g., @user_location = params.fetch("user_location").

○ Let's incorporate google map API. To do so, you need to install http package by adding the line `gem "http"` to Gemfile and running the command `bundle install`. You also need to add the command `require "http"` within app.rb.

• To get geo data from google API, modify the code within the process_umbrella route as shown below. Note that `@user location` and `GMAPS_KEY` are passed to the url by concatenating to the url string using the '+' operator. Also note how the api information is being read as JSON, which is of type dictionary. The dictionary data type is then parsed using the method .dig() hierarchically as and stored as `@loc_hash: @loc_hash = @parsed_response.dig("results", 0, "geometry", "location")`. 

```
get("/process_umbrella") do
  @user_location = params.fetch("user_location")

  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=Merchandise%20Mart%20" + @user_location + "&key=" + ENV.fetch("GMAPS_KEY")

  @raw_response = HTTP.get(gmaps_url).to_s

  @parsed_response = JSON.parse(@raw_response)

  @loc_hash = @parsed_response.dig("results", 0, "geometry", "location")

  @latitude = @loc_hash.fetch("lat")
  @longitude = @loc_hash.fetch("lng")   

  erb(:umbrella_results)
end
```

○ To implement cookies, within app.rb, do the following. 
• Add the command `require "sinatra/cookies"`. Within the Gemfile, make sure to have `gem "sinatra-contrib"` and reinstall with `bundle install`. 
• Add the following route into app.rb to test:

```
get ("/zebra") do
  cookies["color"]="purple"
  cookies["sport"]="tennis"
end
```

• Navigate into the route .../zebra on a chrome browser. Right click and choose Inspect. Click on Application tab and review the cookies. You should now see the cookies hash corresponding to "color" and "sport" keys.

• You may store the parameters into cookies has, by modifying the route block within the app.rb file as follows:

```
get("/process_umbrella") do
  @user_location = params.fetch("user_location")

  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=Merchandise%20Mart%20" + @user_location + "&key=" + ENV.fetch("GMAPS_KEY")

  @raw_response = HTTP.get(gmaps_url).to_s

  @parsed_response = JSON.parse(@raw_response)

  @loc_hash = @parsed_response.dig("results", 0, "geometry", "location")

  @latitude = @loc_hash.fetch("lat")
  @longitude = @loc_hash.fetch("lng")  
  
  #store information into cookies
  cookies["last_location"] = @user_location
  cookies["last_lat"] = @latitude
  cookies["last_lng"] = @longitude

  erb(:umbrella_results)
end
```

• You can display the cookies hash within the umbrella_results.erb using the command `<%=cookies%>`, as follows:

```
<h1>Should I take an umbrella?</h1>
<%=cookies%>
<dl>
  <dt>User location</dt>
  <dd><%=@user_location%></dd>

  <dt>Latitude</dt>
  <dd><%=@latitude%></dd>

  <dt>Longitude</dt>
  <dd><%=@longitude%></dd>

  <dt>Current temperature</dt>
  <dd>34.77</dd>

  <dt>Current summary</dt>
  <dd>Cloudy</dd>

  <dt>Umbrella?</dt>
  <dd>You probably won&#39;t need an umbrella.</dd>
</dl>

<a href="/umbrella">Go back</a>
```

• You can also retrieve the cookies and display it within the umbrella_form as follows. 

```
<h1>Should I take an umbrella?</h1>

<form action="/process_umbrella">
<div>
  <label for="location_field">Where are you located?</label>
</div>

<div>
  <input id="location_field" type="text" name="user_location">
</div>

  <button>Submit</button>
</form>

<p> You last search for: </p>

<ul>
  <li><%=cookies["last_location"]%></li>
  <li><%=cookies["last_lat"]%></li>
  <li><%=cookies["last_lng"]%></li>
</ul>
```
○ Incorporating the weather API:
• Link to weather API. If at any point, you get an error message saying key not found do update the API key. It is likely that the key has become obsolete. Alternatively, check to make sure that the repository is linked to the API key you are trying to use.
• The weather api url requires both the API key and the latitude and longitude information to work. Make sure to specify both of those!
• I found that the algorithm for determining whether to bring an umbrella based on precipitation threshold adopted from the umbrella project is inconsistent with the message indicated in `@next_hour_summary`. Upon inspection, I found that the `precip_prob_threshold` is set to -1. To be consistent, in this case, the umbrella recommendation is determined from the @next_hour_summary, as follows:

```
  if @next_hour_summary.downcase == 'rain'
    return "You might want to take an umbrella!"
  else
    return "You probably won't need an umbrella."
  end  
```
○ To hide the key-value query in the url, you would want to use "post" rather than "get" method. Sometimes, however, the get method is preferred over get method for transparency and ease of changing the query parameters. To implement a POST method to retrieve API data, you need to change the get method in 3 places:
• Change the `get("/my_route")` do to `post("/my_route")`
• Within the post block, change `HTTP.get(...).to_s` to `HTTP.post(...).to_s`.
• Within the submission form page, change `<form action="/process_umbrella" method="get">` to `<form action="/process_umbrella" method="post">`. If the method parameter is not set, the default is set to "get".

3. Work on a single AI message form which uses chatgpt API.

○ You may set up the API key on this website: https://platform.openai.com/.

○ Create a file called view/message_form.erb to process user message. The contents is as follows:
```
<h1>Your query:</h1>
<!--<%=cookies%>-->


<p>Your message:</p>
<p><%=@the_message%></p>

<p>GPT-4's response:</p>
<p>...</p>

<br>
<br>
<a href="/message">Go back</a>
```

○ Follow the instructions described here: https://learn.firstdraft.com/lessons/121 to set up GPT-API. 

○ Link message_form.erb to message_form.erb within app.rb as follows. Pass the user query using the variable @the_message.
```
post("/process_single_message") do
  """Respond to a message via ChatGPT
  """

  #get user message
  @the_message = params.fetch("the_message")

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
        "content" => @the_message
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
  @parsed_message = JSON.parse(raw_response)["choices"][0]["message"]["content"]


  erb(:message_results)
end
```

○ Issue:

• At first, I got an error message saying: "You exceeded your current quota, please check your plan and billing details. For more information on this error, read the docs: https://platform.openai.com/docs/guides/error-codes/api-error".

• I went into my account and added balance. I re-ran my query and continued to receive the error. After waiting for about 15 minutes, the api started working. 

• Also, there was an occasion when the ChatGPT page loaded an empty page for approximately 30 minutes. After waiting for about 45 minutes, the page loaded normally. I dismissed it as the server being down.

4. Work on AI Chat feature

○ I decided to functionalize the code for the single AI message feature into the following:

```
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
```

○ Strategy: In order to keep appending the conversation into the page, you would want to accumulate the chat into an array.

○ For this part of the project, I create a new function called chat_with_assistant to append conversation both for display and for chatgpt to carry on a continuous conversation, which is as follows.

  ```
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
  ```

  It is possible to further refactor the code to combine the two functions (ask_chatgpt and chat_with_assistant), but I am leaving the code as it is for clarity.

  ○ I tested the feature by asing a series of related questions, which is as follows:
  
  ```
  user:
  what is 2*9?
  assistant:
  2 * 9 = 18
  user:
  Minus 3?
  assistant:
  15
  user:
  Add 4.
  assistant:
  It is 19.
  ```
  
  ~~~
