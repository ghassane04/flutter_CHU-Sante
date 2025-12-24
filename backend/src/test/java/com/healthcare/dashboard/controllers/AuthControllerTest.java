package com.healthcare.dashboard.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthcare.dashboard.dto.LoginRequest;
import com.healthcare.dashboard.dto.SignupRequest;
import com.healthcare.dashboard.entities.Role;
import com.healthcare.dashboard.entities.User;
import com.healthcare.dashboard.repositories.RoleRepository;
import com.healthcare.dashboard.repositories.UserRepository;
import com.healthcare.dashboard.security.JwtTokenProvider;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(AuthController.class)
@AutoConfigureMockMvc(addFilters = false)
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private AuthenticationManager authenticationManager;

    @MockBean
    private UserRepository userRepository;

    @MockBean
    private RoleRepository roleRepository;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @MockBean
    private UserDetailsService userDetailsService;

    @MockBean
    private PasswordEncoder passwordEncoder;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void authenticateUser_ShouldReturnToken_WhenValid() throws Exception {
        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setUsername("testuser");
        loginRequest.setPassword("password");

        Authentication authentication = mock(Authentication.class);
        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .thenReturn(authentication);
        
        when(jwtTokenProvider.generateToken(authentication)).thenReturn("fake-jwt-token");
        
        User user = new User();
        user.setId(1L);
        user.setUsername("testuser");
        user.setEmail("test@test.com");
        when(userRepository.findByUsername("testuser")).thenReturn(Optional.of(user));

        mockMvc.perform(post("/api/auth/login")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").value("fake-jwt-token"))
                .andExpect(jsonPath("$.username").value("testuser"));
    }

    @Test
    void registerUser_ShouldReturnOk_WhenNewUser() throws Exception {
        SignupRequest signupRequest = new SignupRequest();
        signupRequest.setUsername("newuser");
        signupRequest.setEmail("new@test.com");
        signupRequest.setPassword("password");
        signupRequest.setNom("New");
        signupRequest.setPrenom("User");

        when(userRepository.findByUsername("newuser")).thenReturn(Optional.empty());
        when(userRepository.findByEmail("new@test.com")).thenReturn(Optional.empty());
        
        Role role = new Role();
        role.setName("ROLE_USER");
        when(roleRepository.findByName("ROLE_USER")).thenReturn(Optional.of(role));

        when(passwordEncoder.encode(any())).thenReturn("encodedPassword");

        mockMvc.perform(post("/api/auth/signup")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(signupRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Utilisateur enregistré avec succès"));
    }

    @Test
    void authenticateUser_ShouldReturnUnauthorized_WhenInvalid() throws Exception {
        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setUsername("baduser");
        loginRequest.setPassword("badpassword");

        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .thenThrow(new RuntimeException("Bad credentials"));

        mockMvc.perform(post("/api/auth/login")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message").value("Identifiants incorrects"));
    }

    @Test
    void registerUser_ShouldReturnBadRequest_WhenUsernameExists() throws Exception {
        SignupRequest signupRequest = new SignupRequest();
        signupRequest.setUsername("existinguser");
        signupRequest.setEmail("new@test.com");
        signupRequest.setPassword("password");

        when(userRepository.findByUsername("existinguser")).thenReturn(Optional.of(new User()));

        mockMvc.perform(post("/api/auth/signup")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(signupRequest)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Erreur: Ce nom d'utilisateur est déjà utilisé"));
    }

    @Test
    void registerUser_ShouldReturnBadRequest_WhenEmailExists() throws Exception {
        SignupRequest signupRequest = new SignupRequest();
        signupRequest.setUsername("newuser");
        signupRequest.setEmail("existing@test.com");
        signupRequest.setPassword("password");

        when(userRepository.findByUsername("newuser")).thenReturn(Optional.empty());
        when(userRepository.findByEmail("existing@test.com")).thenReturn(Optional.of(new User()));

        mockMvc.perform(post("/api/auth/signup")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(signupRequest)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Erreur: Cet email est déjà utilisé"));
    }

    @Test
    void registerUser_ShouldCreateRole_WhenRoleNotFound() throws Exception {
        SignupRequest signupRequest = new SignupRequest();
        signupRequest.setUsername("newuser");
        signupRequest.setEmail("new@test.com");
        signupRequest.setPassword("password");

        when(userRepository.findByUsername("newuser")).thenReturn(Optional.empty());
        when(userRepository.findByEmail("new@test.com")).thenReturn(Optional.empty());
        // Role not found - should create new one
        when(roleRepository.findByName("ROLE_USER")).thenReturn(Optional.empty());
        Role newRole = new Role();
        newRole.setName("ROLE_USER");
        when(roleRepository.save(any(Role.class))).thenReturn(newRole);
        when(passwordEncoder.encode(any())).thenReturn("encodedPassword");

        mockMvc.perform(post("/api/auth/signup")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(signupRequest)))
                .andExpect(status().isOk());
    }

    @Test
    void checkUsername_ShouldReturnExists_WhenUsernameExists() throws Exception {
        when(userRepository.findByUsername("existinguser")).thenReturn(Optional.of(new User()));

        mockMvc.perform(get("/api/auth/check-username/existinguser"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("exists"));
    }

    @Test
    void checkUsername_ShouldReturnAvailable_WhenUsernameNotExists() throws Exception {
        when(userRepository.findByUsername("newuser")).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/auth/check-username/newuser"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("available"));
    }

    @Test
    void checkEmail_ShouldReturnExists_WhenEmailExists() throws Exception {
        when(userRepository.findByEmail("existing@test.com")).thenReturn(Optional.of(new User()));

        mockMvc.perform(get("/api/auth/check-email/existing@test.com"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("exists"));
    }

    @Test
    void checkEmail_ShouldReturnAvailable_WhenEmailNotExists() throws Exception {
        when(userRepository.findByEmail("new@test.com")).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/auth/check-email/new@test.com"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("available"));
    }
}
