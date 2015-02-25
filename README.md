
# map_helper
Easy way to implement google maps in your Rails app or other.

# Place js file in vendor folder

└ vendor
  └ javascripts
    └ map_helper
      └ map_helper.coffee


# Load in application.js

/app/javascripts/application.js

```
//= require map_helper/map_helper
```

# Rails app

Assuming you hava Place model

```
rails g scaffold place name:string address:stiring latitude:float longitude:float
```

#Show Map

### View

app/views/places/new

```erb
<%= f.label :address %><br>
<%= f.text_field :address, class: "address" %>
<%= link_to "SEARCH", "#", class: "map-search-button" %>
<div class="map-canvas" style="height: 0;"
            data-lat="<%= f.object.latitude %>"
            data-lng="<%= f.object.longitude %>">
</div>
<%= f.text_field :latitude, readonly: true %>
<%= f.text_field :longitude,readonly: true %>
```

### Javascript

```coffee

ready = ->

	if !window.google

		script = document.createElement('script')
		script.type = 'text/javascript';
		script.src = 'https://maps.googleapis.com/maps/api/js?v=3.exp&' +
		    					'language=ja&callback=triggerMap'
		document.body.appendChild(script)
	
	else
		triggerMap()

window.triggerMap = ->

	# --- show --- #
	mapCanvas = $('.map-show-canvas')
	if mapCanvas.length && mapCanvas.attr('data-latitude')

		MapHelper.showMap(mapCanvas.get(0),
			{
				mapHeight: 300,
				mapLat:  mapCanvas.attr('data-latitude'),
				mapLng:  mapCanvas.attr('data-longitude'),
				zoom: 10
				#scaleControl: ,
				#scrollwheel: ,
				#showMarker: ,
				#draggable: ,
			}
		)


# For turbolinks
$(document).ready(ready)
$(document).on 'page:load', ready

```

