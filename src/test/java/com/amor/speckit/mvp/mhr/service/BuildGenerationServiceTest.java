package com.amor.speckit.mvp.mhr.service;

import com.amor.speckit.mvp.mhr.domain.EquipmentPart;
import com.amor.speckit.mvp.mhr.domain.WeaponType;
import com.amor.speckit.mvp.mhr.dto.BuildGenerateRequest;
import com.amor.speckit.mvp.mhr.dto.BuildGenerateResponse;
import com.amor.speckit.mvp.mhr.dto.BuildResultResponse;
import com.amor.speckit.mvp.mhr.dto.TargetSkillRequest;
import com.amor.speckit.mvp.mhr.exception.BuildGenerationTimeoutException;
import com.amor.speckit.mvp.mhr.repository.EquipmentCatalogRepository;
import com.amor.speckit.mvp.mhr.repository.SkillCatalogRepository;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class BuildGenerationServiceTest {

    private final SkillCatalogRepository skillRepository = new SkillCatalogRepository();
    private final EquipmentCatalogRepository equipmentRepository = new EquipmentCatalogRepository();
    private final CatalogService catalogService = new CatalogService(skillRepository, equipmentRepository);
    private final BuildGenerationService service = new BuildGenerationService(
            equipmentRepository,
            skillRepository,
            catalogService,
            new BuildResultStore()
    );

    @Test
    void shouldKeepUniquePartsAndSatisfyThresholds() {
        BuildGenerateRequest request = new BuildGenerateRequest();
        request.setWeaponType(WeaponType.LONG_SWORD);
        request.setTargetSkills(Arrays.asList(skill("ATTACK_BOOST", 4), skill("WEAKNESS_EXPLOIT", 3)));
        request.setMaxResults(5);

        BuildGenerateResponse response = service.generate(request);
        assertFalse(response.getResults().isEmpty());

        for (BuildResultResponse result : response.getResults()) {
            Set<String> uniqueParts = new HashSet<>(result.getEquipmentSet().keySet());
            assertTrue(uniqueParts.containsAll(List.of(
                    EquipmentPart.HEAD.name(),
                    EquipmentPart.CHEST.name(),
                    EquipmentPart.ARMS.name(),
                    EquipmentPart.WAIST.name(),
                    EquipmentPart.LEGS.name()
            )));
            assertTrue(result.getTotalSkills().getOrDefault("ATTACK_BOOST", 0) >= 4);
            assertTrue(result.getTotalSkills().getOrDefault("WEAKNESS_EXPLOIT", 0) >= 3);
        }
    }

    @Test
    void shouldThrowTimeoutWhenGenerationExceedsDeadline() {
        BuildGenerateRequest request = new BuildGenerateRequest();
        request.setWeaponType(WeaponType.LONG_SWORD);
        request.setTargetSkills(Arrays.asList(skill("ATTACK_BOOST", 4), skill("WEAKNESS_EXPLOIT", 3)));
        request.setMaxResults(5);

        service.setGenerateTimeoutSeconds(0);

        assertThrows(BuildGenerationTimeoutException.class, () -> service.generate(request));
    }

    private TargetSkillRequest skill(String code, int minLevel) {
        TargetSkillRequest request = new TargetSkillRequest();
        request.setSkillCode(code);
        request.setMinLevel(minLevel);
        return request;
    }
}
