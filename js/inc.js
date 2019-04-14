var isLoaderVisible = false,
    loaderTimeout,
    pageTimer;

function setCookie(cname, cvalue, days, cpath) {
    var expires = '',
        path = '';
    if (days) {
        var date = new Date();
        date.setTime(date.getTime()+(days*24*60*60*1000));
        expires = '; expires=' + date.toUTCString();
    }
    if (cpath) {
        path = '; path=' + cpath;
    }
    document.cookie = cname + "=" + cvalue + expires + path;
}

function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i=0; i<ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1);
        if (c.indexOf(name) == 0) return c.substring(name.length, c.length);
    }
    return "";
}

function showPageLoader( s ){
    if( !isLoaderVisible ){
        s = typeof s !== 'undefined' ? s : 'fast';
        $('.page-loader').fadeIn( s );
        isLoaderVisible = true;
        $('body').css({
            // 'position': 'fixed',
            'width': '100%'
        });

        var s = Math.round( moment().valueOf() / 1000 );;
        var updateText = function(){
            $('.page-loader #page-timer').html( Math.round( moment().valueOf() / 1000 ) - s + 's' )
        }
        pageTimer = setInterval( updateText, 1000 );
        
        loaderTimeout = setTimeout(function(){
            $('.page-loader').animate({'opacity': '0.95'}, 'slow').find('.close').fadeIn();
            $('.still-working').animate({'top':'15px', 'opacity': '0.9'},'slow');
            $('.page-loader #page-timer').fadeIn();
        }, 2500);
    }
}

function hidePageLoader(){
    if( isLoaderVisible ){
        clearTimeout(loaderTimeout);
        clearInterval( pageTimer );
        $('body').css({
            // 'position': 'static',
            'width': 'auto'
        });
        $('.page-loader').find('.close').fadeOut();
        $('.page-loader').animate({'opacity': '0.8'}).fadeOut('fast');
        $('.still-working').css({'top':'99%', 'opacity': '0'});
        $('.page-loader #page-timer').fadeOut();
        isLoaderVisible = false;
    }
}

var showElementLoader = function(obj){
    $(obj).css({
        'background': 'url("img/loader.gif") no-repeat 99% 1px transparent'
    });
}

var hideElementLoader = function(obj){
    $(obj).css({
        'background': 'none'
    });
}

function ucfirst(str) {
    var firstLetter = str.substr(0, 1);
    return firstLetter.toUpperCase() + str.substr(1);
}

Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
}

Object.objectsCount = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (typeof(obj[key]) == 'object') size++;
    }
    return size;
}

function preload(arrayOfImages) {
    $(arrayOfImages).each(function(){
        $('<img/>')[0].src = this;
    });
}

$(function(){
    $('.page-loader .close').click(function(){
        hidePageLoader();
    });
});
/*
window.onerror = function(msg, url, linenumber) {
    hidePageLoader();
    alert('Server Error: ' + msg + '\nURL: ' + url + '\nLine Number: ' + linenumber + '. Please try again later.');
    return true;
}
*/
function htmlEncode(value){
  //create a in-memory div, set it's inner text(which jQuery automatically encodes)
  //then grab the encoded contents back out.  The div never exists on the page.
  return $('<div/>').text(value).html();
}

function htmlDecode(value){
  return $('<div/>').html(value).text();
}

function bgGlow( elem ){
    var $obj = $( elem );
    $obj.toggleClass('bg-glow');
    setTimeout( function(){
        $obj.toggleClass('bg-glow');
    }, 1500);
}

$.fn.scrollGuard2 = function() {
    return this
    .on( 'wheel', function ( e ) {
        var $this = $(this);
        if (e.originalEvent.deltaY < 0) {
            /* scrolling up */
            return ($this.scrollTop() > 0);
        } else {
            /* scrolling down */
            return ($this.scrollTop() + $this.innerHeight() < $this[0].scrollHeight);
        }
    });
};

