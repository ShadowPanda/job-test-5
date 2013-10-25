#= require "jquery"
#= require "sugar"
#= require "twitter/bootstrap/tooltip"

class Application
  constructor: ->
    @container = $("@tweets-container")
    @loadMap()
    @setupInput()
    @setupEvents()
    @setupTooltip()
    @performSearch()

  setupInput: ->
    @input = $("input")
    @input.tooltip({
      placement: "right",
      trigger: "focus"
      html: true,
      title: """
        Use decimal notation (e.g: 12.34,45.67) specifying first latitude and then longitude.<br/>
        Optionally you can append a radius (in Km), e.g: '@ 10'. The default radius is 50km.<br/>
        You can also append "with media" to show only posts with media.
      """,
      container: "body"
    })


  setupEvents: ->
    $("body").on("click", "a@view-in-map", (ev) => @moveMapTo(ev))
    $("body").on("click", "a@load-more", (ev) => @loadMore(ev))
    @input.on("keypress", (ev) => @performSearch(ev))

  loadMap: ->
    mapOptions = {zoom: 4, center: new google.maps.LatLng(38.50, -98.35), mapTypeId: google.maps.MapTypeId.ROADMAP}
    @map = new google.maps.Map(document.getElementById("map"), mapOptions)

  loadMore: (ev) ->
    link = $(ev.currentTarget)
    ev.preventDefault()

    @beginLoading(false)
    @loadResults(link.data("query"), link.data("maxId"))

  moveMapTo: (ev) ->
    link = $(ev.currentTarget)
    ev.preventDefault()

    @marker.setMap(null) if @marker?
    @marker = new google.maps.Marker({
      map: @map, position: new google.maps.LatLng(link.data("latitude"), link.data("longitude")),
      title: "Hello World!", animation: google.maps.Animation.DROP
    })

    @map.setCenter(@marker.getPosition())
    @map.setZoom(9)

  performSearch: (ev = null) ->
    query = @input.val()

    if !query.isBlank() && (!ev? || ev.keyCode == 13)
      @beginLoading(true)
      @loadResults(query, "")

  beginLoading: (clear) ->
    if clear
      @container.html("")
    else
      @container.find("@system-status, @load-more").remove()

    $('<h6 data-role="system-status" class="loading"><i class="icon-spinner icon-spin icon-large"></i> Loading data ...</h6>').appendTo(@container)

  loadResults: (query, max_id) ->
    $.get("/search",
      {query: query, max_id: max_id},
      (data, status, xhr) =>
        @container.find("@system-status").remove()
        $(data).appendTo(@container).hide().fadeIn("fast")
        @setupTooltip()
    )

  setupTooltip: -> $('[rel="tooltip"]').tooltip()

jQuery.expr.match.ROLE = /^@((?:\\.|[\w-]|[^\x00-\xa0])+)/
jQuery.expr.filter.ROLE = (role) ->
  (element) -> element.getAttribute("data-role") == role
jQuery(-> new Application())