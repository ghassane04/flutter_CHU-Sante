package com.healthcare.dashboard.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DatasetRowDTO {
    private String date;
    private String service;
    private Integer patientsCount;
    private Integer actesCount;
    private Integer sejoursActifs;
    private Double dureeMoyenneSejour;
    private Double coutTotal;
    private Double coutMoyenActe;
    private Double tauxOccupation;
    private Integer personnelPresent;
    private Integer equipementsUtilises;
    private Integer urgencesAdmissions;
    private Integer interventionsChirurgicales;
    private Integer examensRadiologie;
    private Integer consultations;
    private Integer hospitalisations;
    private Double tarifMoyen;
    private Double coutMaintenance;
    private String saison;
    private String jourSemaine;
    private Integer estWeekend;
    private Integer estFerie;
    private String meteo;
    private Integer temperature;
    private Integer mois;
    private Integer annee;
}
