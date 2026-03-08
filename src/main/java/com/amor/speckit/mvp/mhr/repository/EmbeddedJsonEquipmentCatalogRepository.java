package com.amor.speckit.mvp.mhr.repository;

import com.amor.speckit.mvp.mhr.domain.Equipment;
import com.amor.speckit.mvp.mhr.domain.EquipmentPart;
import com.amor.speckit.mvp.mhr.domain.WeaponType;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Repository
@ConditionalOnProperty(name = "app.mhr.catalog.repository-mode", havingValue = "embedded-json")
public class EmbeddedJsonEquipmentCatalogRepository implements EquipmentCatalogPort {
    private final List<Equipment> equipments;

    public EmbeddedJsonEquipmentCatalogRepository(EmbeddedMhrCatalogStore store) {
        this.equipments = store.getEquipments();
    }

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
        if (weaponType == null) {
            return true;
        }
        Set<WeaponType> supported = equipment.getSupportedWeaponTypes();
        return supported.contains(weaponType);
    }
}
