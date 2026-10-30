# Отключаем приветствие
set fish_greeting

# Пример установки переменной окружения
set -gx EDITOR nvim

# Алиас на Python-скрипт rebuild
alias rebuild="python3 /home/kasiro/nixos-config/scripts/rebuild.py"
alias cpx="python /home/kasiro/Документы/project_scope/main.py"

function opencode
    wtype -k lctrl -k lshift -k 0
    command opencode $argv
    wtype -k lctrl -k lshift -k 9
end
function devshell-init --description "Создать flake.nix + .envrc в текущей директории"
    if test -e flake.nix
        echo "flake.nix уже существует — прерываю" >&2
        return 1
    end
    if test -e .envrc
        echo ".envrc уже существует — прерываю" >&2
        return 1
    end

    set -l dirname (basename (pwd))
    set -l system "x86_64-linux"   # поменяй на aarch64-linux, если надо

    echo "{
    description = \"$dirname\";

    inputs = {
        nixpkgs.url = \"github:nixos/nixpkgs/nixos-unstable\";
    };

    outputs = { self, nixpkgs }:
        let
        system = \"$system\";
        pkgs = import nixpkgs { inherit system; };
        in
        {
        devShells.\${system}.default = pkgs.mkShell {
            packages = with pkgs; [
            # добавь нужные пакеты здесь
            ];

            shellHook = \'\'
            echo \"Добро пожаловать в среду разработки!\";
            # if [ -z \"\$DIRENV_IN_ENVRC\" ]; then
                # shellHook
            # fi
            \'\';
        };
        };
    }" > flake.nix
    string replace -a "\\'" "'" < flake.nix > flake.nix.new
    mv flake.nix.new flake.nix

    echo "use flake" > .envrc
    git add . && git commit -m "add devshell"
    direnv allow .

    echo "✔ Создано: flake.nix, .envrc"
end

# Здесь можно добавить любые другие команды на языке fish
# Например, для сброса прокси, о котором мы говорили ранее:
# gsettings set org.gnome.system.proxy mode 'none'
