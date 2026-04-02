#!/usr/bin/env bash

termux=false
linux=false

function for_termux() {
    cd "${PREFIX}/opt/holehe"
    command pip install --upgrade pip setuptools wheel

    if ! command python3 -c "import requests"; then
        command pip install requests
    fi

    command pip install .
    cd
}

function for_linux() {
    cd "${PREFIX}/opt/holehe"
    command python3 -m venv holehe_venv
    source "holehe_venv/bin/activate"
    command pip install --upgrade pip setuptools wheel

    if ! command python3 -c "import requests"; then
        command pip install requests
    fi

    command pip install .
    deactivate
    cd

    echo \
        '#!/usr/bin/env bash' \
        > "${PREFIX}/bin/holehe"

    echo -e \
        "exec ${PREFIX}/opt/holehe/holehe_venv/bin/python3 -m holehe \"\${@}\"" \
        >> "${PREFIX}/bin/holehe"

    command chmod +x "${PREFIX}/bin/holehe"
}

if [[ -n "${TERMUX_VERSION}" ]]; then
    termux=true
elif [[ -x "/system/bin/getprop" ]] || [[ -d "/data/data/com.termux" ]]; then
    termux=true
elif [[ -f "/etc/os-release" ]]; then
    if ! command grep -iq "termux" "/etc/os-release"; then
        linux=true
    else
        termux=true
    fi
fi

if [[ ! -d "${PREFIX}/opt" ]]; then
    command mkdir -p "${PREFIX}/opt"
fi

if [[ -d "${PREFIX}/opt/holehe" ]]; then
    command rm -rf "${PREFIX}/opt/holehe"
fi

if [[ -x "${PREFIX}/bin/holehe" ]]; then
    command rm -f "${PREFIX}/bin/holehe"
fi

command git clone --depth 1 \
    'https://github.com/megadose/holehe' \
    "${PREFIX}/opt/holehe"

if [[ "${termux}" == true ]]; then
    for_termux
elif [[ "${linux}" == true ]]; then
    for_linux
fi