function fontSize(d,i) {
  if(d.key == null)
    return 0;

  var size =  18; //Math.max(d.dx/5, d.dy);
  var words = d.key.split(' ');
  var word = words[0];
  var width = d.dx;
  var height = d.dy;
  var length = 0;
  d3.select(this).style("font-size", size + "px").text(word);
  while(((this.getBBox().width >= width) || (this.getBBox().height >= height)) && (size > 12))
   {
    size--;
    d3.select(this).style("font-size", size + "px");
    this.firstChild.data = word;
   }
}

function wordWrap(d, i){
  if(d.key == null)
    return 0;
  var words = d.key.split('_');
  var line = new Array();
  var length = 0;
  var text = "";
  var width = d.dx;
  var height = d.dy;
  var word;
  do {
     word = words.shift();
     line.push(word);
     if (words.length)
       this.firstChild.data = line.join(' ') + " " + words[0]; 
     else
       this.firstChild.data = line.join(' ');
     length = this.getBBox().width;
     if (length < width && words.length) {
       ;
     }
     else {
       text = line.join(' ');
       this.firstChild.data = text;
       if (this.getBBox().width > width) { 
         text = d3.select(this).select(function() {return this.lastChild;}).text();
         text = text + "...";
         d3.select(this).select(function() {return this.lastChild;}).text(text);
         d3.select(this).classed("wordwrapped", true);
         break;
      }
      else
        ;

    if (text != '') {
      d3.select(this).append("svg:tspan")
      .attr("x", 0)
      .attr("dx", "0.15em")
      .attr("dy", "0.9em")
      .text(text);
    }
    else
       ;

    if(this.getBBox().height > height && words.length) {
       text = d3.select(this).select(function() {return this.lastChild;}).text();
       text = text + "...";
       d3.select(this).select(function() {return this.lastChild;}).text(text);
       d3.select(this).classed("wordwrapped", true);

       break;
    }
    else
       ;

    line = new Array();
      }
    } while (words.length);
    this.firstChild.data = '';
} 
