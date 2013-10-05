// Generated by LiveScript 1.2.0
(function(){
  var trace, _sumStats, sumVisits, sumSubscribers, foldRealNodes, updateAllNodes, killChildren, prelude, map, flatten, groupBy, objToPairs, fold1, fold, filter, pow, sqrt, width, height, tree, diagonal, svg;
  trace = function(v){
    console.log(v);
    return v;
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
  foldRealNodes = function(node, func, seed){
    switch (false) {
    case node.children.length !== 0:
      return func(node, seed);
    default:
      return fold(function(ac, a){
        return foldRealNodes(a, func, ac);
      }, seed, node.children);
    }
  };
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
  killChildren = curry$(function(minVisits, visitsSelector, node){
    switch (false) {
    case node.children.length !== 0:
      node;
      break;
    default:
      node.children = filter(function(it){
        return visitsSelector(it) > minVisits;
      }, node.children);
      map(killChildren(minVisits, visitsSelector), node.children);
    }
    return node;
  });
  window.requirejs = require;
  prelude = require('prelude-ls');
  map = prelude.map;
  flatten = prelude.flatten;
  groupBy = prelude.groupBy;
  objToPairs = prelude.objToPairs;
  fold1 = prelude.fold1;
  fold = prelude.fold;
  filter = prelude.filter;
  pow = Math.pow;
  sqrt = Math.sqrt;
  width = 1000;
  height = 2000;
  tree = d3.layout.tree().size([height, width - 160]);
  diagonal = d3.svg.diagonal().projection(function(d){
    return [d.y, d.x];
  });
  svg = d3.select("body").append("svg").attr("width", width).attr("height", height).append("g").attr("transform", "translate(40,0)");
  $.get('/data/ae.json', function(root){
    var selectedSubscriptionMethods, methodFilter, selectedVisits, selectedSubscribers, selectedStats, totalVisits, totalSubscribers, totalConv, convStnDev, convAverage, sor, color, nodes, links, link, node;
    selectedSubscriptionMethods = ['sms', 'smsto', 'mailto', 'JAVA_APP'];
    methodFilter = function(method){
      return in$(method, selectedSubscriptionMethods);
    };
    selectedVisits = sumVisits(methodFilter);
    selectedSubscribers = sumSubscribers(methodFilter);
    selectedStats = function(node){
      var v, s, c;
      v = selectedVisits(node);
      s = selectedSubscribers(node);
      c = v === 0
        ? 0
        : s / v;
      return [v, s, c];
    };
    updateAllNodes(function(node){
      node.visits = selectedVisits(node);
      node.subscribers = selectedSubscribers(node);
      node.conv = node.visits === 0
        ? 0
        : node.subscribers / node.visits;
      return node;
    }, root);
    totalVisits = selectedVisits(root);
    totalSubscribers = selectedSubscribers(root);
    totalConv = totalSubscribers / totalVisits;
    convStnDev = foldRealNodes(root, function(n, acc){
      var ref$, v, s, conv;
      ref$ = selectedStats(n), v = ref$[0], s = ref$[1], conv = ref$[2];
      return acc + sqrt(pow(conv - totalConv, 2)) * v / totalVisits;
    }, 0);
    convAverage = foldRealNodes(root, function(n, acc){
      var ref$, v, s, conv;
      ref$ = selectedStats(n), v = ref$[0], s = ref$[1], conv = ref$[2];
      return acc + conv * v / totalVisits;
    }, 0);
    console.log(totalConv);
    console.log(convAverage);
    console.log(convStnDev);
    root = killChildren(100, selectedVisits, root);
    sor = function(a, b){
      if (!!a && a.length > 0 && a !== ' ') {
        return a;
      } else {
        return b;
      }
    };
    color = d3.scale.quantile().range(['#ffe866', '#fefd69', '#eafd6d', '#d5fc70', '#c2fa74', '#b1f977', '#a0f87a', '#91f77e', '#83f681', '#84f592', '#87f4a4', '#8af2b5', '#8df1c4', '#90f0d3', '#93efe0', '#96eeec', '#99e3ed', '#9cd7eb', '#9fccea', '#a2c3e9']);
    color.domain([0, root.conv + 2 * convStnDev]);
    nodes = tree.nodes(root);
    links = tree.links(nodes);
    link = svg.selectAll("path.link").data(links).enter().append("path").attr("class", "link").attr("d", diagonal);
    node = svg.selectAll("g.node").data(nodes).enter().append("g").attr("class", "node").attr("transform", function(d){
      return "translate(" + d.y + "," + d.x + ")";
    });
    node.append("circle").attr("r", 4.5);
    node.append("text").attr("dx", function(d){
      if (d.children.length > 0) {
        return -8;
      } else {
        return 8;
      }
    }).attr("dy", 3).attr("text-anchor", function(d){
      if (d.children.length > 0) {
        return "end";
      } else {
        return "start";
      }
    }).text(function(d){
      return sor(sor(d.device, d.brand), d.os);
    }).attr('fill', function(it){
      return color(selectedStats(it)[2]);
    }).on('mouseover', function(it){
      return console.log(selectedStats(it));
    });
    return d3.select(self.frameElement).style("height", height + "px");
  });
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
