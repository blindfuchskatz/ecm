*** Settings ***
Library             String
Library             Process
Library             OperatingSystem
Variables           Varfile.py

Test Setup          Create Directory    ${TEST_DIR}
Test Teardown       Delete test files and terminate processes


*** Test Cases ***
Store meter data in flat file
    Given ECM is connected to MQTT broker
    When New meter data are published
    Then Meter data is stored in flat file in JSON format

Show help text on demand
    Given ECM is builded
    When ECM is started with a usage request
    Then Help text is printed

Show help text on wrong usage
    Given ECM is builded
    When ECM is started with more than one topic
    Then Help text with error message is printed

Print error message on invalid output path
    Given ECM is builded
    When ECM is started with invalid output path
    Then Output path error message is printed to stdout

Print error message on invalid URL
    Given ECM is builded
    When ECM is started with invalid URL
    Then URL error message is printed to stdout


*** Keywords ***
ECM is connected to MQTT broker
    Start MQTT broker
    Build ECM
    Start ECM

ECM is builded
    Build ECM

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
    Wait Until Keyword Succeeds
    ...    5s
    ...    1s
    ...    File Should Exist
    ...    ${TEST_DIR}${METER_DATA_FILE}

    ${content}    Get File    ${TEST_DIR}${METER_DATA_FILE}

    Should Be Equal As Strings
    ...    ${content}
    ...    meter_data: ${METER_DATA_1}\nmeter_data: ${METER_DATA_2}\n

Help text is printed
    File should contain    ${ECM_STDOUT_FILE}    ${HELP_TEXT}

Help text with error message is printed
    File should contain    ${ECM_STDOUT_FILE}    ${HELP_TEXT_AND_ERROR_MSG}

Output path error message is printed to stdout
    File should contain    ${ECM_STDOUT_FILE}    ${INVALID_PATH_MSG}

URL error message is printed to stdout
    File content should match regex pattern
    ...    ${ECM_STDOUT_FILE}
    ...    ${INVALID_URL_MSG}

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

ECM is started with a usage request
    ${service}    Start Process
    ...    ${ECM_SERVICE}
    ...    -h
    ...    stdout=${ECM_STDOUT_FILE}
    ...    stderr=STDOUT

ECM is started with more than one topic
    ${service}    Start Process    ${ECM_SERVICE}
    ...    ${TEST_DIR}${METER_DATA_FILE}
    ...    ${IP}
    ...    topic1
    ...    topic2
    ...    stdout=${ECM_STDOUT_FILE}
    ...    stderr=STDOUT

ECM is started with invalid output path
    ${service}    Start Process    ${ECM_SERVICE}
    ...    /tmp/invalid/dir.txt
    ...    ${IP}
    ...    ${MQTT_TOPIC}
    ...    stdout=${ECM_STDOUT_FILE}
    ...    stderr=STDOUT

ECM is started with invalid URL
    ${service}    Run Process    ${ECM_SERVICE}
    ...    ${TEST_DIR}${METER_DATA_FILE}
    ...    Invalid_URl
    ...    ${MQTT_TOPIC}
    ...    stdout=${ECM_STDOUT_FILE}
    ...    stderr=STDOUT

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

File should contain
    [Arguments]    ${file}    ${expected_msg}
    File Should Exist    ${file}
    ${content}    Get File    ${file}
    Should Be Equal As Strings    ${content}    ${expected_msg}

Delete test files and terminate processes
    Remove Directory    ${TEST_DIR}    ${True}
    Terminate All Processes
