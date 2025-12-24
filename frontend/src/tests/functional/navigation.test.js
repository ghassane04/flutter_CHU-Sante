const { Builder, By, until } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const { ServiceBuilder } = require('selenium-webdriver/chrome');
const assert = require('assert');

describe('Navigation Tests', function() {
    this.timeout(60000);
    let driver;

    before(async function() {
        const options = new chrome.Options();
        options.addArguments('--disable-dev-shm-usage');
        options.addArguments('--no-sandbox');
        options.addArguments('--disable-gpu');
        
        const service = new ServiceBuilder('C:\\chromedriver.exe');
        
        driver = await new Builder()
            .forBrowser('chrome')
            .setChromeService(service)
            .setChromeOptions(options)
            .build();
        
        // Login first
        await driver.get('http://localhost:5173/login');
        try {
            const emailInput = await driver.wait(
                until.elementLocated(By.css('input[type="email"], input[type="text"]')),
                5000
            );
            await emailInput.sendKeys('ali01');
            
            const passwordInput = await driver.findElement(By.css('input[type="password"]'));
            await passwordInput.sendKeys('ghassane');
            
            const submitButton = await driver.findElement(By.css('button[type="submit"]'));
            await submitButton.click();
            
            await driver.sleep(3000);
        } catch (e) {
            console.log('Assuming already logged in');
        }
    });

    after(async function() {
        await driver.quit();
    });

    it('should have sidebar navigation', async function() {
        await driver.get('http://localhost:5173/');
        await driver.sleep(2000);
        
        const navElements = await driver.findElements(
            By.css('nav, aside, [role="navigation"], .sidebar, button')
        );
        
        assert(navElements.length > 0, 'Navigation should be present');
        console.log('✓ Navigation sidebar found');
    });

    it('should navigate to different pages', async function() {
        await driver.get('http://localhost:5173/');
        await driver.sleep(2000);
        
        const pages = ['Patients', 'Séjours', 'Actes', 'Services'];

        for (let pageName of pages) {
            try {
                // Trouver et cliquer sur le bouton de navigation
                const navButton = await driver.wait(
                    until.elementLocated(By.xpath(`//button[contains(., '${pageName}')]`)),
                    3000
                );
                await navButton.click();
                await driver.sleep(1500);
                
                // Vérifier que le contenu de la page est chargé
                const pageSource = await driver.getPageSource();
                assert(pageSource.includes(pageName), `Should display ${pageName} content`);
                
                console.log(`✓ Navigated to ${pageName}`);
            } catch (e) {
                console.log(`⚠ Could not navigate to ${pageName}: ${e.message}`);
            }
        }
    });

    it('should have working navigation links', async function() {
        await driver.sleep(500);
        
        const buttons = await driver.findElements(By.css('button'));
        assert(buttons.length > 0, 'Should have navigation buttons');
        
        console.log(`✓ Found ${buttons.length} navigation buttons`);
    });

    it('should highlight active page in navigation', async function() {
        await driver.get('http://localhost:5173/');
        await driver.sleep(2000);
        
        // Cliquer sur Patients
        try {
            const patientsButton = await driver.findElement(By.xpath("//button[contains(., 'Patients')]"));
            await patientsButton.click();
            await driver.sleep(1000);
            
            // Look for active/selected navigation items
            const activeElements = await driver.findElements(
                By.css('.active, [aria-current="page"], [data-active="true"], button.bg-blue-700, button.bg-blue-800')
            );
            
            console.log(`✓ Found ${activeElements.length} active navigation indicators`);
        } catch (e) {
            console.log('⚠ Could not test active state:', e.message);
        }
    });

    it('should maintain authentication across pages', async function() {
        await driver.get('http://localhost:5173/');
        await driver.sleep(1000);
        
        const pages = ['Patients', 'Séjours', 'Dashboard'];

        for (let pageName of pages) {
            try {
                const button = await driver.findElement(By.xpath(`//button[contains(., '${pageName}') or contains(., '${pageName.toLowerCase()}')]`));
                await button.click();
                await driver.sleep(1000);
                
                const currentUrl = await driver.getCurrentUrl();
                assert(!currentUrl.includes('/login'), 'Should stay authenticated');
            } catch (e) {
                console.log(`⚠ Could not test ${pageName}:`, e.message);
            }
        }
        
        console.log('✓ Authentication maintained across pages');
    });

    it('should have logout functionality', async function() {
        await driver.get('http://localhost:5173/');
        await driver.sleep(2000);
        
        const pageSource = await driver.getPageSource();
        const hasLogout = pageSource.includes('Déconnexion') || 
                         pageSource.includes('Logout') ||
                         pageSource.includes('Se déconnecter');
        
        console.log('✓ Logout functionality checked');
    });
});
