package com.amor.speckit.mvp.mhr.service;

import com.amor.speckit.mvp.mhr.domain.Equipment;
import com.amor.speckit.mvp.mhr.domain.EquipmentPart;
import com.amor.speckit.mvp.mhr.domain.Skill;
import com.amor.speckit.mvp.mhr.dto.BuildGenerateRequest;
import com.amor.speckit.mvp.mhr.dto.BuildGenerateResponse;
import com.amor.speckit.mvp.mhr.dto.BuildResultResponse;
import com.amor.speckit.mvp.mhr.dto.CharmDto;
import com.amor.speckit.mvp.mhr.dto.EquipmentResponse;
import com.amor.speckit.mvp.mhr.dto.ErrorDetail;
import com.amor.speckit.mvp.mhr.dto.TargetSkillRequest;
import com.amor.speckit.mvp.mhr.exception.ValidationException;
import com.amor.speckit.mvp.mhr.repository.EquipmentCatalogRepository;
import com.amor.speckit.mvp.mhr.repository.SkillCatalogRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class BuildGenerationService {
    private final EquipmentCatalogRepository equipmentCatalogRepository;
    private final SkillCatalogRepository skillCatalogRepository;
    private final CatalogService catalogService;
    private final BuildResultStore buildResultStore;

    public BuildGenerationService(EquipmentCatalogRepository equipmentCatalogRepository,
                                  SkillCatalogRepository skillCatalogRepository,
                                  CatalogService catalogService,
                                  BuildResultStore buildResultStore) {
        this.equipmentCatalogRepository = equipmentCatalogRepository;
        this.skillCatalogRepository = skillCatalogRepository;
        this.catalogService = catalogService;
        this.buildResultStore = buildResultStore;
    }

    public BuildGenerateResponse generate(BuildGenerateRequest request) {
        validateBusinessRules(request);

        List<Equipment> heads = equipmentCatalogRepository.findByPartAndWeapon(EquipmentPart.HEAD, request.getWeaponType());
        List<Equipment> chests = equipmentCatalogRepository.findByPartAndWeapon(EquipmentPart.CHEST, request.getWeaponType());
        List<Equipment> arms = equipmentCatalogRepository.findByPartAndWeapon(EquipmentPart.ARMS, request.getWeaponType());
        List<Equipment> waists = equipmentCatalogRepository.findByPartAndWeapon(EquipmentPart.WAIST, request.getWeaponType());
        List<Equipment> legs = equipmentCatalogRepository.findByPartAndWeapon(EquipmentPart.LEGS, request.getWeaponType());

        List<BuildResultResponse> candidates = new ArrayList<>();

        // Brute-force is acceptable for MVP sample data size.
        for (Equipment head : heads) {
            for (Equipment chest : chests) {
                for (Equipment arm : arms) {
                    for (Equipment waist : waists) {
                        for (Equipment leg : legs) {
                            List<Equipment> set = List.of(head, chest, arm, waist, leg);
                            Map<String, Integer> totalSkills = aggregateSkills(set, request.getOptionalCharm());
                            if (!matchesSkillThreshold(totalSkills, request.getTargetSkills())) {
                                continue;
                            }
                            BuildResultResponse response = buildResponse(set, totalSkills, request.getOptionalCharm(), request.getTargetSkills());
                            candidates.add(response);
                        }
                    }
                }
            }
        }

        List<BuildResultResponse> results = candidates.stream()
                .sorted(Comparator.comparingInt(BuildResultResponse::getScore).reversed())
                .limit(request.getMaxResults())
                .collect(Collectors.toList());

        results.forEach(buildResultStore::put);
        return new BuildGenerateResponse(results);
    }

    private void validateBusinessRules(BuildGenerateRequest request) {
        List<ErrorDetail> details = new ArrayList<>();

        if (request.getMaxResults() < 1 || request.getMaxResults() > 20) {
            details.add(new ErrorDetail("maxResults", "out_of_range"));
        }

        for (TargetSkillRequest target : request.getTargetSkills()) {
            Optional<Skill> skill = skillCatalogRepository.findByCode(target.getSkillCode());
            if (skill.isEmpty()) {
                details.add(new ErrorDetail("targetSkills.skillCode", "unknown_skill"));
                continue;
            }
            if (target.getMinLevel() > skill.get().getMaxLevel()) {
                details.add(new ErrorDetail("targetSkills.minLevel", "exceeds_skill_max"));
            }
        }

        if (!details.isEmpty()) {
            if (details.stream().anyMatch(d -> "maxResults".equals(d.getField()))) {
                throw new ValidationException("maxResults must be between 1 and 20", details);
            }
            throw new ValidationException("Request validation failed", details);
        }
    }

    private Map<String, Integer> aggregateSkills(List<Equipment> set, CharmDto charm) {
        Map<String, Integer> totals = new HashMap<>();
        for (Equipment equipment : set) {
            equipment.getSkillPoints().forEach((k, v) -> totals.merge(k, v, Integer::sum));
        }
        if (charm != null && charm.getSkillPoints() != null) {
            charm.getSkillPoints().forEach((k, v) -> totals.merge(k, v, Integer::sum));
        }
        return totals;
    }

    private boolean matchesSkillThreshold(Map<String, Integer> totalSkills, List<TargetSkillRequest> targets) {
        for (TargetSkillRequest target : targets) {
            int actual = totalSkills.getOrDefault(target.getSkillCode(), 0);
            if (actual < target.getMinLevel()) {
                return false;
            }
        }
        return true;
    }

    private BuildResultResponse buildResponse(List<Equipment> set,
                                              Map<String, Integer> totalSkills,
                                              CharmDto optionalCharm,
                                              List<TargetSkillRequest> targets) {
        BuildResultResponse response = new BuildResultResponse();
        response.setId(UUID.randomUUID().toString());

        Map<String, EquipmentResponse> equipmentSet = new HashMap<>();
        for (Equipment equipment : set) {
            equipmentSet.put(equipment.getPart().name(), catalogService.toEquipmentResponse(equipment));
        }
        response.setEquipmentSet(equipmentSet);
        response.setTotalSkills(totalSkills);
        response.setSlotSummary(summarizeSlots(set, optionalCharm));
        response.setScore(score(totalSkills, targets, set));
        return response;
    }

    private Map<Integer, Integer> summarizeSlots(List<Equipment> set, CharmDto optionalCharm) {
        Map<Integer, Integer> slotSummary = new HashMap<>();
        for (Equipment equipment : set) {
            for (Integer slot : equipment.getSlots()) {
                slotSummary.merge(slot, 1, Integer::sum);
            }
        }
        if (optionalCharm != null && optionalCharm.getSlots() != null) {
            for (Integer slot : optionalCharm.getSlots()) {
                slotSummary.merge(slot, 1, Integer::sum);
            }
        }
        return slotSummary;
    }

    private int score(Map<String, Integer> totalSkills, List<TargetSkillRequest> targets, List<Equipment> set) {
        int targetScore = targets.stream()
                .mapToInt(t -> totalSkills.getOrDefault(t.getSkillCode(), 0) * 10)
                .sum();
        int rarityScore = set.stream().mapToInt(Equipment::getRarity).sum();
        return targetScore + rarityScore;
    }
}
