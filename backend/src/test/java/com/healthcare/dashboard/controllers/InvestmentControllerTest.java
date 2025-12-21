package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.entities.Investment;
import com.healthcare.dashboard.repositories.InvestmentRepository;
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
class InvestmentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private InvestmentRepository investmentRepository;

    private Investment investment;

    @BeforeEach
    void setUp() {
        investment = new Investment();
        investment.setId(1L);
        investment.setNom("Equipment Upgrade");
        investment.setMontant(50000.0);
        investment.setStatut("EN_COURS");
        investment.setCategorie("EQUIPEMENT");
    }

    @Test
    @WithMockUser
    void getAllInvestments_ShouldReturnList() throws Exception {
        when(investmentRepository.findAll()).thenReturn(Arrays.asList(investment));

        mockMvc.perform(get("/api/investments"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].nom").value("Equipment Upgrade"));
    }

    @Test
    @WithMockUser
    void getInvestmentById_ShouldReturnInvestment() throws Exception {
        when(investmentRepository.findById(1L)).thenReturn(Optional.of(investment));

        mockMvc.perform(get("/api/investments/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nom").value("Equipment Upgrade"));
    }

    @Test
    @WithMockUser
    void getInvestmentsByStatut_ShouldReturnList() throws Exception {
        when(investmentRepository.findByStatut("EN_COURS")).thenReturn(Arrays.asList(investment));

        mockMvc.perform(get("/api/investments/statut/EN_COURS"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].statut").value("EN_COURS"));
    }

    @Test
    @WithMockUser
    void getInvestmentsByCategorie_ShouldReturnList() throws Exception {
        when(investmentRepository.findByCategorie("EQUIPEMENT")).thenReturn(Arrays.asList(investment));

        mockMvc.perform(get("/api/investments/categorie/EQUIPEMENT"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].categorie").value("EQUIPEMENT"));
    }

    @Test
    @WithMockUser
    void deleteInvestment_ShouldReturnOk() throws Exception {
        when(investmentRepository.existsById(1L)).thenReturn(true);

        mockMvc.perform(delete("/api/investments/1")
                .with(csrf()))
                .andExpect(status().isOk());
    }
}
