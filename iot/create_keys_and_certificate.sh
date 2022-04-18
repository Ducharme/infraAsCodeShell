#!/bin/sh

TXT_CRT=$(aws s3 ls s3://$S3_OBJECT_STORE/certs/$THING_TXT_FILENAME | grep $THING_TXT_FILENAME)
#fatal error: An error occurred (404) when calling the HeadObject operation: Key "certs/certificate-id.txt" does not exist
#
LEN_TXT=${#TXT_CRT}

if [ "$LEN_TXT" = "0" ]; then
  curl https://www.amazontrust.com/repository/AmazonRootCA1.pem > $THING_RCA_FILENAME

  THING_CERTIFICATE_ARN=$(aws iot create-keys-and-certificate --set-as-active \
    --certificate-pem-outfile "$THING_CRT_FILENAME" \
    --public-key-outfile "$THING_PUB_FILENAME" \
    --private-key-outfile "$THING_PRV_FILENAME" \
    --query certificateArn | tr -d '"')

  THING_CERTIFICATE_ID=${THING_CERTIFICATE_ARN#*/}

  echo $THING_CERTIFICATE_ID > $THING_TXT_FILENAME
  aws s3 cp ./$THING_TXT_FILENAME s3://$S3_OBJECT_STORE/certs/
  aws s3 cp ./$THING_CRT_FILENAME s3://$S3_OBJECT_STORE/certs/
  aws s3 cp ./$THING_PUB_FILENAME s3://$S3_OBJECT_STORE/certs/
  aws s3 cp ./$THING_PRV_FILENAME s3://$S3_OBJECT_STORE/certs/
  aws s3 cp ./$THING_RCA_FILENAME s3://$S3_OBJECT_STORE/certs/

  echo "THING_CERTIFICATE_ID (NEW): $THING_CERTIFICATE_ID"
  rm $THING_TXT_FILENAME
else
  aws s3 cp s3://$S3_OBJECT_STORE/certs/$THING_TXT_FILENAME ./$THING_TXT_FILENAME
  THING_CERTIFICATE_ID=$(cat ./$THING_TXT_FILENAME)
  THING_CERTIFICATE_ARN=arn:aws:iot:$AWS_REGION_VALUE:$AWS_ACCOUNT_ID_VALUE:cert/$THING_CERTIFICATE_ID
  echo "THING_CERTIFICATE_ID (CURRENT): $THING_CERTIFICATE_ID"
  echo "THING_CERTIFICATE_ARN (CURRENT): $THING_CERTIFICATE_ARN"
  rm $THING_TXT_FILENAME
fi
