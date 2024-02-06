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

Every time you create a form, you will have to create two routes and not just one. The first route defines the form and the second route defines the page that displays the output of the form.  

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

• Let's incorporate google map API. To do so, you need to install http package by adding the line `gem "http"` to Gemfile and running the command `bundle install`. You also need to add the command `require "http"` within app.rb.

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
