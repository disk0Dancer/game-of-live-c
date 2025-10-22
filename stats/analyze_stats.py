#!/usr/bin/env python3
import os
import sys
from collections import Counter
from pathlib import Path
import argparse


def analyze_traces(trace_file):
    if not os.path.exists(trace_file):
        print(f"Файл не найден: {trace_file}")
        return None

    instructions = []
    with open(trace_file, 'r') as f:
        for line in f:
            line = line.strip()
            if line:
                instructions.append(line)

    counter = Counter(instructions)
    total = len(instructions)
    unique = len(counter)

    print(f"Всего инструкций: {total:,}")
    print(f"Уникальных инструкций: {unique}")
    print(f"\n{'Инструкция':<20} {'Количество':<15} {'Процент':<10}")
    print("-" * 50)

    for inst, count in counter.most_common(30):
        percent = (count / total) * 100
        print(f"{inst:<20} {count:>12,}   {percent:>6.2f}%")

    return counter


def analyze_relations(relations_file):
    print(f"\nФайл: {relations_file}")

    if not os.path.exists(relations_file):
        print(f"Файл не найден: {relations_file}")
        return None

    relations = []
    with open(relations_file, 'r') as f:
        for line in f:
            line = line.strip()
            if line and '<-' in line:
                relations.append(line)

    counter = Counter(relations)
    total = len(relations)
    unique = len(counter)

    print(f"Всего отношений: {total:,}")
    print(f"Уникальных отношений: {unique}")
    print(f"\n{'Отношение':<40} {'Количество':<15} {'Процент':<10}")
    print("-" * 70)

    for rel, count in counter.most_common(30):
        percent = (count / total) * 100
        print(f"{rel:<40} {count:>12,}   {percent:>6.2f}%")

    return counter


def compare_optimizations(stats_dir):
    print("\n" + "="*80)
    print("СРАВНИТЕЛЬНЫЙ АНАЛИЗ ПО УРОВНЯМ ОПТИМИЗАЦИИ")
    print("="*80)

    opt_levels = ['O1', 'O2', 'O3', 'Os']
    all_stats = {}

    for opt in opt_levels:
        trace_file = os.path.join(stats_dir, f'trace_{opt}.txt')
        if os.path.exists(trace_file):
            print(f"\n{'='*80}")
            print(f"Уровень оптимизации: {opt}")
            print(f"{'='*80}")
            counter = analyze_traces(trace_file)
            if counter:
                all_stats[opt] = counter

    if all_stats:
        print(f"\n{'='*80}")
        print("СВОДНАЯ ТАБЛИЦА: ТОП-10 ИНСТРУКЦИЙ ПО УРОВНЯМ ОПТИМИЗАЦИИ")
        print(f"{'='*80}")

        top_instructions = set()
        for counter in all_stats.values():
            top_instructions.update([inst for inst, _ in counter.most_common(10)])

        header = f"{'Инструкция':<20}"
        for opt in opt_levels:
            if opt in all_stats:
                header += f" {opt:>12}"
        print(header)
        print("-" * (20 + 13 * len(all_stats)))

        for inst in sorted(top_instructions):
            row = f"{inst:<20}"
            for opt in opt_levels:
                if opt in all_stats:
                    count = all_stats[opt].get(inst, 0)
                    row += f" {count:>12,}"
            print(row)


def compare_relations(stats_dir):
    print("\n" + "="*80)
    print("СРАВНИТЕЛЬНЫЙ АНАЛИЗ ОТНОШЕНИЙ ПО УРОВНЯМ ОПТИМИЗАЦИИ")
    print("="*80)

    opt_levels = ['O1', 'O2', 'O3', 'Os']

    for opt in opt_levels:
        rel_file = os.path.join(stats_dir, f'relations_{opt}.txt')
        if os.path.exists(rel_file):
            print(f"\n{'='*80}")
            print(f"Уровень оптимизации: {opt}")
            print(f"{'='*80}")
            analyze_relations(rel_file)


def main():
    parser = argparse.ArgumentParser(
        description='Анализ статистики LLVM IR инструкций',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
  %(prog)s                          # Полный анализ всех файлов
  %(prog)s --traces                 # Анализ только trace файлов
  %(prog)s --relations              # Анализ только relations файлов
        """
    )

    parser.add_argument(
        '--dir',
        default='.',
    )

    parser.add_argument(
        '--traces',
        action='store_true',
    )

    parser.add_argument(
        '--relations',
        action='store_true',
    )

    parser.add_argument(
        '--opt',
        choices=['O1', 'O2', 'O3', 'Os'],
    )

    args = parser.parse_args()
    stats_dir = args.dir
    analyze_all = not (args.traces or args.relations)

    if args.opt:
        if args.traces or analyze_all:
            trace_file = os.path.join(stats_dir, f'trace_{args.opt}.txt')
            analyze_traces(trace_file)

        if args.relations or analyze_all:
            rel_file = os.path.join(stats_dir, f'relations_{args.opt}.txt')
            analyze_relations(rel_file)
    else:
        if args.traces or analyze_all:
            compare_optimizations(stats_dir)

        if args.relations or analyze_all:
            compare_relations(stats_dir)


if __name__ == '__main__':
    main()
