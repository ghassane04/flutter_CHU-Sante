package com.healthcare.dashboard.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthcare.dashboard.dto.MedecinDTO;
import com.healthcare.dashboard.security.JwtTokenProvider;
import com.healthcare.dashboard.services.MedecinService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.Collections;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;

@WebMvcTest(MedecinController.class)
class MedecinControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private MedecinService medecinService;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @MockBean
    private UserDetailsService userDetailsService;

    @Autowired
    private ObjectMapper objectMapper;

    private MedecinDTO medecinDTO;

    @BeforeEach
    void setUp() {
        medecinDTO = new MedecinDTO();
        medecinDTO.setId(1L);
        medecinDTO.setNom("House");
        medecinDTO.setPrenom("Gregory");
        medecinDTO.setSpecialite("Diagnostician");
        medecinDTO.setNumeroInscription("MD12345");
        medecinDTO.setEmail("house@hospital.com");
        medecinDTO.setStatut("ACTIF");
    }

    @Test
    @WithMockUser
    void getAllMedecins_ShouldReturnList() throws Exception {
        when(medecinService.getAllMedecins()).thenReturn(Arrays.asList(medecinDTO));

        mockMvc.perform(get("/api/medecins"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].nom").value("House"));
    }

    @Test
    @WithMockUser
    void getMedecinById_ShouldReturnMedecin() throws Exception {
        when(medecinService.getMedecinById(1L)).thenReturn(medecinDTO);

        mockMvc.perform(get("/api/medecins/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nom").value("House"));
    }

    @Test
    @WithMockUser
    void createMedecin_ShouldReturnCreated() throws Exception {
        when(medecinService.createMedecin(any(MedecinDTO.class))).thenReturn(medecinDTO);

        mockMvc.perform(post("/api/medecins")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(medecinDTO)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.nom").value("House"));
    }

    @Test
    @WithMockUser
    void updateMedecin_ShouldReturnUpdated() throws Exception {
        when(medecinService.updateMedecin(eq(1L), any(MedecinDTO.class))).thenReturn(medecinDTO);

        mockMvc.perform(put("/api/medecins/1")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(medecinDTO)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nom").value("House"));
    }

    @Test
    @WithMockUser
    void deleteMedecin_ShouldReturnNoContent() throws Exception {
        doNothing().when(medecinService).deleteMedecin(1L);

        mockMvc.perform(delete("/api/medecins/1")
                .with(csrf()))
                .andExpect(status().isNoContent());
    }

    @Test
    @WithMockUser
    void searchMedecins_ShouldReturnList() throws Exception {
        when(medecinService.searchMedecins("House")).thenReturn(Arrays.asList(medecinDTO));

        mockMvc.perform(get("/api/medecins/search")
                .param("query", "House"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].nom").value("House"));
    }
}
