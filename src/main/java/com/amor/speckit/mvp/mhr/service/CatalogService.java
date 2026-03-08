package com.amor.speckit.mvp.mhr.service;

import com.amor.speckit.mvp.mhr.domain.Equipment;
import com.amor.speckit.mvp.mhr.domain.EquipmentPart;
import com.amor.speckit.mvp.mhr.domain.Skill;
import com.amor.speckit.mvp.mhr.domain.WeaponType;
import com.amor.speckit.mvp.mhr.dto.EquipmentResponse;
import com.amor.speckit.mvp.mhr.dto.SkillResponse;
import com.amor.speckit.mvp.mhr.repository.EquipmentCatalogPort;
import com.amor.speckit.mvp.mhr.repository.SkillCatalogPort;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CatalogService {
    private final SkillCatalogPort skillCatalogRepository;
    private final EquipmentCatalogPort equipmentCatalogRepository;

    public CatalogService(SkillCatalogPort skillCatalogRepository,
                          EquipmentCatalogPort equipmentCatalogRepository) {
        this.skillCatalogRepository = skillCatalogRepository;
        this.equipmentCatalogRepository = equipmentCatalogRepository;
    }

    public List<SkillResponse> getSkills() {
        return skillCatalogRepository.findAll().stream().map(this::toSkillResponse).collect(Collectors.toList());
    }

    public List<EquipmentResponse> getEquipments(EquipmentPart part, WeaponType weaponType) {
        List<Equipment> equipments;
        if (part == null) {
            equipments = equipmentCatalogRepository.findByWeapon(weaponType);
        } else {
            equipments = equipmentCatalogRepository.findByPartAndWeapon(part, weaponType);
        }
        return equipments.stream().map(this::toEquipmentResponse).collect(Collectors.toList());
    }

    EquipmentResponse toEquipmentResponse(Equipment equipment) {
        EquipmentResponse response = new EquipmentResponse();
        response.setId(equipment.getId());
        response.setName(equipment.getName());
        response.setNameZh(equipment.getNameZh());
        response.setPart(equipment.getPart());
        response.setRarity(equipment.getRarity());
        response.setSlots(equipment.getSlots());
        response.setSkillPoints(equipment.getSkillPoints());
        return response;
    }

    SkillResponse toSkillResponse(Skill skill) {
        SkillResponse response = new SkillResponse();
        response.setId(skill.getId());
        response.setCode(skill.getCode());
        response.setName(skill.getName());
        response.setNameZh(skill.getNameZh());
        response.setMaxLevel(skill.getMaxLevel());
        response.setEffect(skill.getEffect());
        return response;
    }
}
