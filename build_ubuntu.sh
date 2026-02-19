LAZYDOCKER_VERSION=$1
BUILD_VERSION=$2
ARCH=${3:-amd64}

if [ -z "$LAZYDOCKER_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <lazydocker_version> <build_version> [architecture]"
    echo "Example: $0 0.24.2 1 arm64"
    echo "Example: $0 0.24.2 1 all    # Build for all architectures"
    echo "Supported architectures: amd64, arm64, armhf, all"
    exit 1
fi

get_lazydocker_release() {
    local arch=$1
    case "$arch" in
        "amd64") echo "Linux_x86_64" ;;
        "arm64") echo "Linux_arm64" ;;
        "armhf") echo "Linux_armv7" ;;
        *) echo "" ;;
    esac
}

build_architecture() {
    local build_arch=$1
    local lazydocker_release

    lazydocker_release=$(get_lazydocker_release "$build_arch")
    if [ -z "$lazydocker_release" ]; then
        echo "❌ Unsupported architecture: $build_arch"
        echo "Supported architectures: amd64, arm64, armhf"
        return 1
    fi

    echo "Building for architecture: $build_arch using $lazydocker_release"

    rm -rf $lazydocker_release || true
    rm -f "lazydocker_${LAZYDOCKER_VERSION}_${lazydocker_release}.tar.gz" || true

    if ! wget "https://github.com/dariogriffo/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_${lazydocker_release}.tar.gz"; then
        echo "❌ Failed to download lazydocker binary for $build_arch"
        return 1
    fi

    mkdir -p "$lazydocker_release"
    if ! tar -xzf "lazydocker_${LAZYDOCKER_VERSION}_${lazydocker_release}.tar.gz" -C "$lazydocker_release"; then
        echo "❌ Failed to extract lazydocker binary for $build_arch"
        return 1
    fi

    declare -a arr=("jammy" "noble" "questing")

    for dist in "${arr[@]}"; do
        FULL_VERSION="$LAZYDOCKER_VERSION-${BUILD_VERSION}+${dist}_${build_arch}_ubu"
        echo "  Building $FULL_VERSION"

        if ! docker build . -f Dockerfile.ubu -t "lazydocker-ubuntu-$dist-$build_arch" \
            --build-arg UBUNTU_DIST="$dist" \
            --build-arg LAZYDOCKER_VERSION="$LAZYDOCKER_VERSION" \
            --build-arg BUILD_VERSION="$BUILD_VERSION" \
            --build-arg FULL_VERSION="$FULL_VERSION" \
            --build-arg ARCH="$build_arch" \
            --build-arg LAZYDOCKER_RELEASE="$lazydocker_release"; then
            echo "❌ Failed to build Docker image for $dist on $build_arch"
            return 1
        fi

        id="$(docker create "lazydocker-ubuntu-$dist-$build_arch")"
        if ! docker cp "$id:/lazydocker_$FULL_VERSION.deb" - > "./lazydocker_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb package for $dist on $build_arch"
            return 1
        fi

        if ! tar -xf "./lazydocker_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb contents for $dist on $build_arch"
            return 1
        fi
    done

    echo "✅ Successfully built for $build_arch"
    return 0
}

if [ "$ARCH" = "all" ]; then
    echo "🚀 Building lazydocker $LAZYDOCKER_VERSION-$BUILD_VERSION for all supported Ubuntu architectures..."
    echo ""
    ARCHITECTURES=("amd64" "arm64" "armhf")
    for build_arch in "${ARCHITECTURES[@]}"; do
        echo "==========================================="
        echo "Building for architecture: $build_arch"
        echo "==========================================="
        if ! build_architecture "$build_arch"; then
            echo "❌ Failed to build for $build_arch"
            exit 1
        fi
        echo ""
    done
    echo "🎉 All architectures built successfully!"
    echo "Generated packages:"
    ls -la lazydocker_*.deb
else
    if ! build_architecture "$ARCH"; then
        exit 1
    fi
fi
