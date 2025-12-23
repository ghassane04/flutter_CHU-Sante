#!/usr/bin/env node

/**
 * Environment Check Script
 * Verifies that all prerequisites are met before running tests
 */

const { execSync } = require('child_process');
const http = require('http');
const https = require('https');

console.log('🔍 CHU Santé - Environment Check for E2E Tests\n');

let allGood = true;

// Check 1: Node.js version
console.log('1. Checking Node.js version...');
try {
    const nodeVersion = process.version;
    const majorVersion = parseInt(nodeVersion.split('.')[0].slice(1));
    if (majorVersion >= 16) {
        console.log(`   ✅ Node.js ${nodeVersion} (OK)`);
    } else {
        console.log(`   ⚠️  Node.js ${nodeVersion} (Recommended: v16+)`);
    }
} catch (e) {
    console.log('   ❌ Could not check Node.js version');
    allGood = false;
}

// Check 2: npm
console.log('\n2. Checking npm...');
try {
    const npmVersion = execSync('npm --version', { encoding: 'utf-8' }).trim();
    console.log(`   ✅ npm ${npmVersion}`);
} catch (e) {
    console.log('   ❌ npm not found');
    allGood = false;
}

// Check 3: Chrome
console.log('\n3. Checking Chrome browser...');
try {
    const chromeCommand = process.platform === 'win32' 
        ? '"C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe" --version'
        : 'google-chrome --version || chromium --version';
    
    const chromeVersion = execSync(chromeCommand, { encoding: 'utf-8', stdio: 'pipe' }).trim();
    console.log(`   ✅ ${chromeVersion}`);
} catch (e) {
    console.log('   ⚠️  Chrome not found or not in PATH');
    console.log('      Please install Chrome: https://www.google.com/chrome/');
}

// Check 4: ChromeDriver
console.log('\n4. Checking ChromeDriver...');
try {
    const chromeDriverVersion = execSync('chromedriver --version', { encoding: 'utf-8', stdio: 'pipe' }).trim();
    console.log(`   ✅ ${chromeDriverVersion}`);
} catch (e) {
    console.log('   ⚠️  ChromeDriver not found globally');
    console.log('      Will try to use local installation');
    
    // Check if it's installed locally
    try {
        const fs = require('fs');
        const path = require('path');
        const localDriver = path.join(process.cwd(), 'node_modules', '.bin', 'chromedriver');
        if (fs.existsSync(localDriver) || fs.existsSync(localDriver + '.cmd')) {
            console.log('   ✅ ChromeDriver found locally in node_modules');
        } else {
            console.log('   ⚠️  Install with: npm install --save-dev chromedriver');
        }
    } catch (err) {
        console.log('   ❌ ChromeDriver not available');
        allGood = false;
    }
}

// Check 5: Dependencies
console.log('\n5. Checking npm dependencies...');
try {
    const fs = require('fs');
    const path = require('path');
    const packageJsonPath = path.join(process.cwd(), 'package.json');
    
    if (!fs.existsSync(packageJsonPath)) {
        console.log('   ⚠️  package.json not found');
        console.log('      Are you in the frontend directory?');
        allGood = false;
    } else {
        const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
        const requiredDeps = ['selenium-webdriver', 'mocha'];
        const missing = [];
        
        for (const dep of requiredDeps) {
            if (!packageJson.devDependencies || !packageJson.devDependencies[dep]) {
                missing.push(dep);
            }
        }
        
        if (missing.length > 0) {
            console.log(`   ⚠️  Missing dependencies: ${missing.join(', ')}`);
            console.log('      Run: npm install');
            allGood = false;
        } else {
            console.log('   ✅ All required dependencies present');
            
            // Check if node_modules exists
            const nodeModulesPath = path.join(process.cwd(), 'node_modules');
            if (!fs.existsSync(nodeModulesPath)) {
                console.log('   ⚠️  node_modules not found');
                console.log('      Run: npm install');
                allGood = false;
            }
        }
    }
} catch (e) {
    console.log('   ❌ Error checking dependencies:', e.message);
    allGood = false;
}

// Check 6: Frontend dev server
console.log('\n6. Checking frontend dev server...');
checkUrl('http://localhost:5173', 'Frontend (Vite)')
    .then(result => {
        if (result) {
            console.log('   ✅ Frontend is running on http://localhost:5173');
        } else {
            console.log('   ❌ Frontend not accessible');
            console.log('      Start with: npm run dev');
            allGood = false;
        }
        
        // Check 7: Backend API
        console.log('\n7. Checking backend API...');
        return checkUrl('http://localhost:8080', 'Backend API');
    })
    .then(result => {
        if (result) {
            console.log('   ✅ Backend is running on http://localhost:8080');
        } else {
            console.log('   ❌ Backend not accessible');
            console.log('      Start with: cd backend && mvn spring-boot:run');
            allGood = false;
        }
        
        // Final summary
        console.log('\n' + '='.repeat(60));
        if (allGood) {
            console.log('✅ Environment Check PASSED');
            console.log('   You can run tests with: npm run test:e2e');
        } else {
            console.log('⚠️  Environment Check completed with warnings');
            console.log('   Please fix the issues above before running tests');
        }
        console.log('='.repeat(60) + '\n');
    });

/**
 * Check if URL is accessible
 */
function checkUrl(url, name) {
    return new Promise((resolve) => {
        const protocol = url.startsWith('https') ? https : http;
        const req = protocol.get(url, { timeout: 3000 }, (res) => {
            resolve(true);
        });
        
        req.on('error', () => {
            resolve(false);
        });
        
        req.on('timeout', () => {
            req.destroy();
            resolve(false);
        });
    });
}
