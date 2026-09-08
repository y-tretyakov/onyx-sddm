# Onyx SDDM Theme

**Onyx** — новый экран входа (SDDM greeter) с орбитальным clockwork-дизайном.

Проект создан с нуля на основе визуального языка оригинальной темы *clockwork/orbital* (Ryoku / Darkkal44), но с полностью переработанной архитектурой, чистым кодом и чёткой дорожной картой.

## Текущий статус

**Phase 0 / Foundation** — документация и архитектура готовы.  
Код темы ещё не начат (ждём перехода к MVP).

## Документация

| Документ | Описание |
|----------|----------|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Архитектура, подсистемы, технические решения |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Дорожная карта, вехи, версии, фазы |
| [docs/SPECS/00-mvp.md](docs/SPECS/00-mvp.md) | Детальные спеки MVP |
| [docs/SPECS/01-alpha.md](docs/SPECS/01-alpha.md) | Детальные спеки Alpha |
| [docs/SPECS/02-beta.md](docs/SPECS/02-beta.md) | Детальные спеки Beta |
| [docs/SPECS/03-rc.md](docs/SPECS/03-rc.md) | Детальные спеки RC |
| [docs/SPECS/04-stable.md](docs/SPECS/04-stable.md) | Детальные спеки Stable |

## Основные элементы (сохраняем дизайн)

- Две орбитали (минуты + секунды) вокруг цифровых часов
- Indicator-pill
- Login-панель (user / session / password)
- HUD (power, reboot, language selector)
- Характерные анимации: windup → boom, sparks, tick-feedback, spotlight

## Целевые платформы

- Arch Linux / CachyOS
- Wayland (primary, Weston kiosk)
- X11 (secondary, с полным паритетом)

## Лицензия

GPL-3.0

---

*Onyx · 2026-09-08*
