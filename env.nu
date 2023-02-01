# Nushell Environment Config File

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
let-env ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
}

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
let-env NU_LIB_DIRS = [
    ($nu.config-path | path dirname | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
let-env NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]

alias py = python3.11
alias pynv = (source venv/bin/activate.nu)
alias dump = (ls *Tempnvim.* | each { rm $in.name })

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# let-env PATH = ($env.PATH | split row (char esep) | prepend '/some/path')

# function that serves as a runner for `hopper`, allows program to change directory of current terminal
def-env hop [cmd: string, p2: string = "", p3: string = ""] {
    let command = (nu -c ($"C:/Users/steph/Projects/hop/target/release/hopper ($cmd) ($p2) ($p3)" | str trim))
    let new_loc = if ($command | str starts-with 'cd') {
        ($command | parse "{cmd} {dir}" | get dir | first)
    } else {
        bash -c $command
        $env.PWD
    }
    cd $new_loc
}
let-env STARSHIP_SHELL = "nu"
let-env STARSHIP_SESSION_KEY = (random chars -l 16)
let-env PROMPT_MULTILINE_INDICATOR = (^'C:\Program Files\starship\bin\starship.exe' prompt --continuation)

# Does not play well with default character module.
# TODO: Also Use starship vi mode indicators?
let-env PROMPT_INDICATOR = ""
let-env STARSHIP_CONFIG = ^'C:\Users\steph\.config\starship.toml'
let-env PROMPT_COMMAND = {
    # jobs are not supported
    let width = (term size).columns
    ^'C:\Program Files\starship\bin\starship.exe' prompt $"--cmd-duration=($env.CMD_DURATION_MS)" $"--status=($env.LAST_EXIT_CODE)" $"--terminal-width=($width)"
}

# Whether we can show right prompt on the last line
let has_rprompt_last_line_support = (version).version >= 0.71.0

# Whether we have config items
let has_config_items = (not ($env | get -i config | is-empty))

if $has_rprompt_last_line_support {
    let config = if $has_config_items {
        $env.config | upsert render_right_prompt_on_last_line true
    } else {
        {render_right_prompt_on_last_line: true}
    }
    {config: $config}
} else {
    { }
} | load-env

let-env PROMPT_COMMAND_RIGHT = {
    if $has_rprompt_last_line_support {
        let width = (term size).columns
        ^'C:\Program Files\starship\bin\starship.exe' prompt --right $"--cmd-duration=($env.CMD_DURATION_MS)" $"--status=($env.LAST_EXIT_CODE)" $"--terminal-width=($width)"
    } else {
        ''
    }
}

let-env PROMPT_INDICATOR_VI_INSERT = "-> "
let-env PROMPT_INDICATOR_VI_NORMAL = "=> "
let-env PROMPT_MULTILINE_INDICATOR = "::: "
