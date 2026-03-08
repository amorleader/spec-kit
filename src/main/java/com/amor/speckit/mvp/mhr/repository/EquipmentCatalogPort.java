package com.amor.speckit.mvp.mhr.repository;

import com.amor.speckit.mvp.mhr.domain.Equipment;
import com.amor.speckit.mvp.mhr.domain.EquipmentPart;
import com.amor.speckit.mvp.mhr.domain.WeaponType;

import java.util.List;

public interface EquipmentCatalogPort {
    List<Equipment> findAll();

    List<Equipment> findByPartAndWeapon(EquipmentPart part, WeaponType weaponType);

    List<Equipment> findByWeapon(WeaponType weaponType);

    List<Equipment> findCandidatesByPart(WeaponType weaponType, int topPerPart);
}
