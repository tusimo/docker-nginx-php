#!/bin/bash

# Replace variables $ENV{<environment varname>}
function ReplaceEnvironmentVariable() {
    grep -rl "\$ENV{\"$1\"}" $3|xargs -r \
        sed -i "s|\\\$ENV{\"$1\"}|$2|g"
}

# Replace all variables
for _curVar in `env | grep NGINX_ | awk -F = '{print $1}'`;do
    # awk has split them by the equals sign
    # Pass the name and value to our function
    ReplaceEnvironmentVariable "${_curVar}" "${!_curVar}" /etc/nginx/conf.d/*
    # replace nginx.conf
    ReplaceEnvironmentVariable "${_curVar}" "${!_curVar}" /etc/nginx/nginx.conf
done

nginx -V
php -v

export EXEC_CMD="${EXEC_CMD:-env}"

echo "执行自定义命令${EXEC_CMD}" 

${EXEC_CMD}

exec "$@"
