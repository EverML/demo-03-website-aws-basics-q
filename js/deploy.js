// Deployment functionality for AWS Basics Demo Website

// Function to execute the deployment script
async function deployWebsite() {
    const deployButton = document.getElementById('deploy-button');
    const destroyButton = document.getElementById('destroy-button');
    const deployStatus = document.getElementById('deploy-status');
    
    if (!deployButton || !deployStatus) {
        console.error('Deploy button or status element not found');
        return;
    }
    
    // Update UI to show deployment in progress
    deployButton.disabled = true;
    if (destroyButton) destroyButton.disabled = true;
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
            
            // Enable destroy button if it exists
            if (destroyButton) {
                destroyButton.disabled = false;
                destroyButton.classList.remove('hidden');
            }
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

// Function to execute the destroy script
async function destroyWebsite() {
    const deployButton = document.getElementById('deploy-button');
    const destroyButton = document.getElementById('destroy-button');
    const deployStatus = document.getElementById('deploy-status');
    
    if (!destroyButton || !deployStatus) {
        console.error('Destroy button or status element not found');
        return;
    }
    
    // Confirm before destroying
    if (!confirm('Are you sure you want to destroy all AWS resources created for this website? This action cannot be undone.')) {
        return;
    }
    
    // Update UI to show destruction in progress
    destroyButton.disabled = true;
    if (deployButton) deployButton.disabled = true;
    destroyButton.textContent = 'Destroying...';
    deployStatus.innerHTML = '<p class="status-info">⏳ Cleanup in progress. This may take a few minutes...</p>';
    
    try {
        // Execute the destroy script
        const response = await fetch('/destroy', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ action: 'destroy' }),
        });
        
        if (!response.ok) {
            throw new Error(`Cleanup failed with status: ${response.status}`);
        }
        
        const result = await response.json();
        
        if (result.success) {
            deployStatus.innerHTML = `
                <p class="status-success">✅ Cleanup successful!</p>
                <p>All AWS resources have been removed.</p>
            `;
            
            // Hide destroy button
            destroyButton.classList.add('hidden');
        } else {
            throw new Error(result.message || 'Unknown cleanup error');
        }
    } catch (error) {
        console.error('Cleanup error:', error);
        deployStatus.innerHTML = `
            <p class="status-error">❌ Cleanup failed: ${error.message}</p>
            <p>Please check the console for more details or try again later.</p>
        `;
    } finally {
        // Reset button state
        destroyButton.disabled = false;
        destroyButton.textContent = 'Destroy Site';
        if (deployButton) deployButton.disabled = false;
    }
}

// Check if deployment exists
async function checkDeployment() {
    const destroyButton = document.getElementById('destroy-button');
    if (!destroyButton) return;
    
    try {
        const response = await fetch('/check-deployment');
        const result = await response.json();
        
        if (result.deployed) {
            destroyButton.classList.remove('hidden');
            
            // Update status with existing deployment info
            const deployStatus = document.getElementById('deploy-status');
            if (deployStatus) {
                deployStatus.innerHTML = `
                    <p class="status-success">✅ Website is currently deployed!</p>
                    <p>Your website is available at:</p>
                    <a href="https://${result.domainName}" target="_blank" class="website-url">https://${result.domainName}</a>
                    <p class="deployment-details">
                        <strong>Bucket:</strong> ${result.bucketName}<br>
                        <strong>Region:</strong> ${result.region}<br>
                        <strong>Distribution ID:</strong> ${result.distributionId}
                    </p>
                `;
            }
        } else {
            destroyButton.classList.add('hidden');
        }
    } catch (error) {
        console.error('Error checking deployment:', error);
        destroyButton.classList.add('hidden');
    }
}

// Initialize deployment functionality
function initDeployment() {
    const deployButton = document.getElementById('deploy-button');
    const destroyButton = document.getElementById('destroy-button');
    
    if (deployButton) {
        deployButton.addEventListener('click', deployWebsite);
    }
    
    if (destroyButton) {
        destroyButton.addEventListener('click', destroyWebsite);
        destroyButton.classList.add('hidden'); // Hide by default until we check
    }
    
    // Check if there's an existing deployment
    checkDeployment();
}

// Add event listener for when the DOM is fully loaded
document.addEventListener('DOMContentLoaded', initDeployment);
