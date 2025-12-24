package com.healthcare.dashboard.security;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;

/**
 * Configuration de test pour les tests de sécurité.
 * Fournit des utilisateurs de test avec différents rôles.
 */
@TestConfiguration
public class SecurityTestsConfig {
    
    @Bean
    public UserDetailsService testUserDetailsService() {
        UserDetails adminUser = User.builder()
            .username("admin")
            .password("$2a$10$encodedPassword")
            .roles("ADMIN", "USER")
            .build();
            
        UserDetails regularUser = User.builder()
            .username("user")
            .password("$2a$10$encodedPassword")
            .roles("USER")
            .build();
            
        return new InMemoryUserDetailsManager(adminUser, regularUser);
    }
}
