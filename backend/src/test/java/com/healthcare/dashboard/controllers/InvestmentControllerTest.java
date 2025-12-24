package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.entities.Investment;
import com.healthcare.dashboard.repositories.InvestmentRepository;
import com.healthcare.dashboard.security.JwtTokenProvider;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(InvestmentController.class)
class InvestmentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private InvestmentRepository investmentRepository;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @MockBean
    private UserDetailsService userDetailsService;

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

    @Test
    @WithMockUser
    void getInvestmentById_ShouldReturnNotFound() throws Exception {
        when(investmentRepository.findById(999L)).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/investments/999"))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser
    void getInvestmentStats_ShouldReturnStats() throws Exception {
        when(investmentRepository.findAll()).thenReturn(Arrays.asList(investment));
        when(investmentRepository.sumMontantByStatutEnCours()).thenReturn(30000.0);
        when(investmentRepository.sumMontantByStatutTermine()).thenReturn(20000.0);
        when(investmentRepository.count()).thenReturn(1L);

        mockMvc.perform(get("/api/investments/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalInvesti").value(50000.0))
                .andExpect(jsonPath("$.montantEnCours").value(30000.0));
    }

    @Test
    @WithMockUser
    void getInvestmentStats_ShouldHandleNullValues() throws Exception {
        when(investmentRepository.findAll()).thenReturn(Arrays.asList());
        when(investmentRepository.sumMontantByStatutEnCours()).thenReturn(null);
        when(investmentRepository.sumMontantByStatutTermine()).thenReturn(null);
        when(investmentRepository.count()).thenReturn(0L);

        mockMvc.perform(get("/api/investments/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.montantEnCours").value(0.0))
                .andExpect(jsonPath("$.montantTermine").value(0.0));
    }

    @Test
    @WithMockUser
    void createInvestment_ShouldReturnCreated() throws Exception {
        when(investmentRepository.save(any(Investment.class))).thenReturn(investment);

        mockMvc.perform(post("/api/investments")
                .with(csrf())
                .contentType(org.springframework.http.MediaType.APPLICATION_JSON)
                .content("{\"nom\":\"New Investment\",\"montant\":10000}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nom").value("Equipment Upgrade"));
    }

    @Test
    @WithMockUser
    void updateInvestment_ShouldReturnUpdated() throws Exception {
        when(investmentRepository.findById(1L)).thenReturn(Optional.of(investment));
        when(investmentRepository.save(any(Investment.class))).thenReturn(investment);

        mockMvc.perform(put("/api/investments/1")
                .with(csrf())
                .contentType(org.springframework.http.MediaType.APPLICATION_JSON)
                .content("{\"nom\":\"Updated Investment\",\"montant\":60000}"))
                .andExpect(status().isOk());
    }

    @Test
    @WithMockUser
    void updateInvestment_ShouldReturnNotFound() throws Exception {
        when(investmentRepository.findById(999L)).thenReturn(Optional.empty());

        mockMvc.perform(put("/api/investments/999")
                .with(csrf())
                .contentType(org.springframework.http.MediaType.APPLICATION_JSON)
                .content("{\"nom\":\"Updated\",\"montant\":10000}"))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser
    void deleteInvestment_ShouldReturnNotFound() throws Exception {
        when(investmentRepository.existsById(999L)).thenReturn(false);

        mockMvc.perform(delete("/api/investments/999")
                .with(csrf()))
                .andExpect(status().isNotFound());
    }
}
