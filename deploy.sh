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

# Create S3 bucket
echo "📦 Creating S3 bucket..."
if aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION --profile $PROFILE; then
    echo "✅ S3 bucket created successfully."
else
    echo "❌ Failed to create S3 bucket. Exiting."
    exit 1
fi

# Enable static website hosting
echo "🌐 Configuring bucket for static website hosting..."
aws s3 website s3://$BUCKET_NAME --index-document index.html --error-document error.html --profile $PROFILE

# Set bucket policy for public read access
echo "🔒 Setting bucket policy for public read access..."
POLICY='{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::'$BUCKET_NAME'/*"
        }
    ]
}'

aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy "$POLICY" --profile $PROFILE

# Upload website files
echo "📤 Uploading website files..."
aws s3 sync $WEBSITE_DIR s3://$BUCKET_NAME --exclude "*.sh" --exclude ".git/*" --exclude "*.md" --exclude "deploy.sh" --profile $PROFILE

# Create CloudFront distribution
echo "☁️ Creating CloudFront distribution..."
DISTRIBUTION_CONFIG='{
    "CallerReference": "'$BUCKET_NAME'",
    "DefaultRootObject": "index.html",
    "Origins": {
        "Quantity": 1,
        "Items": [
            {
                "Id": "S3-'$BUCKET_NAME'",
                "DomainName": "'$BUCKET_NAME'.s3-website-'$REGION'.amazonaws.com",
                "CustomOriginConfig": {
                    "HTTPPort": 80,
                    "HTTPSPort": 443,
                    "OriginProtocolPolicy": "http-only",
                    "OriginSslProtocols": {
                        "Quantity": 1,
                        "Items": ["TLSv1.2"]
                    },
                    "OriginReadTimeout": 30,
                    "OriginKeepaliveTimeout": 5
                }
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

if [ -n "$DISTRIBUTION_ID" ]; then
    DOMAIN_NAME=$(aws cloudfront get-distribution --id $DISTRIBUTION_ID --profile $PROFILE --query "Distribution.DomainName" --output text)
    echo "✅ CloudFront distribution created successfully."
    echo "🌎 Website URL: https://$DOMAIN_NAME"
    
    # Save deployment info to a file
    echo "{\"bucketName\":\"$BUCKET_NAME\",\"region\":\"$REGION\",\"distributionId\":\"$DISTRIBUTION_ID\",\"domainName\":\"$DOMAIN_NAME\"}" > deployment-info.json
    echo "📝 Deployment information saved to deployment-info.json"
else
    echo "❌ Failed to create CloudFront distribution."
    echo "🌎 Website is still accessible via S3 website endpoint: http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
fi

echo "✨ Deployment completed!"
