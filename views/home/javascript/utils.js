// Generated by LiveScript 1.2.0
(function(){
  var ref$, Obj, map, filter, each, find, fold, foldr, fold1, all, flatten, sum, groupBy, objToPairs, partition, join, unique, exports;
  ref$ = require('prelude-ls'), Obj = ref$.Obj, map = ref$.map, filter = ref$.filter, each = ref$.each, find = ref$.find, fold = ref$.fold, foldr = ref$.foldr, fold1 = ref$.fold1, all = ref$.all, flatten = ref$.flatten, sum = ref$.sum, groupBy = ref$.groupBy, objToPairs = ref$.objToPairs, partition = ref$.partition, join = ref$.join, unique = ref$.unique;
  exports = exports || this;
  exports.foldRealNodes = function(node, func, seed){
    switch (false) {
    case node.children.length !== 0:
      return func(node, seed);
    default:
      return fold(function(ac, a){
        return foldRealNodes(a, func, ac);
      }, seed, node.children);
    }
  };
}).call(this);