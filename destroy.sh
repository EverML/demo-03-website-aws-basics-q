#!/bin/bash

# AWS Static Website Destruction Script
# This script removes all AWS resources created by the deploy.sh script
# It requires the AWS CLI to be installed and configured with the "ever" profile

# Configuration
PROFILE="ever"

# Check if deployment info exists
if [ ! -f "deployment-info.json" ]; then
    echo "❌ No deployment information found. Please deploy the website first."
    exit 1
fi

# Read deployment info
BUCKET_NAME=$(grep -o '"bucketName":"[^"]*' deployment-info.json | cut -d'"' -f4)
REGION=$(grep -o '"region":"[^"]*' deployment-info.json | cut -d'"' -f4)
DISTRIBUTION_ID=$(grep -o '"distributionId":"[^"]*' deployment-info.json | cut -d'"' -f4)
DOMAIN_NAME=$(grep -o '"domainName":"[^"]*' deployment-info.json | cut -d'"' -f4)

echo "🧹 Starting cleanup process..."
echo "Using AWS Profile: $PROFILE"
echo "Bucket Name: $BUCKET_NAME"
echo "Region: $REGION"
echo "CloudFront Distribution ID: $DISTRIBUTION_ID"

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

# Disable CloudFront distribution
if [ -n "$DISTRIBUTION_ID" ]; then
    echo "☁️ Disabling CloudFront distribution..."
    
    # Get the current configuration (ETag)
    ETAG=$(aws cloudfront get-distribution-config --id $DISTRIBUTION_ID --profile $PROFILE --query "ETag" --output text)
    
    # Get the current config and update it to disabled
    aws cloudfront get-distribution-config --id $DISTRIBUTION_ID --profile $PROFILE > cf-config.json
    
    # Create a new JSON with Enabled=false
    cat cf-config.json | jq '.DistributionConfig.Enabled = false' > cf-config-disabled.json
    
    # Update the distribution
    aws cloudfront update-distribution --id $DISTRIBUTION_ID --if-match $ETAG --distribution-config file://cf-config-disabled.json --profile $PROFILE
    
    echo "⏳ Waiting for CloudFront distribution to be disabled (this may take a while)..."
    aws cloudfront wait distribution-deployed --id $DISTRIBUTION_ID --profile $PROFILE
    
    # Delete the distribution
    echo "🗑️ Deleting CloudFront distribution..."
    ETAG=$(aws cloudfront get-distribution --id $DISTRIBUTION_ID --profile $PROFILE --query "ETag" --output text)
    aws cloudfront delete-distribution --id $DISTRIBUTION_ID --if-match $ETAG --profile $PROFILE
    
    # Clean up temporary files
    rm -f cf-config.json cf-config-disabled.json
else
    echo "⚠️ No CloudFront distribution ID found. Skipping CloudFront cleanup."
fi

# Empty and delete S3 bucket
if [ -n "$BUCKET_NAME" ]; then
    echo "🗑️ Emptying S3 bucket..."
    aws s3 rm s3://$BUCKET_NAME --recursive --profile $PROFILE
    
    echo "🗑️ Deleting S3 bucket..."
    aws s3api delete-bucket --bucket $BUCKET_NAME --profile $PROFILE
else
    echo "⚠️ No S3 bucket name found. Skipping S3 cleanup."
fi

# Remove deployment info file
echo "🗑️ Removing deployment information file..."
rm -f deployment-info.json

echo "✨ Cleanup completed! All AWS resources have been removed."
