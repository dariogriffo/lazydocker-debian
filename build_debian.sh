LAZYDOCKER_VERSION=$1
BUILD_VERSION=$2
ARCH=${3:-amd64}  # Default to amd64 if no architecture specified

if [ -z "$LAZYDOCKER_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <lazydocker_version> <build_version> [architecture]"
    echo "Example: $0 0.24.2 1 arm64"
    echo "Example: $0 0.24.2 1 all    # Build for all architectures"
    echo "Supported architectures: amd64, arm64, armhf, armel, i386, all"
    exit 1
fi

# Function to map Debian architecture to lazydocker release name
get_lazydocker_release() {
    local arch=$1
    case "$arch" in
        "amd64")
            echo "Linux_x86_64"
            ;;
        "arm64")
            echo "Linux_arm64"
            ;;
        "armhf")
            echo "Linux_armv7"
            ;;
        "armel")
            echo "Linux_armv6"
            ;;
        "i386")
            echo "Linux_x86"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to build for a specific architecture
build_architecture() {
    local build_arch=$1
    local lazydocker_release

    lazydocker_release=$(get_lazydocker_release "$build_arch")
    if [ -z "$lazydocker_release" ]; then
        echo "❌ Unsupported architecture: $build_arch"
        echo "Supported architectures: amd64, arm64, armhf, armel, i386"
        return 1
    fi

    echo "Building for architecture: $build_arch using $lazydocker_release"
    
    rm -rf $lazydocker_release || true
    rm -f "lazydocker_${LAZYDOCKER_VERSION}_${lazydocker_release}.tar.gz" || true
    
    # Download and extract lazydocker binary for this architecture
        if ! wget "https://github.com/dariogriffo/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_${lazydocker_release}.tar.gz"; then
            echo "❌ Failed to download lazydocker binary for $build_arch"
            return 1
        fi
    
        # Create directory and extract zip file
        mkdir -p "$lazydocker_release"
        if ! tar -xzf "lazydocker_${LAZYDOCKER_VERSION}_${lazydocker_release}.tar.gz" -C "$lazydocker_release"; then
            echo "❌ Failed to extract lazydocker binary for $build_arch"
            return 1
        fi

    # Build packages for all Debian distributions
    declare -a arr=("bookworm" "trixie" "forky" "sid")

    for dist in "${arr[@]}"; do
        FULL_VERSION="$LAZYDOCKER_VERSION-${BUILD_VERSION}+${dist}_${build_arch}"
        echo "  Building $FULL_VERSION"

        if ! docker build . -t "lazydocker-$dist-$build_arch" \
            --build-arg DEBIAN_DIST="$dist" \
            --build-arg LAZYDOCKER_VERSION="$LAZYDOCKER_VERSION" \
            --build-arg BUILD_VERSION="$BUILD_VERSION" \
            --build-arg FULL_VERSION="$FULL_VERSION" \
            --build-arg ARCH="$build_arch" \
            --build-arg LAZYDOCKER_RELEASE="$lazydocker_release"; then
            echo "❌ Failed to build Docker image for $dist on $build_arch"
            return 1
        fi

        id="$(docker create "lazydocker-$dist-$build_arch")"
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

# Main build logic
if [ "$ARCH" = "all" ]; then
    echo "🚀 Building lazydocker $LAZYDOCKER_VERSION-$BUILD_VERSION for all supported architectures..."
    echo ""

    # All supported architectures
    ARCHITECTURES=("amd64" "arm64" "armhf" "armel" "i386")

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
    # Build for single architecture
    if ! build_architecture "$ARCH"; then
        exit 1
    fi
fi


