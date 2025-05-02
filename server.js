// Simple Express server to handle deployment requests
const express = require('express');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');
const app = express();
const port = 3000;

// Serve static files
app.use(express.static(__dirname));
app.use(express.json());

// Endpoint to handle deployment
app.post('/deploy', (req, res) => {
    console.log('Deployment requested');
    
    // Execute the deployment script
    exec('bash deploy.sh', (error, stdout, stderr) => {
        console.log('Deployment script output:', stdout);
        
        if (error) {
            console.error('Deployment error:', error);
            return res.status(500).json({
                success: false,
                message: `Deployment failed: ${error.message}`
            });
        }
        
        // Read the deployment info file
        try {
            const deploymentInfo = JSON.parse(
                fs.readFileSync(path.join(__dirname, 'deployment-info.json'), 'utf8')
            );
            
            res.json({
                success: true,
                ...deploymentInfo
            });
        } catch (readError) {
            console.error('Error reading deployment info:', readError);
            res.status(500).json({
                success: false,
                message: 'Deployment completed but could not read deployment information'
            });
        }
    });
});

// Start the server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
    console.log(`Open this URL in your browser to view the website`);
});
