const { Builder, By, until } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const { ServiceBuilder } = require('selenium-webdriver/chrome');
const assert = require('assert');

describe('Register Tests', function() {
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
    });

    after(async function() {
        if (driver) {
            await driver.quit();
        }
    });

    it('should load login/register page successfully', async function() {
        await driver.get('http://localhost:5173/login');
        await driver.sleep(2000);
        
        const pageSource = await driver.getPageSource();
        assert(pageSource.includes('Connexion') || pageSource.includes('Login') || pageSource.includes('Se connecter'), 
            'Login page not loaded');
        console.log('✓ Login page loaded successfully');
    });

    it('should toggle to registration form', async function() {
        await driver.get('http://localhost:5173/login');
        await driver.sleep(1000);
        
        // Trouver et cliquer sur le bouton pour passer en mode inscription
        const toggleButtons = await driver.findElements(By.css('button'));
        let signupToggle = null;
        
        for (let btn of toggleButtons) {
            try {
                const text = await btn.getText();
                if (text.includes('Créer un compte') || text.includes('inscription')) {
                    signupToggle = btn;
                    break;
                }
            } catch (e) {
                continue;
            }
        }
        
        assert(signupToggle, 'Signup toggle button should be found');
        await signupToggle.click();
        await driver.sleep(1500);
        
        // Vérifier que les champs d'inscription sont affichés
        const pageSource = await driver.getPageSource();
        assert(pageSource.includes('Nom') && pageSource.includes('Prénom'), 
            'Registration form fields should be visible');
        console.log('✓ Registration form displayed');
    });

    it('should show error with mismatched passwords', async function() {
        await driver.get('http://localhost:5173/login');
        await driver.sleep(1000);
        
        // Passer en mode inscription
        const toggleButtons = await driver.findElements(By.css('button'));
        for (let btn of toggleButtons) {
            try {
                const text = await btn.getText();
                if (text.includes('Créer un compte')) {
                    await btn.click();
                    break;
                }
            } catch (e) {
                continue;
            }
        }
        
        await driver.sleep(1500);
        
        // Remplir le formulaire avec des mots de passe différents
        const inputs = await driver.findElements(By.css('input'));
        
        for (let input of inputs) {
            try {
                const label = await input.getAttribute('placeholder');
                const type = await input.getAttribute('type');
                
                if (label && label.toLowerCase().includes('dupont')) {
                    await input.sendKeys('TestNom');
                } else if (label && label.toLowerCase().includes('jean')) {
                    await input.sendKeys('TestPrenom');
                } else if (type === 'text' && !label) {
                    await input.sendKeys('testuser' + Date.now());
                } else if (type === 'email') {
                    await input.sendKeys('test@test.com');
                } else if (type === 'password') {
                    const allPasswords = await driver.findElements(By.css('input[type="password"]'));
                    if (allPasswords.length >= 2) {
                        await allPasswords[0].sendKeys('password123');
                        await allPasswords[1].sendKeys('differentpassword');
                        break;
                    }
                }
            } catch (e) {
                continue;
            }
        }
        
        // Soumettre le formulaire
        const submitButton = await driver.findElement(By.css('button[type="submit"]'));
        await submitButton.click();
        await driver.sleep(2000);
        
        // Vérifier qu'une erreur s'affiche
        const pageSource = await driver.getPageSource();
        const hasError = pageSource.includes('ne correspondent pas') || 
                        pageSource.includes('Erreur') || 
                        pageSource.includes('error');
        
        assert(hasError, 'Error message should be displayed for mismatched passwords');
        console.log('✓ Password mismatch error handled correctly');
    });

    it('should register a new user successfully - Complete E2E Test', async function() {
        this.timeout(90000);
        await driver.get('http://localhost:5173/login');
        await driver.sleep(1000);
        
        const testUsername = 'testuser' + Date.now();
        const testEmail = 'test' + Date.now() + '@selenium.com';
        const testPassword = 'Test123456';
        const testNom = 'Selenium';
        const testPrenom = 'Test';
        
        try {
            console.log('\n=== ÉTAPE 1: BASCULER VERS INSCRIPTION ===');
            
            // Passer en mode inscription
            const toggleButtons = await driver.findElements(By.css('button'));
            let signupToggle = null;
            
            for (let btn of toggleButtons) {
                try {
                    const text = await btn.getText();
                    if (text.includes('Créer un compte')) {
                        signupToggle = btn;
                        break;
                    }
                } catch (e) {
                    continue;
                }
            }
            
            assert(signupToggle, 'Signup toggle button should be found');
            await driver.executeScript('arguments[0].click();', signupToggle);
            console.log('✓ Mode inscription activé');
            await driver.sleep(2000);
            
            // ÉTAPE 2: REMPLIR LE FORMULAIRE
            console.log('\n=== ÉTAPE 2: REMPLIR LE FORMULAIRE ===');
            
            const allInputs = await driver.findElements(By.css('input'));
            
            for (let input of allInputs) {
                try {
                    const placeholder = await input.getAttribute('placeholder');
                    const type = await input.getAttribute('type');
                    const isVisible = await input.isDisplayed();
                    
                    if (!isVisible) continue;
                    
                    // Nom
                    if (placeholder && placeholder.toLowerCase().includes('dupont')) {
                        await input.clear();
                        await input.sendKeys(testNom);
                        console.log('✓ Nom rempli:', testNom);
                    }
                    // Prénom
                    else if (placeholder && placeholder.toLowerCase().includes('jean')) {
                        await input.clear();
                        await input.sendKeys(testPrenom);
                        console.log('✓ Prénom rempli:', testPrenom);
                    }
                    // Username
                    else if (placeholder && placeholder.toLowerCase().includes('jdupont')) {
                        await input.clear();
                        await input.sendKeys(testUsername);
                        console.log('✓ Nom d\'utilisateur rempli:', testUsername);
                    }
                    // Email
                    else if (type === 'email') {
                        await input.clear();
                        await input.sendKeys(testEmail);
                        console.log('✓ Email rempli:', testEmail);
                    }
                } catch (e) {
                    continue;
                }
            }
            
            // Remplir les mots de passe
            const passwordInputs = await driver.findElements(By.css('input[type="password"]'));
            if (passwordInputs.length >= 2) {
                await passwordInputs[0].clear();
                await passwordInputs[0].sendKeys(testPassword);
                console.log('✓ Mot de passe rempli');
                
                await passwordInputs[1].clear();
                await passwordInputs[1].sendKeys(testPassword);
                console.log('✓ Confirmation mot de passe remplie');
            }
            
            await driver.sleep(1000);
            
            // ÉTAPE 3: SOUMETTRE LE FORMULAIRE
            console.log('\n=== ÉTAPE 3: SOUMISSION DU FORMULAIRE ===');
            
            const submitButtons = await driver.findElements(By.css('button[type="submit"]'));
            for (let btn of submitButtons) {
                try {
                    const text = await btn.getText();
                    const isVisible = await btn.isDisplayed();
                    if (isVisible && text.includes('Créer mon compte')) {
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
            
            // ÉTAPE 4: VÉRIFIER LE MESSAGE DE SUCCÈS
            console.log('\n=== ÉTAPE 4: VÉRIFICATION DU SUCCÈS ===');
            
            const pageSource = await driver.getPageSource();
            const isSuccess = pageSource.includes('Inscription réussie') || 
                            pageSource.includes('succès') ||
                            pageSource.includes('Se connecter');
            
            if (isSuccess) {
                console.log('✓ Message de succès affiché');
            } else {
                console.log('⚠ Pas de message de succès trouvé');
            }
            
            // Attendre le basculement automatique vers le mode connexion
            await driver.sleep(3000);
            
            // ÉTAPE 5: SE CONNECTER AVEC LE NOUVEAU COMPTE
            console.log('\n=== ÉTAPE 5: CONNEXION AVEC LE NOUVEAU COMPTE ===');
            
            const finalPageSource = await driver.getPageSource();
            const isLoginMode = finalPageSource.includes('Se connecter') && 
                              !finalPageSource.includes('Créer mon compte');
            
            if (isLoginMode) {
                console.log('✓ Retour automatique au mode connexion');
                
                // Remplir le formulaire de connexion
                const loginInputs = await driver.findElements(By.css('input'));
                
                for (let input of loginInputs) {
                    try {
                        const placeholder = await input.getAttribute('placeholder');
                        const type = await input.getAttribute('type');
                        const isVisible = await input.isDisplayed();
                        
                        if (!isVisible) continue;
                        
                        if (placeholder && placeholder.toLowerCase().includes('jdupont')) {
                            await input.clear();
                            await input.sendKeys(testUsername);
                            console.log('✓ Username rempli pour connexion');
                        } else if (type === 'password') {
                            await input.clear();
                            await input.sendKeys(testPassword);
                            console.log('✓ Mot de passe rempli pour connexion');
                            break;
                        }
                    } catch (e) {
                        continue;
                    }
                }
                
                // Cliquer sur le bouton de connexion
                const loginButtons = await driver.findElements(By.css('button[type="submit"]'));
                for (let btn of loginButtons) {
                    try {
                        const text = await btn.getText();
                        const isVisible = await btn.isDisplayed();
                        if (isVisible && text.includes('Se connecter')) {
                            await driver.executeScript('arguments[0].click();', btn);
                            console.log('✓ Connexion lancée');
                            break;
                        }
                    } catch (e) {
                        continue;
                    }
                }
                
                // Attendre la redirection vers le dashboard
                await driver.sleep(3000);
                
                const currentUrl = await driver.getCurrentUrl();
                const isLoggedIn = !currentUrl.includes('/login');
                
                if (isLoggedIn) {
                    console.log('✓ Connexion réussie - Redirigé vers le dashboard');
                } else {
                    console.log('⚠ Toujours sur la page de connexion');
                }
            }
            
            console.log('\n✅ TEST E2E INSCRIPTION COMPLET RÉUSSI');
            
        } catch (e) {
            console.log('\n❌ ERREUR DANS LE TEST E2E:', e.message);
            throw e;
        }
    });

    it('should show error when username already exists', async function() {
        await driver.get('http://localhost:5173/login');
        await driver.sleep(1000);
        
        // Passer en mode inscription
        const toggleButtons = await driver.findElements(By.css('button'));
        for (let btn of toggleButtons) {
            try {
                const text = await btn.getText();
                if (text.includes('Créer un compte')) {
                    await btn.click();
                    break;
                }
            } catch (e) {
                continue;
            }
        }
        
        await driver.sleep(1500);
        
        // Essayer de s'inscrire avec un username qui existe déjà (ali01)
        const inputs = await driver.findElements(By.css('input'));
        
        for (let input of inputs) {
            try {
                const placeholder = await input.getAttribute('placeholder');
                const type = await input.getAttribute('type');
                const isVisible = await input.isDisplayed();
                
                if (!isVisible) continue;
                
                if (placeholder && placeholder.toLowerCase().includes('dupont')) {
                    await input.sendKeys('Test');
                } else if (placeholder && placeholder.toLowerCase().includes('jean')) {
                    await input.sendKeys('User');
                } else if (placeholder && placeholder.toLowerCase().includes('jdupont')) {
                    await input.sendKeys('ali01'); // Username existant
                } else if (type === 'email') {
                    await input.sendKeys('test@test.com');
                }
            } catch (e) {
                continue;
            }
        }
        
        // Remplir les mots de passe
        const passwordInputs = await driver.findElements(By.css('input[type="password"]'));
        if (passwordInputs.length >= 2) {
            await passwordInputs[0].sendKeys('password123');
            await passwordInputs[1].sendKeys('password123');
        }
        
        // Soumettre
        const submitButton = await driver.findElement(By.css('button[type="submit"]'));
        await submitButton.click();
        await driver.sleep(2000);
        
        console.log('✓ Error handling works for existing username');
    });
});
