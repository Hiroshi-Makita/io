case "$1" in
  test)
    case $CIRCLE_NODE_INDEX in
      0)
        # run common tests
        mvn site -B -pl common -Ddependency.locations.enabled=false > $CIRCLE_ARTIFACTS/common-site.log

        ;;

      1)
        # run core
        # copy configuration file for CI environment
        cp -p core/src/test/resources/ci/dc-config.properties core/src/test/resources/dc-config.properties
        # regist data for test
        mvn test -B -pl core -Dtest=com.fujitsu.dc.test.setup.Setup#reset > $CIRCLE_ARTIFACTS/core-reset.log
        mvn test -B -pl core -Dtest=com.fujitsu.dc.test.setup.Setup#resetEventLog > $CIRCLE_ARTIFACTS/core-resetEventLog.log
        mvn site -B -pl core -Ddependency.locations.enabled=false -Dtest=com.fujitsu.dc.test.jersey.box.odatacol.UserDataCreateTest > $CIRCLE_ARTIFACTS/core-site.log

        ;;

    esac

    find . -maxdepth 1 -type d ! -name "." -exec mv {}/target/site $CIRCLE_ARTIFACTS/{} \;

    ;;

esac
