$(
	function(){
	
		$('#title h2').each(		
			function(){
				var flash = '<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0" width="775" height="82" id="main_title" align="middle"><param name="allowScriptAccess" value="sameDomain" /><param name="movie" value="/images/2009design/header.swf" /><param name="quality" value="high" /><param name="flashVars" value="labeltext='+escape($(this).text())+'" /><param name="bgcolor" value="#ffffff" /><param name="wmode" value="transparent" /><embed src="/images/2009design/header.swf" quality="high" bgcolor="#ffffff" width="775" height="82" name="main_title" align="middle" allowScriptAccess="sameDomain" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" wmode="transparent" flashVars="labeltext='+escape($(this).text())+'" /></object>';	
			
				$(this).replaceWith(flash);
			}
		);
	}
)