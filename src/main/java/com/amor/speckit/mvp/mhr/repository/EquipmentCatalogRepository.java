package com.amor.speckit.mvp.mhr.repository;

import com.amor.speckit.mvp.mhr.domain.Equipment;
import com.amor.speckit.mvp.mhr.domain.EquipmentPart;
import com.amor.speckit.mvp.mhr.domain.WeaponType;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Repository
@ConditionalOnProperty(name = "app.mhr.catalog.repository-mode", havingValue = "in-memory", matchIfMissing = true)
public class EquipmentCatalogRepository implements EquipmentCatalogPort {

    private final List<Equipment> equipments = List.of(
            new Equipment(101L, "Rathalos Helm", "火龙头盔", EquipmentPart.HEAD, 6, List.of(2, 1), Map.of("ATTACK_BOOST", 2), EnumSet.allOf(WeaponType.class)),
            new Equipment(102L, "Hunter Helm S", "猎人头盔S", EquipmentPart.HEAD, 4, List.of(1, 1), Map.of("CRITICAL_EYE", 2), EnumSet.allOf(WeaponType.class)),
            new Equipment(201L, "Rathalos Mail", "火龙铠甲", EquipmentPart.CHEST, 6, List.of(2), Map.of("ATTACK_BOOST", 1, "WEAKNESS_EXPLOIT", 1), EnumSet.of(WeaponType.LONG_SWORD, WeaponType.GREAT_SWORD)),
            new Equipment(202L, "Nargacuga Mail", "迅龙铠甲", EquipmentPart.CHEST, 5, List.of(2), Map.of("CRITICAL_EYE", 2), EnumSet.allOf(WeaponType.class)),
            new Equipment(301L, "Anjanath Vambraces", "蛮颚龙腕甲", EquipmentPart.ARMS, 5, List.of(2), Map.of("ATTACK_BOOST", 2), EnumSet.of(WeaponType.LONG_SWORD, WeaponType.GREAT_SWORD)),
            new Equipment(302L, "Kaiser Vambraces", "炎王龙腕甲", EquipmentPart.ARMS, 6, List.of(1, 1), Map.of("WEAKNESS_EXPLOIT", 1, "CRITICAL_EYE", 1), EnumSet.allOf(WeaponType.class)),
            new Equipment(401L, "Ingot Coil", "铸铁腰甲", EquipmentPart.WAIST, 4, List.of(2), Map.of("ATTACK_BOOST", 2), EnumSet.allOf(WeaponType.class)),
            new Equipment(402L, "Skalda Elytra", "骸蜘蛛腰甲", EquipmentPart.WAIST, 5, List.of(1), Map.of("WEAKNESS_EXPLOIT", 2), EnumSet.of(WeaponType.LONG_SWORD, WeaponType.BOW)),
            new Equipment(501L, "Ingot Greaves", "铸铁腿甲", EquipmentPart.LEGS, 4, List.of(2, 1), Map.of("ATTACK_BOOST", 1, "CRITICAL_EYE", 1), EnumSet.allOf(WeaponType.class)),
            new Equipment(502L, "Nargacuga Greaves", "迅龙腿甲", EquipmentPart.LEGS, 5, List.of(2), Map.of("WEAKNESS_EXPLOIT", 1, "CRITICAL_EYE", 2), EnumSet.allOf(WeaponType.class))
    );

    @Override
    public List<Equipment> findAll() {
        return equipments;
    }

    @Override
    public List<Equipment> findByPartAndWeapon(EquipmentPart part, WeaponType weaponType) {
        return equipments.stream()
                .filter(e -> e.getPart() == part)
                .filter(e -> supportsWeapon(e, weaponType))
                .collect(Collectors.toList());
    }

    @Override
    public List<Equipment> findByWeapon(WeaponType weaponType) {
        return equipments.stream()
                .filter(e -> supportsWeapon(e, weaponType))
                .collect(Collectors.toList());
    }

    @Override
    public List<Equipment> findCandidatesByPart(WeaponType weaponType, int topPerPart) {
        List<Equipment> result = new ArrayList<>();
        for (EquipmentPart part : EquipmentPart.values()) {
            List<Equipment> byPart = findByPartAndWeapon(part, weaponType);
            byPart.stream().limit(topPerPart).forEach(result::add);
        }
        return result;
    }

    private boolean supportsWeapon(Equipment equipment, WeaponType weaponType) {
        Set<WeaponType> support = equipment.getSupportedWeaponTypes();
        return support.contains(weaponType);
    }
}
