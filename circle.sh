case "$1" in
  test)
    case $CIRCLE_NODE_INDEX in
      0)
        echo pwd: `pwd`
        # run common tests
        mvn site -B -pl common -Ddependency.locations.enabled=false > artifacts/log/common-site.log

        ;;

      1)
        echo pwd: `pwd`
        # run core
        # regist data for test
        mvn test -B -pl core -Dtest=com.fujitsu.dc.test.setup.Setup#reset > artifacts/log/core-reset.log
        mvn test -B -pl core -Dtest=com.fujitsu.dc.test.setup.Setup#resetEventLog > artifacts/log/core-resetEventLog.log
        mvn site -B -pl core -Ddependency.locations.enabled=false -Dtest=com.fujitsu.dc.test.jersey.box.odatacol > artifacts/log/core-site.log

        ;;

    esac

    ;;
esac
