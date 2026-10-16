# nix-your-shell
if not contains /run/wrappers/bin $PATH
    set -gx PATH /run/wrappers/bin $PATH
end
if command -q nix-your-shell
    nix-your-shell fish | source
end

# bun
if test -d "$HOME/.bun/bin"
    set -gx PATH "$HOME/.bun/bin" $PATH
end
if command -q bun
    bun completions fish | source
end
