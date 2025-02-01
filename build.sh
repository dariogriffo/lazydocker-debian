LAZYDOCKER_VERSION=$1
BUILD_VERSION=$2
declare -a arr=("bookworm" "trixie" "sid")
for i in "${arr[@]}"
do
  DEBIAN_DIST=$i
  FULL_VERSION=$LAZYDOCKER_VERSION-${BUILD_VERSION}+${DEBIAN_DIST}_amd64
docker build . -t lazydocker-$DEBIAN_DIST  --build-arg DEBIAN_DIST=$DEBIAN_DIST --build-arg LAZYDOCKER_VERSION=$LAZYDOCKER_VERSION --build-arg BUILD_VERSION=$BUILD_VERSION --build-arg FULL_VERSION=$FULL_VERSION
  id="$(docker create lazydocker-$DEBIAN_DIST)"
  docker cp $id:/lazydocker_$FULL_VERSION.deb - > ./lazydocker_$FULL_VERSION.deb
  tar -xf ./lazydocker_$FULL_VERSION.deb
done


