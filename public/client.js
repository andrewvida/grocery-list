(function() {

  $(function() {
    var addItem, deleteItem, item, socket, source, target, template, updateItem, _i, _len, _ref;
    socket = io.connect(window.location.hostname);
    source = $("#item-template").html();
    template = Handlebars.compile(source);
    target = $("#existing-items");
    addItem = function(item) {
      var html;
      html = template(item);
      return target.append(html);
    };
    updateItem = function(item) {
      return $("li[data-id=\"" + item._id + "\"]").find('input[type=text]').val(item.name);
    };
    deleteItem = function(item) {
      return $("li[data-id=\"" + item._id + "\"]").remove();
    };
    _ref = window.items;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      addItem(item);
    }
    $('#save').live("click", function(e) {
      var data, input;
      e.preventDefault();
      data = {};
      input = $('#new-item');
      data.name = input.val();
      data._id = input.parents('li').attr('data-id');
      data.purchased = false;
      input.val('');
      return socket.emit('new item posted', data);
    });
    $('.input-prepend input[type=text]').live("blur", function() {
      var name, _id;
      name = $(this).val();
      _id = $(this).parents('li').attr('data-id');
      return socket.emit('item edited', {
        name: name,
        _id: _id
      });
    });
    $('.add-on input[type=checkbox]').live("change", function() {
      var _id;
      _id = $(this).parents('li').attr('data-id');
      return socket.emit('item deleted', {
        _id: _id
      });
    });
    socket.on('new item saved', function(data) {
      return addItem(data);
    });
    socket.on('item was edited', function(data) {
      return updateItem(data);
    });
    return socket.on('item was deleted', function(data) {
      return deleteItem(data);
    });
  });

}).call(this);
