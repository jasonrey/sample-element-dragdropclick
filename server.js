var exec = require("child_process").exec

exec("cake", function() {
    require("coffee-script/register")

    var app = require("./app");

    app.listen(process.env.PORT || 3000);
});