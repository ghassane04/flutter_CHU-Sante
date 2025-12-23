/**
 * Script to run all Selenium tests
 * Run with: node src/tests/functional/run-all-tests.js
 */

const { spawn } = require('child_process');
const path = require('path');

const testFiles = [
    'smoke.test.js',        // Basic setup verification
    'login.test.js',
    'dashboard.test.js',
    'navigation.test.js',
    'patients.test.js',
    'sejours.test.js',
    'actes.test.js',
    'services.test.js'
];

console.log('🚀 Starting Selenium Test Suite\n');
console.log('Prerequisites:');
console.log('  1. Frontend dev server running on http://localhost:5173');
console.log('  2. Backend API running on http://localhost:8080');
console.log('  3. Chrome browser installed');
console.log('  4. ChromeDriver installed\n');

let currentTest = 0;

function runNextTest() {
    if (currentTest >= testFiles.length) {
        console.log('\n✅ All tests completed!');
        return;
    }

    const testFile = testFiles[currentTest];
    console.log(`\n${'='.repeat(60)}`);
    console.log(`Running: ${testFile}`);
    console.log('='.repeat(60));

    const testPath = path.join(__dirname, testFile);
    const mocha = spawn('npx', ['mocha', testPath], {
        stdio: 'inherit',
        shell: true
    });

    mocha.on('close', (code) => {
        if (code !== 0) {
            console.log(`⚠️  ${testFile} finished with code ${code}`);
        }
        currentTest++;
        runNextTest();
    });
}

// Check if mocha is available
const checkMocha = spawn('npx', ['mocha', '--version'], { shell: true });

checkMocha.on('close', (code) => {
    if (code !== 0) {
        console.error('❌ Mocha not found. Installing...');
        const install = spawn('npm', ['install', '--save-dev', 'mocha'], {
            stdio: 'inherit',
            shell: true
        });
        install.on('close', () => {
            runNextTest();
        });
    } else {
        runNextTest();
    }
});
