

function getViewport () {
	  // https://stackoverflow.com/a/8876069
	  const width = Math.max(
	    document.documentElement.clientWidth,
	    window.innerWidth || 0
	  )
	  if (width <= 576) return 'xs'
	  if (width <= 768) return 'sm'
	  if (width <= 992) return 'md'
	  if (width <= 1200) return 'lg'
	  return 'xl'
}

$(document).ready(function () {
	  let viewport = getViewport()
	  let debounce
	  $(window).resize(() => {
	    debounce = setTimeout(() => {
	      const currentViewport = getViewport()
	      if (currentViewport !== viewport) {
	        viewport = currentViewport
	        newViewport(viewport);
	      }
	    }, 500);
	  });
	  // run when page loads
	  newViewport(viewport);
    
        jQuery.ajaxSetup({
          beforeSend: function() {
             $('#loader').show();
          },
          complete: function(){
             $('#loader').hide();
             feather.replace();
          },
          success: function() {}
        });
      $('#loader').hide();
});

function newViewport(viewport) {
	console.log("viewport=" + viewport);
}

function openLayer(url) {
    $('#layerContainer').load(url);
}

function closeLayer() {
    $("#layer").remove();
}

function formSubmit(submitUrl, form) {

    var formData = $(form);
    $.ajax({
          type: "POST",
          url: submitUrl,
          data: formData.serialize(),
          dataType: "script"
        });
    return false;
}

function checkboxChanged(checkbox) {
    if (checkbox.checked) {
        $( "#result" ).load( checkbox.dataset.url + "&value=true" );
    } else {
        $( "#result" ).load( checkbox.dataset.url + "&value=false" );
    }
}
