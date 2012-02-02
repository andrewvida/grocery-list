$ ->
  socket     = io.connect(window.location.hostname)
  source     = $("#item-template").html()
  template   = Handlebars.compile(source)
  target     = $("#existing-items")

  addItem = (item) ->
    html = template(item)
    target.append(html)

  updateItem = (item) ->
    $("li[data-id=\"#{item._id}\"]").find('input[type=text]').val(item.name)

  deleteItem = (item) ->
    $("li[data-id=\"#{item._id}\"]").remove()

  for item in window.items
    addItem(item)

  $('#save').live "click", (e) ->
    e.preventDefault()
    data           = {}
    input          = $('#new-item')
    data.name      = input.val()
    data._id       = input.parents('li').attr('data-id')
    data.purchased = false
    input.val('')
    socket.emit 'new item posted', data

  $('.input-prepend input[type=text]').live "blur", ->
    name = $(this).val()
    _id  = $(this).parents('li').attr('data-id')
    socket.emit 'item edited', {name: name, _id: _id}

  $('.add-on input[type=checkbox]').live "change", ->
    _id = $(this).parents('li').attr('data-id')
    socket.emit 'item deleted', {_id: _id}


  # Sockets
  socket.on 'new item saved', (data)->
    addItem(data)

  socket.on 'item was edited', (data) ->
   updateItem(data)

  socket.on 'item was deleted', (data) ->
    deleteItem(data)



