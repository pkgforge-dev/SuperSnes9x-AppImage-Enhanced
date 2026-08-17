#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -S --noconfirm --needed \
	alsa-lib            \
	cmake               \
	libpng              \
	libusb              \
	libx11              \
	libxext             \
	libxkbcommon        \
	ninja               \
	qt6-svg             \
	sdl3                \
	wayland-protocols   \
	zlib

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package

# If the application needs to be manually built that has to be done down here
echo "Building the SuperSnes9x..."
echo "---------------------------------------------------------------"
git clone https://github.com/shanytc/snes9x.git ./snes9x && (
	cd ./snes9x
	if [ "${DEVEL_RELEASE-}" = 1 ]; then
		git rev-parse --short HEAD > ~/version
	else
		git fetch --tags origin
		TAG=$(git tag --sort=-v:refname | grep -vi 'rc\|alpha' | head -1)
		git checkout "$TAG"
		echo "$TAG" > ~/version
	fi

	git submodule update --init --recursive

	# BUILD
	cmake \
		-G Ninja                     \
		-S ./qt                      \
		-B ./qt/build                \
		-DCMAKE_BUILD_TYPE=Release   \
		-DUSE_SYSTEM_SDL3=ON         \
		-DCMAKE_INSTALL_PREFIX=/usr  \
		-DCMAKE_DISABLE_PRECOMPILE_HEADERS=ON
	cmake --build ./qt/build -j"$(nproc)"
	cmake --install ./qt/build
)
