-- Global variables for luakit
globals = {
    homepage            = "http://www.google.it",
 -- homepage            = "http://github.com/mason-larobina/luakit",
    scroll_step         = 40,
    zoom_step           = 0.1,
    max_cmd_history     = 100,
    max_srch_history    = 100,
    http_proxy          = "http://localhost:8118",
    default_window_size = "1024x600",

 -- Disables loading of hostnames from /etc/hosts (for large host files)
 -- load_etc_hosts      = false,
 -- Disables checking if a filepath exists in search_open function
 -- check_filepath      = false,
}

-- Make useragent
local _, arch = luakit.spawn_sync("uname -sm")
-- Only use the luakit version if in date format (reduces identifiability)
local lkv = string.match(luakit.version, "^(%d+.%d+.%d+)")
globals.useragent = string.format("Mozilla/5.0 (%s) AppleWebKit/%s+ (KHTML, like Gecko) WebKitGTK+",
    string.sub(arch, 1, -2), luakit.webkit_user_agent_version)

-- Search common locations for a ca file which is used for ssl connection validation.
local ca_files = {
    -- $XDG_DATA_HOME/luakit/ca-certificates.crt
    luakit.data_dir .. "/ca-certificates.crt",
    "/etc/certs/ca-certificates.crt",
    "/etc/ssl/certs/ca-certificates.crt",
}
-- Use the first ca-file found
for _, ca_file in ipairs(ca_files) do
    if os.exists(ca_file) then
        soup.ssl_ca_file = ca_file
        break
    end
end

-- Change to stop navigation sites with invalid or expired ssl certificates
soup.ssl_strict = false

-- Set cookie acceptance policy
cookie_policy = { always = 0, never = 1, no_third_party = 2 }
soup.accept_policy = cookie_policy.always

-- List of search engines. Each item must contain a single %s which is
-- replaced by URI encoded search terms. All other occurances of the percent
-- character (%) may need to be escaped by placing another % before or after
-- it to avoid collisions with lua's string.format characters.
-- See: http://www.lua.org/manual/5.1/manual.html#pdf-string.format
search_engines = {
    luakit      = "http://luakit.org/search/index/luakit?q=%s",
    ggl         = "http://google.com/search?q=%s",
    wiki        = "http://en.wikipedia.org/wiki/Special:Search?search=%s",
    aur         = "http://aur.archlinux.org/packages.php?K=%s",
    -- archlinux forum search has changed, using duckduckgo !bang syntax
--     archforum   = "http://bbs.archlinux.org/search.php?action=search&keywords=%s&show_as=topics&sort_dir=DESC",
    archforum   = "http://duckduckgo.com/?q=!archlinux %s",
    map         = "http://maps.google.com/maps?q=%s",
    yt          = "http://www.youtube.com/results?search_query=%s&search_sort=video_view_count",
    duck        = "http://duckduckgo.com/?q=%s",
    git         = "https://github.com/search?q=%s&type=Everything&repo=&langOverride=&start_value=1",
    stack       = "http://stackoverflow.com/search?q=%s",
    port        = "http://michaelis.uol.com.br/moderno/ingles/index.php?lingua=portugues-ingles&palavra=%s",
    span        = "http://www.spanishdict.com/translate/%s",
    fork        = "http://punchfork.com/search/%s",
}

-- Set google as fallback search engine
search_engines.default = search_engines.google
-- Use this instead to disable auto-searching
--search_engines.default = "%s"

-- Per-domain webview properties
-- See http://webkitgtk.org/reference/webkitgtk/stable/WebKitWebSettings.html
domain_props = {
    ["all"] = {
        enable_scripts          = true,
        enable_plugins          = false,
        enable_private_browsing = false,
        user_stylesheet_uri     = "",
    },
    ["youtube.com"] = {
        enable_scripts = true,
        enable_plugins = true,
    },
    ["grooveshark.com"] = {
        enable_scripts = true,
        enable_plugins = true,
    },
    ["duckduckgo.com"] = {
        enable_scripts = true,
        enable_plugins = true,
    },
    ["bbs.archlinux.org"] = {
        user_stylesheet_uri     = "file://" .. luakit.data_dir .. "/styles/dark.css",
        enable_private_browsing = true,
    },
}

-- vim: et:sw=4:ts=8:sts=4:tw=80
