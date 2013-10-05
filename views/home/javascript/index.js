// Generated by LiveScript 1.2.0
(function(){
  var prelude, ref$, Obj, map, filter, each, find, fold, foldr, fold1, all, flatten, sum, groupBy, objToPairs, partition, join, unique, pow, sqrt, listOfSubscriptioMethods, trace, sor, _sumStats, sumVisits, sumSubscribers, foldRealNodes, updateAllNodes, killChildren, stats, width, height, tree, diagonal, $svg, updateTree;
  prelude = require('prelude-ls');
  ref$ = require('prelude-ls'), Obj = ref$.Obj, map = ref$.map, filter = ref$.filter, each = ref$.each, find = ref$.find, fold = ref$.fold, foldr = ref$.foldr, fold1 = ref$.fold1, all = ref$.all, flatten = ref$.flatten, sum = ref$.sum, groupBy = ref$.groupBy, objToPairs = ref$.objToPairs, partition = ref$.partition, join = ref$.join, unique = ref$.unique;
  pow = Math.pow;
  sqrt = Math.sqrt;
  listOfSubscriptioMethods = [
    {
      "id": 0,
      "name": "Unknown",
      label: "??"
    }, {
      "id": 11,
      "name": "WAP",
      label: "DW"
    }, {
      "id": 1,
      "name": "sms",
      label: "SMS"
    }, {
      "id": 2,
      "name": "smsto",
      label: "STO"
    }, {
      "id": 3,
      "name": "mailto",
      label: "MTO"
    }, {
      "id": 7,
      "name": "SMS_WAP",
      label: "MO"
    }, {
      "id": 8,
      "name": "LINKCLICK",
      label: "LKC"
    }, {
      "id": 6,
      "name": "JAVA_APP",
      label: "JA"
    }, {
      "id": 4,
      "name": "LinkAndPIN",
      label: "LnP"
    }, {
      "id": 5,
      "name": "LinkAndPrefilledPIN",
      label: "LnPP"
    }, {
      "id": 9,
      "name": "WAPPIN",
      label: "Pin"
    }, {
      "id": 10,
      "name": "GooglePlay",
      label: "GP"
    }
  ];
  trace = function(v){
    console.log(v);
    return v;
  };
  sor = function(a, b){
    if (!!a && a.length > 0 && a !== ' ') {
      return a;
    } else {
      return b;
    }
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
  stats = function(methodFilter, node){
    var v, s, c;
    v = sumVisits(methodFilter, node);
    s = sumSubscribers(methodFilter, node);
    c = v === 0
      ? 0
      : s / v;
    return [v, s, c];
  };
  width = 1000;
  height = 2000;
  tree = d3.layout.tree().size([height, width - 160]);
  diagonal = d3.svg.diagonal().projection(function(d){
    return [d.y, d.x];
  });
  $svg = d3.select(".tree").append("svg").attr("width", width).attr("height", height).append("g").attr("transform", "translate(40,0)");
  updateTree = function(root, selectedSubscriptionMethods){
    var createMethodFilter, selectedMethodFilter, selectedVisits, selectedSubscribers, selectedStats, ref$, totalVisitsSelected, totalSubscribersSelected, convAverageSelected, convStnDevSelected, transition, color, nodes, links, $link, $node, $nodeEnter, $renderNodeMethodsStats;
    createMethodFilter = function(selectedMethods){
      return function(method){
        return in$(method, selectedMethods);
      };
    };
    selectedMethodFilter = createMethodFilter(selectedSubscriptionMethods);
    selectedVisits = sumVisits(selectedMethodFilter);
    selectedSubscribers = sumSubscribers(selectedMethodFilter);
    selectedStats = function(node){
      return stats(selectedMethodFilter, node);
    };
    ref$ = selectedStats(root), totalVisitsSelected = ref$[0], totalSubscribersSelected = ref$[1], convAverageSelected = ref$[2];
    convStnDevSelected = foldRealNodes(root, function(n, acc){
      var ref$, v, s, conv;
      ref$ = selectedStats(n), v = ref$[0], s = ref$[1], conv = ref$[2];
      return acc + sqrt(pow(conv - convAverageSelected, 2)) * v / totalVisitsSelected;
    }, 0);
    console.log(convAverageSelected);
    console.log(convAverageSelected);
    console.log(convStnDevSelected);
    transition = function(node){
      return node.transition().duration(500);
    };
    root = killChildren(100, selectedVisits, root);
    color = d3.scale.quantile().range(['#f21b1b', '#ed771c', '#e9ce1e', '#a9e41f', '#53df21', '#22da40', '#23d58e', '#24cbd0', '#257ecb', '#2636c7']);
    color.domain([0, convAverageSelected + 2 * convStnDevSelected]);
    nodes = tree.nodes(root);
    links = tree.links(nodes);
    $link = $svg.selectAll("path.link").data(links);
    $link.enter().append("path").attr("class", "link").attr("d", diagonal({
      source: {
        x: 0,
        y: 0
      },
      target: {
        x: 0,
        y: 0
      }
    }));
    transition($link).attr("d", diagonal);
    $node = $svg.selectAll("g.node").data(nodes);
    $nodeEnter = $node.enter().append("g").attr("class", "node");
    transition($node).attr("transform", function(d){
      return "translate(" + d.y + "," + d.x + ")";
    });
    $nodeEnter.append("circle").attr("r", 4.5);
    $nodeEnter.append("text");
    $node.select("text").attr("dx", function(d){
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
      var name, dStats, res$, i$, ref$, len$, ref1$, m, l, dMethodsWithVisits;
      name = sor(sor(sor(d.device, d.brand), d.os), '');
      res$ = [];
      for (i$ = 0, len$ = (ref$ = listOfSubscriptioMethods).length; i$ < len$; ++i$) {
        ref1$ = ref$[i$], m = ref1$.name, l = ref1$.label;
        res$.push([m, l].concat(stats(createMethodFilter([m]), d)));
      }
      dStats = res$;
      dMethodsWithVisits = fold(function(acc, c){
        if (c[2] > 0) {
          return acc.concat(c[1]);
        } else {
          return acc;
        }
      }, [], dStats);
      return name + ' {' + join('|', dMethodsWithVisits) + '}';
    }).attr('fill', function(it){
      return color(selectedStats(it)[2]);
    }).on('mousedown', function(it){
      return $renderNodeMethodsStats(it);
    });
    $node.exit().remove();
    $link.exit().remove();
    $renderNodeMethodsStats = function(node){
      var ref$, vSelected, sSelected, cSelected, $li, $liEnter, renderMethodStats;
      ref$ = selectedStats(node), vSelected = ref$[0], sSelected = ref$[1], cSelected = ref$[2];
      $li = d3.select('.node-methods-stats').selectAll('li').data(node.stats);
      $liEnter = $li.enter().append('li');
      renderMethodStats = function(className, text){
        $liEnter.append("span").attr("class", className);
        return $li.select("span." + className).text(text);
      };
      each(function(it){
        return renderMethodStats(it, function(m){
          return m[it];
        });
      }, ['method', 'visits', 'subscribers']);
      return renderMethodStats('converson', function(m){
        return d3.format('.1%')(m.visits === 0
          ? 0
          : m.subscribers / m.visits);
      });
    };
    return $renderNodeMethodsStats(root);
  };
  $.get('/data/ae.json', function(root){
    updateTree(root, ['sms', 'smsto', 'mailto', 'JAVA_APP']);
    return setTimeout(function(){
      return updateTree(root, ['GooglePlay']);
    }, 2000);
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
