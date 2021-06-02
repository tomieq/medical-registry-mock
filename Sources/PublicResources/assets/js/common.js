

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
});

function newViewport(viewport) {
	console.log("viewport=" + viewport);
}