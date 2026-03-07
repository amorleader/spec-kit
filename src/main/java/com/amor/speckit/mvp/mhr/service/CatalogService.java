package com.amor.speckit.mvp.mhr.service;

import com.amor.speckit.mvp.mhr.domain.Equipment;
import com.amor.speckit.mvp.mhr.domain.EquipmentPart;
import com.amor.speckit.mvp.mhr.domain.Skill;
import com.amor.speckit.mvp.mhr.domain.WeaponType;
import com.amor.speckit.mvp.mhr.dto.EquipmentResponse;
import com.amor.speckit.mvp.mhr.dto.SkillResponse;
import com.amor.speckit.mvp.mhr.repository.EquipmentCatalogRepository;
import com.amor.speckit.mvp.mhr.repository.SkillCatalogRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CatalogService {
    private final SkillCatalogRepository skillCatalogRepository;
    private final EquipmentCatalogRepository equipmentCatalogRepository;

    public CatalogService(SkillCatalogRepository skillCatalogRepository,
                          EquipmentCatalogRepository equipmentCatalogRepository) {
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
        response.setMaxLevel(skill.getMaxLevel());
        return response;
    }
}
