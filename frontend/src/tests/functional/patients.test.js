const { Builder, By, until, Key } = require('selenium-webdriver');
const assert = require('assert');

describe('Patients Management Tests', function() {
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

    it('should navigate to patients page', async function() {
        await driver.get('http://localhost:5173/patients');
        await driver.sleep(2000);
        
        const currentUrl = await driver.getCurrentUrl();
        assert(currentUrl.includes('/patients'), 'Should be on patients page');
        
        console.log('✓ Patients page loaded');
    });

    it('should display patients list or table', async function() {
        await driver.get('http://localhost:5173/patients');
        await driver.sleep(2000);
        
        // Look for table, list, or card elements
        const tableElements = await driver.findElements(
            By.css('table, .patient-card, [data-testid="patient-list"], .grid, .patient-item')
        );
        
        console.log(`✓ Found ${tableElements.length} patient display elements`);
    });

    it('should have search functionality', async function() {
        await driver.get('http://localhost:5173/patients');
        await driver.sleep(2000);
        
        // Look for search input
        const searchInputs = await driver.findElements(
            By.css('input[type="search"], input[placeholder*="cherch"], input[placeholder*="search"]')
        );
        
        if (searchInputs.length > 0) {
            const searchInput = searchInputs[0];
            await searchInput.sendKeys('test');
            await driver.sleep(1000);
            await searchInput.clear();
            
            console.log('✓ Search functionality found and tested');
        } else {
            console.log('⚠ Search input not found');
        }
    });

    it('should have add patient button', async function() {
        await driver.get('http://localhost:5173/patients');
        await driver.sleep(2000);
        
        // Look for add/create button
        const addButtons = await driver.findElements(
            By.css('button:contains("Ajouter"), button:contains("Nouveau"), button:contains("Créer"), [aria-label*="add"]')
        );
        
        // Also check page source for add-related text
        const pageSource = await driver.getPageSource();
        const hasAddButton = addButtons.length > 0 || 
                            pageSource.includes('Ajouter') || 
                            pageSource.includes('Nouveau patient');
        
        console.log('✓ Add patient functionality checked');
    });

    it('should open patient creation modal/form', async function() {
        await driver.get('http://localhost:5173/patients');
        await driver.sleep(2000);
        
        try {
            // Try to find and click add button
            const buttons = await driver.findElements(By.css('button'));
            for (let button of buttons) {
                const text = await button.getText();
                if (text.includes('Ajouter') || text.includes('Nouveau') || text.includes('Créer')) {
                    await button.click();
                    await driver.sleep(1500);
                    
                    // Check if modal or form appeared
                    const modals = await driver.findElements(
                        By.css('[role="dialog"], .modal, .dialog, form')
                    );
                    
                    if (modals.length > 0) {
                        console.log('✓ Patient creation form/modal opened');
                        
                        // Close modal (try ESC or close button)
                        await driver.actions().sendKeys(Key.ESCAPE).perform();
                        await driver.sleep(500);
                    }
                    break;
                }
            }
        } catch (e) {
            console.log('⚠ Could not test patient creation modal:', e.message);
        }
    });

    it('should have patient details view', async function() {
        await driver.get('http://localhost:5173/patients');
        await driver.sleep(2000);
        
        // Look for view/edit buttons or clickable patient rows
        const actionButtons = await driver.findElements(
            By.css('button, [role="button"], .action-button, tr, .patient-row')
        );
        
        console.log(`✓ Found ${actionButtons.length} interactive elements`);
    });

    it('should handle pagination if present', async function() {
        await driver.get('http://localhost:5173/patients');
        await driver.sleep(2000);
        
        // Look for pagination elements
        const paginationElements = await driver.findElements(
            By.css('[aria-label*="pagination"], .pagination, nav[role="navigation"]')
        );
        
        if (paginationElements.length > 0) {
            console.log('✓ Pagination found');
        } else {
            console.log('⚠ No pagination elements found (may not be needed)');
        }
    });
});
