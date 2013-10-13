// Generated by LiveScript 1.2.0
(function(){
  var prelude, ref$, Obj, map, filter, each, find, fold, foldr, fold1, all, flatten, sum, groupBy, objToPairs, partition, join, unique, listOfSubscriptioMethods, formatDate, pow, pow2, sqrt, sor, hardClone, trace, treeUiTypes, treeChart;
  prelude = require('prelude-ls');
  ref$ = require('prelude-ls'), Obj = ref$.Obj, map = ref$.map, filter = ref$.filter, each = ref$.each, find = ref$.find, fold = ref$.fold, foldr = ref$.foldr, fold1 = ref$.fold1, all = ref$.all, flatten = ref$.flatten, sum = ref$.sum, groupBy = ref$.groupBy, objToPairs = ref$.objToPairs, partition = ref$.partition, join = ref$.join, unique = ref$.unique;
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
  formatDate = d3.time.format('%Y-%m-%d');
  pow = Math.pow;
  pow2 = function(n){
    return Math.pow(n, 2);
  };
  sqrt = Math.sqrt;
  sor = function(a, b){
    if (!!a && a.length > 0 && a !== ' ') {
      return a;
    } else {
      return b;
    }
  };
  hardClone = function(it){
    return JSON.parse(JSON.stringify(it));
  };
  trace = function(v){
    console.log(v);
    return v;
  };
  treeUiTypes = {
    'tree-long-branches': treeLongBranches,
    'tree-map': treeMap
  };
  treeChart = treeMap(screen.width - 10, 1000);
  $(function(){
    var updateStatsAtFooter;
    updateStatsAtFooter = function(node){
      var allMethodsSummary, $summarySpan, $li, $liEnter, renderMethodStats;
      allMethodsSummary = fold(function(acc, a){
        return {
          visits: a.visits + acc.visits,
          subscribers: a.subscribers + acc.subscribers
        };
      }, {
        visits: 0,
        subscribers: 0
      }, node.stats);
      allMethodsSummary.conversion = allMethodsSummary.subscribers / allMethodsSummary.visits;
      $summarySpan = d3.select('.all-methods-summary').selectAll('span').data(objToPairs(allMethodsSummary));
      $summarySpan.enter().append('span').attr('class', function(it){
        return it[0];
      });
      $summarySpan.text(function(it){
        return ('conversion' === it[0]
          ? d3.format('.1%')
          : d3.format(','))(it[1]);
      });
      $li = d3.select('.node-methods-stats').selectAll('li').data(node.stats);
      $liEnter = $li.enter().append('li');
      $li.exit().remove();
      renderMethodStats = function(className, text){
        $liEnter.append("span").attr("class", className);
        return $li.select("span." + className).text(text);
      };
      each(function(it){
        return renderMethodStats(it, function(m){
          return m[it];
        });
      }, ['method', 'visits', 'subscribers']);
      renderMethodStats('conversion', function(m){
        return d3.format('.1%')(m.visits === 0
          ? 0
          : m.subscribers / m.visits);
      });
      return $li.transition().duration(200).style("opacity", function(it){
        var ratio;
        ratio = it.visits / allMethodsSummary.visits;
        return d3.scale.linear().domain([0, 0.33]).range([0.2, 1]).clamp(true)(ratio);
      });
    };
    return $(window).on("tree/node-selected", function(ref$, node){
      var nameNode, allParents, selectNode, names, $a;
      nameNode = function(n){
        return sor(sor(sor(n.device, n.brand), n.os), '');
      };
      allParents = function(n, list){
        switch (false) {
        case !!n.parent:
          return [n].concat(list);
        default:
          return allParents(n.parent, list).concat([n], list);
        }
      };
      selectNode = function(n){
        console.log('select-node', n.treeId);
        d3.selectAll('rect.selected').classed('selected', false);
        d3.select(".node-" + n.treeId).classed('selected', true);
        return updateStatsAtFooter(n);
      };
      selectNode(node);
      $('.stats h2').html('');
      names = allParents(node, []);
      return $a = d3.select('.stats h2').selectAll('a').data(names).enter().append('a').text(function(it){
        return nameNode(it);
      }).on('click', function(it){
        return selectNode(it);
      });
    });
  });
  $(function(){
    var root, changeTreeUi, updateTreeFromUi, val, reRoot, reRootAgain, reRootCountry, reRootSuperCampaign, populateChosenSelect;
    root = null;
    changeTreeUi = function(type){
      $(".tree").html('');
      treeChart = treeUiTypes[type](screen.width - 10, 1000);
      return updateTreeFromUi();
    };
    updateTreeFromUi = function(){
      var lastId, addIdToNode, findMethod, calcConv, stndDevOfConversionForMethod, id, name;
      if (!root.stats) {
        console.log('nothing!');
        return;
      }
      lastId = 0;
      addIdToNode = function(n){
        switch (false) {
        case !(!n.children || n.children.length === 0):
          return n.treeId = ++lastId;
        default:
          n.treeId = ++lastId;
          return each(addIdToNode, n.children);
        }
      };
      addIdToNode(root);
      findMethod = function(name, stats){
        return find(function(it){
          return it.method === name;
        }, stats) || {
          visits: 0,
          subscribers: 0
        };
      };
      calcConv = function(m){
        if (m.visits === 0) {
          return 0;
        } else {
          return m.subscribers / m.visits;
        }
      };
      stndDevOfConversionForMethod = function(methodName, node){
        return sqrt(foldRealNodes(node, function(n, acc){
          var method, rootMethod, v;
          if (!!n.children && n.children.length > 0) {
            return 0;
          }
          method = findMethod(methodName, n.stats);
          rootMethod = findMethod(methodName, node.stats);
          v = pow2(calcConv(method) - calcConv(rootMethod)) * method.visits / rootMethod.visits;
          return v + acc;
        }, 0));
      };
      console.log((function(){
        var i$, ref$, len$, ref1$, results$ = [];
        for (i$ = 0, len$ = (ref$ = listOfSubscriptioMethods).length; i$ < len$; ++i$) {
          ref1$ = ref$[i$], id = ref1$.id, name = ref1$.name;
          results$.push([name, calcConv(findMethod(name, root.stats)), stndDevOfConversionForMethod(name, root)]);
        }
        return results$;
      }()));
      return treeChart.updateTree(hardClone(root), $('#chosen-methods').val(), $('#chosen-methods-orand').is(':checked'), true, parseInt($('#kill-children-threshold').val()));
    };
    val = function(cssSelector){
      return $(cssSelector).val() || '-';
    };
    reRoot = function(url){
      $('#loading').show();
      setTimeout(function(){
        return $('#loading').addClass('visible');
      }, 500);
      console.log('*** ', url);
      return $.get(url, function(r){
        root = r;
        updateTreeFromUi();
        $('#loading').removeClass('visible');
        return setTimeout(function(){
          return $('#loading').hide();
        }, 500);
      });
    };
    reRootAgain = null;
    reRootCountry = function(){
      var url;
      $('#chosen-superCampaigns').select2('val', '');
      url = !$('#chosen-tests').val() || parseInt($('#chosen-tests').val()) === 0
        ? "/api/stats/tree/" + val('#fromDate') + "/" + val('#toDate') + "/" + val('#chosen-countries') + "/" + val('#chosen-refs') + "/0"
        : "/api/test/tree/" + val('#chosen-tests') + "/" + val('#fromDate') + "/" + val('#toDate') + "/" + val('#chosen-countries') + "/" + val('#chosen-refs');
      reRootAgain = reRootCountry;
      return reRoot(url);
    };
    reRootSuperCampaign = function(){
      var url;
      $('#chosen-countries, #chosen-refs, #chosen-tests').select2('val', '');
      url = "/api/stats/tree-by-superCampaign/" + val('#fromDate') + "/" + val('#toDate') + "/" + val('#chosen-superCampaigns') + "/" + val('#chosen-refs') + "/0";
      reRootAgain = reRootSuperCampaign;
      return reRoot(url);
    };
    reRootAgain = reRootCountry;
    d3.select('#chosen-methods').selectAll('option').data(listOfSubscriptioMethods).enter().append('option').text(function(it){
      return it.name;
    });
    $('#chosen-methods').select2({
      width: 'element'
    }).change(function(){
      return updateTreeFromUi();
    });
    $('#chosen-methods-orand').change(function(){
      $('#kill-children-threshold').val($(this).is(':checked') ? 100 : 0);
      return updateTreeFromUi();
    });
    $('#kill-children-threshold').change(function(){
      return updateTreeFromUi();
    });
    populateChosenSelect = function($select, url, mapFunc, defaultValue, callback){
      return $.get(url, function(data){
        data = mapFunc(data);
        d3.select($select[0]).selectAll('option').data(data).enter().append('option').attr("value", function(it){
          return it.id;
        }).text(function(it){
          return it.name;
        });
        $select.select2({
          width: 'element',
          allowClear: true
        }).select2('val', defaultValue);
        return callback($select);
      });
    };
    return populateChosenSelect($('#chosen-countries').on('change', function(){
      return reRootCountry();
    }), 'http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetAllCountries', function(countries){
      return [{}].concat(countries);
    }, 2, function(_){
      var now;
      (function(){
        return populateChosenSelect($('#chosen-refs').on('change', function(){
          return reRootAgain();
        }), 'http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetRefs', function(refs){
          refs[0] = {};
          return refs;
        }, '', function(_){
          return populateChosenSelect($('#chosen-superCampaigns').on('change', function(){
            return reRootSuperCampaign();
          }), 'http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetSuperCampaigns', function(superCampaigns){
            return [{}].concat(filter(function(it){
              return it.name.indexOf('[') !== 0;
            }, superCampaigns));
          }, '', function(_){
            return populateChosenSelect($('#chosen-tests').on('change', function(){
              return reRootAgain();
            }), '/api/tests/true', function(tests){
              var t;
              return [{}].concat((function(){
                var i$, ref$, len$, results$ = [];
                for (i$ = 0, len$ = (ref$ = tests).length; i$ < len$; ++i$) {
                  t = ref$[i$];
                  results$.push({
                    id: t.id,
                    name: t.device + " (" + t.id + ")"
                  });
                }
                return results$;
              }()));
            }, '', function(_){});
          });
        });
      })();
      now = new Date();
      $('#fromDate').attr("max", formatDate(new Date(now.valueOf() - 1 * 24 * 60 * 60 * 1000))).val(formatDate(new Date(now.valueOf() - 2 * 24 * 60 * 60 * 1000))).change(function(){
        return reRootAgain();
      });
      $('#toDate').attr("max", formatDate(now)).val(formatDate(new Date(now.valueOf() - 1 * 24 * 60 * 60 * 1000))).change(function(){
        return reRootAgain();
      });
      $('#chosen-tree-ui-type').select2().change(function(){
        return changeTreeUi($(this).val());
      });
      return reRootAgain();
    });
  });
}).call(this);
