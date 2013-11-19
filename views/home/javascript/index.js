// Generated by LiveScript 1.2.0
(function(){
  var prelude, ref$, Obj, map, filter, each, find, fold, foldr, fold1, all, flatten, sum, groupBy, objToPairs, partition, join, unique, sortBy, reverse, listOfSubscriptionMethods, formatDate, pow, pow2, sqrt, treeUiTypes, treeChart, showDialog, showCreateATestDialog, showConcludeATestDialog;
  prelude = require('prelude-ls');
  ref$ = require('prelude-ls'), Obj = ref$.Obj, map = ref$.map, filter = ref$.filter, each = ref$.each, find = ref$.find, fold = ref$.fold, foldr = ref$.foldr, fold1 = ref$.fold1, all = ref$.all, flatten = ref$.flatten, sum = ref$.sum, groupBy = ref$.groupBy, objToPairs = ref$.objToPairs, partition = ref$.partition, join = ref$.join, unique = ref$.unique, sortBy = ref$.sortBy, reverse = ref$.reverse;
  listOfSubscriptionMethods = [
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
    }, {
      "id": 12,
      "name": "BANNER_JAVAAPP",
      label: "JAB"
    }
  ];
  formatDate = d3.time.format('%Y-%m-%d');
  pow = Math.pow;
  pow2 = function(n){
    return Math.pow(n, 2);
  };
  sqrt = Math.sqrt;
  treeUiTypes = {
    'tree-long-branches': treeLongBranches,
    'tree-map': treeMap,
    'devices-histogram': devicesHistogram
  };
  treeChart = devicesHistogram(screen.width - 10, 1000);
  $(function(){
    var updateStatsAtFooter, allParents;
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
    allParents = function(n, list){
      switch (false) {
      case !!n._parent:
        return [n].concat(list);
      default:
        return allParents(n._parent, list).concat([n], list);
      }
    };
    return $(window).on("tree/node-selected", function(ref$, node, keepBreadcrumb){
      var names, $a;
      keepBreadcrumb == null && (keepBreadcrumb = false);
      $('#create-a-test').unbind('click').one('click', function(){
        if (!!$('#chosen-tests').val()) {
          return showConcludeATestDialog(node);
        } else {
          return showCreateATestDialog(node);
        }
      });
      updateStatsAtFooter(node);
      if (!keepBreadcrumb) {
        $('.stats h2').html('');
        names = allParents(node, []);
        return $a = d3.select('.stats h2').selectAll('a').data(names).enter().append('a').text(function(it){
          return nameNode(it);
        }).on('click', function(it){
          return $(window).trigger("tree/node-selected", [it, true]);
        });
      }
    });
  });
  $(function(){
    var root, changeTreeUi, updateTreeFromUi, val, reRoot, reRootAgain, reRootCountry, reRootSuperCampaign, populateMethods, populateChosenSelectByData, populateChosenSelect;
    root = null;
    changeTreeUi = function(type){
      $(".tree").html('');
      treeChart = treeUiTypes[type](screen.width - 10, 1000);
      return updateTreeFromUi();
    };
    updateTreeFromUi = function(){
      var lastTreeId, addTreeIdToNode, addParentToNode, findMethod, calcConv, stndDevOfConversionForMethod, ref$, filteredRoot, selectedStats, untree, $wurflSelect, currentWurflNode, $option;
      if (!root.stats) {
        console.log('nothing!');
        return;
      }
      lastTreeId = 0;
      addTreeIdToNode = function(n){
        switch (false) {
        case !(!n.children || n.children.length === 0):
          return n.treeId = ++lastTreeId;
        default:
          n.treeId = ++lastTreeId;
          return each(addTreeIdToNode, n.children);
        }
      };
      addTreeIdToNode(root);
      addParentToNode = curry$(function(parent, n){
        n._parent = parent;
        if (!!n.children) {
          n.children = map(addParentToNode(n), n.children);
        }
        return n;
      });
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
      ref$ = filterTree(hardClone(root), $('#chosen-methods').val(), $('#chosen-methods-orand').is(':checked'), true, parseInt($('#kill-children-threshold').val())), filteredRoot = ref$[0], selectedStats = ref$[1];
      untree = function(){
        return filter(function(it){
          return !!it;
        })(foldRealNodes(filteredRoot, function(n, acc){
          return [n].concat(acc);
        }, null));
      }();
      $wurflSelect = $('#chosen-find-wurfl-node');
      currentWurflNode = $wurflSelect.val();
      $option = d3.select('#chosen-find-wurfl-node').selectAll('option').data([{}].concat(untree));
      $option.enter().append('option');
      $option.text(function(it){
        return it.device;
      }).attr('value', function(it){
        return it.device;
      });
      $option.exit().remove();
      $wurflSelect.select2({
        width: 'element',
        allowClear: true
      });
      $wurflSelect.on('change', function(){
        var node;
        if (this.selectedIndex > 0) {
          node = this.options[this.selectedIndex].__data__;
          return $(window).trigger("tree/node-selected", [node, true]);
        }
      });
      $wurflSelect.select2('val', currentWurflNode);
      treeChart.updateTree(addParentToNode(null, filteredRoot), selectedStats);
      if (!!$wurflSelect.val()) {
        return $wurflSelect.change();
      }
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
    populateMethods = function($d3select){
      return $d3select.selectAll('option').data(listOfSubscriptionMethods).enter().append('option').text(function(it){
        return it.name;
      });
    };
    populateMethods(d3.select('#chosen-methods'));
    $('#chosen-methods').select2({
      width: 'element'
    }).change(function(){
      return updateTreeFromUi();
    });
    populateMethods(d3.select('#chosen-create-test-methods')).attr('value', function(it){
      return it.id;
    });
    $('#chosen-create-test-methods').select2({
      width: 'element'
    });
    $('#chosen-methods-orand').change(function(){
      $('#kill-children-threshold').val($(this).is(':checked') ? 100 : 0);
      return updateTreeFromUi();
    });
    $('#kill-children-threshold').change(function(){
      return updateTreeFromUi();
    });
    populateChosenSelectByData = function($select, data, defaultValue){
      var $select2;
      defaultValue == null && (defaultValue = null);
      d3.select($select[0]).selectAll('option').data(data).enter().append('option').attr("value", function(it){
        return it.id;
      }).text(function(it){
        return it.name;
      });
      $select2 = $select.select2({
        width: 'element',
        allowClear: true
      });
      if (defaultValue !== null && typeof defaultValue !== "undefined") {
        $select2.select2('val', defaultValue);
      }
      return [$select, data];
    };
    populateChosenSelect = function($select, url, mapFunc, defaultValue, callback){
      return $.get(url, function(data){
        data = mapFunc(data);
        populateChosenSelectByData($select, data, defaultValue);
        return callback($select, data);
      });
    };
    return populateChosenSelect($('#chosen-countries').on('change', function(){
      return reRootCountry();
    }), 'http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetAllCountries', function(countries){
      return [{}].concat(countries);
    }, 2, function(_, countries){
      var now;
      populateChosenSelectByData($('#create-a-test-dialog .countries'), countries);
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
      $('#toDate').attr("max", formatDate(new Date(now.valueOf() + 2 * 24 * 60 * 60 * 1000))).val(formatDate(now)).change(function(){
        return reRootAgain();
      });
      $('#chosen-tree-ui-type').select2().change(function(){
        return changeTreeUi($(this).val());
      });
      return reRootAgain();
    });
  });
  showDialog = function($selector){
    var hideDilaog;
    hideDilaog = function(){
      console.log('hiding dialog');
      $selector.removeClass('visible');
      return setTimeout(function(){
        return $selector.hide();
      }, 500);
    };
    $selector.find('.step').hide();
    $selector.find('.step-1').show();
    $selector.show();
    setTimeout(function(){
      return $selector.addClass('visible');
    }, 500);
    $selector.find('.dialog-close').one('mousedown', function(){
      return hideDilaog();
    });
    return {
      hide: hideDilaog
    };
  };
  showCreateATestDialog = function(node){
    var dialog;
    dialog = showDialog($('#create-a-test-dialog'));
    $('.wurflId').text(nameNode(node));
    return $('#create-a-test-dialog .commit').one('click', function(){
      var countries, methods, url;
      countries = $('#chosen-create-test-countries').val();
      methods = $('#chosen-create-test-methods').val();
      if (!!countries && !!methods && !!countries.length && !!methods.length) {
        url = "http://mobitransapi.mozook.com/devicetestingservice.svc/json/CreateDeviceTest?wurfl_id=" + node.id + "&methods=" + methods + "&countries=" + countries;
        console.log("create-a-test url << ", url);
        return $.get(url, function(result){
          console.log('test created', result);
          $('#create-a-test-dialog .step-1').hide();
          $('#create-a-test-dialog .step-2').show();
          return $('#create-a-test-dialog .step-2 .results').text("Test Created, ID = " + result[0].id);
        });
      }
    });
  };
  showConcludeATestDialog = function(node){
    var dialog, stats, makeStat, testId, $dialog, render;
    dialog = showDialog($('#conclude-a-test-dialog'));
    $('.wurflId').text(nameNode(node));
    stats = sortBy(function(it){
      return it.conversion;
    }, node.stats);
    makeStat = function(method, visits, subscribers){
      if (filter(function(it){
        return it.method === method;
      }, stats).length === 0) {
        return [{
          method: method,
          visits: visits,
          subscribers: subscribers
        }];
      } else {
        return [];
      }
    };
    stats = makeStat('WAP', 1, 1).concat(stats, makeStat('WAPPIN', 1, 1), makeStat('SMS_WAP', 1, 1));
    testId = parseInt($('#chosen-tests').val());
    $dialog = $('#conclude-a-test-dialog');
    $dialog.find('.cancel').one('click', function(){
      return $.get("http://mobitransapi.mozook.com/devicetestingservice.svc/json/InterruptDeviceTest?test_id=" + testId, function(result){
        console.log(result);
        $dialog.find('.step-1').hide();
        $dialog.find('.step-2').show();
        return $dialog.find('.step-2 .results').text("Test Interrupted");
      });
    });
    $dialog.find('.commit').one('click', function(){
      var methodNames, methodIds, res$, i$, len$, name, j$, ref$, len1$, m, methoIdsString, url;
      methodNames = map(function(it){
        return it.method;
      }, stats);
      res$ = [];
      for (i$ = 0, len$ = methodNames.length; i$ < len$; ++i$) {
        name = methodNames[i$];
        for (j$ = 0, len1$ = (ref$ = listOfSubscriptionMethods).length; j$ < len1$; ++j$) {
          m = ref$[j$];
          if (name === m.name) {
            res$.push(m.id);
          }
        }
      }
      methodIds = res$;
      console.log("names", methodNames);
      methoIdsString = join(',', methodIds);
      console.log(methodIds, methoIdsString);
      url = "http://mobitransapi.mozook.com/devicetestingservice.svc/json/ConcludeDeviceTest?test_id=" + testId + "&wurfl_id=" + node.id + "&methods=" + methoIdsString;
      return $.get(url, function(result){
        console.log(result);
        $dialog.find('.step-1').hide();
        $dialog.find('.step-2').show();
        return $dialog.find('.step-2 .results').text("Test Concluded");
      });
    });
    render = function(){
      var $li, $liEnter, renderMethodStats;
      console.log("render", stats);
      $li = d3.select("ol.methods").selectAll('li.method').data(stats);
      $liEnter = $li.enter().append('li').attr('class', 'method');
      $li.exit().remove();
      $li.attr('data-method', function(it){
        return it.method;
      });
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
      $liEnter.append('span').attr('class', 'close').text('x').on('click', function(d){
        stats = filter(function(it){
          return it.method !== d.method;
        }, stats);
        return render();
      });
      return $("ol.methods").sortable().bind('sortupdate', function(){
        var names;
        names = $('ol.methods > li.method').map(function(){
          return $(this).attr('data-method');
        });
        stats = map(function(name){
          return find(function(s){
            return s.method === name;
          }, stats);
        }, names);
        return render();
      });
    };
    return render();
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
}).call(this);
