# AWS Basics Demo Website

This project is a meta-style website that demonstrates common AWS use cases while being itself an example of those use cases. The website is interactive, educational, and visually appealing, focusing initially on:

1. Deploying Static Websites on AWS
2. Launching EC2 Instances

## Features

- Interactive tutorials with step-by-step guides
- Visual demonstrations of AWS services
- Code snippets and examples
- Cost estimation calculators
- Self-deployment functionality

## Project Structure

- `index.html` - Main landing page
- `pages/` - Tutorial and demonstration pages
  - `static-website.html` - Tutorial for hosting static websites on AWS
  - `ec2-instance.html` - Tutorial for launching EC2 instances
  - `deploy-me.html` - Page to deploy this website to your own AWS account
- `css/` - Stylesheets
- `js/` - JavaScript files
- `assets/` - Images and other static assets
- `docs/` - Project documentation
- `deploy.sh` - Deployment script for AWS

## Getting Started

### Prerequisites

- Node.js and npm
- AWS CLI installed and configured with an "ever" profile
- Appropriate AWS permissions to create S3 buckets and CloudFront distributions

### Running Locally

1. Clone this repository
2. Install dependencies:
   ```
   npm install
   ```
3. Start the local server:
   ```
   npm start
   ```
4. Open your browser and navigate to `http://localhost:3000`

### Deploying to AWS

You can deploy this website to your AWS account in two ways:

1. **Using the web interface:**
   - Navigate to the "Deploy Me" page in the running application
   - Click the "Deploy to AWS" button
   - Wait for the deployment to complete

2. **Using the command line:**
   ```
   npm run deploy
   ```

The deployment script will:
- Create an S3 bucket with a unique name
- Configure it for static website hosting
- Upload all website files
- Create a CloudFront distribution
- Provide you with the URL to access your deployed site

## Development

### Adding New Tutorials

1. Create a new HTML file in the `pages/` directory
2. Follow the structure of existing tutorial pages
3. Add a link to the new page in the navigation menu

### Modifying Styles

The project uses a custom CSS framework with AWS-inspired design elements. The main styles are in `css/styles.css`.

## Project Status

- ✅ Static Website Hosting Tutorial (70% complete)
- ⏳ EC2 Instance Tutorial (Pending)
- ✅ Deployment Functionality

## License

This project is for educational purposes only. Amazon Web Services and AWS are trademarks of Amazon.com, Inc. This site is not affiliated with Amazon Web Services.
