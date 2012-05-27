// Based conceptually on the _.extend() function in underscore.js ( http://documentcloud.github.com/underscore/#extend )
// Author: Kurt Milam - http://xioup.com

deepExtend = function(obj) {
  var parentRE = /#{\s*?_\s*?}/,
      slice = Array.prototype.slice,
      hasOwnProperty = Object.prototype.hasOwnProperty;

  _.each(slice.call(arguments, 1), function(source) {
    for (var prop in source) {
      if (hasOwnProperty.call(source, prop)) {
        if (_.isUndefined(obj[prop])) {
          obj[prop] = source[prop];
        }
        else if (_.isString(source[prop]) && parentRE.test(source[prop])) {
          if (_.isString(obj[prop])) {
            obj[prop] = source[prop].replace(parentRE, obj[prop]);
          }
        }
        else if (_.isArray(obj[prop]) || _.isArray(source[prop])){
          if (!_.isArray(obj[prop]) || !_.isArray(source[prop])){
            throw 'Error: Trying to combine an array with a non-array (' + prop + ')';
          } else {
            obj[prop] = _.reject(_.deepExtend(obj[prop], source[prop]), function (item) { return _.isNull(item);});
          }
        }
        else if (_.isObject(obj[prop]) || _.isObject(source[prop])){
          if (!_.isObject(obj[prop]) || !_.isObject(source[prop])){
            throw 'Error: Trying to combine an object with a non-object (' + prop + ')';
          } else {
            obj[prop] = _.deepExtend(obj[prop], source[prop]);
          }
        } else {
          obj[prop] = source[prop];
        }
      }
    }
  });
  return obj;
};
_.mixin({deepExtend: deepExtend});

/**
 * Dependency: underscore.js ( http://documentcloud.github.com/underscore/ )
 *
 * Mix it in with underscore.js:
 * _.mixin({deepExtend: deepExtend});
 * 
 * Call it like this:
 * var myObj = _.deepExtend(grandparent, child, grandchild, greatgrandchild)
 *
 * Notes:
 * Keep it DRY.
 * This function is especially useful if you're working with JSON config documents. It allows you to create a default
 * config document with the most common settings, then override those settings for specific cases. It accepts any
 * number of objects as arguments, giving you fine-grained control over your config document hierarchy.
 *
 * Special Features and Considerations:
 * - parentRE allows you to concatenate strings. example:
 *   var obj = _.deepExtend({url: "www.example.com"}, {url: "http://#{_}/path/to/file.html"});
 *   console.log(obj.url);
 *   output: "http://www.example.com/path/to/file.html"
 *
 * - parentRE also acts as a placeholder, which can be useful when you need to change one value in an array, while
 *   leaving the others untouched. example:
 *   var arr = _.deepExtend([100,    {id: 1234}, true,  "foo",  [250, 500]],
 *                          ["#{_}", "#{_}",     false, "#{_}", "#{_}"]);
 *   console.log(arr);
 *   output: [100, {id: 1234}, false, "foo", [250, 500]]
 *
 * - The previous example can also be written like this:
 *   var arr = _.deepExtend([100,    {id:1234},   true,  "foo",  [250, 500]],
 *                          ["#{_}", {},          false, "#{_}", []]);
 *   console.log(arr);
 *   output: [100, {id: 1234}, false, "foo", [250, 500]]
 *
 * - And also like this:
 *   var arr = _.deepExtend([100,    {id:1234},   true,  "foo",  [250, 500]],
 *                          ["#{_}", {},          false]);
 *   console.log(arr);
 *   output: [100, {id: 1234}, false, "foo", [250, 500]]
 *
 * - Array order is important. example:
 *   var arr = _.deepExtend([1, 2, 3, 4], [1, 4, 3, 2]);
 *   console.log(arr);
 *   output: [1, 4, 3, 2]
 *
 * - You can remove an array element set in a parent object by setting the same index value to null in a child object.
 *   example:
 *   var obj = _.deepExtend({arr: [1, 2, 3, 4]}, {arr: ["#{_}", null]});
 *   console.log(obj.arr);
 *   output: [1, 3, 4]
 *
 **/
