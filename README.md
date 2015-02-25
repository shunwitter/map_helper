
# map_helper
Easy way to implement google maps in your Rails app or other.


##Load
Place map_helper in vendor folder.
vendor/javascripts/map_helper/map_helper.coffee

/app/javascripts/application.js

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

# For turbolinks
$(document).ready(ready)
$(document).on 'page:load', ready

```



##Search location and display map

Add "address" class to your text field (could be multipul).
By clicking trigger, it gets/sets latitude and longitude and display the map.

### View

app/views/places/new

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

```coffee

window.triggerMap = ->

	# --- new/edit --- #
	if $('.map-search-button').length

		MapHelper.searchShowMap($('.map-canvas').get(0),
			{
				mapHeight: 		300,
				trigger: 			$('.map-search-button'),
				addressInput: $('.address'), #could be multiple
				latInput: 		$('#place_latitude'),
				lngInput: 		$('#place_longitude'),
				zoom: 				10
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

Name 					| Type 					| Default
------------- | ------------- | ------------------------
mapHeight 		| integer 			| 300
trigger 			| jQuery object | $('.search-map-trigger')
latInput			| jQuery object | $('input.latitude')
lngInput			| jQuery object | $('input.longitude')
zoom					| integer				| 4
scaleControl	| boolean 			| true
scrollwheel		| boolean 			| false
showMarker		| boolean 			| true
draggable			| boolean 			| false
afterShow			| function 			| null



