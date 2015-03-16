fs = require "fs"
{exec} = require "child_process"

pwd = __dirname

publicFolders = [
    "public"
    "public/js"
    "public/css"
]

libraries =
    "js": [
        "less/dist/less.min.js"
        "jquery/dist/jquery.min.js"
        "coffee-script/extras/coffee-script.js"
    ]
    "css": [
        "bootstrap/dist/css/bootstrap.min.css"
    ]

task "development",
    "Development build.",
    ->
        invoke "copyDevLibraries"

task "production",
    "Production build.",
    ->
        invoke "copyLibraries"
        invoke "copyImages"
        invoke "compilejs"
        invoke "compilecss"

task "phpbuild",
    "PHP build.",
    ->
        invoke "copyLibraries"
        invoke "copyImages"
        invoke "compilejs"
        invoke "compilecss"
        invoke "compileHTML"
        invoke "copyExternalLibraries"
        invoke "copyAPI"

task "phpbeautybuild",
    "PHP build beautifully.",
    ->
        invoke "copyLibraries"
        invoke "copyImages"
        invoke "compilebeautyjs"
        invoke "compilebeautycss"
        invoke "compileHTML"
        invoke "copyExternalLibraries"
        invoke "copyAPI"

task "prepareFolders",
    "Creates the necessary folders for further process.",
    ->
        for folder in publicFolders
            fs.mkdirSync folder unless fs.existsSync folder

task "copyLibraries",
    "Copy static libraries to public folder.",
    ->
        invoke "prepareFolders"

        for type, files of libraries
            for file in files
                exec "cp -f #{pwd}/bower_components/#{file} #{pwd}/public/#{type}"

task "copyDevLibraries",
    "Copy static libraries to assets folder.",
    ->
        for type, files of libraries
            fs.mkdirSync "#{pwd}/assets/#{type}" unless fs.existsSync "#{pwd}/assets/#{type}"

            for file in files
                exec "cp -f #{pwd}/bower_components/#{file} #{pwd}/assets/#{type}"

task "copyImages",
    "Copy images to public folder.",
    ->
        invoke "prepareFolders"
        exec "cp #{pwd}/assets/images/* #{pwd}/public/images/"

task "compilejs",
    "Compiles coffeescript to javascript.",
    ->
        invoke "prepareFolders"

        fs.mkdirSync "#{pwd}/assets/js" unless fs.existsSync "#{pwd}/assets/js"

        exec "coffee --compile --bare --output #{pwd}/assets/js #{pwd}/assets/coffee", ->
            for file in fs.readdirSync "#{pwd}/assets/js"
                exec "uglifyjs --unsafe --output #{pwd}/public/js/#{file} #{pwd}/assets/js/#{file}"

task "compilebeautyjs",
    "Compiles coffeescript to javascript.",
    ->
        invoke "prepareFolders"

        fs.mkdirSync "#{pwd}/public/js" unless fs.existsSync "#{pwd}/public/js"

        exec "coffee --compile --bare --output #{pwd}/public/js #{pwd}/assets/coffee"

task "compilecss",
    "Compiles less to css.",
    ->
        invoke "prepareFolders"
        for file in fs.readdirSync "#{pwd}/assets/less"
            filename = file.slice 0, -5
            exec "lessc -x #{pwd}/assets/less/#{file} > #{pwd}/public/css/#{filename}.css"

task "compilebeautycss",
    "Compiles less to css beautifully.",
    ->
        invoke "prepareFolders"
        for file in fs.readdirSync "#{pwd}/assets/less"
            filename = file.slice 0, -5
            exec "lessc #{pwd}/assets/less/#{file} > #{pwd}/public/css/#{filename}.css"

task "compileHTML",
    "Compiles jade to html.",
    ->
        invoke "prepareFolders"

        jade = require "jade"

        options =
            pretty: true

        for file in fs.readdirSync "#{pwd}/views" when file isnt "html.jade"
            filename = file.slice 0, -5

            content = fs.readFileSync "#{pwd}/views/" + file, encoding: "utf8"

            content = content.replace 'script(type="text/javascript", src="js/less.min.js")', ''
            content = content.replace 'script(type="text/javascript", src="js/coffee-script.js")', ''
            content = content.replace /link\(rel="stylesheet\/less", type="text\/css", href="less\/(.*).less"\)/, 'link(rel="stylesheet", type="text/css", href="css/$1.css")'
            content = content.replace /script\(type="text\/coffeescript", src="coffee\/(.*)\.coffee"\)/, 'script(type="text/javascript", src="js/$1.js")'

            fs.writeFileSync "#{pwd}/public/" + filename + ".html", jade.render(content, options), encoding: "utf8"

task "copyAPI",
    "Copies additional API files.",
    ->
        invoke "prepareFolders"
        exec "cp #{pwd}/assets/api/* #{pwd}/public/api/" if fs.existsSync "#{pwd}/assets/api"

task "copyExternalLibraries",
    "Copies external libraries to assets and public folder."
    ->
        invoke "prepareFolders"

        if fs.existsSync "#{pwd}/external_components"
            for folder in fs.readdirSync "#{pwd}/external_components"
                for type in fs.readdirSync "#{pwd}/external_components/#{folder}"
                    fs.mkdirSync "#{pwd}/public/#{type}" unless fs.existsSync "#{pwd}/public/#{type}"
                    fs.mkdirSync "#{pwd}/assets/#{type}" unless fs.existsSync "#{pwd}/assets/#{type}"

                    exec "cp #{pwd}/external_components/#{folder}/#{type}/* #{pwd}/public/#{type}/"
                    exec "cp #{pwd}/external_components/#{folder}/#{type}/* #{pwd}/"