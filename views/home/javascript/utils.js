// Generated by LiveScript 1.2.0
(function(){
  var ref$, Obj, empty, breakList, reverse, map, filter, each, find, fold, foldr, fold1, all, flatten, sum, groupBy, objToPairs, partition, join, unique, exports, eachTreeNode, hardClone, trace, sor, _sumStats, sumVisits, sumSubscribers, updateAllNodes, killChildrenByCriteria, killChildren, stats;
  ref$ = require('prelude-ls'), Obj = ref$.Obj, empty = ref$.empty, breakList = ref$.breakList, reverse = ref$.reverse, map = ref$.map, filter = ref$.filter, each = ref$.each, find = ref$.find, fold = ref$.fold, foldr = ref$.foldr, fold1 = ref$.fold1, all = ref$.all, flatten = ref$.flatten, sum = ref$.sum, groupBy = ref$.groupBy, objToPairs = ref$.objToPairs, partition = ref$.partition, join = ref$.join, unique = ref$.unique;
  exports = exports || this;
  exports.insertAfter = function(condition, newElement, list){
    return function(){
      return reverse(function(arg$){
        var h, t;
        h = arg$[0], t = arg$[1];
        if (empty(t)) {
          return h;
        } else {
          return h.concat([newElement], t);
        }
      }(breakList(condition)(reverse.apply(this, arguments))));
    }(list);
  };
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
  eachTreeNode = curry$(function(func, node){
    func(node);
    if (!!node.children && !!node.children.length) {
      return each(eachTreeNode(func), node.children);
    }
  });
  exports.eachTreeNode = eachTreeNode;
  hardClone = function(it){
    return JSON.parse(JSON.stringify(it));
  };
  exports.hardClone = hardClone;
  trace = function(v){
    console.log(v);
    return v;
  };
  exports.trace = trace;
  sor = function(a, b){
    if (!!a && a.length > 0 && a !== ' ') {
      return a;
    } else {
      return b;
    }
  };
  exports.sor = sor;
  exports.nameNode = function(n){
    return sor(sor(sor(n.device, n.brand), n.os), '');
  };
  _sumStats = curry$(function(methodSelector, prop, node){
    var m;
    return fold1(curry$(function(x$, y$){
      return x$ + y$;
    }))((function(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = node.stats).length; i$ < len$; ++i$) {
        m = ref$[i$];
        if (methodSelector(m.method)) {
          results$.push(m[prop]);
        }
      }
      return results$;
    }()));
  });
  sumVisits = curry$(function(methodSelector, node){
    return _sumStats(methodSelector, 'visits', node);
  });
  sumSubscribers = curry$(function(methodSelector, node){
    return _sumStats(methodSelector, 'subscribers', node);
  });
  updateAllNodes = curry$(function(updater, node){
    switch (false) {
    case node.children.length !== 0:
      node;
      break;
    default:
      map(updateAllNodes(updater), node.children);
    }
    return updater(node);
  });
  killChildrenByCriteria = curry$(function(criteria, node){
    switch (false) {
    case node.children.length !== 0:
      node;
      break;
    default:
      node.children = filter(function(it){
        return criteria(it);
      }, node.children);
      map(killChildrenByCriteria(criteria), node.children);
    }
    return node;
  });
  killChildren = curry$(function(minVisits, visitsSelector, node){
    return killChildrenByCriteria(function(it){
      return visitsSelector(it) > minVisits;
    }, node);
  });
  stats = function(methodFilter, node){
    var v, s, c;
    v = sumVisits(methodFilter, node);
    s = sumSubscribers(methodFilter, node);
    c = v === 0
      ? 0
      : s / v;
    return [v, s, c];
  };
  exports.nodeSelectedStats = stats;
  exports.filterTree = function(root, selectedSubscriptionMethods, selectedSubscriptionMethodsOr, excludeDesktop, killChildrenThreshold){
    var createMethodFilter, selectedMethodFilter, selectedVisits, selectedSubscribers, selectedStats;
    killChildrenThreshold == null && (killChildrenThreshold = 100);
    if (excludeDesktop) {
      root.children = filter(function(it){
        return it.os !== 'Desktop';
      }, root.children);
    }
    createMethodFilter = function(selectedMethods){
      return function(method){
        return in$(method, selectedMethods);
      };
    };
    selectedMethodFilter = !selectedSubscriptionMethods
      ? function(){
        return true;
      }
      : createMethodFilter(selectedSubscriptionMethods);
    selectedVisits = sumVisits(selectedMethodFilter);
    selectedSubscribers = sumSubscribers(selectedMethodFilter);
    selectedStats = function(node){
      return stats(selectedMethodFilter, node);
    };
    if (selectedSubscriptionMethodsOr) {
      root = killChildren(killChildrenThreshold, selectedVisits, root);
    } else {
      root = killChildrenByCriteria(function(node){
        var m;
        return all(function(it){
          return it;
        }, (function(){
          var i$, ref$, len$, results$ = [];
          for (i$ = 0, len$ = (ref$ = selectedSubscriptionMethods).length; i$ < len$; ++i$) {
            m = ref$[i$];
            results$.push(find(fn$, node.stats).visits > killChildrenThreshold);
          }
          return results$;
          function fn$(it){
            return it.method === m;
          }
        }()));
      }, root);
    }
    return [root, selectedStats];
  };
  function curry$(f, bound){
    var context,
    _curry = function(args) {
      return f.length > 1 ? function(){
        var params = args ? args.concat() : [];
        context = bound ? context || this : this;
        return params.push.apply(params, arguments) <
            f.length && arguments.length ?
          _curry.call(context, params) : f.apply(context, params);
      } : f;
    };
    return _curry();
  }
  function in$(x, xs){
    var i = -1, l = xs.length >>> 0;
    while (++i < l) if (x === xs[i]) return true;
    return false;
  }
}).call(this);
