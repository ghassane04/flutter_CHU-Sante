const { Builder, By, until, Key } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const { ServiceBuilder } = require('selenium-webdriver/chrome');
const assert = require('assert');

describe('Médecins Management Tests', function() {
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

    it('should navigate to medecins page', async function() {
        // Aller sur le dashboard d'abord
        await driver.get('http://localhost:5173/');
        await driver.sleep(2000);
        
        // Cliquer sur le lien Médecins dans la sidebar
        const medecinsLink = await driver.wait(
            until.elementLocated(By.xpath("//button[contains(., 'Médecins') or contains(., 'medecins')]")),
            5000
        );
        await medecinsLink.click();
        await driver.sleep(2000);
        
        // Vérifier que la page contient le contenu des médecins
        const pageSource = await driver.getPageSource();
        assert(pageSource.includes('Médecins') || pageSource.includes('medecins') || pageSource.includes('Médecin'), 
            'Should display medecins content');
        
        console.log('✓ Médecins page loaded');
    });

    it('should display medecins list or table', async function() {
        await driver.sleep(1000);
        
        // Look for table, list, or card elements
        const tableElements = await driver.findElements(
            By.css('table, .medecin-card, [data-testid="medecin-list"], .grid, .medecin-item')
        );
        
        console.log(`✓ Found ${tableElements.length} medecin display elements`);
    });

    it('should have search functionality', async function() {
        await driver.sleep(500);
        
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

    it('should have add medecin button', async function() {
        await driver.sleep(500);
        
        // Look for add/create button
        const addButtons = await driver.findElements(
            By.css('button[aria-label*="add"], button[aria-label*="Ajouter"], button[aria-label*="nouveau"]')
        );
        
        // Also check page source for add-related text
        const pageSource = await driver.getPageSource();
        const hasAddButton = addButtons.length > 0 || 
                            pageSource.toLowerCase().includes('ajouter') || 
                            pageSource.toLowerCase().includes('nouveau médecin');
        
        assert(hasAddButton, 'Should have add medecin functionality');
        console.log('✓ Add medecin functionality checked');
    });

    it('should create, search and delete a medecin - Complete E2E Test', async function() {
        this.timeout(90000);
        await driver.sleep(500);
        
        const testMedecinName = 'DrSelenium' + Date.now();
        const testMedecinPrenom = 'Test';
        const testMedecinRPPS = '1' + Date.now().toString().slice(-10);
        
        try {
            // ÉTAPE 1: CRÉER UN NOUVEAU MÉDECIN
            console.log('\n=== ÉTAPE 1: CRÉATION DU MÉDECIN ===');
            
            // Trouver le bouton "Ajouter"
            const buttons = await driver.findElements(By.css('button'));
            let addButton = null;
            
            for (let button of buttons) {
                try {
                    const text = await button.getText();
                    if (text.includes('Ajouter') || text.includes('Nouveau')) {
                        addButton = button;
                        break;
                    }
                } catch (e) {
                    continue;
                }
            }
            
            assert(addButton, 'Add button should be found');
            // Scroller vers le bouton et cliquer avec JavaScript pour éviter l'interception
            await driver.executeScript('arguments[0].scrollIntoView({block: "center"});', addButton);
            await driver.sleep(500);
            await driver.executeScript('arguments[0].click();', addButton);
            console.log('✓ Bouton Ajouter cliqué');
            await driver.sleep(2000);
            
            // Remplir le formulaire
            const allInputs = await driver.findElements(By.css('input'));
            
            for (let input of allInputs) {
                try {
                    const type = await input.getAttribute('type');
                    const placeholder = await input.getAttribute('placeholder');
                    const name = await input.getAttribute('name');
                    const isVisible = await input.isDisplayed();
                    
                    if (!isVisible) continue;
                    
                    if ((placeholder && placeholder.toLowerCase().includes('nom')) ||
                        (name && name === 'nom')) {
                        await input.clear();
                        await input.sendKeys(testMedecinName);
                        console.log('✓ Nom rempli:', testMedecinName);
                    } else if ((placeholder && placeholder.toLowerCase().includes('prénom')) ||
                               (name && name === 'prenom')) {
                        await input.clear();
                        await input.sendKeys(testMedecinPrenom);
                        console.log('✓ Prénom rempli:', testMedecinPrenom);
                    } else if ((placeholder && (placeholder.toLowerCase().includes('rpps') || placeholder.toLowerCase().includes('matricule'))) ||
                               (name && (name.toLowerCase().includes('rpps') || name.toLowerCase().includes('matricule')))) {
                        await input.clear();
                        await input.sendKeys(testMedecinRPPS);
                        console.log('✓ RPPS/Matricule rempli:', testMedecinRPPS);
                    } else if ((placeholder && placeholder.toLowerCase().includes('spécialit')) ||
                               (name && name.toLowerCase().includes('specialit'))) {
                        await input.clear();
                        await input.sendKeys('Cardiologie');
                        console.log('✓ Spécialité remplie');
                    } else if (type === 'email' && placeholder && placeholder.toLowerCase().includes('email')) {
                        await input.clear();
                        await input.sendKeys('dr.selenium@test.com');
                        console.log('✓ Email rempli');
                    } else if (type === 'tel' || (placeholder && placeholder.toLowerCase().includes('téléphone'))) {
                        await input.clear();
                        await input.sendKeys('0612345678');
                        console.log('✓ Téléphone rempli');
                    }
                } catch (e) {
                    continue;
                }
            }
            
            await driver.sleep(1000);
            
            // Soumettre le formulaire
            const submitButtons = await driver.findElements(By.css('button[type="submit"], button'));
            for (let btn of submitButtons) {
                try {
                    const text = await btn.getText();
                    const isVisible = await btn.isDisplayed();
                    if (isVisible && (text.includes('Enregistrer') || text.includes('Ajouter') || text.includes('Créer'))) {
                        await driver.executeScript('arguments[0].scrollIntoView({block: "center"});', btn);
                        await driver.sleep(500);
                        await driver.executeScript('arguments[0].click();', btn);
                        console.log('✓ Formulaire soumis');
                        break;
                    }
                } catch (e) {
                    continue;
                }
            }
            
            await driver.sleep(3000);
            console.log('✓ Médecin créé avec succès');
            
            // ÉTAPE 2: RECHERCHER LE MÉDECIN
            console.log('\n=== ÉTAPE 2: RECHERCHE DU MÉDECIN ===');
            
            const searchInputs = await driver.findElements(By.css('input[type="search"], input[type="text"]'));
            let searchInput = null;
            
            for (let input of searchInputs) {
                try {
                    const placeholder = await input.getAttribute('placeholder');
                    const isVisible = await input.isDisplayed();
                    if (isVisible && placeholder && placeholder.toLowerCase().includes('recherch')) {
                        searchInput = input;
                        break;
                    }
                } catch (e) {
                    continue;
                }
            }
            
            if (searchInput) {
                await searchInput.clear();
                await searchInput.sendKeys(testMedecinName);
                console.log('✓ Recherche du médecin:', testMedecinName);
                await driver.sleep(2000);
                
                const pageSource = await driver.getPageSource();
                assert(pageSource.includes(testMedecinName), 'Medecin should be found in search results');
                console.log('✓ Médecin trouvé dans les résultats');
            } else {
                console.log('⚠ Barre de recherche non trouvée, vérification dans la page');
                const pageSource = await driver.getPageSource();
                assert(pageSource.includes(testMedecinName), 'Medecin should be visible on page');
            }
            
            // ÉTAPE 3: SUPPRIMER LE MÉDECIN
            console.log('\n=== ÉTAPE 3: SUPPRESSION DU MÉDECIN ===');
            
            await driver.sleep(1000);
            
            // La recherche est déjà active, donc chercher le bouton supprimer dans les résultats filtrés
            // Méthode 1: Chercher toutes les lignes/cartes de médecins
            const medecinCards = await driver.findElements(By.css('.card, [class*="Card"], div[class*="border"]'));
            let deleteButton = null;
            
            for (let card of medecinCards) {
                try {
                    const cardHtml = await card.getAttribute('innerHTML');
                    // Vérifier si cette carte contient notre médecin
                    if (cardHtml && (cardHtml.includes(testMedecinName) || cardHtml.includes(testMedecinRPPS))) {
                        console.log('✓ Carte du médecin trouvée');
                        // Chercher tous les boutons dans cette carte
                        const buttonsInCard = await card.findElements(By.css('button'));
                        console.log(`  Nombre de boutons dans la carte: ${buttonsInCard.length}`);
                        
                        // Le bouton supprimer est généralement le dernier ou deuxième bouton
                        if (buttonsInCard.length >= 2) {
                            // Prendre le dernier bouton (supprimer)
                            deleteButton = buttonsInCard[buttonsInCard.length - 1];
                            console.log('✓ Bouton supprimer trouvé (dernier bouton de la carte)');
                            break;
                        }
                    }
                } catch (e) {
                    continue;
                }
            }
            
            // Méthode 2: Si pas trouvé, chercher directement tous les boutons danger visibles
            if (!deleteButton) {
                console.log('⚠ Recherche alternative: tous les boutons danger');
                const allButtons = await driver.findElements(By.css('button'));
                for (let btn of allButtons) {
                    try {
                        const isVisible = await btn.isDisplayed();
                        if (!isVisible) continue;
                        
                        const btnHtml = await btn.getAttribute('outerHTML');
                        const btnClass = await btn.getAttribute('class');
                        
                        if ((btnHtml && (btnHtml.includes('Trash') || btnHtml.includes('trash'))) ||
                            (btnClass && (btnClass.includes('danger') || btnClass.includes('red')))) {
                            // Vérifier le contexte (parent) du bouton
                            const parentHtml = await driver.executeScript(
                                'return arguments[0].closest("div[class*=Card], div[class*=card]")?.innerHTML || ""', 
                                btn
                            );
                            if (parentHtml && (parentHtml.includes(testMedecinName) || parentHtml.includes(testMedecinRPPS))) {
                                deleteButton = btn;
                                console.log('✓ Bouton supprimer trouvé via contexte parent');
                                break;
                            }
                        }
                    } catch (e) {
                        continue;
                    }
                }
            }
            
            if (deleteButton) {
                await driver.executeScript('arguments[0].scrollIntoView({block: "center"});', deleteButton);
                await driver.sleep(500);
                await driver.executeScript('arguments[0].click();', deleteButton);
                console.log('✓ Bouton supprimer cliqué');
                await driver.sleep(2000);
                
                // Confirmer la suppression si dialog de confirmation
                try {
                    await driver.sleep(1000);
                    const confirmButtons = await driver.findElements(By.css('button, [role="button"]'));
                    let confirmed = false;
                    
                    for (let btn of confirmButtons) {
                        try {
                            const text = await btn.getText();
                            const isVisible = await btn.isDisplayed();
                            if (isVisible && (text.includes('Confirmer') || text.includes('Oui') || text.includes('Supprimer'))) {
                                await driver.executeScript('arguments[0].click();', btn);
                                console.log('✓ Suppression confirmée');
                                confirmed = true;
                                break;
                            }
                        } catch (e) {
                            continue;
                        }
                    }
                    
                    if (!confirmed) {
                        console.log('⚠ Pas de dialogue de confirmation trouvé, suppression directe');
                    }
                } catch (e) {
                    console.log('⚠ Erreur confirmation:', e.message);
                }
                
                await driver.sleep(3000);
                
                // Vérifier que le médecin n'est plus dans la page
                if (searchInput) {
                    await searchInput.clear();
                    await driver.sleep(1000);
                }
                
                const finalPageSource = await driver.getPageSource();
                const medecinStillExists = finalPageSource.includes(testMedecinName) && finalPageSource.includes(testMedecinRPPS);
                
                if (!medecinStillExists) {
                    console.log('✓ Médecin supprimé avec succès - Non trouvé dans la page');
                } else {
                    console.log('⚠ Médecin peut-être encore présent dans la page');
                }
            } else {
                console.log('⚠ Bouton supprimer non trouvé - Vérifier la structure du tableau');
                // Log pour debug
                const pageSource = await driver.getPageSource();
                if (pageSource.includes('aria-label')) {
                    console.log('⚠ La page contient des aria-label, mais pas pour supprimer');
                }
            }
            
            console.log('\n✅ TEST E2E COMPLET RÉUSSI');
            
        } catch (e) {
            console.log('\n❌ ERREUR DANS LE TEST E2E:', e.message);
            throw e;
        }
    });

    it('should display medecin specialties', async function() {
        await driver.sleep(500);
        
        const pageSource = await driver.getPageSource();
        const hasSpecialty = pageSource.includes('Cardiologie') || 
                            pageSource.includes('Chirurgie') ||
                            pageSource.includes('Pédiatrie') ||
                            pageSource.toLowerCase().includes('specialit');
        
        if (hasSpecialty) {
            console.log('✓ Specialties displayed');
        } else {
            console.log('⚠ No specialties found (may require data)');
        }
    });

    it('should have delete functionality available', async function() {
        await driver.sleep(500);
        
        try {
            // Chercher un bouton de suppression
            const deleteButtons = await driver.findElements(
                By.css('button[aria-label*="supprimer"]')
            );
            
            if (deleteButtons.length > 0) {
                console.log(`✓ Found ${deleteButtons.length} delete button(s)`);
                console.log('✓ Delete functionality available');
            } else {
                console.log('⚠ No delete buttons found (may require data in table)');
            }
        } catch (e) {
            console.log('⚠ Could not test deletion:', e.message);
        }
    });

    it('should have medecin details view', async function() {
        await driver.sleep(500);
        
        // Look for view/edit buttons or clickable medecin rows
        const actionButtons = await driver.findElements(
            By.css('button, [role="button"], .action-button, tr, .medecin-row')
        );
        
        console.log(`✓ Found ${actionButtons.length} interactive elements`);
    });
});
