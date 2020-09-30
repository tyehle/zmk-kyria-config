init:
    docker pull zmkfirmware/zephyr-west-action-arm:latest
    docker run --mount="type=bind,source=$(pwd),target=/source" --tty --rm --workdir=/source --entrypoint=bash zmkfirmware/zephyr-west-action-arm:latest -c "\
        west init --local=config || true \
        && west update"

build:
    mkdir -p build
    chmod g+s build
    docker run --mount="type=bind,source=$(pwd),target=/source" --tty --rm --workdir=/source --entrypoint=bash zmkfirmware/zephyr-west-action-arm:latest -c "\
        umask 0002 \
        && west config --local zephyr.base-prefer configfile \
        && west zephyr-export \
        && west build --pristine -s zmk/app -b nice_nano -- -DSHIELD=kyria_left -DZMK_CONFIG=/source/config\
        && cp build/zephyr/zmk.uf2 kyria_left_nice_nano.uf2\
        && west build --pristine -s zmk/app -b nice_nano -- -DSHIELD=kyria_right -DZMK_CONFIG=/source/config\
        && cp build/zephyr/zmk.uf2 kyria_right_nice_nano.uf2"

docker:
    docker run --mount="type=bind,source=$(pwd),target=/source" --tty --rm --workdir=/source --entrypoint=bash --interactive zmkfirmware/zephyr-west-action-arm:latest
