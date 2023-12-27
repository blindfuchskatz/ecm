*** Settings ***
Library             String
Library             Process
Library             OperatingSystem

Test Setup          Create Directory    ${TEST_DIR}
Test Teardown       Delete test files and terminate processes


*** Variables ***
${TEST_DIR}             /tmp/ecm_test/
${METER_DATA_FILE}      meter_data.txt
${MQTT_TOPIC}           meter_data
${IP}                   127.0.0.1
${MQTT_STDOUT_FILE}     ${TEST_DIR}mqtt_stdout.txt
${ECM_STDOUT_FILE}      ${TEST_DIR}ecm_stdout.txt
${ECM_SERVICE}          /ecm_sdk/target/debug/main
${METER_DATA_1}         "{"Time":"time","ENERGY":{"Total":2.0,"Total_t1:2.0"}}"
${METER_DATA_2}         "{"Time":"time","ENERGY":{"Total":5.0,"Total_t1:2.4"}}"


*** Test Cases ***
Store meter data in flat file
    Given ECM is connected to MQTT broker
    When New meter data are published
    Then Meter data is stored in flat file in JSON format


*** Keywords ***
ECM is connected to MQTT broker
    Start MQTT broker
    Build ECM
    Start ECM

New meter data are published
    @{meter_data_list}    Create List    ${METER_DATA_1}    ${METER_DATA_2}

    FOR    ${index}    ${meta_data}    IN ENUMERATE    @{meter_data_list}
        ${process}    Run Process
        ...    mosquitto_pub
        ...    -h    ${IP}
        ...    -t    ${MQTT_TOPIC}
        ...    -m    ${meta_data}
        Should Be Equal As Integers    ${process.rc}    0
    END

Meter data is stored in flat file in JSON format
    Wait Until Keyword Succeeds    5s    1s    File Should Exist    ${TEST_DIR}${METER_DATA_FILE}
    ${content}    Get File    ${TEST_DIR}${METER_DATA_FILE}
    Should Be Equal As Strings    ${content}
    ...    meter_data: ${METER_DATA_1}\nmeter_data: ${METER_DATA_2}\n

Start MQTT broker
    ${service}    Start Process
    ...    mosquitto
    ...    -c
    ...    /ecm_sdk/e2e_tests/test_files/mosquitto.conf
    ...    alias=mqtt_broker
    ...    stdout=${MQTT_STDOUT_FILE}
    ...    stderr=STDOUT

    Process Should Be Running    mqtt_broker

    MQTT broker should be ready for connections

    Log    MQTT broker started with pid: ${service.pid}

Build ECM
    Run Process    /ecm_sdk/run_build.sh    x86
    File Should Exist    ${ECM_SERVICE}

Start ECM
    ${service}    Start Process    ${ECM_SERVICE}
    ...    ${TEST_DIR}${METER_DATA_FILE}
    ...    ${IP}
    ...    ${MQTT_TOPIC}
    ...    alias=ecm
    ...    stdout=${ECM_STDOUT_FILE}
    ...    stderr=STDOUT

    Process Should Be Running    ecm

    ECM should be ready for messages

    Log    ECM started with pid: ${service.pid}

MQTT broker should be ready for connections
    Wait Until Keyword Succeeds
    ...    5s
    ...    1s
    ...    File content should match regex pattern
    ...    ${MQTT_STDOUT_FILE}
    ...    mosquitto version ([\\w.]+) running

ECM should be ready for messages
    Wait Until Keyword Succeeds
    ...    5s
    ...    1s
    ...    File content should match regex pattern
    ...    ${ECM_STDOUT_FILE}
    ...    Waiting for messages

File content should match regex pattern
    [Arguments]    ${file_path}    ${expected_regex}
    File Should Exist    ${file_path}
    ${content}    Get File    ${file_path}
    Should Match Regexp    ${content}    ${expected_regex}

Delete test files and terminate processes
    Remove Directory    ${TEST_DIR}    ${True}
    Terminate All Processes
