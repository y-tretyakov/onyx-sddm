# Onyx — Detailed Specs: Stable (1.0.0+)

**Milestone:** Stable  
**Version range:** 1.0.0 → …  
**Goal:** Production-ready релиз и дальнейшая поддержка.

---

## Stage 5.1 — First Stable Release  
**Version:** `1.0.0`

### Requirements

1. Git tag `v1.0.0`.
2. AUR package (или обновление существующего).
3. Announcement (README badge, release notes).
4. Все критерии Success Metrics из ROADMAP закрыты.

### Success Metrics (must all be true)

- [ ] Работает из коробки на CachyOS (Niri / Noctalia / Hyprland / KDE Plasma)
- [ ] Время до интерактивности < 400 ms
- [ ] 0 крашей за 100 логинов (тестовый прогон)
- [ ] Hover/click на всех dropdown’ах работают на X11 **и** Wayland
- [ ] 9 языков без missing strings
- [ ] Полностью оффлайн install
- [ ] Документация позволяет новичку установить за < 5 минут

### Acceptance

- [ ] Релиз опубликован.
- [ ] Пользователи могут ставить через `yay -S onyx-sddm-theme` (или аналог).

---

## Stage 5.2 — Hotfixes  
**Version:** `1.0.x`

Только bugfixes. Никаких новых фич.

Правила:

- Каждый hotfix — отдельный PATCH bump.
- Changelog обязателен.
- Regression tests (хотя бы ручные) перед релизом.

---

## Stage 5.3 — Minor Features (post-1.0)  
**Version:** `1.1.0+`

Возможные направления (не обязательства):

- Дополнительные языки (ja, pt, ar, pl, …)
- Дополнительные визуальные пресеты
- Улучшенная keyboard navigation / a11y
- Поддержка multi-monitor (если SDDM позволит)
- Интеграция с Noctalia / Niri specific features
- Theme configurator (внешний)

Каждый такой релиз идёт через обычный цикл Alpha → Beta → RC внутри minor.

---

## Maintenance Policy

| Тип изменения          | Версия     | Процесс                     |
|------------------------|------------|-----------------------------|
| Bugfix                  | 1.0.x      | Hotfix branch → main → tag  |
| Small feature / i18n   | 1.x.0      | Feature branch → RC → tag   |
| Breaking change        | 2.0.0      | Полный цикл + migration guide |

---

*Spec · Stable · Onyx · 2026-09-08*
