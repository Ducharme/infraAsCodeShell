#!/bin/sh

# Specific values for this build
DEVICE_POLICY_NAME=device-policy
THING_POLICY_NAME=$PROJECT_NAME-$DEVICE_POLICY_NAME


TEMPLATE_JSON=./iot/device_policy_template.json
VALUES_JSON=./iot/tmp_device_policy-values.json
cp $TEMPLATE_JSON $VALUES_JSON
sed -i 's@THING_TOPIC@'"$THING_TOPIC"'@g' $VALUES_JSON
sed -i 's@AWS_ACCOUNT_ID_VALUE@'"$AWS_ACCOUNT_ID_VALUE"'@g' $VALUES_JSON
sed -i 's@AWS_REGION_VALUE@'"$AWS_REGION_VALUE"'@g' $VALUES_JSON
aws iot create-policy --policy-name $THING_POLICY_NAME --policy-document file://$VALUES_JSON
aws iot attach-policy --policy-name $THING_POLICY_NAME --target $THING_CERTIFICATE_ARN
aws iot attach-thing-principal --thing-name $THING_NAME --principal $THING_CERTIFICATE_ARN

TEMPLATE_JSON=./iot/register_thing_template_body.json
VALUES_JSON=./iot/tmp_register_thing_body-values.json
cp $TEMPLATE_JSON $VALUES_JSON
sed -i 's@THING_POLICY_NAME@'"$THING_POLICY_NAME"'@g' $VALUES_JSON
THING_TEMPLATE_BODY=$(cat $VALUES_JSON)

TEMPLATE_JSON=./iot/register_thing_template_params.json
VALUES_JSON=./iot/tmp_register_thing_params-values.json
cp $TEMPLATE_JSON $VALUES_JSON
sed -i 's@THING_NAME@'"$THING_NAME"'@g' $VALUES_JSON
sed -i 's@THING_CERTIFICATE_ID@'"$THING_CERTIFICATE_ID"'@g' $VALUES_JSON
THING_PARAMETERS=$(cat $VALUES_JSON)


aws iot register-thing --template-body "$THING_TEMPLATE_BODY" --parameters "$THING_PARAMETERS"
