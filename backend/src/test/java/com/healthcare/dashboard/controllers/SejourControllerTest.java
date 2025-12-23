package com.healthcare.dashboard.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthcare.dashboard.dto.SejourDTO;
import com.healthcare.dashboard.security.JwtTokenProvider;
import com.healthcare.dashboard.services.SejourService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;

@WebMvcTest(SejourController.class)
class SejourControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private SejourService sejourService;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @MockBean
    private UserDetailsService userDetailsService;

    @Autowired
    private ObjectMapper objectMapper;

    private SejourDTO sejourDTO;

    @BeforeEach
    void setUp() {
        sejourDTO = new SejourDTO();
        sejourDTO.setId(1L);
        sejourDTO.setPatientId(1L);
        sejourDTO.setPatientNom("Doe");
        sejourDTO.setServiceId(1L);
        sejourDTO.setServiceNom("Cardiologie");
        sejourDTO.setDateEntree(LocalDateTime.now().minusDays(5));
        sejourDTO.setStatut("EN_COURS");
        sejourDTO.setTypeAdmission("URGENCE");
    }

    @Test
    @WithMockUser
    void getAllSejours_ShouldReturnList() throws Exception {
        when(sejourService.getAllSejours()).thenReturn(Arrays.asList(sejourDTO));

        mockMvc.perform(get("/api/sejours"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].statut").value("EN_COURS"));
    }

    @Test
    @WithMockUser
    void getSejourById_ShouldReturnSejour() throws Exception {
        when(sejourService.getSejourById(1L)).thenReturn(sejourDTO);

        mockMvc.perform(get("/api/sejours/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.statut").value("EN_COURS"));
    }

    @Test
    @WithMockUser
    void getSejoursEnCours_ShouldReturnList() throws Exception {
        when(sejourService.getSejoursEnCours()).thenReturn(Arrays.asList(sejourDTO));

        mockMvc.perform(get("/api/sejours/en-cours"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].statut").value("EN_COURS"));
    }

    @Test
    @WithMockUser
    void countSejoursEnCours_ShouldReturnCount() throws Exception {
        when(sejourService.countSejoursEnCours()).thenReturn(5L);

        mockMvc.perform(get("/api/sejours/count/en-cours"))
                .andExpect(status().isOk())
                .andExpect(content().string("5"));
    }

    @Test
    @WithMockUser
    void createSejour_ShouldReturnCreated() throws Exception {
        when(sejourService.createSejour(any(SejourDTO.class))).thenReturn(sejourDTO);

        mockMvc.perform(post("/api/sejours")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(sejourDTO)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.statut").value("EN_COURS"));
    }

    @Test
    @WithMockUser
    void updateSejour_ShouldReturnUpdated() throws Exception {
        when(sejourService.updateSejour(eq(1L), any(SejourDTO.class))).thenReturn(sejourDTO);

        mockMvc.perform(put("/api/sejours/1")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(sejourDTO)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.statut").value("EN_COURS"));
    }

    @Test
    @WithMockUser
    void deleteSejour_ShouldReturnNoContent() throws Exception {
        doNothing().when(sejourService).deleteSejour(1L);

        mockMvc.perform(delete("/api/sejours/1")
                .with(csrf()))
                .andExpect(status().isNoContent());
    }
}
