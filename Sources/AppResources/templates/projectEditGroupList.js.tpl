$("#groupList :checkbox").change(function() {
    if (this.checked) {
        $( "#result" ).load( this.dataset.url + "&value=true" );
    } else {
        $( "#result" ).load( this.dataset.url + "&value=false" );
    }
});
