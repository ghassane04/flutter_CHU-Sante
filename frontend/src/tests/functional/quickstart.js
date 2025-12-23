#!/usr/bin/env node

/**
 * Quick Start Script for Selenium E2E Tests
 * This script helps you set up and run tests quickly
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🚀 CHU Santé - Selenium E2E Tests Quick Start\n');

// Check if we're in the right directory
const packageJsonPath = path.join(process.cwd(), 'package.json');
if (!fs.existsSync(packageJsonPath)) {
    console.error('❌ Error: Run this script from the frontend directory');
    process.exit(1);
}

console.log('Step 1: Checking dependencies...');
try {
    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
    const hasSelenium = packageJson.devDependencies['selenium-webdriver'];
    const hasMocha = packageJson.devDependencies['mocha'];
    
    if (!hasSelenium || !hasMocha) {
        console.log('📦 Installing missing dependencies...');
        execSync('npm install', { stdio: 'inherit' });
    } else {
        console.log('✅ All dependencies installed');
    }
} catch (e) {
    console.error('❌ Error checking dependencies:', e.message);
    process.exit(1);
}

console.log('\nStep 2: Checking ChromeDriver...');
try {
    execSync('chromedriver --version', { stdio: 'pipe' });
    console.log('✅ ChromeDriver is installed');
} catch (e) {
    console.log('⚠️  ChromeDriver not found globally');
    console.log('💡 Installing ChromeDriver locally...');
    try {
        execSync('npm install chromedriver --save-dev', { stdio: 'inherit' });
        console.log('✅ ChromeDriver installed');
    } catch (installError) {
        console.error('❌ Failed to install ChromeDriver');
        console.log('\n📖 Manual installation:');
        console.log('   npm install -g chromedriver');
        console.log('   or download from: https://chromedriver.chromium.org/');
    }
}

console.log('\n' + '='.repeat(60));
console.log('📋 Pre-flight Checklist:');
console.log('='.repeat(60));

console.log('\n1. Backend API:');
console.log('   ⏺️  Should be running on http://localhost:8080');
console.log('   ▶️  Start with: cd backend && mvn spring-boot:run');

console.log('\n2. Frontend Dev Server:');
console.log('   ⏺️  Should be running on http://localhost:5173');
console.log('   ▶️  Start with: npm run dev');

console.log('\n3. Chrome Browser:');
console.log('   ⏺️  Should be installed on your system');

console.log('\n' + '='.repeat(60));
console.log('🧪 Available Test Commands:');
console.log('='.repeat(60));
console.log('\n  npm run test:e2e              # Run all E2E tests');
console.log('  npm run test:e2e:login        # Test login functionality');
console.log('  npm run test:e2e:dashboard    # Test dashboard');
console.log('  npm run test:e2e:patients     # Test patients module');
console.log('  npm run test:e2e:sejours      # Test séjours module');

console.log('\n' + '='.repeat(60));
console.log('📚 Quick Tips:');
console.log('='.repeat(60));
console.log('\n  • Wait for both servers to fully start before running tests');
console.log('  • Check logs if tests fail (look for connection errors)');
console.log('  • Use screenshots/ folder to debug visual issues');
console.log('  • See README.md for detailed documentation');

console.log('\n✨ You\'re all set! Run your first test with:');
console.log('   npm run test:e2e:login\n');