jQuery.fn.extend({  
  selectContents: function() {  
    jQuery(this).each(function(i) {  
      var node = this;  
      var selection, range, doc, win;  
      if ((doc = node.ownerDocument) &&  
          (win = doc.defaultView) &&  
          typeof win.getSelection != 'undefined' &&  
          typeof doc.createRange != 'undefined' &&  
          (selection = window.getSelection()) &&  
          typeof selection.removeAllRanges != 'undefined') {  
        range = doc.createRange();  
        range.selectNode(node);  
        if (i == 0) {  
          selection.removeAllRanges();  
        }  
        selection.addRange(range);  
      } else if (document.body &&  
                 typeof document.body.createTextRange != 'undefined' &&  
                 (range = document.body.createTextRange())) {  
        range.moveToElementText(node);  
        range.select();  
      }  
    });  
  }
});

(function ($) {
    $('#copy').click(function(){

        var $table = $( '.dataTables_scrollBody .dataTable').length ? $('.dataTables_scrollBody .dataTable').eq(0) : $(".dataTable").eq(0);
        $table.selectContents();
        try {

            // Hack: to set the height of the header in scrollbody to 1px so that the text could be copied
            if( $('#pr-view-table-wrap').length || $('#rli-view-table-wrap').length )
                $('.dataTables_wrapper .dataTables_scroll div.dataTables_scrollBody th>div.dataTables_sizing').css('height', '2px');

            if( document.execCommand('copy') ){
                $('#copy').attr('title', 'Copied').tooltip('fixTitle').tooltip('show');
                $('#copy').on('hidden.bs.tooltip', function () {
                    $(this).attr('title', 'Copy table data to Clipboard').tooltip('fixTitle');
                });
            }
            else{
                $('#copy').attr('title', 'Press Ctrl/Cmd + C to copy').tooltip('fixTitle').tooltip('show');
                $('#copy').on('hidden.bs.tooltip', function () {
                    $(this).attr('title', 'Copy table data to Clipboard').tooltip('fixTitle');
                });

            }

            // Hack: to revert the height of the header in scrollbody to 0 so that the text could be copied
            if( $('#pr-view-table-wrap').length || $('#rli-view-table-wrap').length )
                $('.dataTables_wrapper .dataTables_scroll div.dataTables_scrollBody th>div.dataTables_sizing').css('height', '0');

        }
        catch (err) {
            alert('please press Ctrl+C/Cmd+C to copy');
        }

    });
}(jQuery));

function debounce(func, wait, immediate) {
    var timeout;
    return function() {
        var context = this, args = arguments;
        var later = function() {
            timeout = null;
            if (!immediate) func.apply(context, args);
        };
        var callNow = immediate && !timeout;
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
        if (callNow) func.apply(context, args);
    };
};


// Set / update URL query String
var updateQueryStringParam = function (key, value) {
    var hash = location.hash,
        index = hash.indexOf('?');

    if( index != -1 )
        hash = hash.slice(0, index);

    var baseUrl = [location.protocol, '//', location.host, location.pathname, hash].join(''),
        urlQueryString = document.location.search,
        newParam = key + '=' + value,
        params = '?' + newParam;

    // If the "search" string exists, then build params from it
    if (urlQueryString) {
        keyRegex = new RegExp('([\?&])' + key + '[^&]*');

        // If param exists already, update it
        if (urlQueryString.match(keyRegex) !== null) {
            params = urlQueryString.replace(keyRegex, "$1" + newParam);
        } else { // Otherwise, add it to end of query string
            params = urlQueryString + '&' + newParam;
        }
    }
    window.history.replaceState({}, "", baseUrl + params);
};

// Get URL query String
var getQueryStringParam = function (name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}

// Remove URL query string
var removeQueryStringParam = function(param){
    var url=document.location.href;
    var urlparts= url.split('?');

    if (urlparts.length>=2){
        var urlBase=urlparts.shift(); 
        var queryString=urlparts.join("?"); 

        var prefix = encodeURIComponent(param)+'=';
        var pars = queryString.split(/[&;]/g);
        for (var i= pars.length; i-->0;){
            if (pars[i].lastIndexOf(prefix, 0)!==-1)   
                pars.splice(i, 1);
        }
        url = urlBase+'?'+pars.join('&');
        window.history.pushState('',document.title,url); // added this line to push the new url directly to url bar .
    }
}

var intersect = function(a, b){
    var t;
    if (b.length > a.length) t = b, b = a, a = t; // indexOf to loop over shorter
    return a.filter(function (e) {
        return b.indexOf(e) > -1;
    });
}
