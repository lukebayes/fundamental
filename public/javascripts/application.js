
function toggleOpenIdEntry() {
    var target = $('#any-open-id');
    var vis = target.is(':visible');
    target[ vis ? 'hide' : 'show' ]('medium');
    $('#toggle-any-open-id').text( (vis ? '(+) Show' : '(-) Hide') + ' OpenID URL entry' ); 
    return false;
}
