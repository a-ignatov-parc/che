(function() {

  define(function() {
    var getElementByClass;
    getElementByClass = function(class_name, node) {
      var classElements, element, elements, pattern, _i, _len;
      node = node || document;
      if (node.getElementByClassName) {
        getElementByClass = function(class_name, node) {
          return (node || document).getElementByClassName(class_name);
        };
        return node.getElementByClassName(class_name);
      } else {
        classElements = [];
        elements = node.getElementsByTagName("*");
        pattern = new RegExp("(^|\\s)" + class_name + "(\\s|$)");
        for (_i = 0, _len = elements.length; _i < _len; _i++) {
          element = elements[_i];
          if (pattern.test(element.className)) {
            classElements.push(element);
          }
        }
        return classElements;
      }
    };
    return {
      getElementByClass: getElementByClass
    };
  });

}).call(this);