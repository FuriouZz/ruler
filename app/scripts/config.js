var Ruler = Ruler || {};

Ruler.config   = {
  ENV: 'development'
};

Ruler.CSS = {
    ruleHeight: 17,
    ruleWidth:  17
};

Ruler.toPixel = function(number){
    return number + 'px'
}

Ruler.range = function(number, min, max){
    return Math.max(Math.min(number, max), min);
}

Ruler.parent = function(target, selector){
    els = document.querySelectorAll(selector)
    for (i = 0; i < els.length; i++) {
        if (els[i] == target.parentNode)
            return target.parentNode
    }
    return null
}
