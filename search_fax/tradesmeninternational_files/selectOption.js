/* This script and many more are available free online at
The JavaScript Source!! http://www.javascriptsource.com
Created by: Stephen Griffin | http://www.i-code.co.uk */
function changeLocation(menuObj) {
  var i = menuObj.selectedIndex;
  if(i > 0) {
    window.location = menuObj.options[i].value;
  }
}