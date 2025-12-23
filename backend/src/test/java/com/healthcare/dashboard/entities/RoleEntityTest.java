package com.healthcare.dashboard.entities;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class RoleEntityTest {

    @Test
    void testRoleCreation() {
        Role role = new Role();
        role.setId(1L);
        role.setName("ROLE_ADMIN");

        assertThat(role.getId()).isEqualTo(1L);
        assertThat(role.getName()).isEqualTo("ROLE_ADMIN");
    }

    @Test
    void testRoleWithDifferentNames() {
        Role adminRole = new Role();
        adminRole.setName("ROLE_ADMIN");

        Role userRole = new Role();
        userRole.setName("ROLE_USER");

        Role doctorRole = new Role();
        doctorRole.setName("ROLE_DOCTOR");

        assertThat(adminRole.getName()).isEqualTo("ROLE_ADMIN");
        assertThat(userRole.getName()).isEqualTo("ROLE_USER");
        assertThat(doctorRole.getName()).isEqualTo("ROLE_DOCTOR");
    }
}
