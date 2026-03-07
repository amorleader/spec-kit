package com.amor.speckit.mvp.mhr.repository;

import com.amor.speckit.mvp.mhr.domain.Equipment;
import com.amor.speckit.mvp.mhr.domain.EquipmentPart;
import com.amor.speckit.mvp.mhr.domain.WeaponType;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Repository
public class EquipmentCatalogRepository {

    private final List<Equipment> equipments = List.of(
            new Equipment(101L, "Rathalos Helm", EquipmentPart.HEAD, 6, List.of(2, 1), Map.of("ATTACK_BOOST", 2), EnumSet.allOf(WeaponType.class)),
            new Equipment(102L, "Hunter Helm S", EquipmentPart.HEAD, 4, List.of(1, 1), Map.of("CRITICAL_EYE", 2), EnumSet.allOf(WeaponType.class)),
            new Equipment(201L, "Rathalos Mail", EquipmentPart.CHEST, 6, List.of(2), Map.of("ATTACK_BOOST", 1, "WEAKNESS_EXPLOIT", 1), EnumSet.of(WeaponType.LONG_SWORD, WeaponType.GREAT_SWORD)),
            new Equipment(202L, "Nargacuga Mail", EquipmentPart.CHEST, 5, List.of(2), Map.of("CRITICAL_EYE", 2), EnumSet.allOf(WeaponType.class)),
            new Equipment(301L, "Anjanath Vambraces", EquipmentPart.ARMS, 5, List.of(2), Map.of("ATTACK_BOOST", 2), EnumSet.of(WeaponType.LONG_SWORD, WeaponType.GREAT_SWORD)),
            new Equipment(302L, "Kaiser Vambraces", EquipmentPart.ARMS, 6, List.of(1, 1), Map.of("WEAKNESS_EXPLOIT", 1, "CRITICAL_EYE", 1), EnumSet.allOf(WeaponType.class)),
            new Equipment(401L, "Ingot Coil", EquipmentPart.WAIST, 4, List.of(2), Map.of("ATTACK_BOOST", 2), EnumSet.allOf(WeaponType.class)),
            new Equipment(402L, "Skalda Elytra", EquipmentPart.WAIST, 5, List.of(1), Map.of("WEAKNESS_EXPLOIT", 2), EnumSet.of(WeaponType.LONG_SWORD, WeaponType.BOW)),
            new Equipment(501L, "Ingot Greaves", EquipmentPart.LEGS, 4, List.of(2, 1), Map.of("ATTACK_BOOST", 1, "CRITICAL_EYE", 1), EnumSet.allOf(WeaponType.class)),
            new Equipment(502L, "Nargacuga Greaves", EquipmentPart.LEGS, 5, List.of(2), Map.of("WEAKNESS_EXPLOIT", 1, "CRITICAL_EYE", 2), EnumSet.allOf(WeaponType.class))
    );

    public List<Equipment> findAll() {
        return equipments;
    }

    public List<Equipment> findByPartAndWeapon(EquipmentPart part, WeaponType weaponType) {
        return equipments.stream()
                .filter(e -> e.getPart() == part)
                .filter(e -> supportsWeapon(e, weaponType))
                .collect(Collectors.toList());
    }

    public List<Equipment> findByWeapon(WeaponType weaponType) {
        return equipments.stream()
                .filter(e -> supportsWeapon(e, weaponType))
                .collect(Collectors.toList());
    }

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
