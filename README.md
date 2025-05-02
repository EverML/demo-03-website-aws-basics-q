# AWS Basics Demo Website

This project is a meta-style website that demonstrates common AWS use cases while being itself an example of those use cases. 

# AWS Basics Demo Website - Step-by-Step Guide

This document provides a series of prompts to build an interactive AWS demo website that teaches AWS concepts while being hosted on AWS itself.

## Project Setup

1. **Create the basic project structure**
   ```
   Create a new project for an educational AWS demo website that teaches AWS basics while being hosted on AWS itself. Set up the directory structure with folders for pages, css, js, and assets.
   ```

2. **Create the main HTML file**
   ```
   Create an index.html file with a responsive design that includes a navigation bar, hero section, feature cards for different AWS tutorials, and a footer. Use AWS-inspired colors (dark blue, orange accents).
   ```

3. **Create the main CSS file**
   ```
   Create a styles.css file with AWS-inspired design elements, including variables for colors, spacing, and border-radius. Include responsive styles for mobile devices.
   ```

4. **Create the JavaScript file**
   ```
   Create a main.js file with basic functionality for the website, including mobile navigation toggle.
   ```

## Static Website Tutorial Page

5. **Create the static website tutorial page**
   ```
   Create a detailed tutorial page called static-website.html that explains how to host a static website on AWS using S3 and CloudFront. Include step-by-step instructions with code snippets and visual aids.
   ```

6. **Add interactive cost calculator**
   ```
   Add an interactive cost calculator to the static website tutorial page that estimates monthly costs based on storage, visitors, page size, and pages per visit.
   ```

7. **Add AWS console simulations**
   ```
   Add simulated AWS console interfaces to the tutorial page to demonstrate S3 bucket creation, static website configuration, and CloudFront distribution setup.
   ```

## Deployment Functionality

8. **Create deployment script**
   ```
   Create a bash script called deploy.sh that uses the AWS CLI to deploy the website to S3 and CloudFront. The script should create a bucket with a unique name, configure it for static website hosting, upload files, and create a CloudFront distribution.
   ```

9. **Create destruction script**
   ```
   Create a bash script called destroy.sh that cleans up all AWS resources created by the deployment script, including disabling and deleting the CloudFront distribution and emptying and deleting the S3 bucket.
   ```

10. **Create server for local development**
    ```
    Create a simple Express server (server.js) that serves the static files locally and provides endpoints for deployment and destruction operations.
    ```

11. **Create package.json**
    ```
    Create a package.json file with dependencies and scripts for running the local server and deploying the website.
    ```

12. **Create deployment page**
    ```
    Create a deploy-me.html page with a user interface for deploying the website to AWS and destroying it when done. Include buttons for deployment and destruction, and a status display area.
    ```

13. **Create deployment JavaScript**
    ```
    Create a deploy.js file that handles the deployment and destruction button clicks, sends requests to the server, and updates the UI with the results.
    ```

14. **Create deployment CSS**
    ```
    Create a deploy.css file with styles for the deployment interface, including buttons, status displays, and responsive design.
    ```

## Final Touches

15. **Update navigation**
    ```
    Update all navigation menus to include links to the home page, static website tutorial, EC2 tutorial (placeholder), and deploy-me page.
    ```

16. **Create README**
    ```
    Create a comprehensive README.md file that explains the project, its features, how to run it locally, and how to deploy it to AWS.
    ```

17. **Create .gitignore**
    ```
    Create a .gitignore file to exclude node_modules, deployment information, and other unnecessary files from version control.
    ```

## Running the Project

18. **Install dependencies**
    ```
    Run npm install to install the Express dependency.
    ```

19. **Start the local server**
    ```
    Run npm start to start the local server and open the website in a browser.
    ```

20. **Deploy the website**
    ```
    Navigate to the Deploy Me page and click the Deploy to AWS button to deploy the website to your AWS account using the "ever" profile.
    ```

21. **Clean up resources**
    ```
    When finished, click the Destroy Site button to remove all AWS resources created for the website.
    ```

## Key Features of the Final Project

- Interactive tutorials on AWS services
- Step-by-step guides with code snippets
- Cost estimation calculators
- AWS console simulations
- One-click deployment to AWS
- One-click cleanup of AWS resources
- Responsive design for all device sizes
- AWS-inspired visual design

This demo website serves as both an educational tool for learning AWS basics and a practical example of hosting a static website on AWS using S3 and CloudFront.


