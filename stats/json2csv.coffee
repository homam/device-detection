JSON2CSV = (objArray, quote) ->
  array = (if typeof objArray isnt "object" then JSON.parse(objArray) else objArray)
  str = ""
  line = ""
  head = array[0]
  if quote
    for index of array[0]
      value = index + ""
      line += "\"" + value.replace(/"/g, "\"\"") + "\","
  else
    for index of array[0]
      line += index + ","
  line = line.slice(0, -1)
  str += line + "\r\n"
  i = 0

  while i < array.length
    line = ""
    if quote
      for index of array[i]
        value = array[i][index] + ""
        line += "\"" + value.replace(/"/g, "\"\"") + "\","
    else
      for index of array[i]
        line += array[i][index] + ","
    line = line.slice(0, -1)
    str += line + "\r\n"
    i++
  str

exports.json2csv = JSON2CSV