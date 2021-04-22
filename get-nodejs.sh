#!/usr/bin/env bash

lts_url='https://nodejs.org/en/'
download_url='https://nodejs.org/dist/'
tarball='/tmp/nodejs-tarball'
nodejs_path=/usr/local/lib/nodejs

main() {
    download_tar_file
    install
}

getlts() {
    local lts=$(wget -qO- https://nodejs.org/en/ | sed -n 's/ *\([[:digit:]]\{1,2\}\.[[:digit:]]\{1,2\}\.[[:digit:]]\{1,2\}\) LTS$/\1/p')
    if ! echo "$lts" | grep -qE '^[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}$'; then
        echo "Fail to get LTS version. Stop. ($lts)"; exit 1
    fi
    echo $lts
}

download_tar_file() {
    if [ -e "$tarball" ]; then
        rm -rf $tarball
    fi
    version=v$(getlts)
    distro=linux-x64
    local url="https://nodejs.org/dist/$version/node-$version-$distro.tar.xz"
    wget $url -O $tarball
    if [ "$?" != "0" ]; then
        echo "Fail to get Node.js $version"
        echo "$url"
        echo "Stop."
        exit 1
    fi
}

modify_bash_configuration_file() {
    local bash_config="$HOME/.profile"

    printf "\nModify $bash_config\n"

    if grep -q NODEJS_VERSION "$bash_config"; then
        sed -i "s/\(NODEJS_VERSION=\)v[0-9]\{1,2\}\.[0-9]\{1,2\}\.[0-9]\{1,2\}/\1$version/" $bash_config
    else
        printf "\n\n# set PATH so it includes Node.js\n" >> $bash_config
        echo "NODEJS_VERSION=$version" >> $bash_config
        echo "NODEJS_DISTRO=$distro" >> $bash_config
        echo 'PATH=/usr/local/lib/nodejs/node-$NODEJS_VERSION-$NODEJS_DISTRO/bin:$PATH' >> $bash_config
        printf 'export PATH' >> $bash_config
    fi

    . $bash_config
    if [ "$?" != "0" ]; then
        printf "error($?). Fail to Modify source $bash_config."
        PATH=/usr/local/lib/nodejs/node-$version-$distro/bin:$PATH
        export PATH  
    fi
}

install() {
    printf "Install Node.js to $nodejs_path\n"

    if [ "$(id -u)" != "0" ]; then
        SUDO=sudo
    fi

    $SUDO mkdir -p $nodejs_path

    printf "\nExtract tarball......\n"
    $SUDO tar -xJf $tarball -C $nodejs_path

    # modify_bash_configuration_file
    $SUDO rm -f /usr/local/bin /usr/local/bin/npm /usr/local/bin/npx
    $SUDO cp $nodejs_path/node-$version-$distro/bin/node /usr/local/bin
    $SUDO ln -s $nodejs_path/node-$version-$distro/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm
    $SUDO ln -s $nodejs_path/node-$version-$distro/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

    printf "\nFinish installing Node.js\n"
    echo "You now have:"
    echo "node version for $(node -v)"
    echo "npm version for $(npm -v)"
    echo "npx version for $(npx -v)"
}

main