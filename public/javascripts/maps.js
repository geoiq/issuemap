Maps = {
  searchCallback: function(results) {
    MyClass.results = results;
    Maker.load_map('my_map', results[0].pk)
  }
};