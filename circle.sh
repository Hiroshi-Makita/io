case "$1" in
  test)
    case $CIRCLE_NODE_INDEX in
      0)
        # run common tests
        mvn site -B -pl common -Ddependency.locations.enabled=false > $CIRCLE_ARTIFACTS/common-site.log

        ;;

      1)
        # run core that included in com.fujitsu.dc.core

        # copy configuration file for CI environment
        cp -p core/src/test/resources/ci/dc-config.properties core/src/test/resources/dc-config.properties

        # regist data for test
        mvn test -B -pl core -Dtest=com.fujitsu.dc.test.setup.Setup#reset > $CIRCLE_ARTIFACTS/core-reset.log
        mvn test -B -pl core -Dtest=com.fujitsu.dc.test.setup.Setup#resetEventLog > $CIRCLE_ARTIFACTS/core-resetEventLog.log

        # exclude test
        echo "com.fujitsu.dc.test.*" >> .test-excludes

        mvn site -B -pl core -Ddependency.locations.enabled=false > $CIRCLE_ARTIFACTS/core-site.log

        ;;

      2)
        # run core that included in com.fujitsu.dc.test

        # copy configuration file for CI environment
        cp -p core/src/test/resources/ci/dc-config.properties core/src/test/resources/dc-config.properties

        # regist data for test
        mvn test -B -pl core -Dtest=com.fujitsu.dc.test.setup.Setup#reset > $CIRCLE_ARTIFACTS/core-reset.log
        mvn test -B -pl core -Dtest=com.fujitsu.dc.test.setup.Setup#resetEventLog > $CIRCLE_ARTIFACTS/core-resetEventLog.log

        # exclude test
        echo "com.fujitsu.dc.core.*" >> .test-excludes

        mvn site -B -pl core -Ddependency.locations.enabled=false > $CIRCLE_ARTIFACTS/core-site.log

        ;;

      3)
        # run engine tests

        ;;

    esac

    find . -maxdepth 1 -type d ! -name "." -exec mv {}/target/site $CIRCLE_ARTIFACTS/{} \;

    ;;

esac
