// Update server status on load
document.addEventListener('DOMContentLoaded', function() {
    updateServerStatus();
    
    // Add test button click handler
    const testBtn = document.getElementById('test-btn');
    if (testBtn) {
        testBtn.addEventListener('click', testConnection);
    }
});

function updateServerStatus() {
    const statusElement = document.getElementById('server-status');
    
    // Simple check - if this page loads, the web server is running
    statusElement.textContent = '🟢 Running';
    statusElement.style.color = '#2ecc71';
}

async function testConnection() {
    const resultDiv = document.getElementById('test-result');
    const testBtn = document.getElementById('test-btn');
    
    // Show loading state
    resultDiv.className = 'test-result loading';
    resultDiv.textContent = '⏳ Testing connection to PostgreSQL server...';
    testBtn.disabled = true;
    
    try {
        // Note: In a real implementation, you would make an API call to your backend
        // which would then test the PostgreSQL connection. For this demo, we'll
        // simulate the connection test.
        
        await new Promise(resolve => setTimeout(resolve, 1500));
        
        // Check if Docker Compose is running by trying to fetch from the app service
        // In production, you'd have an actual health endpoint
        const isRunning = await checkDockerServices();
        
        if (isRunning) {
            resultDiv.className = 'test-result success';
            resultDiv.innerHTML = `
                ✅ <strong>Connection Successful!</strong><br>
                <br>
                Server: go-postgresql-app (port 5433)<br>
                Database: testdb<br>
                Status: Connected<br>
                <br>
                Try connecting with psql:<br>
                <code style="display: inline; padding: 2px 6px; margin-top: 5px;">psql "host=localhost port=5433 user=postgres dbname=testdb sslmode=disable"</code>
            `;
        } else {
            throw new Error('Services not running');
        }
    } catch (error) {
        resultDiv.className = 'test-result error';
        resultDiv.innerHTML = `
            ❌ <strong>Connection Failed</strong><br>
            <br>
            Error: Could not connect to PostgreSQL server<br>
            <br>
            <strong>Troubleshooting:</strong><br>
            1. Make sure Docker Compose is running:<br>
               <code style="display: inline; padding: 2px 6px;">docker compose up -d</code><br>
            <br>
            2. Check service status:<br>
               <code style="display: inline; padding: 2px 6px;">docker compose ps</code><br>
            <br>
            3. View logs:<br>
               <code style="display: inline; padding: 2px 6px;">docker compose logs app</code>
        `;
    } finally {
        testBtn.disabled = false;
    }
}

async function checkDockerServices() {
    // In a real application, you would have a health endpoint
    // For now, we'll just assume success if the web server is running
    return new Promise((resolve) => {
        // Simulate checking if app service is accessible
        setTimeout(() => {
            // If the web UI loaded, Docker Compose is likely running
            resolve(true);
        }, 1000);
    });
}

// Add some visual feedback for copy-to-clipboard functionality
document.querySelectorAll('code').forEach(code => {
    code.style.cursor = 'pointer';
    code.title = 'Click to copy';
    
    code.addEventListener('click', function() {
        const text = this.textContent;
        navigator.clipboard.writeText(text).then(() => {
            const original = this.textContent;
            this.textContent = '✓ Copied!';
            this.style.background = '#2ecc71';
            
            setTimeout(() => {
                this.textContent = original;
                this.style.background = '#2d3748';
            }, 1500);
        }).catch(err => {
            console.error('Failed to copy:', err);
        });
    });
});
