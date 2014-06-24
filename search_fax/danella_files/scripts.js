












$(document).ready(function () {


    //datepicker
    $("#ctl00_MainContentPlaceHolder_startDate,#ctl00_MainContentPlaceHolder_endDate").datepicker();

    $('#ctl00_MainContentPlaceHolder_startDate').bind("blur", function () {
        if (this.value == "") {
            this.value = "Start";
        }
    });

    $('#ctl00_MainContentPlaceHolder_endDate').bind("blur", function () {
        if (this.value == "") {
            this.value = "End";
        }
    });

    //  search box
    $('.search-form-field').bind("focus", function () {
        if (this.value == "Search") {
            this.value = "";
        }
    }).bind("blur", function () {
        if (this.value == "") {
            this.value = "Search";
        }
    });

    //freatured-projects slideshow
    $("#project-slideshow").before('<ul id="project-slideshow-nav2"><li><a href="#" id="project-slideshow-nav2-prev">Prev</a></li><li><a href="#" id="project-slideshow-nav2-next">Next</a></li></ul>');

    $('#project-slideshow').after('<ul id="project-slideshow-nav">').cycle({
        fx: 'fade',
        speed: 'fast',
        timeout: 0,
        prev: '#project-slideshow-nav2-prev',
        next: '#project-slideshow-nav2-next',
        pager: '#project-slideshow-nav',
        pagerAnchorBuilder: function (idx, slide) {
            return '<li><a href="#"><img src="' + slide.src + '" width="59" height="39" /></a></li>';
        }
    });

    // cycle

    /* add nav placeholder  */

    /*
    $("#main").prepend('<ul id="nav-main-slides"></ul>');

    $("#main-slides").cycle({	
    speed:  'fast', 												   
    timeout: 0,	
    pager: '#nav-main-slides',	
    pagerAnchorBuilder: function(idx, slide) { 
    navname = $(slide).children("h2").children("img").attr("alt");
	
    return '<li><a href="#" id="nav-main-slide-' + idx + '">' + navname + '</a></li>'; 
    }
    });
    */
    /*
    $("#nav-main-slides li a").hover( 
    function (){
    $(this).css("color" , "#00a1db");
    },
    function (){
    $(this).css("color" , "#fff");
    }

    );
    */


    // rental systems slide show
    // large thumbs
    var thumbIndex = jQuery.url.param("ind");
    var ecode = jQuery.url.param("ecode");

    if (ecode != null && thumbIndex == null) {
        // do nothing
    }
    else {
        if (thumbIndex == null)
            thumbIndex = 0;

        var activeThumb = "";
        activeThumb = $('div.thumbnail-wrapper').get(thumbIndex);
        $(activeThumb).addClass("active").siblings().removeClass("active");
    }

    var listSize = $("div.rental-enlargement li").size();
    $('div.rental-enlargement-nav .total').html(listSize);


    $("div.rental-enlargement ul#rental-slide-viewer").before('<ul id="rental-nav"><li><a href="javascript:void(0);" id="rental-slide-previous">Prev</a></li><li><a href="javascript:void(0);" id="rental-slide-next">Next</a></li></ul>');
    //var rotator = $('div.rental-enlargement ul');
    $("div.rental-enlargement ul#rental-slide-viewer").cycle({
        fx: 'scrollHorz',
        timeout: 0,
        speed: 'fast',
        prev: '#rental-slide-previous',
        next: '#rental-slide-next',
        pager: '.rental-enlargement-pager',
        after: function () {
            var curr = $(this).prevAll().length + 1;
            $('div.rental-enlargement .curr').html(curr);
            //alert('cycle');
        }
    });

    if ($("ul#rental-slide-viewer").length == 1) {
        $("p.view-count").hide();
    }

    $('div.thumbnail-wrapper').hover(function () {
        $(this).addClass('current');
    }, function () {
        $(this).removeClass('current');
    });

    // small thumbs
    $('div.rental-thumbnails ul').cycle({
        fx: 'scrollHorz',
        timeout: 0,
        speed: 'fast',
        prev: 'div.rental-thumbnails-nav span#prevSm',
        next: 'div.rental-thumbnails-nav span#nextSm'
    });

    var rentalModClass = "";

    // fix webkit background bug
    if ($.browser.webkit) {
        rentalModClass = "rental-mod web-kit";
        $("#main-content #rental-item-gallery ul#rental-nav li a").css('background-position', '0 -1px');
    } else {
        rentalModClass = "rental-mod";
    }

    // rental enlargements
    var rentalDialog = $('<div id="rental-enlargement"></div>')
	.dialog({
	    autoOpen: false,
	    modal: false,
	    width: 549,
	    height: 406,
	    resizable: false,
	    draggable: true,
	    dialogClass: rentalModClass,
	    buttons: {
	        'Close Window': function () {
	            $(this).dialog('close');
	        }
	    }
	});

    var rentalImage = "";

    $("div.rental-enlargement-enlarger a").click(function () {
        var ulSize = $("ul#rental-slide-viewer > li").size();

        if (ulSize == 1) {
            rentalImage = $("ul#rental-slide-viewer li").find("input").attr("value");
        }
        else {

            rentalImage = $("ul#rental-slide-viewer li").filter(function () {
                return $(this).css('z-index') == '3';
            }).find("input").attr("value");
        }
        rentalImage = "<img src='" + rentalImage + "' alt='' />";
        rentalDialog.dialog({ title: $("#rental-item-gallery h1").text() });
        rentalDialog.html(rentalImage);
        rentalDialog.dialog('open');
        return false;
    });

    //$("#nav-main-slides li a").css("display", "none");

    // home billboard cycler
    var $homeCycle = $("div#main-slides").cycle({
        fx: 'fade',
        speed: 'fast',
        timeout: 4000,
        startingSlide: 1,
        before: onBefore
    });

    var triggerID = '';
    var triggerColor = "";
    var triggerNum = 0;

    $("#nav-main-slides li a").click(function () {

        $("#nav-main-slides li a").css("color", "#fff");
        //$("#nav-main-slides li").css("background-position", "15px 15px");

        triggerID = $(this).parent().attr("id");
        //alert(triggerID);

        switch (triggerID) {
            case "nav-slide-construction":
                triggerColor = "#00a1db";
                triggerNum = 0;
                break;
            case "nav-slide-engineering":
                triggerColor = "#dc6139";
                triggerNum = 1;
                break;
            case "nav-slide-integrated":
                triggerColor = "#dc6139";
                triggerNum = 2;
                break;
            case "nav-slide-rental":
                triggerColor = "#7ca35c";
                triggerNum = 3;
                break;
        }

        //alert(triggerNum);
        $homeCycle.cycle(triggerNum);
        return false;

        //$(this).css("color", triggerColor);
        //$(this).parent().css("background-position", "15px 5px").addClass("active").siblings().removeClass("active");


        //	$("#main-slides div").css("display" , "none");
        //$("#main-slides div").fadeOut();
        whichId = $(this).parent().attr("id");
        //	alert(whichId);
        //whichSlide = whichId.substr(4);
        //alert(whichSlide);
        //whichSlide.css("display" , "none");
        //$("#" + whichSlide + "").css("display" , "block");
        //$("#" + whichSlide + "").fadeIn();



    });

    function onBefore() {
        var currentID = $(this).attr('ID');
        var currentAnchor = "#nav-" + currentID;
        //$(currentAnchor).css('width', '175px').find('p').css('display', 'block').parent('li').siblings().css('width', '50px').find('p').css('display', 'block').parent().find('p').css('display', 'none');
        $(currentAnchor).find('p').css('display', 'block').parent('li').siblings().find('p').css('display', 'none');
    }



    /*$("#nav-main-slides li a").hover(function () {
    //$("#nav-main-slides li a").css("color", "#fff");
    //$("#nav-main-slides li:not(.active)").css("background-position", "15px 15px");
    //$(this).css("color", "#00a1db");
    $(this).parent().css("background-position", "15px 5px");



    }, function () {
    $(this).parent().css("background-position", "15px 15px");
    });*/



    // rental form text
    var formLabels = new Array(5);
    var x = 0;
    var formIndex = "";
    $("div#rental-item-form input.text").each(function () {
        formLabels[x] = $(this).val();
        x++;
    });
    $("div#rental-item-form input.text").click(function () {
        formIndex = $(this).index();
        if ($(this).val() == formLabels[formIndex])
            $(this).val("");
    });

    $("div#rental-item-form input.text").blur(function () {
        formIndex = $(this).index();
        if ($(this).val() == "")
            $(this).val(formLabels[formIndex]);
    });


    /*

    var bc = $('#buttonContainer'); 
 
    var $container = $('#container').cycle({ 
    fx:     'scrollHorz', 
    speed:   300, 
    timeout: 0 
    }); 
 
    $container.children().each(function(i) { 
    // create input 
    $('<input type="button" value="'+(i+1)+'" />') 
    // append it to button container 
    .appendTo(bc) 
    // bind click handler 
    .click(function() { 
    // cycle to the corresponding slide 
    $container.cycle(i); 
    return false; 
    }); 
    }); 



    */


    if (jQuery.url.segment(0) == "rental_Danella_Rental_Systems.aspx") {
        $("div#scroll-nav, div.scroller-wrapper").hide();
    } else {

        $('ul.scroll-content').jcarousel({
            scroll: 1
        });

    }

    $("div#scroll-nav p.title, div#scroll-nav p.expand").click(function () {
        if ($("div.scroller-wrapper").css("position") == "absolute") {
            $("div.scroller-wrapper").css('position', 'static').slideDown();
            $("div#scroll-nav p.title, div#scroll-nav p.expand").removeClass('inactive').addClass('active');
        } else {
            $("div.scroller-wrapper").css('position', 'absolute');
            $("div#scroll-nav p.title, div#scroll-nav p.expand").removeClass('active').addClass('inactive');
        }
    });

    var featureFirstIndex = 0;
    var feature_text = "";
    var feature_pos = 0;
    var feature_offset = 0;
    var left_pos = 0;

    $("ul#featured-projects-navigation").jcarousel({
        itemFirstInCallback: mycarousel_itemFirstInCallback
    });

    $("#featured-projects-navigation li a").hover(function () {
        feature_text = $(this).siblings("div.project-info").html();
        feature_pos = $(this).parent("li").attr("jcarouselindex");
        feature_offset = feature_pos - featureFirstIndex;
        left_pos = 155 + (feature_offset * 50);
        $("div.project-caption").html(feature_text).show().css('left', left_pos);
    },
		function () {
		    $("div.project-caption").hide();
		}
		);

    /**
    * This is the callback function which receives notification
    * when an item becomes the first one in the visible range.
    */
    function mycarousel_itemFirstInCallback(carousel, item, idx, state) {
        //alert(idx);
        //display('Item #' + idx + ' is now the first item');
        featureFirstIndex = idx;
    };



    /* featured projects */

    /*$(function () {
    $("div#scroll-nav p.title, div#scroll-nav p.expand").toggle(
    function (event) {
    $("div.scroller-wrapper").slideDown();
    },
    function (event) {
    $("div.scroller-wrapper").slideUp();
    }
    );
    });*/


    // sub navigation

    $("#sub-navigation ul#feature-project-links").css("display", "none");

    $("#sub-navigation ul#feature-project-links").each(function () {
        //  alert(this);
        //	$(this).siblings("a").css("background", "#333");
        //	$(this).siblings().css("background-color", "#f00");
        $(this).siblings("a").css({
            'background-image': 'url(imgs/sub-navigation-closed.png)',
            'background-repeat': 'no-repeat',
            'background-position': '288px 5px'
        }).addClass('parent-node');

    });

    $(function () {
        $("#sub-navigation li#featured-project a.parent-node").toggle(
    function (event) {
        $(this).siblings("ul").show("fast");
        $(this).siblings("ul").parent().children("a").css({
            'background-image': 'url(imgs/sub-navigation-open.png)',
            'background-repeat': 'no-repeat',
            'background-position': '288px 9px'
        });
    },
    function (event) {
        $(this).siblings("ul").hide("fast");
        $(this).siblings("ul").parent().children("a").css({
            'background-image': 'url(imgs/sub-navigation-closed.png)',
            'background-repeat': 'no-repeat',
            'background-position': '288px 5px'
        });
    }
    );
    });

    /*$("#sub-navigation li a").click(function () {
    $(this).siblings("ul").show("fast");

    $(this).siblings("ul").parent().children("a").css({
    'background-image': 'url(imgs/sub-navigation-open.png)',
    'background-repeat': 'no-repeat',
    'background-position': '288px 9px'
    });
    }, function () {
    $(this).siblings("ul").hide("fast");
    $(this).siblings("ul").parent().children("a").css({
    'background-image': 'url(imgs/sub-navigation-closed.png)',
    'background-repeat': 'no-repeat',
    'background-position': '288px 5px'
    });

    });*/



    /*$("#featured-projects-navigation").before('<ul id="featured-scroller-nav"><li id="fsn-left"><a href="javascript:void(0)">left</a></li><li id="fsn-right"><a href="javascript:void(0)">right</a></li></ul>');*/




    // rental nav thumbnails
    var default_thumb;
    default_thumb = $("#sub-navigation li.current span").html();

    if (default_thumb == null)
        default_thumb = "<img src='imgs/TH_utility_trucks.png' alt='Rental Trucks' />";

    $("div#left-column div.callout").html(default_thumb);
    $("#sub-navigation li").hover(function () {
        $("div#left-column div.callout").html($(this).find("span").html());
    }, function () {
        $("div#left-column div.callout").html(default_thumb);
    });







    //scroller ui
    /*

    //scrollpane parts
    var scrollPane = $('.scroll-pane');
    var scrollContent = $('.scroll-content');
		
    //build slider
    var scrollbar = $(".scroll-bar").slider({
    slide:function(e, ui){
    if( scrollContent.width() > scrollPane.width() ){ scrollContent.css('margin-left', Math.round( ui.value / 100 * ( scrollPane.width() - scrollContent.width() )) + 'px'); }
    else { scrollContent.css('margin-left', 0); }
    }
    });
		
    //append icon to handle
    var handleHelper = scrollbar.find('.ui-slider-handle')
    .mousedown(function(){
    scrollbar.width( handleHelper.width() );
    })
    .mouseup(function(){
    scrollbar.width( '100%' );
    })
    .append('<span class="ui-icon ui-icon-grip-dotted-vertical"></span>')
    .wrap('<div class="ui-handle-helper-parent"></div>').parent();
		
    //change overflow to hidden now that slider handles the scrolling
    scrollPane.css('overflow','hidden');
		
    //size scrollbar and handle proportionally to scroll distance
    function sizeScrollbar(){
    var remainder = scrollContent.width() - scrollPane.width();
    var proportion = remainder / scrollContent.width();
    var handleSize = scrollPane.width() - (proportion * scrollPane.width());
    scrollbar.find('.ui-slider-handle').css({
    width: handleSize,
    'margin-left': -handleSize/2
    });
    handleHelper.width('').width( scrollbar.width() - handleSize);
    }
		
    //reset slider value based on scroll content position
    function resetValue(){
    var remainder = scrollPane.width() - scrollContent.width();
    var leftVal = scrollContent.css('margin-left') == 'auto' ? 0 : parseInt(scrollContent.css('margin-left'));
    var percentage = Math.round(leftVal / remainder * 100);
    scrollbar.slider("value", percentage);
    }
    //if the slider is 100% and window gets larger, reveal content
    function reflowContent(){
    var showing = scrollContent.width() + parseInt( scrollContent.css('margin-left') );
    var gap = scrollPane.width() - showing;
    if(gap > 0){
    scrollContent.css('margin-left', parseInt( scrollContent.css('margin-left') ) + gap);
    }
    }
		
    //change handle position on window resize
    $(window)
    .resize(function(){
    resetValue();
    sizeScrollbar();
    reflowContent();
    });
    //init scrollbar size
    setTimeout(sizeScrollbar,10);//safari wants a timeout

	
    */

    var $dialog = $("<div id='call-now-dialog'></div>")
        .html("<strong>610 828 6200</strong>")
        .dialog({
            autoOpen: false,
            title: "Call Now",
            modal: 'true',
            width: 400,
            height: 250,
            resizable: false
        });

    $('#call-now').click(function () {
        $dialog.dialog('open');
        // prevent the default action, e.g., following a link
        return false;
    });









});                                                                                        //end doc ready




