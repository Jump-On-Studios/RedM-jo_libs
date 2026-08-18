#!/usr/bin/env python3

"""Ensure every locale contains the same keys as en.json."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
LOCALES_DIR = ROOT / "jo_libs" / "locales"


def read_index_or_worktree(relative_path: str, use_index: bool) -> str:
    """Read the staged version when available, otherwise the working-tree file."""
    if use_index:
        result = subprocess.run(
            ["git", "-C", str(ROOT), "show", f":{relative_path}"],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            check=False,
        )
        if result.returncode == 0:
            return result.stdout.decode("utf-8-sig")

    return (ROOT / relative_path).read_text(encoding="utf-8-sig")


def flatten_keys(value: Any, prefix: str = "") -> set[str]:
    if not isinstance(value, dict):
        return {prefix}

    keys: set[str] = set()
    for key, child in value.items():
        full_key = f"{prefix}.{key}" if prefix else key
        keys.update(flatten_keys(child, full_key))
    return keys


def load_locale(filename: str, use_index: bool) -> set[str]:
    relative_path = f"jo_libs/locales/{filename}"
    try:
        data = json.loads(read_index_or_worktree(relative_path, use_index))
    except FileNotFoundError:
        raise ValueError(f"fichier introuvable: {relative_path}") from None
    except json.JSONDecodeError as error:
        raise ValueError(f"JSON invalide à la ligne {error.lineno}: {relative_path}") from None

    if not isinstance(data, dict):
        raise ValueError(f"la racine doit être un objet JSON: {relative_path}")

    return flatten_keys(data)


def main() -> int:
    use_index = "--worktree" not in sys.argv[1:]

    try:
        reference_keys = load_locale("en.json", use_index)
    except ValueError as error:
        print(f"[locales] ERREUR: {error}", file=sys.stderr)
        return 1

    errors = 0
    locale_files = sorted(LOCALES_DIR.glob("*.json"))

    for locale_path in locale_files:
        if locale_path.name == "en.json":
            continue

        try:
            locale_keys = load_locale(locale_path.name, use_index)
        except ValueError as error:
            print(f"[locales] ERREUR: {error}", file=sys.stderr)
            errors += 1
            continue

        missing_keys = sorted(reference_keys - locale_keys)
        extra_keys = sorted(locale_keys - reference_keys)

        if missing_keys:
            print(
                f"[locales] ERREUR: {locale_path.name} contient des clés manquantes:",
                file=sys.stderr,
            )
            for key in missing_keys:
                print(f"  - {key}", file=sys.stderr)
            errors += 1

        if extra_keys:
            print(
                f"[locales] ERREUR: {locale_path.name} contient des clés absentes de en.json:",
                file=sys.stderr,
            )
            for key in extra_keys:
                print(f"  + {key}", file=sys.stderr)
            errors += 1

    if errors:
        print("[locales] Commit refusé. Synchronise les clés avec en.json.", file=sys.stderr)
        return 1

    print(f"[locales] OK: {len(reference_keys)} clés vérifiées dans {len(locale_files)} fichiers.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
