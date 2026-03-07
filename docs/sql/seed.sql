INSERT INTO skills (id, code, name, max_level) VALUES
(1, 'ATTACK_BOOST', 'Attack Boost', 7),
(2, 'WEAKNESS_EXPLOIT', 'Weakness Exploit', 3),
(3, 'CRITICAL_EYE', 'Critical Eye', 7)
ON CONFLICT (id) DO NOTHING;
