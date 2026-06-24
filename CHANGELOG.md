## 2.2.0
- Add: `addInjector(injector, resolveUpward: true)` lets a nested injector resolve the params of its own binds against an ancestor scope as a fallback (default `false` keeps the previous downward-only behavior). Local/downward binds always take precedence; mutual upward links throw `UpwardResolutionCycle`.
- Fix: `LayersGraph` no longer leaks dispose listeners. Re-running `commit()` on a long-lived injector kept stacking one dispose listener per surviving inner injector on every commit; listener (re)registration is now idempotent.

## 2.1.1
- Fix lints

## 2.1.0
- Add: `addBind` for complex registration.

## 2.0.5
- Fix: replaceInstance now dont throw errors.

## 2.0.4
- Fix: Instance callback on dispose (@thalissonmt)

## 2.0.3
- pump encrypt version

## 2.0.2 (2023-09-01)
- fix: Remove `fake_reflection`
- fix: dispose callback

## 2.0.0 (2023-08-24)

- fix: replace with others tags
- fix: Custom split to generics datas in many levels (thanks @luanbatistadev)
- add: Multi Injector (thanks @davidsdearaujo).
- add: Get and register instances by name (thanks toshi @toshiossada).

## 1.1.1 (2023-08-05)

- fix: allow add same bind with tag diff

## 1.1.0+4 (2023-07-31)

- add: BindConfig
- chore: Update Exceptions

## 1.0.5+2 (2023-07-30)

- fix: filter injectable params
- chore: Separed Injector interface

## 1.0.4 (2023-06-29)

- fix: Internal call dispose.

## 1.0.3 (2023-06-03)

- fix: disposeSingletonsByTag error

## 1.0.2+2 (2023-03-08)

- Fix: dart doc & readme

## 1.0.2+1 (2023-03-07)

- Added: documentation with dart doc
- Readme updated

## 1.0.2 (2023-02-11)

- fix: Resolver class name with Object

## 1.0.1 (2023-01-31)

- fix: param with named and positional params

## 1.0.0 (2023-01-30)

- Initial version.
