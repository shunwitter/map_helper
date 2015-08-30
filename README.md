
# map_helper
Easy way to implement google maps in your Rails app or other.

###[DEMO](https://shunwitter-test-app.herokuapp.com/places)

Dependency: jQuery


##Load
Place map_helper in vendor folder.

- vendor
  - javascripts
    - map_helper
      - maphelper.coffee

/app/assets/javascripts/application.js

```
//= require map_helper/map_helper
```


##Rails app

Assuming you hava Place model.

```
rails g scaffold place name:string address:stiring latitude:float longitude:float
```

Load google maps api.
Make it compatible with turbolinks if needed.

/app/assets/javascripts/places.js.coffee

```coffee

ready = ->

  if !window.google

  # if !window.google.maps (if you are useing other google api)

    script = document.createElement('script')
    script.type = 'text/javascript';
    script.src = 'https://maps.googleapis.com/maps/api/js?v=3.exp&' +
                  'language=ja&callback=triggerMap'
    document.body.appendChild(script)

  else
    triggerMap()

window.triggerMap = ->
  # your code (see examples below)

# For turbolinks
$(document).ready(ready)
$(document).on 'page:load', ready

```





　　
##Display map

### View

app/views/places/show.html.erb

```erb

<div class="map-show-canvas"
            data-latitude="<%= @place.latitude %>"
            data-longitude="<%= @place.longitude %>">
</div>

```

### Javascript

```MapHelper.showMap(canvas, options)```

/app/assets/javascripts/places.js.coffee

```coffee

window.triggerMap = ->

  # --- show --- #
  mapCanvas = $('.map-show-canvas')
  if mapCanvas.length && mapCanvas.attr('data-latitude')

    MapHelper.showMap(mapCanvas.get(0),
      {
        mapHeight:      300,
        mapLat:         mapCanvas.attr('data-latitude'),
        mapLng:         mapCanvas.attr('data-longitude'),
        zoom:           10
        #scaleControl: ,
        #scrollwheel: ,
        #showMarker: ,
        #draggable: ,
      }
    )

```

####Options

Name          | Type          | Default
------------- | ------------- | ------------------------
mapHeight     | integer       | 300
mapLat        | float         | 35.6894875   #Tokyo
mapLng        | float         | 139.6917064 #Tokyo
zoom          | integer       | 4
scaleControl  | boolean       | true
scrollwheel   | boolean       | false
showMarker    | boolean       | true
draggable     | boolean       | false
afterShow     | function      | null






　　
##Search location and display map

Add "address" class to your text field (could be multipul).
By clicking trigger, it sets latitude and longitude and display the map.

[DEMO](https://shunwitter-test-app.herokuapp.com/places/new)

### View

app/views/places/new.html.erb

```erb
<%= form_for(@place) do |f| %>
  <div class="field">
    <%= f.label :name %><br>
    <%= f.text_field :name %>
  </div>
  <div class="field">
    <%= f.label :address %><br>
    <%= f.text_field :address, class: "address" %>
    <%= link_to "SEARCH", "#", class: "map-search-button" %>
    <div class="map-canvas" style="height: 0;"
                data-lat="<%= f.object.latitude %>"
                data-lng="<%= f.object.longitude %>">
    </div>
    <%= f.text_field :latitude, readonly: true %>
    <%= f.text_field :longitude,readonly: true %>
  </div>
<% end %>
```

### Javascript

```MapHelper.searchShowMap(canvas, options)```

```coffee

window.triggerMap = ->

  # --- new/edit --- #
  if $('.map-search-button').length

    MapHelper.searchShowMap($('.map-canvas').get(0),
      {
        mapHeight:      300,
        trigger:        $('.map-search-button'),
        addressInput:   $('.address'), #could be multiple
        latInput:       $('#place_latitude'),
        lngInput:       $('#place_longitude'),
        zoom:           10
        #scaleControl: ,
        #scrollwheel: ,
        #showMarker: ,
        #draggable: ,
        afterShow: ->
          console.log "Map is displayed."
      }
    )

```

####Options

Name          | Type          | Default
------------- | ------------- | ------------------------
mapHeight     | integer       | 300
trigger       | jQuery object | $('.search-map-trigger')
addressInput  | jQuery object | $('.search-map-address')
latInput      | jQuery object | $('input.latitude')
lngInput      | jQuery object | $('input.longitude')
zoom          | integer       | 4
scaleControl  | boolean       | true
scrollwheel   | boolean       | false
showMarker    | boolean       | true
draggable     | boolean       | false
afterShow     | function      | null






　　
##Display map with markers

You can drop map markers as many as you want.
(Return json from your Rails controller.)

###Controller

/app/controllers/places_controller.rb

```ruby

def index
  @places = Place.all
  respond_to do |f|
    f.html
    f.json { render json: @places }
  end
end

```


### View

app/views/places/index.html.erb

```erb

<div class="map-index"></div>

```

### Javascript

```MapHelper.showMapWithMarkers(canvas, options, json)```

```coffee

window.triggerMap = ->

  # --- index --- #
  if $('.map-index').length
    $.ajax(
      type: 'GET',
      url: '/places.json',
      # data: { if you need }
    ).done( (data) ->
      if data.length
        MapHelper.showMapWithMarkers($('.map-index').get(0),
          {
            mapHeight:    400,
            mapLat:       data[0].latitude,  #center
            mapLng:       data[0].longitude, #center
            zoom:         2,
            showMarker:   false,
            draggable:    false,
            controller:   'places',
            titleField:   'name'
          }, data)
    )

```

####Options

```controller``` and ```titleField``` are used for adding [Info windows](https://developers.google.com/maps/documentation/javascript/examples/infowindow-simple).

Name          | Type          | Default
------------- | ------------- | ------------------------
mapHeight     | integer       | 300
mapLat        | float         | 35.6894875   #Tokyo
mapLng        | float         | 139.6917064 #Tokyo
zoom          | integer       | 4
scaleControl  | boolean       | true
scrollwheel   | boolean       | false
showMarker    | boolean       | true
draggable     | boolean       | false
afterShow     | function      | null
controller    | string        | "posts"
titleField    | string        | "title"




