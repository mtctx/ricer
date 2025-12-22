set -e

exit_dir_on_error() {
    cd $HOME || true
}

trap exit_dir_on_error ERR

############

export rice_directory=$(cat "./data/rice_dir.txt")
export os=$(cat "./data/os.txt")

export cpmm_kde="$rice_directory/catppuccin/kde"
export cpmm_sddm="$rice_directory/catppuccin/sddm"
export cpmm_kvantum="$rice_directory/catppuccin/kvantum"

############

check_var_empty() {
    local var="$1"

    if [[ $# -lt 1 || -z "$var" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

parse_path() {
    local path="$1"

    var_empty=$(check_var_empty "$path")
    if [[ var_empty == "true" ]]; then
        echo "No path provided or empty string!"
        exit 1
    fi

    if [[ $path == ~* ]]; then
        path="${path/#\$HOME/$HOME}"
    fi

    path=${path// /\\}

    echo $path
}

is_directory_or_file() {
    local path="$1"

    var_empty=$(check_var_empty "$path")
    if [[ var_empty == "true" ]]; then
        echo "No path provided or empty string!"
        exit 1
    fi

    path=$(parse_path "$path")

    if [[ -f $path || $path == *.* ]]; then
        echo "file"
    elif [[ -d $path ]]; then
        echo "directory"
    else
        echo "directory"
    fi
}

clone() {
    local repo="$1"
    local out="$2"
    local remove="$3"

    var_empty=$(check_var_empty "$repo")
    if [[ var_empty == "true" ]]; then
        echo "No repo url provided or empty string!"
        exit 1
    fi
    var_empty=$(check_var_empty "$out")
    if [[ var_empty == "true" ]]; then
        echo "No output directory provided or empty string!"
        exit 1
    fi

    remove=${remove:-false}

    if [[ $remove == true ]]; then
        rm -rf "$out"
    fi

    git clone -- "$repo" "$out" || {
        echo "Clone failed or incomplete" >&2
        rm -rf -- "$out"
        exit 1
    }
}

safe_curl() {
    local target_path="$1"
    local url="$2"
    local simlink_location="$3"

    var_empty=$(check_var_empty "$target_path")
    if [[ var_empty == "true" ]]; then
        echo "No target path provided or empty string!"
        exit 1
    else
        target_path=$(parse_path "$target_path")
    fi

    var_empty=$(check_var_empty "$url")
    if [[ var_empty == "true" ]]; then
        echo "No url provided or empty string!"
        exit 1
    fi

    sudo rm -rf $target_path

    dir_or_file=$(is_directory_or_file $target_path)
    if [[ dir_or_file == "file" ]]; then
        curl -Lo $target_path $url
    elif [[ dir_or_file == "directory" ]]; then
        curl -LO --output-dir $target_path $url
    else
        exit 1
    fi

    var_empty=$(check_var_empty "$simlink_location")
    if [[ var_empty == "false" ]]; then
        simlink_location=$(parse_path "$simlink_location")
        ln -sf $target_path $simlink_location
    fi
}

trim_indent() {
    local line min_indent=999999 indent content
    local -a lines=()

    # Read all lines into an array
    while IFS= read -r line; do
        lines+=("$line")
    done

    # Find minimum indent (ignore blank lines)
    for line in "${lines[@]}"; do
        if [[ $line =~ ^([[:space:]]*)(.*)$ ]]; then
            content=${BASH_REMATCH[2]}
            indent=${#BASH_REMATCH[1]}
            # Only consider non-blank lines
            [[ -n $content ]] && (( indent < min_indent )) && min_indent=$indent
        fi
    done

    # If no indent found, just output as-is
    (( min_indent == 999999 )) && min_indent=0

    # Output each line with min_indent removed
    for line in "${lines[@]}"; do
        printf '%s\n' "${line:min_indent}"
    done
}