#= require "jquery"
#= require "twitter/bootstrap/tooltip"

class Application
  constructor: ->
    @loadMap()
    @setupInput()

  setupInput: ->
    @input = $("input")
    @input.tooltip({
      placement: "right",
      trigger: "focus"
      html: true,
      title: """
        Use decimal notation (e.g: 12.34,45.67) specifying latitude and then longitude.<br/>
        Optionally you can append a radius (in Km), e.g: '@ 10'. The default radius is 50km.<br/>
        Maximum radius is 1000km and all whitespaces are ignored.
      """,
      container: "body"
    })

  loadMap: ->
    mapOptions = {zoom: 4, center: new google.maps.LatLng(38.50, -98.35), mapTypeId: google.maps.MapTypeId.ROADMAP}
    @map = new google.maps.Map(document.getElementById("map"), mapOptions)

jQuery(-> new Application())