#!/bin/bash

# AWS Static Website Deployment Script
# This script deploys the static website to AWS using S3 and CloudFront
# It requires the AWS CLI to be installed and configured with the "ever" profile

# Configuration
PROFILE="ever"
BUCKET_NAME="aws-basics-demo-website-$(date +%s)"
REGION="us-east-1"
WEBSITE_DIR="$(pwd)"

echo "🚀 Starting deployment process..."
echo "Using AWS Profile: $PROFILE"
echo "Bucket Name: $BUCKET_NAME"
echo "Region: $REGION"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if the profile exists
if ! aws configure list --profile $PROFILE &> /dev/null; then
    echo "❌ AWS profile '$PROFILE' not found. Please configure it first."
    exit 1
fi

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --profile $PROFILE --query "Account" --output text)
if [ -z "$ACCOUNT_ID" ]; then
    echo "❌ Failed to get AWS account ID. Exiting."
    exit 1
fi
echo "AWS Account ID: $ACCOUNT_ID"

# Create S3 bucket
echo "📦 Creating S3 bucket..."
if aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION --profile $PROFILE; then
    echo "✅ S3 bucket created successfully."
else
    echo "❌ Failed to create S3 bucket. Exiting."
    exit 1
fi

# Configure bucket for website hosting (for index/error document handling)
echo "🌐 Configuring bucket for static website hosting..."
aws s3api put-bucket-website --bucket $BUCKET_NAME --website-configuration '{"IndexDocument":{"Suffix":"index.html"},"ErrorDocument":{"Key":"error.html"}}' --profile $PROFILE

# Upload website files
echo "📤 Uploading website files..."
aws s3 sync $WEBSITE_DIR s3://$BUCKET_NAME --exclude "*.sh" --exclude ".git/*" --exclude "*.md" --exclude "deploy.sh" --profile $PROFILE

# Create Origin Access Control (OAC)
echo "🔑 Creating Origin Access Control..."
OAC_NAME="OAC-$BUCKET_NAME"
OAC_CONFIG='{
    "Name": "'$OAC_NAME'",
    "Description": "OAC for '$BUCKET_NAME'",
    "SigningProtocol": "sigv4",
    "SigningBehavior": "always",
    "OriginAccessControlOriginType": "s3"
}'

OAC_ID=$(aws cloudfront create-origin-access-control --origin-access-control-config "$OAC_CONFIG" --profile $PROFILE --query "OriginAccessControl.Id" --output text)

if [ -z "$OAC_ID" ]; then
    echo "❌ Failed to create Origin Access Control. Exiting."
    exit 1
fi
echo "✅ Origin Access Control created successfully with ID: $OAC_ID"

# Create CloudFront distribution with OAC
echo "☁️ Creating CloudFront distribution..."
DISTRIBUTION_CONFIG='{
    "CallerReference": "'$BUCKET_NAME'",
    "DefaultRootObject": "index.html",
    "Origins": {
        "Quantity": 1,
        "Items": [
            {
                "Id": "S3-'$BUCKET_NAME'",
                "DomainName": "'$BUCKET_NAME'.s3.'$REGION'.amazonaws.com",
                "S3OriginConfig": {
                    "OriginAccessIdentity": ""
                },
                "OriginAccessControlId": "'$OAC_ID'"
            }
        ]
    },
    "DefaultCacheBehavior": {
        "TargetOriginId": "S3-'$BUCKET_NAME'",
        "ViewerProtocolPolicy": "redirect-to-https",
        "AllowedMethods": {
            "Quantity": 2,
            "Items": ["GET", "HEAD"],
            "CachedMethods": {
                "Quantity": 2,
                "Items": ["GET", "HEAD"]
            }
        },
        "Compress": true,
        "ForwardedValues": {
            "QueryString": false,
            "Cookies": {
                "Forward": "none"
            }
        },
        "MinTTL": 0,
        "DefaultTTL": 86400,
        "MaxTTL": 31536000
    },
    "Comment": "CloudFront distribution for '$BUCKET_NAME'",
    "Enabled": true,
    "PriceClass": "PriceClass_100"
}'

DISTRIBUTION_ID=$(aws cloudfront create-distribution --distribution-config "$DISTRIBUTION_CONFIG" --profile $PROFILE --query "Distribution.Id" --output text)

if [ -z "$DISTRIBUTION_ID" ]; then
    echo "❌ Failed to create CloudFront distribution. Exiting."
    exit 1
fi

DOMAIN_NAME=$(aws cloudfront get-distribution --id $DISTRIBUTION_ID --profile $PROFILE --query "Distribution.DomainName" --output text)
echo "✅ CloudFront distribution created successfully with ID: $DISTRIBUTION_ID"
echo "🌎 Website URL: https://$DOMAIN_NAME"

# Set bucket policy to allow access only from CloudFront
echo "🔒 Setting bucket policy to allow access only from CloudFront..."
POLICY='{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowCloudFrontServicePrincipal",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::'$BUCKET_NAME'/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "arn:aws:cloudfront::'$ACCOUNT_ID':distribution/'$DISTRIBUTION_ID'"
                }
            }
        }
    ]
}'

aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy "$POLICY" --profile $PROFILE
echo "✅ Bucket policy set successfully."

# Save deployment info to a file
echo "{\"bucketName\":\"$BUCKET_NAME\",\"region\":\"$REGION\",\"distributionId\":\"$DISTRIBUTION_ID\",\"domainName\":\"$DOMAIN_NAME\"}" > deployment-info.json
echo "📝 Deployment information saved to deployment-info.json"

echo "✨ Deployment completed! Your website is now accessible only through CloudFront."
echo "🌎 Website URL: https://$DOMAIN_NAME"
echo "⏱️ Note: It may take a few minutes for the CloudFront distribution to fully deploy."
