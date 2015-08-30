
class window.MapHelper

  @STYLE_OPTIONS = [
    {
      featureType: 'all',
      elementType: 'geometry',
      stylers: [{ hue: '#6d4d38' }, { saturation: '-70' }, { gamma: '2.0' }]
    },
    {
      featureType: 'water',
      elementType: 'geometry',
      stylers: [{ color: "#acdcfa" }]
    },
    {
      featureType: 'all',
      elementType: 'labels',
      stylers: [{ lightness: "10" }]
    }
  ]

  @CLUSTER_STYLES = (path = '/assets/map_helper/images', imageName = 'cluster') ->
    [
      {
        url: "#{path}/#{imageName}55.png",
        height: 55,
        width: 55,
        anchor: [19, 0],
        textColor: '#fff',
        textSize: 16
      }, {
        url: "#{path}/#{imageName}75.png",
        height: 75,
        width: 75,
        anchor: [28, 0],
        textColor: '#fff',
        textSize: 20
      }, {
        url: "#{path}/#{imageName}95.png",
        height: 95,
        width: 95,
        anchor: [38, 0],
        textColor: '#fff',
        textSize: 26
      }
    ]


  # a = b || c doesn't work for boolean value
  # Javascript falsy values
  # false
  # 0 (zero)
  # "" (empty string)
  # null
  # undefined
  # NaN
  @optionValue = (supplied, default_value) ->
    if supplied == undefined
      return default_value
    else
      supplied


  # --------------------------------------------------------------------
  # Just showing google map
  # --------------------------------------------------------------------

  @showMap = (canvas, options) ->

    # Options
    mapHeight       = @optionValue( options.mapHeight,     300 )
    mapLat          = @optionValue( options.mapLat,        35.6894875 )  #Tokyo
    mapLng          = @optionValue( options.mapLng,        139.6917064 ) #Tokyo
    zoom            = @optionValue( options.zoom,          4 )
    scaleControl    = @optionValue( options.scaleControl,  true )
    scrollwheel     = @optionValue( options.scrollwheel,   false )
    showMarker      = @optionValue( options.showMarker,    true )
    draggable       = @optionValue( options.draggable,     false )

    # Display map area
    $(canvas).css('height', mapHeight + 'px').css('backgroundColor', '#C0E6F7')

    # No location info supplied
    if mapLat == undefined || mapLng == undefined
      $(canvas).html('<p class="map-error">You need to specify the location to display map.</p>')
      return

    # Load map
    center = new google.maps.LatLng(mapLat, mapLng, false)
    googleMap = new google.maps.Map(canvas, {
      center:         center,
      zoom:           zoom,
      mapTypeId:      google.maps.MapTypeId.ROADMAP,
      scaleControl:   scaleControl,
      scrollwheel:    scrollwheel
    })

    # Style
    mapStyle = new google.maps.StyledMapType(@STYLE_OPTIONS)
    googleMap.mapTypes.set('coolBlue', mapStyle)
    googleMap.setMapTypeId('coolBlue')

    marker = null
    if showMarker
      # Marker
      marker = new google.maps.Marker(
        {
          position: center,
          draggable: draggable
        }
      )
      marker.setMap(googleMap)

    return {googleMap: googleMap, marker: marker}




  # --------------------------------------------------------------------
  # Search location and show map
  # --------------------------------------------------------------------

  @searchShowMap = (canvas, options) ->

    trigger        = @optionValue( options.trigger,       $('.search-map-trigger') )
    addressInput   = @optionValue( options.addressInput,  $('.search-map-address') )
    latInput       = @optionValue( options.latInput,      $('input.latitude') )
    lngInput       = @optionValue( options.lngInput,      $('input.longitude') )
    mapHeight      = @optionValue( options.mapHeight,     300 )
    zoom           = @optionValue( options.zoom,          4 )
    scaleControl   = @optionValue( options.scaleControl,  true )
    scrollwheel    = @optionValue( options.scrollwheel,    false )
    afterShow      = options.afterShow || null

    markerDrag = (marker) ->
      # Change values after dragging
      google.maps.event.addListener(marker, 'dragend', (e) ->
        latInput.val(e.latLng.lat())
        lngInput.val(e.latLng.lng())
      )

    # When error occured, show same map again
    if latInput.val() && lngInput.val()
      # Show map
      mapResult = @showMap(canvas,
        {
          mapLat:       latInput.val(),
          mapLng:       lngInput.val(),
          draggable:    true,
          mapHeight:    mapHeight,
          zoom:         zoom,
          scaleControl: scaleControl,
          scrollwheel:  scrollwheel
        }
      )
      markerDrag(mapResult.marker)

    # When button clicked
    trigger.on 'click', (e) ->
      e.preventDefault()

      # Address field could be multiple elements.
      address = []
      $('.address').each( ->
        address.push($(this).val())
      )
      address = address.join()

      if !address
        return #cancel if string is empty

      # Search from address
      geocoder = new google.maps.Geocoder()
      geocoder.geocode( { 'address': address }, (results, status) ->
        if status == google.maps.GeocoderStatus.OK
          location = results[0].geometry.location

          # Set value
          latInput.val(location.lat())
          lngInput.val(location.lng())

          # Show map
          mapResult = MapHelper.showMap(canvas,
            {
              mapLat:       location.lat(),
              mapLng:       location.lng(),
              draggable:    true,
              mapHeight:    mapHeight,
              zoom:         zoom,
              scaleControl: scaleControl,
              scrollwheel:  scrollwheel
            }
          )
          markerDrag(mapResult.marker)

          # Callback
          if afterShow
            afterShow()
      ) #geocode






  # --------------------------------------------------------------------
  # Show map and drop many markers
  # --------------------------------------------------------------------

  @showMapWithMarkers = (canvas, options, json) ->

    controller    = @optionValue( options.controller, 'posts' )
    titleField    = @optionValue( options.titleField, 'title' )
    showClusterer = @optionValue( options.showClusterer, true )
    clustererImagesPath = @optionValue( options.clustererImagesPath, '/assets/map_helper/images' )
    options.showMarker = false # markers will be added later

    mapResult = @showMap(canvas, options)
    markers = []
    infoWindows = []
    window.openedWindow = null

    for item, i in json

      # Check position
      # If exact same position exist, change the position.
      for m in markers
        if item.latitude == m.getPosition().lat() && item.longitude == m.getPosition().lng()
          item.latitude += 0.00002

      # Drop marker
      markers[i] = new google.maps.Marker({
        position: new google.maps.LatLng(item.latitude, item.longitude),
        map: mapResult.googleMap
      })

      # Create info window
      content = '<a href="/' + controller + '/' + item.id + '"> ' +
                  item[titleField] +
                '</a>';
      infoWindows[i] = new google.maps.InfoWindow({ content: content })

      # Add click event on marker
      # Can't access i from addListener
      addEvent = (i) ->
        google.maps.event.addListener(markers[i], 'click', (e) ->

          if window.openedWindow
            infoWindows[window.openedWindow].close()

          infoWindows[i].open(mapResult.googleMap, markers[i])
          window.openedWindow = i
        )
      addEvent(i)

    if showClusterer
      MapHelper.showClusterer(mapResult.googleMap, markers)


  # --------------------------------------------------------------------
  # Show clusters
  # --------------------------------------------------------------------

  #google-maps-utility-library-v3
  @showClusterer = (map, markers, options = { gridSize: 50, maxZoom: 15}) =>
    options.styles = @CLUSTER_STYLES()
    window.mc = new MarkerClusterer(map, markers, options)



