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
import com.amor.speckit.mvp.mhr.exception.BuildGenerationTimeoutException;
import com.amor.speckit.mvp.mhr.exception.ValidationException;
import com.amor.speckit.mvp.mhr.repository.EquipmentCatalogPort;
import com.amor.speckit.mvp.mhr.repository.SkillCatalogPort;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.PriorityQueue;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class BuildGenerationService {
    private static final Logger log = LoggerFactory.getLogger(BuildGenerationService.class);

    private final EquipmentCatalogPort equipmentCatalogRepository;
    private final SkillCatalogPort skillCatalogRepository;
    private final CatalogService catalogService;
    private final BuildResultStore buildResultStore;

    @Value("${app.build-planner.generate-timeout-seconds:30}")
    private long generateTimeoutSeconds = 30;

    public BuildGenerationService(EquipmentCatalogPort equipmentCatalogRepository,
                                  SkillCatalogPort skillCatalogRepository,
                                  CatalogService catalogService,
                                  BuildResultStore buildResultStore) {
        this.equipmentCatalogRepository = equipmentCatalogRepository;
        this.skillCatalogRepository = skillCatalogRepository;
        this.catalogService = catalogService;
        this.buildResultStore = buildResultStore;
    }

    public BuildGenerateResponse generate(BuildGenerateRequest request) {
        long startNanos = System.nanoTime();
        long deadlineNanos = startNanos + generateTimeoutSeconds * 1_000_000_000L;
        validateBusinessRules(request);

        long fetchStartNanos = System.nanoTime();
        List<Equipment> heads = equipmentCatalogRepository.findByPartAndWeapon(EquipmentPart.HEAD, request.getWeaponType());
        List<Equipment> chests = equipmentCatalogRepository.findByPartAndWeapon(EquipmentPart.CHEST, request.getWeaponType());
        List<Equipment> arms = equipmentCatalogRepository.findByPartAndWeapon(EquipmentPart.ARMS, request.getWeaponType());
        List<Equipment> waists = equipmentCatalogRepository.findByPartAndWeapon(EquipmentPart.WAIST, request.getWeaponType());
        List<Equipment> legs = equipmentCatalogRepository.findByPartAndWeapon(EquipmentPart.LEGS, request.getWeaponType());
        long fetchElapsedMs = nanosToMs(System.nanoTime() - fetchStartNanos);
        long estimatedCombinations = (long) heads.size() * chests.size() * arms.size() * waists.size() * legs.size();
        List<List<Equipment>> partCandidates = List.of(heads, chests, arms, waists, legs);
        List<Map<String, Integer>> remainingSkillMaxByDepth = buildRemainingSkillMaxByDepth(partCandidates, request.getTargetSkills());
        List<Integer> remainingRarityMaxByDepth = buildRemainingRarityMaxByDepth(partCandidates);
        Map<String, Integer> currentSkills = new HashMap<>();
        if (request.getOptionalCharm() != null && request.getOptionalCharm().getSkillPoints() != null) {
            currentSkills.putAll(request.getOptionalCharm().getSkillPoints());
        }

        log.info("build.generate catalog fetched in {} ms, weaponType={}, sizes=[head:{}, chest:{}, arms:{}, waist:{}, legs:{}], estimatedCombinations={}",
                fetchElapsedMs,
                request.getWeaponType(),
                heads.size(),
                chests.size(),
                arms.size(),
                waists.size(),
                legs.size(),
                estimatedCombinations);

        assertNotTimedOut(deadlineNanos, 0L, 0);

        PriorityQueue<BuildResultResponse> topResults = new PriorityQueue<>(Comparator.comparingInt(BuildResultResponse::getScore));
        SearchMetrics metrics = new SearchMetrics();
        Equipment[] selected = new Equipment[5];
        long computeStartNanos = System.nanoTime();

        searchCombinations(
                0,
                partCandidates,
                selected,
                currentSkills,
                request,
                request.getTargetSkills(),
                remainingSkillMaxByDepth,
                remainingRarityMaxByDepth,
                topResults,
                metrics,
                deadlineNanos
        );

        assertNotTimedOut(deadlineNanos, metrics.checkedCombinations, metrics.matchedCandidates);
        long computeElapsedMs = nanosToMs(System.nanoTime() - computeStartNanos);

        List<BuildResultResponse> results = topResults.stream()
                .sorted(Comparator.comparingInt(BuildResultResponse::getScore).reversed())
                .collect(Collectors.toList());

        long totalElapsedMs = nanosToMs(System.nanoTime() - startNanos);
        log.info("build.generate compute finished in {} ms, checkedCombinations={}, matchedCandidates={}, returnedResults={}, totalElapsedMs={}",
                computeElapsedMs,
            metrics.checkedCombinations,
            metrics.matchedCandidates,
                results.size(),
                totalElapsedMs);
        log.info("build.generate prune stats: prunedByThreshold={}, prunedByScoreBound={}",
            metrics.prunedByThreshold,
            metrics.prunedByScoreBound);

        results.forEach(buildResultStore::put);
        return new BuildGenerateResponse(results);
    }

    void setGenerateTimeoutSeconds(long generateTimeoutSeconds) {
        this.generateTimeoutSeconds = generateTimeoutSeconds;
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

    private void assertNotTimedOut(long deadlineNanos, long checkedCombinations, int matchedCandidates) {
        if (System.nanoTime() > deadlineNanos) {
            throw new BuildGenerationTimeoutException("Build generation exceeded " + generateTimeoutSeconds
                    + " seconds", generateTimeoutSeconds, checkedCombinations, matchedCandidates);
        }
    }

    private long nanosToMs(long nanos) {
        return nanos / 1_000_000L;
    }

    private void searchCombinations(int depth,
                                    List<List<Equipment>> partCandidates,
                                    Equipment[] selected,
                                    Map<String, Integer> currentSkills,
                                    BuildGenerateRequest request,
                                    List<TargetSkillRequest> targets,
                                    List<Map<String, Integer>> remainingSkillMaxByDepth,
                                    List<Integer> remainingRarityMaxByDepth,
                                    PriorityQueue<BuildResultResponse> topResults,
                                    SearchMetrics metrics,
                                    long deadlineNanos) {
        if (!canStillReachTargets(currentSkills, targets, remainingSkillMaxByDepth.get(depth))) {
            metrics.prunedByThreshold++;
            return;
        }

        if (topResults.size() >= request.getMaxResults()) {
            int optimisticScore = estimateMaxPossibleScore(
                    currentSkills,
                    targets,
                    remainingSkillMaxByDepth.get(depth),
                    remainingRarityMaxByDepth.get(depth)
            );
            int currentWorstTopScore = topResults.peek() == null ? Integer.MIN_VALUE : topResults.peek().getScore();
            if (optimisticScore <= currentWorstTopScore) {
                metrics.prunedByScoreBound++;
                return;
            }
        }

        if (depth == partCandidates.size()) {
            metrics.checkedCombinations++;
            if ((metrics.checkedCombinations & 1023L) == 0L) {
                assertNotTimedOut(deadlineNanos, metrics.checkedCombinations, metrics.matchedCandidates);
            }
            if (!matchesSkillThreshold(currentSkills, targets)) {
                return;
            }

            metrics.matchedCandidates++;
            List<Equipment> set = List.of(selected[0], selected[1], selected[2], selected[3], selected[4]);
            BuildResultResponse response = buildResponse(set, new HashMap<>(currentSkills), request.getOptionalCharm(), targets);
            topResults.offer(response);
            if (topResults.size() > request.getMaxResults()) {
                topResults.poll();
            }
            return;
        }

        for (Equipment equipment : partCandidates.get(depth)) {
            selected[depth] = equipment;
            applySkillDelta(currentSkills, equipment.getSkillPoints(), 1);
            searchCombinations(
                    depth + 1,
                    partCandidates,
                    selected,
                    currentSkills,
                    request,
                    targets,
                    remainingSkillMaxByDepth,
                        remainingRarityMaxByDepth,
                    topResults,
                    metrics,
                    deadlineNanos
            );
            applySkillDelta(currentSkills, equipment.getSkillPoints(), -1);
        }
    }

    private List<Map<String, Integer>> buildRemainingSkillMaxByDepth(List<List<Equipment>> partCandidates,
                                                                      List<TargetSkillRequest> targets) {
        List<Map<String, Integer>> remainingMax = new ArrayList<>();
        for (int i = 0; i <= partCandidates.size(); i++) {
            remainingMax.add(new HashMap<>());
        }

        for (int depth = partCandidates.size() - 1; depth >= 0; depth--) {
            Map<String, Integer> next = remainingMax.get(depth + 1);
            Map<String, Integer> current = new HashMap<>(next);

            for (TargetSkillRequest target : targets) {
                String code = target.getSkillCode();
                int bestAtPart = 0;
                for (Equipment equipment : partCandidates.get(depth)) {
                    bestAtPart = Math.max(bestAtPart, equipment.getSkillPoints().getOrDefault(code, 0));
                }
                current.put(code, next.getOrDefault(code, 0) + bestAtPart);
            }
            remainingMax.set(depth, current);
        }

        return remainingMax;
    }

    private List<Integer> buildRemainingRarityMaxByDepth(List<List<Equipment>> partCandidates) {
        List<Integer> remaining = new ArrayList<>();
        for (int i = 0; i <= partCandidates.size(); i++) {
            remaining.add(0);
        }
        for (int depth = partCandidates.size() - 1; depth >= 0; depth--) {
            int bestAtPart = 0;
            for (Equipment equipment : partCandidates.get(depth)) {
                bestAtPart = Math.max(bestAtPart, equipment.getRarity());
            }
            remaining.set(depth, remaining.get(depth + 1) + bestAtPart);
        }
        return remaining;
    }

    private boolean canStillReachTargets(Map<String, Integer> currentSkills,
                                         List<TargetSkillRequest> targets,
                                         Map<String, Integer> remainingMaxAtDepth) {
        for (TargetSkillRequest target : targets) {
            int current = currentSkills.getOrDefault(target.getSkillCode(), 0);
            int maxRemaining = remainingMaxAtDepth.getOrDefault(target.getSkillCode(), 0);
            if (current + maxRemaining < target.getMinLevel()) {
                return false;
            }
        }
        return true;
    }

    private void applySkillDelta(Map<String, Integer> totals, Map<String, Integer> delta, int factor) {
        for (Map.Entry<String, Integer> entry : delta.entrySet()) {
            String code = entry.getKey();
            int changed = totals.getOrDefault(code, 0) + entry.getValue() * factor;
            if (changed == 0) {
                totals.remove(code);
            } else {
                totals.put(code, changed);
            }
        }
    }

    private int estimateMaxPossibleScore(Map<String, Integer> currentSkills,
                                         List<TargetSkillRequest> targets,
                                         Map<String, Integer> remainingSkillMaxAtDepth,
                                         int remainingRarityMaxAtDepth) {
        int optimisticTargetScore = 0;
        for (TargetSkillRequest target : targets) {
            int optimisticSkill = currentSkills.getOrDefault(target.getSkillCode(), 0)
                    + remainingSkillMaxAtDepth.getOrDefault(target.getSkillCode(), 0);
            optimisticTargetScore += optimisticSkill * 10;
        }
        return optimisticTargetScore + remainingRarityMaxAtDepth;
    }

    private static class SearchMetrics {
        private long checkedCombinations;
        private int matchedCandidates;
        private long prunedByThreshold;
        private long prunedByScoreBound;
    }
}
