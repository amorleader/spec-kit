package com.amor.speckit.mvp.mhr.controller;

import com.amor.speckit.mvp.mhr.domain.EquipmentPart;
import com.amor.speckit.mvp.mhr.domain.WeaponType;
import com.amor.speckit.mvp.mhr.dto.EquipmentResponse;
import com.amor.speckit.mvp.mhr.dto.SkillResponse;
import com.amor.speckit.mvp.mhr.service.CatalogService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class CatalogController {
    private final CatalogService catalogService;

    public CatalogController(CatalogService catalogService) {
        this.catalogService = catalogService;
    }

    @GetMapping("/skills")
    public List<SkillResponse> skills() {
        return catalogService.getSkills();
    }

    @GetMapping("/equipments")
    public List<EquipmentResponse> equipments(@RequestParam(required = false) EquipmentPart part,
                                              @RequestParam WeaponType weaponType) {
        return catalogService.getEquipments(part, weaponType);
    }
}
