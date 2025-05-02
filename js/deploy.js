// Deployment functionality for AWS Basics Demo Website

// Function to execute the deployment script
async function deployWebsite() {
    const deployButton = document.getElementById('deploy-button');
    const deployStatus = document.getElementById('deploy-status');
    
    if (!deployButton || !deployStatus) {
        console.error('Deploy button or status element not found');
        return;
    }
    
    // Update UI to show deployment in progress
    deployButton.disabled = true;
    deployButton.textContent = 'Deploying...';
    deployStatus.innerHTML = '<p class="status-info">⏳ Deployment in progress. This may take a few minutes...</p>';
    
    try {
        // Execute the deployment script
        const response = await fetch('/deploy', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ action: 'deploy' }),
        });
        
        if (!response.ok) {
            throw new Error(`Deployment failed with status: ${response.status}`);
        }
        
        const result = await response.json();
        
        if (result.success) {
            deployStatus.innerHTML = `
                <p class="status-success">✅ Deployment successful!</p>
                <p>Your website is now available at:</p>
                <a href="https://${result.domainName}" target="_blank" class="website-url">https://${result.domainName}</a>
                <p class="deployment-details">
                    <strong>Bucket:</strong> ${result.bucketName}<br>
                    <strong>Region:</strong> ${result.region}<br>
                    <strong>Distribution ID:</strong> ${result.distributionId}
                </p>
            `;
        } else {
            throw new Error(result.message || 'Unknown deployment error');
        }
    } catch (error) {
        console.error('Deployment error:', error);
        deployStatus.innerHTML = `
            <p class="status-error">❌ Deployment failed: ${error.message}</p>
            <p>Please check the console for more details or try again later.</p>
        `;
    } finally {
        // Reset button state
        deployButton.disabled = false;
        deployButton.textContent = 'Deploy to AWS';
    }
}

// Initialize deployment functionality
function initDeployment() {
    const deployButton = document.getElementById('deploy-button');
    if (deployButton) {
        deployButton.addEventListener('click', deployWebsite);
    }
}

// Add event listener for when the DOM is fully loaded
document.addEventListener('DOMContentLoaded', initDeployment);
