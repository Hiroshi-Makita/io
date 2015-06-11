# function setupForCoreTest() {
#   # copy configuration file for CI environment
#   cp -p core/src/test/resources/ci/dc-config.properties core/src/test/resources/dc-config.properties
# 
#   # regist data for test
#   mvn test -B -pl core -Dtest=com.fujitsu.dc.test.setup.Setup#reset > $CIRCLE_ARTIFACTS/core-reset.log
#   mvn test -B -pl core -Dtest=com.fujitsu.dc.test.setup.Setup#resetEventLog > $CIRCLE_ARTIFACTS/core-resetEventLog.log
# }

case "$1" in
  pre_machine)
    # ensure correct level of parallelism
    expected_nodes=4
    if [ "$CIRCLE_NODE_TOTAL" -ne "$expected_nodes" ]
    then
        echo "Parallelism is set to ${CIRCLE_NODE_TOTAL}x, but we need ${expected_nodes}x."
        exit 1
    fi

    ;;

  dependencies)
    mvn install -B -pl es-api,common,logback -Dmaven.javadoc.skip=true -Dmaven.test.skip=true

    ;;

  dependencies_post)
    # elasticsearch
    wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.3.4.tar.gz
    tar -xvf elasticsearch-1.3.4.tar.gz
    cp -p core/src/test/resources/ci/elasticsearch.yml elasticsearch-1.3.4/config/elasticsearch.yml
    /bin/sh elasticsearch-1.3.4/bin/elasticsearch {background: true} &

    # MySQL
    sudo apt-add-repository -y 'deb http://ppa.launchpad.net/ondrej/mysql-experimental/ubuntu precise main'
    sudo apt-get update; sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server-5.5
    sudo cp -p core/src/test/resources/ci/my.cnf /etc/mysql/my.cnf
    sudo service mysql restart

    # create directory
    sudo mkdir -p /fjnfs/dc-core/{dav,eventlog,barInstall}
    sudo chown -R ubuntu.ubuntu /fjnfs
    sudo mkdir -p /fj/logback/log/
    sudo chown -R ubuntu.ubuntu /fj

    ;;

  test)
    case $CIRCLE_NODE_INDEX in
      0)
        # run all tests except core
        mvn site -B -pl common -Ddependency.locations.enabled=false > $CIRCLE_ARTIFACTS/common-site.log

        ;;

      1)
        # run core that included in com.fujitsu.dc.core except odatacol
        # copy configuration file for CI environment
        cp -p core/src/test/resources/ci/dc-config.properties core/src/test/resources/dc-config.properties

        # regist data for test
        mvn test -B -pl core -Dtest=com.fujitsu.dc.test.setup.Setup#reset > $CIRCLE_ARTIFACTS/core-reset.log
        mvn test -B -pl core -Dtest=com.fujitsu.dc.test.setup.Setup#resetEventLog > $CIRCLE_ARTIFACTS/core-resetEventLog.log

        mvn site -B -pl core -Ddependency.locations.enabled=false -Dsurefire.exclude.pattern=com/fujitsu/dc/test/** > $CIRCLE_ARTIFACTS/core-site.log

        ;;

      2)
        # run core that included in com.fujitsu.dc.test except odatacol
        # copy configuration file for CI environment
        cp -p core/src/test/resources/ci/dc-config.properties core/src/test/resources/dc-config.properties

        # regist data for test
        mvn test -B -pl core -Dtest=com.fujitsu.dc.test.setup.Setup#reset > $CIRCLE_ARTIFACTS/core-reset.log
        mvn test -B -pl core -Dtest=com.fujitsu.dc.test.setup.Setup#resetEventLog > $CIRCLE_ARTIFACTS/core-resetEventLog.log

        mvn site -B -pl core -Ddependency.locations.enabled=false -Dsurefire.exclude.pattern=com/fujitsu/dc/core/** > $CIRCLE_ARTIFACTS/core-site.log

        ;;

      3)
#        # run core that included in com.fujitsu.dc.test.jersey.box.odatacol
#        setupForCoreTest
#
#        # exclude test
#        echo "com.fujitsu.dc.core.*" >> .test-excludes
#        echo "com.fujitsu.dc.test.*" >> .test-excludes
#
#        mvn site -B -pl core -Ddependency.locations.enabled=false > $CIRCLE_ARTIFACTS/core-site.log

        ;;

    esac

    # save result of site
    find . -maxdepth 1 -type d ! -name "." -exec mv {}/target/site $CIRCLE_ARTIFACTS/{} \;
    # save result of junit
    # find . -type f -regex ".*/target/surefire-reports/.*xml" -exec cp {} $CIRCLE_TEST_REPORTS/junit/ \;

    ;;

esac
