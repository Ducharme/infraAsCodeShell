#!/bin/sh

aws logs create-log-group --log-group-name $CW_IOT_DEVICE_ERROR_LOG_GROUP
