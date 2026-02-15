"""Simulador de dado configurable."""

from __future__ import annotations

import argparse
import random


def lanzar_dado(numero_caras: int) -> int:
    """Devuelve un resultado aleatorio entre 1 y el número de caras indicado."""
    if numero_caras < 2:
        raise ValueError("El dado debe tener al menos 2 caras.")
    return random.randint(1, numero_caras)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Simula el lanzamiento de un dado configurable."
    )
    parser.add_argument(
        "--caras",
        type=int,
        default=6,
        help="Número de caras del dado (mínimo: 2).",
    )
    parser.add_argument(
        "--lanzamientos",
        type=int,
        default=1,
        help="Cantidad de lanzamientos a realizar (mínimo: 1).",
    )

    args = parser.parse_args()

    if args.lanzamientos < 1:
        raise ValueError("La cantidad de lanzamientos debe ser al menos 1.")

    resultados = [lanzar_dado(args.caras) for _ in range(args.lanzamientos)]

    print(f"Dado de {args.caras} caras")
    if args.lanzamientos == 1:
        print(f"Resultado: {resultados[0]}")
    else:
        print(f"Resultados: {', '.join(map(str, resultados))}")


if __name__ == "__main__":
    main()
