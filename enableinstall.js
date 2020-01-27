if(window.location.pathname == '/web/addons/app.php', 'nav_addons') {
    function func(){$(".header_1 ._text").append('&nbsp;&nbsp;&nbsp;&nbsp;<input type="file" name="f_apps_file" class="file_input_hidden" id="f_apps_file" onchange="apps_manually_install();">')}
     $(document).ready(setTimeout(function() { func(); }, 3000));
}
