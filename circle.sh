case "$1" in
  test)
    case $CIRCLE_NODE_INDEX in
      0)
        # run common tests
        mvn site -B -pl common -Ddependency.locations.enabled=false > artifacts/log/common-site.log

        ;;

      1)
        # run core
        mvn site -B -pl core -Ddependency.locations.enabled=false -Dtest=com.fujitsu.dc.test.jersey.box.odatacol > artifacts/log/core-site.log

        ;;

esac
