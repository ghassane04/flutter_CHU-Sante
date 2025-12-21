package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.entities.Settings;
import com.healthcare.dashboard.repositories.SettingsRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.Optional;

import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class SettingsControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private SettingsRepository settingsRepository;

    private Settings settings;

    @BeforeEach
    void setUp() {
        settings = new Settings();
        settings.setId(1L);
        settings.setCle("app.name");
        settings.setValeur("Healthcare Dashboard");
        settings.setCategorie("GENERAL");
    }

    @Test
    @WithMockUser
    void getAllSettings_ShouldReturnList() throws Exception {
        when(settingsRepository.findAll()).thenReturn(Arrays.asList(settings));

        mockMvc.perform(get("/api/settings"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].cle").value("app.name"));
    }

    @Test
    @WithMockUser
    void getSettingById_ShouldReturnSetting() throws Exception {
        when(settingsRepository.findById(1L)).thenReturn(Optional.of(settings));

        mockMvc.perform(get("/api/settings/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.cle").value("app.name"));
    }

    @Test
    @WithMockUser
    void getSettingByCle_ShouldReturnSetting() throws Exception {
        when(settingsRepository.findByCle("app.name")).thenReturn(Optional.of(settings));

        mockMvc.perform(get("/api/settings/cle/app.name"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.valeur").value("Healthcare Dashboard"));
    }

    @Test
    @WithMockUser
    void getSettingsByCategorie_ShouldReturnList() throws Exception {
        when(settingsRepository.findByCategorie("GENERAL")).thenReturn(Arrays.asList(settings));

        mockMvc.perform(get("/api/settings/categorie/GENERAL"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].categorie").value("GENERAL"));
    }

    @Test
    @WithMockUser
    void deleteSetting_ShouldReturnOk() throws Exception {
        when(settingsRepository.existsById(1L)).thenReturn(true);

        mockMvc.perform(delete("/api/settings/1")
                .with(csrf()))
                .andExpect(status().isOk());
    }
}
