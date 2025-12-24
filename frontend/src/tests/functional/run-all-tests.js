/**
 * Script to run all Selenium tests using npm scripts
 * Run with: node src/tests/functional/run-all-tests.js
 */

const { spawn } = require('child_process');

const testCommands = [
    { name: 'Smoke Tests', script: 'test:e2e:smoke' },
    { name: 'Login Tests', script: 'test:e2e:login' },
    { name: 'Register Tests', script: 'test:e2e:register' },
    { name: 'Dashboard Tests', script: 'test:e2e:dashboard' },
    { name: 'Navigation Tests', script: 'test:e2e:navigation' },
    { name: 'Patients Tests', script: 'test:e2e:patients' },
    { name: 'Médecins Tests', script: 'test:e2e:medecins' },
    { name: 'Sejours Tests', script: 'test:e2e:sejours' },
    { name: 'Actes Tests', script: 'test:e2e:actes' },
    { name: 'Services Tests', script: 'test:e2e:services' }
];

console.log('🚀 Starting Selenium Test Suite\n');
console.log('Prerequisites:');
console.log('  1. Frontend dev server running on http://localhost:5173');
console.log('  2. Backend API running on http://localhost:8080');
console.log('  3. Chrome browser installed');
console.log('  4. ChromeDriver installed\n');

let currentTest = 0;
let totalPassed = 0;
let totalFailed = 0;

function runNextTest() {
    if (currentTest >= testCommands.length) {
        console.log('\n' + '='.repeat(60));
        console.log('📊 Test Summary');
        console.log('='.repeat(60));
        console.log(`Total suites: ${testCommands.length}`);
        console.log(`✅ Passed: ${totalPassed}`);
        console.log(`❌ Failed: ${totalFailed}`);
        console.log('='.repeat(60));
        return;
    }

    const test = testCommands[currentTest];
    console.log(`\n${'='.repeat(60)}`);
    console.log(`Running: ${test.name}`);
    console.log('='.repeat(60));

    const npm = spawn('npm', ['run', test.script], {
        stdio: 'inherit',
        shell: true
    });

    npm.on('close', (code) => {
        if (code === 0) {
            console.log(`✅ ${test.name} passed`);
            totalPassed++;
        } else {
            console.log(`❌ ${test.name} failed with code ${code}`);
            totalFailed++;
        }
        currentTest++;
        runNextTest();
    });

    npm.on('error', (err) => {
        console.error(`Error running ${test.name}:`, err.message);
        totalFailed++;
        currentTest++;
        runNextTest();
    });
}

runNextTest();
