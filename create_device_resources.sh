#!/bin/sh

echo "Calling ./iot/create_keys_and_certificate.sh"
. ./iot/create_keys_and_certificate.sh
echo "Calling ./iot/create_thing.sh"
. ./iot/create_thing.sh
echo "Calling . ./iot/create_iot_policy.sh"
. ./iot/create_iot_policy.sh
echo "Calling ./logs/create_cw_iot_device_logs.sh"
. ./logs/create_cw_iot_device_logs.sh
echo "Calling ./logs/create_cw_iot_device_error_logs.sh"
. ./logs/create_cw_iot_device_error_logs.sh
echo "Calling ./iam/create_cw_logs_write_logs_role.sh"
. ./iam/create_cw_logs_write_logs_role.sh
echo "Calling ./iam/create_cw_logs_write_error_logs_role.sh"
. ./iam/create_cw_logs_write_error_logs_role.sh
echo "Calling ./iam/create_iot_rule_sqs_role.sh"
. ./iam/create_iot_rule_sqs_role.sh
echo "Calling ./iot/create_topic_rule.sh"
. ./iot/create_topic_rule.sh
