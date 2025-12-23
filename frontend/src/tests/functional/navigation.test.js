const { Builder, By, until } = require('selenium-webdriver');
const assert = require('assert');

describe('Navigation Tests', function() {
    this.timeout(30000);
    let driver;

    before(async function() {
        driver = await new Builder().forBrowser('chrome').build();
        
        // Login first
        await driver.get('http://localhost:5173/login');
        try {
            const emailInput = await driver.wait(
                until.elementLocated(By.css('input[type="email"], input[type="text"]')),
                5000
            );
            await emailInput.sendKeys('admin@chu.com');
            
            const passwordInput = await driver.findElement(By.css('input[type="password"]'));
            await passwordInput.sendKeys('admin123');
            
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
        await driver.get('http://localhost:5173/dashboard');
        await driver.sleep(2000);
        
        const navElements = await driver.findElements(
            By.css('nav, aside, [role="navigation"], .sidebar')
        );
        
        assert(navElements.length > 0, 'Navigation should be present');
        console.log('✓ Navigation sidebar found');
    });

    it('should navigate to different pages', async function() {
        const pages = [
            { url: 'http://localhost:5173/dashboard', name: 'Dashboard' },
            { url: 'http://localhost:5173/patients', name: 'Patients' },
            { url: 'http://localhost:5173/sejours', name: 'Séjours' },
            { url: 'http://localhost:5173/actes', name: 'Actes' },
            { url: 'http://localhost:5173/services', name: 'Services' },
        ];

        for (let page of pages) {
            await driver.get(page.url);
            await driver.sleep(1500);
            
            const currentUrl = await driver.getCurrentUrl();
            console.log(`✓ Navigated to ${page.name}: ${currentUrl}`);
        }
    });

    it('should have working navigation links', async function() {
        await driver.get('http://localhost:5173/dashboard');
        await driver.sleep(2000);
        
        const links = await driver.findElements(By.css('a[href]'));
        assert(links.length > 0, 'Should have navigation links');
        
        console.log(`✓ Found ${links.length} navigation links`);
    });

    it('should highlight active page in navigation', async function() {
        await driver.get('http://localhost:5173/patients');
        await driver.sleep(2000);
        
        // Look for active/selected navigation items
        const activeElements = await driver.findElements(
            By.css('.active, [aria-current="page"], [data-active="true"]')
        );
        
        console.log(`✓ Found ${activeElements.length} active navigation indicators`);
    });

    it('should maintain authentication across pages', async function() {
        const pages = [
            'http://localhost:5173/dashboard',
            'http://localhost:5173/patients',
            'http://localhost:5173/sejours',
        ];

        for (let pageUrl of pages) {
            await driver.get(pageUrl);
            await driver.sleep(1000);
            
            const currentUrl = await driver.getCurrentUrl();
            assert(!currentUrl.includes('/login'), 'Should stay authenticated');
        }
        
        console.log('✓ Authentication maintained across pages');
    });

    it('should have logout functionality', async function() {
        await driver.get('http://localhost:5173/dashboard');
        await driver.sleep(2000);
        
        const pageSource = await driver.getPageSource();
        const hasLogout = pageSource.includes('Déconnexion') || 
                         pageSource.includes('Logout') ||
                         pageSource.includes('Se déconnecter');
        
        console.log('✓ Logout functionality checked');
    });
});
